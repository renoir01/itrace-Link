import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/aggregator_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/localization_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/error_widget.dart';

class AggregatorRegistrationScreen extends StatefulWidget {
  const AggregatorRegistrationScreen({super.key});

  @override
  State<AggregatorRegistrationScreen> createState() => _AggregatorRegistrationScreenState();
}

class _AggregatorRegistrationScreenState extends State<AggregatorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  // Form controllers
  final _businessNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _tinNumberController = TextEditingController();
  final _storageCapacityController = TextEditingController();
  final _transportCapacityController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _businessAddressController = TextEditingController();

  // Dropdown values
  String? _selectedDistrict;
  final List<String> _selectedServiceAreas = [];

  // File uploads
  XFile? _profileImage;
  XFile? _businessLicense;
  XFile? _tinCertificate;

  // UI state
  bool _isLoading = false;
  bool _termsAccepted = false;
  String? _errorMessage;
  double _uploadProgress = 0.0;

  // Rwanda districts
  final List<String> _districts = [
    'Kigali',
    'Eastern Province',
    'Northern Province',
    'Southern Province',
    'Western Province',
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _registrationNumberController.dispose();
    _tinNumberController.dispose();
    _storageCapacityController.dispose();
    _transportCapacityController.dispose();
    _contactPersonController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _businessAddressController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final image = await _storageService.pickImageFromGallery();
      if (image != null) {
        final file = File(image.path);
        final isValid = await _storageService.validateFileSize(file, maxSizeMB: 5.0);
        if (!isValid) {
          _showError('Image size must be less than 5MB');
          return;
        }

        setState(() {
          _profileImage = image;
          _errorMessage = null;
        });
      }
    } catch (e) {
      _showError('Error picking image: ${e.toString()}');
    }
  }

  Future<void> _pickBusinessLicense() async {
    try {
      final image = await _storageService.pickImageFromGallery();
      if (image != null) {
        final file = File(image.path);
        final isValid = await _storageService.validateFileSize(file, maxSizeMB: 5.0);
        if (!isValid) {
          _showError('File size must be less than 5MB');
          return;
        }

        setState(() {
          _businessLicense = image;
          _errorMessage = null;
        });
      }
    } catch (e) {
      _showError('Error picking file: ${e.toString()}');
    }
  }

  Future<void> _pickTinCertificate() async {
    try {
      final image = await _storageService.pickImageFromGallery();
      if (image != null) {
        final file = File(image.path);
        final isValid = await _storageService.validateFileSize(file, maxSizeMB: 5.0);
        if (!isValid) {
          _showError('File size must be less than 5MB');
          return;
        }

        setState(() {
          _tinCertificate = image;
          _errorMessage = null;
        });
      }
    } catch (e) {
      _showError('Error picking file: ${e.toString()}');
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _toggleServiceArea(String district) {
    setState(() {
      if (_selectedServiceAreas.contains(district)) {
        _selectedServiceAreas.remove(district);
      } else {
        _selectedServiceAreas.add(district);
      }
    });
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_termsAccepted) {
      _showError('Please accept the terms and conditions');
      return;
    }

    if (_selectedDistrict == null) {
      _showError('Please select your business district');
      return;
    }

    if (_selectedServiceAreas.isEmpty) {
      _showError('Please select at least one service area');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _uploadProgress = 0.0;
    });

    try {
      final authService = context.read<AuthService>();
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Upload profile image
      String? profileImageUrl;
      if (_profileImage != null) {
        setState(() => _uploadProgress = 0.2);
        profileImageUrl = await _storageService.uploadProfileImage(
          File(_profileImage!.path),
          currentUser.uid,
          onProgress: (progress) {
            setState(() => _uploadProgress = 0.2 + (progress * 0.2));
          },
        );
      }

      // Upload business license
      String? licenseUrl;
      if (_businessLicense != null) {
        setState(() => _uploadProgress = 0.5);
        licenseUrl = await _storageService.uploadDocument(
          File(_businessLicense!.path),
          currentUser.uid,
          'business_license',
        );
      }

      // Upload TIN certificate
      String? tinUrl;
      if (_tinCertificate != null) {
        setState(() => _uploadProgress = 0.7);
        tinUrl = await _storageService.uploadDocument(
          File(_tinCertificate!.path),
          currentUser.uid,
          'tin_certificate',
        );
      }

      setState(() => _uploadProgress = 0.9);

      // Create aggregator model
      final aggregator = AggregatorModel(
        id: currentUser.uid,
        businessName: _businessNameController.text.trim(),
        registrationNumber: _registrationNumberController.text.trim(),
        tinNumber: _tinNumberController.text.trim(),
        location: {
          'district': _selectedDistrict!,
          'address': _businessAddressController.text.trim(),
        },
        serviceAreas: _selectedServiceAreas,
        storageCapacity: double.parse(_storageCapacityController.text.trim()),
        transportCapacity: double.parse(_transportCapacityController.text.trim()),
        currentInventory: 0.0,
        contactPerson: _contactPersonController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        profileImageUrl: profileImageUrl,
        documents: [
          if (licenseUrl != null) licenseUrl,
          if (tinUrl != null) tinUrl,
        ],
        isVerified: false,
        rating: 0.0,
        totalOrders: 0,
        completedOrders: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestoreService.createAggregator(aggregator);

      // Create/update user profile
      final userModel = UserModel(
        uid: currentUser.uid,
        phoneNumber: _phoneNumberController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        userType: 'aggregator',
        displayName: _businessNameController.text.trim(),
        isVerified: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestoreService.createUser(userModel);

      setState(() => _uploadProgress = 1.0);

      if (!mounted) return;

      // Navigate to aggregator dashboard
      context.go('/aggregator/dashboard');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocalizationService>().isEnglish
                ? 'Registration successful!'
                : 'Kwiyandikisha byagenze neza!',
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Registration failed: ${e.toString()}';
          _isLoading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationService>();
    final isEnglish = localization.isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'Aggregator Registration' : 'Kwiyandikisha kw\'Umucuruzi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryGreen,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  isEnglish
                      ? 'Business Information'
                      : 'Amakuru y\'Ubucuruzi',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEnglish
                      ? 'Provide details about your aggregator business'
                      : 'Tanga amakuru kuri ubucuruzi bwawe',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 32),

                // Profile Image Upload
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _isLoading ? null : _pickProfileImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                          backgroundImage: _profileImage != null
                              ? FileImage(File(_profileImage!.path))
                              : null,
                          child: _profileImage == null
                              ? const Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: AppTheme.primaryGreen,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isEnglish ? 'Add Business Logo' : 'Ongeraho Ikirango cy\'Ubucuruzi',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Business Name
                CustomTextField(
                  controller: _businessNameController,
                  label: isEnglish ? 'Business Name' : 'Izina ry\'Ubucuruzi',
                  hint: isEnglish ? 'Enter business name' : 'Andika izina ry\'ubucuruzi',
                  prefixIcon: Icons.business,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter business name' : 'Andika izina ry\'ubucuruzi';
                    }
                    if (value.length < 3) {
                      return isEnglish ? 'Name too short' : 'Izina ni rigufi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Registration Number
                CustomTextField(
                  controller: _registrationNumberController,
                  label: isEnglish ? 'Business Registration Number' : 'Nomero y\'Iyandikwa ry\'Ubucuruzi',
                  hint: isEnglish ? 'Enter registration number' : 'Andika nomero y\'iyandikwa',
                  prefixIcon: Icons.badge,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter registration number' : 'Andika nomero y\'iyandikwa';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // TIN Number
                CustomTextField(
                  controller: _tinNumberController,
                  label: isEnglish ? 'TIN Number' : 'Nomero ya TIN',
                  hint: isEnglish ? 'Enter TIN number' : 'Andika nomero ya TIN',
                  prefixIcon: Icons.numbers,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter TIN number' : 'Andika nomero ya TIN';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Capacity Section
                Text(
                  isEnglish ? 'Business Capacity' : 'Ubushobozi bw\'Ubucuruzi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Storage Capacity
                NumberField(
                  controller: _storageCapacityController,
                  label: isEnglish ? 'Storage Capacity (kg)' : 'Ubushobozi bwo Kubika (kg)',
                  hint: isEnglish ? 'Enter storage capacity' : 'Andika ubushobozi bwo kubika',
                  prefixIcon: Icons.warehouse,
                  enabled: !_isLoading,
                  minValue: 100,
                  allowDecimal: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter storage capacity' : 'Andika ubushobozi bwo kubika';
                    }
                    final number = double.tryParse(value);
                    if (number == null || number < 100) {
                      return isEnglish ? 'Minimum 100 kg required' : 'Byanze 100 kg';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Transport Capacity
                NumberField(
                  controller: _transportCapacityController,
                  label: isEnglish ? 'Transport Capacity (kg)' : 'Ubushobozi bwo Gutwara (kg)',
                  hint: isEnglish ? 'Enter transport capacity' : 'Andika ubushobozi bwo gutwara',
                  prefixIcon: Icons.local_shipping,
                  enabled: !_isLoading,
                  minValue: 50,
                  allowDecimal: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter transport capacity' : 'Andika ubushobozi bwo gutwara';
                    }
                    final number = double.tryParse(value);
                    if (number == null || number < 50) {
                      return isEnglish ? 'Minimum 50 kg required' : 'Byanze 50 kg';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Location Section
                Text(
                  isEnglish ? 'Business Location' : 'Aho Ubucuruzi Buherereye',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // District Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: InputDecoration(
                    labelText: isEnglish ? 'Business District' : 'Akarere',
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _districts.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _selectedDistrict = value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return isEnglish ? 'Please select district' : 'Hitamo akarere';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Business Address
                TextAreaField(
                  controller: _businessAddressController,
                  label: isEnglish ? 'Business Address' : 'Aderesi y\'Ubucuruzi',
                  hint: isEnglish ? 'Enter detailed address' : 'Andika aderesi irambuye',
                  enabled: !_isLoading,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter address' : 'Andika aderesi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Service Areas Section
                Text(
                  isEnglish ? 'Service Areas' : 'Uturere Dukoresha',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEnglish
                      ? 'Select all districts you can service'
                      : 'Hitamo uturere twose ushobora gukoresha',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),

                // Service Areas Checkboxes
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _districts.map((district) {
                    final isSelected = _selectedServiceAreas.contains(district);
                    return FilterChip(
                      label: Text(district),
                      selected: isSelected,
                      onSelected: _isLoading
                          ? null
                          : (selected) {
                              _toggleServiceArea(district);
                            },
                      selectedColor: AppTheme.primaryGreen.withOpacity(0.3),
                      checkmarkColor: AppTheme.primaryGreen,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Contact Information Section
                Text(
                  isEnglish ? 'Contact Information' : 'Amakuru yo Guhamagara',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Contact Person
                CustomTextField(
                  controller: _contactPersonController,
                  label: isEnglish ? 'Contact Person' : 'Umuntu wo Kuvugana',
                  hint: isEnglish ? 'Enter contact person name' : 'Andika amazina',
                  prefixIcon: Icons.person,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter contact person' : 'Andika amazina';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone Number
                PhoneNumberField(
                  controller: _phoneNumberController,
                  label: isEnglish ? 'Phone Number' : 'Nimero ya Telefoni',
                  hint: '+250 XXX XXX XXX',
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter phone number' : 'Andika nimero ya telefoni';
                    }
                    if (!value.startsWith('+250') && !value.startsWith('0')) {
                      return isEnglish ? 'Invalid Rwanda phone number' : 'Nimero si nziza';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                EmailField(
                  controller: _emailController,
                  label: isEnglish ? 'Email (Optional)' : 'Imeri (Ntabwo byakenewe)',
                  hint: isEnglish ? 'Enter email address' : 'Andika imeri',
                  enabled: !_isLoading,
                  required: false,
                ),
                const SizedBox(height: 24),

                // Documents Section
                Text(
                  isEnglish ? 'Business Documents' : 'Ibyangombwa by\'Ubucuruzi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Business License
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _pickBusinessLicense,
                  icon: Icon(_businessLicense != null ? Icons.check_circle : Icons.upload_file),
                  label: Text(
                    _businessLicense != null
                        ? (isEnglish ? 'Business License Selected' : 'Uruhushya Rutoranijwe')
                        : (isEnglish ? 'Upload Business License' : 'Shyiramo Uruhushya'),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _businessLicense != null ? AppTheme.successGreen : AppTheme.primaryGreen,
                    side: BorderSide(
                      color: _businessLicense != null ? AppTheme.successGreen : AppTheme.primaryGreen,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 12),

                // TIN Certificate
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _pickTinCertificate,
                  icon: Icon(_tinCertificate != null ? Icons.check_circle : Icons.upload_file),
                  label: Text(
                    _tinCertificate != null
                        ? (isEnglish ? 'TIN Certificate Selected' : 'Icyangombwa cya TIN Cyatoranijwe')
                        : (isEnglish ? 'Upload TIN Certificate' : 'Shyiramo Icyangombwa cya TIN'),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _tinCertificate != null ? AppTheme.successGreen : AppTheme.primaryGreen,
                    side: BorderSide(
                      color: _tinCertificate != null ? AppTheme.successGreen : AppTheme.primaryGreen,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // Terms and Conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _termsAccepted = value ?? false;
                              });
                            },
                      activeColor: AppTheme.primaryGreen,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _termsAccepted = !_termsAccepted;
                                });
                              },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            isEnglish
                                ? 'I agree to the terms and conditions and confirm that all information provided is accurate'
                                : 'Nemeye amabwiriza kandi nemeza ko amakuru atanzwe ari ukuri',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Error Message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: InlineErrorMessage(
                      message: _errorMessage!,
                      onDismiss: () {
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                    ),
                  ),

                // Upload Progress
                if (_isLoading && _uploadProgress > 0)
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // Submit Button
                CustomButton(
                  text: isEnglish ? 'Complete Registration' : 'Rangiza Kwiyandikisha',
                  onPressed: _isLoading ? null : _submitRegistration,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
