import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/institution_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/localization_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/error_widget.dart';

class InstitutionRegistrationScreen extends StatefulWidget {
  const InstitutionRegistrationScreen({super.key});

  @override
  State<InstitutionRegistrationScreen> createState() => _InstitutionRegistrationScreenState();
}

class _InstitutionRegistrationScreenState extends State<InstitutionRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  // Form controllers
  final _institutionNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _monthlyRequirementController = TextEditingController();
  final _numberOfBeneficiariesController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _budgetController = TextEditingController();

  // Dropdown values
  String? _institutionType;
  String? _selectedDistrict;
  String? _selectedSector;
  String? _paymentTerms;

  // File uploads
  XFile? _profileImage;
  XFile? _registrationCertificate;

  // UI state
  bool _isLoading = false;
  bool _termsAccepted = false;
  String? _errorMessage;
  double _uploadProgress = 0.0;

  // Institution types
  final List<Map<String, String>> _institutionTypes = [
    {'value': 'school', 'en': 'School', 'rw': 'Ishuri'},
    {'value': 'hospital', 'en': 'Hospital', 'rw': 'Ibitaro'},
  ];

  // Payment terms
  final List<Map<String, String>> _paymentOptions = [
    {'value': 'immediate', 'en': 'Immediate Payment', 'rw': 'Kwishyura ako kanya'},
    {'value': '7_days', 'en': 'Payment within 7 days', 'rw': 'Kwishyura mu minsi 7'},
    {'value': '15_days', 'en': 'Payment within 15 days', 'rw': 'Kwishyura mu minsi 15'},
    {'value': '30_days', 'en': 'Payment within 30 days', 'rw': 'Kwishyura mu minsi 30'},
  ];

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

  @override
  void dispose() {
    _institutionNameController.dispose();
    _registrationNumberController.dispose();
    _monthlyRequirementController.dispose();
    _numberOfBeneficiariesController.dispose();
    _contactPersonController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _budgetController.dispose();
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

  Future<void> _pickCertificate() async {
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

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_termsAccepted) {
      _showError('Please accept the terms and conditions');
      return;
    }

    if (_institutionType == null) {
      _showError('Please select institution type');
      return;
    }

    if (_selectedDistrict == null || _selectedSector == null) {
      _showError('Please select district and sector');
      return;
    }

    if (_paymentTerms == null) {
      _showError('Please select payment terms');
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
        setState(() => _uploadProgress = 0.3);
        profileImageUrl = await _storageService.uploadProfileImage(
          File(_profileImage!.path),
          currentUser.uid,
          onProgress: (progress) {
            setState(() => _uploadProgress = 0.3 + (progress * 0.3));
          },
        );
      }

      // Upload certificate
      String? certificateUrl;
      if (_registrationCertificate != null) {
        setState(() => _uploadProgress = 0.7);
        certificateUrl = await _storageService.uploadDocument(
          File(_registrationCertificate!.path),
          currentUser.uid,
          'registration_certificate',
        );
      }

      setState(() => _uploadProgress = 0.9);

      // Create institution model
      final institution = InstitutionModel(
        id: currentUser.uid,
        institutionName: _institutionNameController.text.trim(),
        institutionType: _institutionType!,
        registrationNumber: _registrationNumberController.text.trim(),
        location: {
          'district': _selectedDistrict!,
          'sector': _selectedSector!,
          'address': _addressController.text.trim(),
        },
        monthlyRequirement: double.parse(_monthlyRequirementController.text.trim()),
        numberOfBeneficiaries: int.parse(_numberOfBeneficiariesController.text.trim()),
        budget: _budgetController.text.trim().isEmpty
            ? null
            : double.tryParse(_budgetController.text.trim()),
        paymentTerms: _paymentTerms!,
        contactPerson: _contactPersonController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        profileImageUrl: profileImageUrl,
        documents: certificateUrl != null ? [certificateUrl] : [],
        isVerified: false,
        totalOrders: 0,
        completedOrders: 0,
        totalSpent: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestoreService.createInstitution(institution);

      // Create/update user profile
      final userModel = UserModel(
        uid: currentUser.uid,
        phoneNumber: _phoneNumberController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        userType: 'institution',
        displayName: _institutionNameController.text.trim(),
        isVerified: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestoreService.createUser(userModel);

      setState(() => _uploadProgress = 1.0);

      if (!mounted) return;

      // Navigate to institution dashboard
      context.go('/institution/dashboard');

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
        title: Text(isEnglish ? 'Institution Registration' : 'Kwiyandikisha kw\'Ikigo'),
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
                      ? 'Institution Information'
                      : 'Amakuru y\'Ikigo',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEnglish
                      ? 'Provide details about your institution'
                      : 'Tanga amakuru kuri ikigo',
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
                        isEnglish ? 'Add Institution Photo' : 'Ongeraho Ifoto y\'Ikigo',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Institution Type
                DropdownButtonFormField<String>(
                  value: _institutionType,
                  decoration: InputDecoration(
                    labelText: isEnglish ? 'Institution Type' : 'Ubwoko bw\'Ikigo',
                    prefixIcon: const Icon(Icons.business),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _institutionTypes.map((type) {
                    return DropdownMenuItem(
                      value: type['value'],
                      child: Text(isEnglish ? type['en']! : type['rw']!),
                    );
                  }).toList(),
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _institutionType = value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return isEnglish ? 'Please select type' : 'Hitamo ubwoko';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Institution Name
                CustomTextField(
                  controller: _institutionNameController,
                  label: isEnglish ? 'Institution Name' : 'Izina ry\'Ikigo',
                  hint: isEnglish ? 'Enter institution name' : 'Andika izina ry\'ikigo',
                  prefixIcon: Icons.account_balance,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter institution name' : 'Andika izina ry\'ikigo';
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
                  label: isEnglish ? 'Registration Number' : 'Nomero y\'Iyandikwa',
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
                const SizedBox(height: 24),

                // Requirements Section
                Text(
                  isEnglish ? 'Bean Requirements' : 'Ibishingwa by\'Ibishyimbo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Monthly Requirement
                NumberField(
                  controller: _monthlyRequirementController,
                  label: isEnglish ? 'Monthly Requirement (kg)' : 'Ibisabwa buri kwezi (kg)',
                  hint: isEnglish ? 'Enter monthly requirement' : 'Andika ibisabwa buri kwezi',
                  prefixIcon: Icons.scale,
                  enabled: !_isLoading,
                  minValue: 10,
                  allowDecimal: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter monthly requirement' : 'Andika ibisabwa buri kwezi';
                    }
                    final number = double.tryParse(value);
                    if (number == null || number < 10) {
                      return isEnglish ? 'Minimum 10 kg required' : 'Byanze 10 kg';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Number of Beneficiaries
                NumberField(
                  controller: _numberOfBeneficiariesController,
                  label: isEnglish ? 'Number of Beneficiaries' : 'Umubare w\'Abungirwa',
                  hint: isEnglish
                      ? 'Students/Patients count'
                      : 'Umubare w\'abanyeshuri cyangwa abarwayi',
                  prefixIcon: Icons.people,
                  enabled: !_isLoading,
                  minValue: 1,
                  allowDecimal: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter number' : 'Andika umubare';
                    }
                    final number = int.tryParse(value);
                    if (number == null || number < 1) {
                      return isEnglish ? 'Invalid number' : 'Nomero si nziza';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Budget (Optional)
                NumberField(
                  controller: _budgetController,
                  label: isEnglish ? 'Monthly Budget (RWF) - Optional' : 'Ingengo y\'imari (RWF) - Ntabwo byakenewe',
                  hint: isEnglish ? 'Enter monthly budget' : 'Andika ingengo y\'imari',
                  prefixIcon: Icons.money,
                  enabled: !_isLoading,
                  allowDecimal: true,
                ),
                const SizedBox(height: 16),

                // Payment Terms
                DropdownButtonFormField<String>(
                  value: _paymentTerms,
                  decoration: InputDecoration(
                    labelText: isEnglish ? 'Payment Terms' : 'Amabwiriza yo Kwishyura',
                    prefixIcon: const Icon(Icons.payment),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _paymentOptions.map((option) {
                    return DropdownMenuItem(
                      value: option['value'],
                      child: Text(isEnglish ? option['en']! : option['rw']!),
                    );
                  }).toList(),
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _paymentTerms = value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return isEnglish ? 'Please select payment terms' : 'Hitamo amabwiriza';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Location Section
                Text(
                  isEnglish ? 'Location' : 'Aho Iherereye',
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

                // Address
                TextAreaField(
                  controller: _addressController,
                  label: isEnglish ? 'Detailed Address' : 'Aderesi Irambuye',
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

                // Document Section
                Text(
                  isEnglish ? 'Registration Certificate' : 'Icyangombwa cy\'Iyandikwa',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _pickCertificate,
                  icon: Icon(_registrationCertificate != null ? Icons.check_circle : Icons.upload_file),
                  label: Text(
                    _registrationCertificate != null
                        ? (isEnglish ? 'Certificate Selected' : 'Icyangombwa Cyatoranijwe')
                        : (isEnglish ? 'Upload Certificate' : 'Shyiramo Icyangombwa'),
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
