import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/agro_dealer_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/localization_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/error_widget.dart';

class AgroDealerRegistrationScreen extends StatefulWidget {
  const AgroDealerRegistrationScreen({super.key});

  @override
  State<AgroDealerRegistrationScreen> createState() => _AgroDealerRegistrationScreenState();
}

class _AgroDealerRegistrationScreenState extends State<AgroDealerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  // Form controllers
  final _businessNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _tinNumberController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _shopAddressController = TextEditingController();

  // Dropdown values
  String? _selectedDistrict;
  String? _selectedSector;
  final List<String> _selectedSeedProducers = [];

  // File uploads
  XFile? _profileImage;
  XFile? _dealerLicense;
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

  final Map<String, List<String>> _sectors = {
    'Kigali': ['Gasabo', 'Kicukiro', 'Nyarugenge'],
    'Eastern Province': ['Bugesera', 'Gatsibo', 'Kayonza', 'Kirehe', 'Ngoma', 'Nyagatare', 'Rwamagana'],
    'Northern Province': ['Burera', 'Gakenke', 'Gicumbi', 'Musanze', 'Rulindo'],
    'Southern Province': ['Gisagara', 'Huye', 'Kamonyi', 'Muhanga', 'Nyamagabe', 'Nyanza', 'Nyaruguru', 'Ruhango'],
    'Western Province': ['Karongi', 'Ngororero', 'Nyabihu', 'Nyamasheke', 'Rubavu', 'Rusizi', 'Rutsiro'],
  };

  // Authorized seed producers (in production, fetch from Firestore)
  final List<String> _seedProducers = [
    'Rwanda Agriculture and Animal Resources Development Board (RAB)',
    'Seed Co Rwanda',
    'East African Seed Company',
    'Other Certified Producer',
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _licenseNumberController.dispose();
    _tinNumberController.dispose();
    _contactPersonController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _shopAddressController.dispose();
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

  Future<void> _pickLicense() async {
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
          _dealerLicense = image;
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

  void _toggleSeedProducer(String producer) {
    setState(() {
      if (_selectedSeedProducers.contains(producer)) {
        _selectedSeedProducers.remove(producer);
      } else {
        _selectedSeedProducers.add(producer);
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

    if (_selectedDistrict == null || _selectedSector == null) {
      _showError('Please select district and sector');
      return;
    }

    if (_selectedSeedProducers.isEmpty) {
      _showError('Please select at least one authorized seed producer');
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

      // Upload dealer license
      String? licenseUrl;
      if (_dealerLicense != null) {
        setState(() => _uploadProgress = 0.5);
        licenseUrl = await _storageService.uploadDocument(
          File(_dealerLicense!.path),
          currentUser.uid,
          'agro_dealer_license',
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

      // Create agro-dealer model
      final agroDealer = AgroDealerModel(
        id: currentUser.uid,
        businessName: _businessNameController.text.trim(),
        licenseNumber: _licenseNumberController.text.trim(),
        tinNumber: _tinNumberController.text.trim(),
        location: {
          'district': _selectedDistrict!,
          'sector': _selectedSector!,
          'address': _shopAddressController.text.trim(),
        },
        authorizedSeedProducers: _selectedSeedProducers,
        inventory: [], // Will be populated when adding seed stock
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
        totalSales: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestoreService.createAgroDealer(agroDealer);

      // Create/update user profile
      final userModel = UserModel(
        uid: currentUser.uid,
        phoneNumber: _phoneNumberController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        userType: 'agro_dealer',
        displayName: _businessNameController.text.trim(),
        isVerified: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestoreService.createUser(userModel);

      setState(() => _uploadProgress = 1.0);

      if (!mounted) return;

      // Navigate to agro-dealer dashboard
      context.go('/agro-dealer/dashboard');

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
        title: Text(isEnglish ? 'Agro-Dealer Registration' : 'Kwiyandikisha kw\'Ucuruzi w\'Imbuto'),
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
                      ? 'Provide details about your agro-dealer business'
                      : 'Tanga amakuru kuri ubucuruzi bwawe bw\'imbuto',
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
                        isEnglish ? 'Add Shop Photo' : 'Ongeraho Ifoto y\'Iduka',
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
                  prefixIcon: Icons.store,
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

                // Dealer License Number
                CustomTextField(
                  controller: _licenseNumberController,
                  label: isEnglish ? 'Agro-Dealer License Number' : 'Nomero y\'Uruhushya rwo Gucuruza Imbuto',
                  hint: isEnglish ? 'Enter license number' : 'Andika nomero y\'uruhushya',
                  prefixIcon: Icons.badge,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter license number' : 'Andika nomero y\'uruhushya';
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

                // Location Section
                Text(
                  isEnglish ? 'Shop Location' : 'Aho Iduka Riherereye',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // District
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: InputDecoration(
                    labelText: isEnglish ? 'District' : 'Akarere',
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
                            _selectedSector = null;
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

                // Sector
                DropdownButtonFormField<String>(
                  value: _selectedSector,
                  decoration: InputDecoration(
                    labelText: isEnglish ? 'Sector' : 'Umurenge',
                    prefixIcon: const Icon(Icons.place),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _selectedDistrict != null
                      ? _sectors[_selectedDistrict]?.map((sector) {
                          return DropdownMenuItem(
                            value: sector,
                            child: Text(sector),
                          );
                        }).toList()
                      : [],
                  onChanged: _isLoading || _selectedDistrict == null
                      ? null
                      : (value) {
                          setState(() {
                            _selectedSector = value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return isEnglish ? 'Please select sector' : 'Hitamo umurenge';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Shop Address
                TextAreaField(
                  controller: _shopAddressController,
                  label: isEnglish ? 'Shop Address' : 'Aderesi y\'Iduka',
                  hint: isEnglish ? 'Enter detailed shop address' : 'Andika aderesi y\'iduka',
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

                // Authorized Seed Producers Section
                Text(
                  isEnglish ? 'Authorized Seed Producers' : 'Abakora Imbuto Bemerewe',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEnglish
                      ? 'Select all seed producers you are authorized to sell for'
                      : 'Hitamo abakora imbuto wemerewe kugurisha',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),

                // Seed Producers Checkboxes
                ..._seedProducers.map((producer) {
                  final isSelected = _selectedSeedProducers.contains(producer);
                  return CheckboxListTile(
                    title: Text(producer),
                    value: isSelected,
                    onChanged: _isLoading
                        ? null
                        : (selected) {
                            _toggleSeedProducer(producer);
                          },
                    activeColor: AppTheme.primaryGreen,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
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

                // Dealer License
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _pickLicense,
                  icon: Icon(_dealerLicense != null ? Icons.check_circle : Icons.upload_file),
                  label: Text(
                    _dealerLicense != null
                        ? (isEnglish ? 'License Selected' : 'Uruhushya Rutoranijwe')
                        : (isEnglish ? 'Upload Dealer License' : 'Shyiramo Uruhushya'),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _dealerLicense != null ? AppTheme.successGreen : AppTheme.primaryGreen,
                    side: BorderSide(
                      color: _dealerLicense != null ? AppTheme.successGreen : AppTheme.primaryGreen,
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
