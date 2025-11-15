import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/cooperative_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/localization_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/error_widget.dart';

class FarmerRegistrationScreen extends StatefulWidget {
  const FarmerRegistrationScreen({super.key});

  @override
  State<FarmerRegistrationScreen> createState() => _FarmerRegistrationScreenState();
}

class _FarmerRegistrationScreenState extends State<FarmerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  // Form controllers
  final _cooperativeNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _numberOfMembersController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  // Dropdown values
  String? _selectedDistrict;
  String? _selectedSector;
  String? _selectedCell;

  // File uploads
  XFile? _profileImage;
  XFile? _certificateFile;

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

  // Sectors per district (simplified - in production, fetch from database)
  final Map<String, List<String>> _sectors = {
    'Kigali': ['Gasabo', 'Kicukiro', 'Nyarugenge'],
    'Eastern Province': ['Bugesera', 'Gatsibo', 'Kayonza', 'Kirehe', 'Ngoma', 'Nyagatare', 'Rwamagana'],
    'Northern Province': ['Burera', 'Gakenke', 'Gicumbi', 'Musanze', 'Rulindo'],
    'Southern Province': ['Gisagara', 'Huye', 'Kamonyi', 'Muhanga', 'Nyamagabe', 'Nyanza', 'Nyaruguru', 'Ruhango'],
    'Western Province': ['Karongi', 'Ngororero', 'Nyabihu', 'Nyamasheke', 'Rubavu', 'Rusizi', 'Rutsiro'],
  };

  // Cells per sector (simplified)
  final Map<String, List<String>> _cells = {
    'Gasabo': ['Bumbogo', 'Gatsata', 'Gikomero', 'Gisozi', 'Jabana', 'Jali', 'Kacyiru'],
    'Kicukiro': ['Gahanga', 'Gatenga', 'Gikondo', 'Kagarama', 'Kanombe', 'Kicukiro', 'Kigarama'],
    'Nyarugenge': ['Gitega', 'Kanyinya', 'Kigali', 'Kimisagara', 'Mageragere', 'Muhima', 'Nyakabanda'],
    // Add more as needed
  };

  @override
  void dispose() {
    _cooperativeNameController.dispose();
    _registrationNumberController.dispose();
    _numberOfMembersController.dispose();
    _contactPersonController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final image = await _storageService.pickImageFromGallery();
      if (image != null) {
        // Validate file size
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
          _certificateFile = image;
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

    if (_selectedDistrict == null || _selectedSector == null || _selectedCell == null) {
      _showError('Please select district, sector, and cell');
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

      // Upload profile image if selected
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

      // Upload certificate if selected
      String? certificateUrl;
      if (_certificateFile != null) {
        setState(() => _uploadProgress = 0.6);
        certificateUrl = await _storageService.uploadDocument(
          File(_certificateFile!.path),
          currentUser.uid,
          'registration_certificate',
        );
      }

      setState(() => _uploadProgress = 0.9);

      // Parse GPS coordinates
      double? latitude;
      double? longitude;
      if (_latitudeController.text.isNotEmpty && _longitudeController.text.isNotEmpty) {
        latitude = double.tryParse(_latitudeController.text);
        longitude = double.tryParse(_longitudeController.text);
      }

      // Create cooperative model
      final cooperative = CooperativeModel(
        id: currentUser.uid,
        cooperativeName: _cooperativeNameController.text.trim(),
        registrationNumber: _registrationNumberController.text.trim(),
        numberOfMembers: int.parse(_numberOfMembersController.text.trim()),
        location: {
          'district': _selectedDistrict!,
          'sector': _selectedSector!,
          'cell': _selectedCell!,
        },
        gpsCoordinates: (latitude != null && longitude != null)
            ? {'latitude': latitude, 'longitude': longitude}
            : null,
        contactPerson: _contactPersonController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        profileImageUrl: profileImageUrl,
        documents: certificateUrl != null ? [certificateUrl] : [],
        totalArea: 0.0, // Will be updated when registering plantings
        plantingRecords: [],
        harvestRecords: [],
        isVerified: false,
        rating: 0.0,
        totalSales: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestoreService.createCooperative(cooperative);

      // Create/update user profile
      final userModel = UserModel(
        uid: currentUser.uid,
        phoneNumber: _phoneNumberController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        userType: 'farmer',
        displayName: _cooperativeNameController.text.trim(),
        isVerified: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestoreService.createUser(userModel);

      setState(() => _uploadProgress = 1.0);

      if (!mounted) return;

      // Navigate to farmer dashboard
      context.go('/farmer/dashboard');

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
        title: Text(isEnglish ? 'Farmer Registration' : 'Kwiyandikisha kw\'Umuhinzi'),
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
                      ? 'Cooperative Information'
                      : 'Amakuru y\'Ikoperative',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEnglish
                      ? 'Please provide accurate information about your cooperative'
                      : 'Tanga amakuru y\'ukuri kuri ikoperative yawe',
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
                        isEnglish ? 'Add Cooperative Photo' : 'Ongeraho Ifoto y\'Ikoperative',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Cooperative Name
                CustomTextField(
                  controller: _cooperativeNameController,
                  label: isEnglish ? 'Cooperative Name' : 'Izina ry\'Ikoperative',
                  hint: isEnglish ? 'Enter cooperative name' : 'Andika izina ry\'ikoperative',
                  prefixIcon: Icons.business,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter cooperative name' : 'Andika izina ry\'ikoperative';
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
                  prefixIcon: Icons.numbers,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter registration number' : 'Andika nomero y\'iyandikwa';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Number of Members
                NumberField(
                  controller: _numberOfMembersController,
                  label: isEnglish ? 'Number of Members' : 'Umubare w\'Abanyamuryango',
                  hint: isEnglish ? 'Enter number of members' : 'Andika umubare w\'abanyamuryango',
                  prefixIcon: Icons.people,
                  enabled: !_isLoading,
                  minValue: 1,
                  allowDecimal: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter number of members' : 'Andika umubare w\'abanyamuryango';
                    }
                    final number = int.tryParse(value);
                    if (number == null || number < 1) {
                      return isEnglish ? 'Invalid number' : 'Nomero si nziza';
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

                // District Dropdown
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
                            _selectedCell = null;
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

                // Sector Dropdown
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
                            _selectedCell = null;
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

                // Cell Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCell,
                  decoration: InputDecoration(
                    labelText: isEnglish ? 'Cell' : 'Akagari',
                    prefixIcon: const Icon(Icons.my_location),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _selectedSector != null && _cells.containsKey(_selectedSector)
                      ? _cells[_selectedSector]?.map((cell) {
                          return DropdownMenuItem(
                            value: cell,
                            child: Text(cell),
                          );
                        }).toList()
                      : [
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text(isEnglish ? 'Other' : 'Ikindi'),
                          )
                        ],
                  onChanged: _isLoading || _selectedSector == null
                      ? null
                      : (value) {
                          setState(() {
                            _selectedCell = value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return isEnglish ? 'Please select cell' : 'Hitamo akagari';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // GPS Coordinates (Optional)
                Text(
                  isEnglish ? 'GPS Coordinates (Optional)' : 'Aho Iherereye kuri GPS (Ntabwo byakenewe)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _latitudeController,
                        label: isEnglish ? 'Latitude' : 'Latitude',
                        hint: '-1.9403',
                        prefixIcon: Icons.location_on,
                        enabled: !_isLoading,
                        keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _longitudeController,
                        label: isEnglish ? 'Longitude' : 'Longitude',
                        hint: '29.8739',
                        prefixIcon: Icons.location_on,
                        enabled: !_isLoading,
                        keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                  ],
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
                  label: isEnglish ? 'Contact Person' : 'Amazina y\'Umuntu wo Kuvugana',
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

                // Email (Optional)
                EmailField(
                  controller: _emailController,
                  label: isEnglish ? 'Email (Optional)' : 'Imeri (Ntabwo byakenewe)',
                  hint: isEnglish ? 'Enter email address' : 'Andika imeri',
                  enabled: !_isLoading,
                  required: false,
                ),
                const SizedBox(height: 24),

                // Certificate Upload
                Text(
                  isEnglish ? 'Registration Certificate' : 'Icyangombwa cy\'Iyandikwa',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEnglish
                      ? 'Upload a photo of your cooperative registration certificate'
                      : 'Shyiramo ifoto y\'icyangombwa cy\'iyandikwa ry\'ikoperative',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _pickCertificate,
                  icon: Icon(_certificateFile != null ? Icons.check_circle : Icons.upload_file),
                  label: Text(
                    _certificateFile != null
                        ? (isEnglish ? 'Certificate Selected' : 'Icyangombwa Cyatoranijwe')
                        : (isEnglish ? 'Upload Certificate' : 'Shyiramo Icyangombwa'),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _certificateFile != null ? AppTheme.successGreen : AppTheme.primaryGreen,
                    side: BorderSide(
                      color: _certificateFile != null ? AppTheme.successGreen : AppTheme.primaryGreen,
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
