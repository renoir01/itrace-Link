import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/seed_producer_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/localization_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/error_widget.dart';

class SeedProducerRegistrationScreen extends StatefulWidget {
  const SeedProducerRegistrationScreen({super.key});

  @override
  State<SeedProducerRegistrationScreen> createState() => _SeedProducerRegistrationScreenState();
}

class _SeedProducerRegistrationScreenState extends State<SeedProducerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  // Form controllers
  final _companyNameController = TextEditingController();
  final _certificationNumberController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _tinNumberController = TextEditingController();
  final _productionCapacityController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _facilityAddressController = TextEditingController();

  // Dropdown values
  String? _selectedDistrict;
  String? _selectedSector;
  final List<String> _certifiedVarieties = [];

  // File uploads
  XFile? _profileImage;
  XFile? _certificationDocument;
  XFile? _registrationCertificate;

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

  // Iron-biofortified bean varieties
  final List<String> _beanVarieties = [
    'RWR 2245 (High Iron)',
    'MAC 42 (High Iron)',
    'RWR 10 (High Iron)',
    'RWV 1129 (High Iron)',
    'MAC 44 (High Iron)',
    'Other Certified Variety',
  ];

  @override
  void dispose() {
    _companyNameController.dispose();
    _certificationNumberController.dispose();
    _registrationNumberController.dispose();
    _tinNumberController.dispose();
    _productionCapacityController.dispose();
    _contactPersonController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _facilityAddressController.dispose();
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

  Future<void> _pickCertification() async {
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
          _certificationDocument = image;
          _errorMessage = null;
        });
      }
    } catch (e) {
      _showError('Error picking file: ${e.toString()}');
    }
  }

  Future<void> _pickRegistrationCert() async {
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
          _registrationCertificate = image;
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

  void _toggleVariety(String variety) {
    setState(() {
      if (_certifiedVarieties.contains(variety)) {
        _certifiedVarieties.remove(variety);
      } else {
        _certifiedVarieties.add(variety);
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

    if (_certifiedVarieties.isEmpty) {
      _showError('Please select at least one certified bean variety');
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
        setState(() => _uploadProgress = 0.15);
        profileImageUrl = await _storageService.uploadProfileImage(
          File(_profileImage!.path),
          currentUser.uid,
          onProgress: (progress) {
            setState(() => _uploadProgress = 0.15 + (progress * 0.15));
          },
        );
      }

      // Upload certification document
      String? certificationUrl;
      if (_certificationDocument != null) {
        setState(() => _uploadProgress = 0.4);
        certificationUrl = await _storageService.uploadDocument(
          File(_certificationDocument!.path),
          currentUser.uid,
          'seed_certification',
        );
      }

      // Upload registration certificate
      String? registrationUrl;
      if (_registrationCertificate != null) {
        setState(() => _uploadProgress = 0.7);
        registrationUrl = await _storageService.uploadDocument(
          File(_registrationCertificate!.path),
          currentUser.uid,
          'business_registration',
        );
      }

      setState(() => _uploadProgress = 0.9);

      // Create seed producer model
      final seedProducer = SeedProducerModel(
        id: currentUser.uid,
        companyName: _companyNameController.text.trim(),
        certificationNumber: _certificationNumberController.text.trim(),
        registrationNumber: _registrationNumberController.text.trim(),
        tinNumber: _tinNumberController.text.trim(),
        location: {
          'district': _selectedDistrict!,
          'sector': _selectedSector!,
          'address': _facilityAddressController.text.trim(),
        },
        productionCapacity: double.parse(_productionCapacityController.text.trim()),
        certifiedVarieties: _certifiedVarieties,
        authorizedDealers: [], // Will be populated when authorizing dealers
        contactPerson: _contactPersonController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        profileImageUrl: profileImageUrl,
        documents: [
          if (certificationUrl != null) certificationUrl,
          if (registrationUrl != null) registrationUrl,
        ],
        isVerified: false,
        totalProduction: 0.0,
        totalDealers: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestoreService.createSeedProducer(seedProducer);

      // Create/update user profile
      final userModel = UserModel(
        uid: currentUser.uid,
        phoneNumber: _phoneNumberController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        userType: 'seed_producer',
        displayName: _companyNameController.text.trim(),
        isVerified: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestoreService.createUser(userModel);

      setState(() => _uploadProgress = 1.0);

      if (!mounted) return;

      // Navigate to seed producer dashboard
      context.go('/seed-producer/dashboard');

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
        title: Text(isEnglish ? 'Seed Producer Registration' : 'Kwiyandikisha kw\'Umukora w\'Imbuto'),
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
                      ? 'Company Information'
                      : 'Amakuru y\'Isosiyete',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEnglish
                      ? 'Provide details about your seed production company'
                      : 'Tanga amakuru kuri isosiyete ikora imbuto',
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
                        isEnglish ? 'Add Company Logo' : 'Ongeraho Ikirango cy\'Isosiyete',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Company Name
                CustomTextField(
                  controller: _companyNameController,
                  label: isEnglish ? 'Company Name' : 'Izina ry\'Isosiyete',
                  hint: isEnglish ? 'Enter company name' : 'Andika izina ry\'isosiyete',
                  prefixIcon: Icons.business,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter company name' : 'Andika izina ry\'isosiyete';
                    }
                    if (value.length < 3) {
                      return isEnglish ? 'Name too short' : 'Izina ni rigufi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Certification Number
                CustomTextField(
                  controller: _certificationNumberController,
                  label: isEnglish ? 'Seed Certification Number' : 'Nomero y\'Icyemezo cy\'Imbuto',
                  hint: isEnglish ? 'Enter certification number' : 'Andika nomero y\'icyemezo',
                  prefixIcon: Icons.verified,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter certification number' : 'Andika nomero y\'icyemezo';
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

                // Production Capacity
                Text(
                  isEnglish ? 'Production Capacity' : 'Ubushobozi bwo Gukora',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                NumberField(
                  controller: _productionCapacityController,
                  label: isEnglish ? 'Annual Production Capacity (kg)' : 'Ubushobozi bwo Gukora buri mwaka (kg)',
                  hint: isEnglish ? 'Enter annual capacity' : 'Andika ubushobozi buri mwaka',
                  prefixIcon: Icons.scale,
                  enabled: !_isLoading,
                  minValue: 100,
                  allowDecimal: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter production capacity' : 'Andika ubushobozi';
                    }
                    final number = double.tryParse(value);
                    if (number == null || number < 100) {
                      return isEnglish ? 'Minimum 100 kg required' : 'Byanze 100 kg';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Certified Varieties Section
                Text(
                  isEnglish ? 'Certified Bean Varieties' : 'Ubwoko bw\'Ibishyimbo Byemejwe',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEnglish
                      ? 'Select all iron-biofortified varieties you produce'
                      : 'Hitamo ubwoko bw\'ibishyimbo bifite iron ukora',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),

                // Varieties Checkboxes
                ..._beanVarieties.map((variety) {
                  final isSelected = _certifiedVarieties.contains(variety);
                  return CheckboxListTile(
                    title: Text(variety),
                    value: isSelected,
                    onChanged: _isLoading
                        ? null
                        : (selected) {
                            _toggleVariety(variety);
                          },
                    activeColor: AppTheme.primaryGreen,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
                const SizedBox(height: 24),

                // Location Section
                Text(
                  isEnglish ? 'Facility Location' : 'Aho Uruganda Ruherereye',
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

                // Facility Address
                TextAreaField(
                  controller: _facilityAddressController,
                  label: isEnglish ? 'Facility Address' : 'Aderesi y\'Uruganda',
                  hint: isEnglish ? 'Enter detailed facility address' : 'Andika aderesi y\'uruganda',
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
                  label: isEnglish ? 'Email' : 'Imeri',
                  hint: isEnglish ? 'Enter email address' : 'Andika imeri',
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter email' : 'Andika imeri';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Documents Section
                Text(
                  isEnglish ? 'Company Documents' : 'Ibyangombwa by\'Isosiyete',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Certification Document
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _pickCertification,
                  icon: Icon(_certificationDocument != null ? Icons.check_circle : Icons.upload_file),
                  label: Text(
                    _certificationDocument != null
                        ? (isEnglish ? 'Certification Selected' : 'Icyemezo Cyatoranijwe')
                        : (isEnglish ? 'Upload Seed Certification' : 'Shyiramo Icyemezo cy\'Imbuto'),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _certificationDocument != null ? AppTheme.successGreen : AppTheme.primaryGreen,
                    side: BorderSide(
                      color: _certificationDocument != null ? AppTheme.successGreen : AppTheme.primaryGreen,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 12),

                // Business Registration
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _pickRegistrationCert,
                  icon: Icon(_registrationCertificate != null ? Icons.check_circle : Icons.upload_file),
                  label: Text(
                    _registrationCertificate != null
                        ? (isEnglish ? 'Registration Selected' : 'Icyangombwa Cyatoranijwe')
                        : (isEnglish ? 'Upload Business Registration' : 'Shyiramo Icyangombwa cy\'Iyandikwa'),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _registrationCertificate != null ? AppTheme.successGreen : AppTheme.primaryGreen,
                    side: BorderSide(
                      color: _registrationCertificate != null ? AppTheme.successGreen : AppTheme.primaryGreen,
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
