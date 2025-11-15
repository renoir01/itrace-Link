import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/cooperative_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/localization_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart';

class RegisterPlantingScreen extends StatefulWidget {
  const RegisterPlantingScreen({super.key});

  @override
  State<RegisterPlantingScreen> createState() => _RegisterPlantingScreenState();
}

class _RegisterPlantingScreenState extends State<RegisterPlantingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  // Form controllers
  final _areaController = TextEditingController();
  final _notesController = TextEditingController();

  // Form state
  String? _selectedVariety;
  DateTime? _plantingDate;
  DateTime? _expectedHarvestDate;

  // UI state
  bool _isLoading = false;
  bool _isLoadingData = true;
  String? _errorMessage;
  CooperativeModel? _cooperative;

  // Bean varieties (iron-biofortified)
  final List<Map<String, String>> _beanVarieties = [
    {'value': 'RWR 2245', 'en': 'RWR 2245 (High Iron)', 'rw': 'RWR 2245 (Iron nyinshi)'},
    {'value': 'MAC 42', 'en': 'MAC 42 (High Iron)', 'rw': 'MAC 42 (Iron nyinshi)'},
    {'value': 'RWR 10', 'en': 'RWR 10 (High Iron)', 'rw': 'RWR 10 (Iron nyinshi)'},
    {'value': 'RWV 1129', 'en': 'RWV 1129 (High Iron)', 'rw': 'RWV 1129 (Iron nyinshi)'},
    {'value': 'MAC 44', 'en': 'MAC 44 (High Iron)', 'rw': 'MAC 44 (Iron nyinshi)'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCooperativeData();
  }

  @override
  void dispose() {
    _areaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCooperativeData() async {
    try {
      final authService = context.read<AuthService>();
      final userId = authService.currentUser?.uid;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final cooperative = await _firestoreService.getCooperative(userId);

      if (cooperative == null) {
        throw Exception('Cooperative profile not found');
      }

      setState(() {
        _cooperative = cooperative;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
        _isLoadingData = false;
      });
    }
  }

  Future<void> _selectPlantingDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1);
    final lastDate = DateTime(now.year + 1);

    final date = await showDatePicker(
      context: context,
      initialDate: _plantingDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _plantingDate = date;
        // Auto-calculate expected harvest (90-120 days for beans)
        _expectedHarvestDate = date.add(const Duration(days: 105));
      });
    }
  }

  Future<void> _selectExpectedHarvestDate() async {
    if (_plantingDate == null) {
      _showError('Please select planting date first');
      return;
    }

    final minDate = _plantingDate!.add(const Duration(days: 60)); // Minimum 60 days
    final maxDate = _plantingDate!.add(const Duration(days: 150)); // Maximum 150 days

    final date = await showDatePicker(
      context: context,
      initialDate: _expectedHarvestDate ?? minDate,
      firstDate: minDate,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _expectedHarvestDate = date;
      });
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _registerPlanting() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedVariety == null) {
      _showError('Please select bean variety');
      return;
    }

    if (_plantingDate == null) {
      _showError('Please select planting date');
      return;
    }

    if (_expectedHarvestDate == null) {
      _showError('Please select expected harvest date');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      final userId = authService.currentUser?.uid;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final area = double.parse(_areaController.text.trim());

      // Create planting record
      final plantingRecord = PlantingRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        beanVariety: _selectedVariety!,
        areaPlanted: area,
        plantingDate: _plantingDate!,
        expectedHarvestDate: _expectedHarvestDate!,
        status: 'active',
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      // Update cooperative with new planting record
      final updatedCooperative = _cooperative!.copyWith(
        plantingRecords: [..._cooperative!.plantingRecords, plantingRecord],
        totalArea: _cooperative!.totalArea + area,
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateCooperative(updatedCooperative);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocalizationService>().isEnglish
                ? 'Planting registered successfully!'
                : 'Ibyahingwe byanditswe neza!',
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );

      // Navigate back
      context.pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to register planting: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationService>();
    final isEnglish = localization.isEnglish;

    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEnglish ? 'Register Planting' : 'Andika Ibyahingwe'),
        ),
        body: const LoadingWidget(message: 'Loading...'),
      );
    }

    if (_errorMessage != null && _cooperative == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEnglish ? 'Register Planting' : 'Andika Ibyahingwe'),
        ),
        body: ErrorDisplay(
          message: _errorMessage!,
          onRetry: _loadCooperativeData,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'Register Planting' : 'Andika Ibyahingwe'),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.agriculture,
                        size: 40,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEnglish ? 'New Planting Record' : 'Ibyahingwe Bishya',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isEnglish
                                  ? 'Record your iron-biofortified bean planting'
                                  : 'Andika ibyahingwe by\'ibishyimbo bifite iron',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Cooperative Info
                Text(
                  isEnglish ? 'Cooperative: ${_cooperative!.cooperativeName}' : 'Ikoperative: ${_cooperative!.cooperativeName}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  isEnglish
                      ? 'Current Total Area: ${_cooperative!.totalArea.toStringAsFixed(2)} ha'
                      : 'Ubuso bwose: ${_cooperative!.totalArea.toStringAsFixed(2)} ha',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 24),

                // Bean Variety
                Text(
                  isEnglish ? 'Bean Variety *' : 'Ubwoko bw\'Ibishyimbo *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedVariety,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.grass),
                    hintText: isEnglish ? 'Select bean variety' : 'Hitamo ubwoko',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _beanVarieties.map((variety) {
                    return DropdownMenuItem(
                      value: variety['value'],
                      child: Text(isEnglish ? variety['en']! : variety['rw']!),
                    );
                  }).toList(),
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _selectedVariety = value;
                            _errorMessage = null;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return isEnglish ? 'Please select variety' : 'Hitamo ubwoko';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Area Planted
                Text(
                  isEnglish ? 'Area Planted *' : 'Ubuso bwahingiwe *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                NumberField(
                  controller: _areaController,
                  label: isEnglish ? 'Area (hectares)' : 'Ubuso (hegitari)',
                  hint: isEnglish ? 'Enter area in hectares' : 'Andika ubuso muri hegitari',
                  prefixIcon: Icons.square_foot,
                  enabled: !_isLoading,
                  allowDecimal: true,
                  minValue: 0.01,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter area' : 'Andika ubuso';
                    }
                    final area = double.tryParse(value);
                    if (area == null || area <= 0) {
                      return isEnglish ? 'Invalid area' : 'Ubuso si bwiza';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Planting Date
                Text(
                  isEnglish ? 'Planting Date *' : 'Itariki yo Gutera *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _isLoading ? null : _selectPlantingDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: AppTheme.primaryGreen),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _plantingDate != null
                                ? _formatDate(_plantingDate!)
                                : (isEnglish ? 'Select planting date' : 'Hitamo itariki'),
                            style: TextStyle(
                              fontSize: 16,
                              color: _plantingDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Expected Harvest Date
                Text(
                  isEnglish ? 'Expected Harvest Date *' : 'Itariki Yateganijwe yo Gusarura *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _isLoading ? null : _selectExpectedHarvestDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event, color: AppTheme.primaryGreen),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _expectedHarvestDate != null
                                ? _formatDate(_expectedHarvestDate!)
                                : (isEnglish ? 'Select expected harvest date' : 'Hitamo itariki yateganijwe'),
                            style: TextStyle(
                              fontSize: 16,
                              color: _expectedHarvestDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                if (_plantingDate != null && _expectedHarvestDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      isEnglish
                          ? 'Growing period: ${_expectedHarvestDate!.difference(_plantingDate!).inDays} days'
                          : 'Igihe cyo gukura: ${_expectedHarvestDate!.difference(_plantingDate!).inDays} iminsi',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Notes (Optional)
                Text(
                  isEnglish ? 'Notes (Optional)' : 'Ibisobanuro (Ntabwo byakenewe)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                TextAreaField(
                  controller: _notesController,
                  label: isEnglish ? 'Additional notes' : 'Ibisobanuro byongeyeho',
                  hint: isEnglish
                      ? 'Add any additional information (optional)'
                      : 'Ongeraho amakuru yose (ntabwo byakenewe)',
                  enabled: !_isLoading,
                  maxLines: 4,
                ),
                const SizedBox(height: 32),

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

                // Submit Button
                CustomButton(
                  text: isEnglish ? 'Register Planting' : 'Andika Ibyahingwe',
                  onPressed: _isLoading ? null : _registerPlanting,
                  isLoading: _isLoading,
                  icon: Icons.check_circle,
                ),
                const SizedBox(height: 16),

                // Cancel Button
                CustomButton(
                  text: isEnglish ? 'Cancel' : 'Kureka',
                  onPressed: _isLoading ? null : () => context.pop(),
                  type: ButtonType.outline,
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
