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

class UpdateHarvestScreen extends StatefulWidget {
  final PlantingRecord planting;

  const UpdateHarvestScreen({super.key, required this.planting});

  @override
  State<UpdateHarvestScreen> createState() => _UpdateHarvestScreenState();
}

class _UpdateHarvestScreenState extends State<UpdateHarvestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  // Form controllers
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  // Form state
  DateTime? _actualHarvestDate;
  String _quality = 'good';

  // UI state
  bool _isLoading = false;
  String? _errorMessage;

  // Quality options
  final List<Map<String, String>> _qualityOptions = [
    {'value': 'excellent', 'en': 'Excellent', 'rw': 'Nziza cyane'},
    {'value': 'good', 'en': 'Good', 'rw': 'Nziza'},
    {'value': 'fair', 'en': 'Fair', 'rw': 'Nziza gusa'},
    {'value': 'poor', 'en': 'Poor', 'rw': 'Ntabwo nziza'},
  ];

  @override
  void initState() {
    super.initState();
    _actualHarvestDate = DateTime.now();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectHarvestDate() async {
    final minDate = widget.planting.plantingDate.add(const Duration(days: 60));
    final maxDate = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _actualHarvestDate ?? DateTime.now(),
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
        _actualHarvestDate = date;
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

  Future<void> _recordHarvest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_actualHarvestDate == null) {
      _showError('Please select harvest date');
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

      final quantity = double.parse(_quantityController.text.trim());

      // Load current cooperative data
      final cooperative = await _firestoreService.getCooperative(userId);

      if (cooperative == null) {
        throw Exception('Cooperative not found');
      }

      // Create harvest record
      final harvestRecord = HarvestRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        plantingId: widget.planting.id,
        beanVariety: widget.planting.beanVariety,
        quantity: quantity,
        harvestDate: _actualHarvestDate!,
        quality: _quality,
        isAvailable: true,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      // Update planting status to harvested
      final updatedPlantings = cooperative.plantingRecords.map((p) {
        if (p.id == widget.planting.id) {
          return PlantingRecord(
            id: p.id,
            beanVariety: p.beanVariety,
            areaPlanted: p.areaPlanted,
            plantingDate: p.plantingDate,
            expectedHarvestDate: p.expectedHarvestDate,
            status: 'harvested',
            notes: p.notes,
          );
        }
        return p;
      }).toList();

      // Update cooperative
      final updatedCooperative = cooperative.copyWith(
        plantingRecords: updatedPlantings,
        harvestRecords: [...cooperative.harvestRecords, harvestRecord],
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateCooperative(updatedCooperative);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocalizationService>().isEnglish
                ? 'Harvest recorded successfully!'
                : 'Isarura ryanditswe neza!',
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );

      // Return to previous screen with success indicator
      context.pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to record harvest: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  double get _expectedYield {
    // Average yield: 1.5 tons per hectare (1500 kg/ha)
    return widget.planting.areaPlanted * 1500;
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationService>();
    final isEnglish = localization.isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'Record Harvest' : 'Andika Isarura'),
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
                // Planting Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.grass,
                            color: AppTheme.primaryGreen,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.planting.beanVariety,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${widget.planting.areaPlanted.toStringAsFixed(2)} ha',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEnglish ? 'Planted' : 'Byatewe',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                _formatDate(widget.planting.plantingDate),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEnglish ? 'Expected' : 'Byitezwe',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                _formatDate(widget.planting.expectedHarvestDate),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEnglish ? 'Est. Yield' : 'Umusaruro',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                '~${_expectedYield.toStringAsFixed(0)} kg',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Harvest Details Header
                Text(
                  isEnglish ? 'Harvest Details' : 'Amakuru y\'Isarura',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                ),
                const SizedBox(height: 24),

                // Actual Harvest Date
                Text(
                  isEnglish ? 'Harvest Date *' : 'Itariki yo Gusarura *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _isLoading ? null : _selectHarvestDate,
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
                            _actualHarvestDate != null
                                ? _formatDate(_actualHarvestDate!)
                                : (isEnglish ? 'Select harvest date' : 'Hitamo itariki'),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Quantity Harvested
                Text(
                  isEnglish ? 'Quantity Harvested (kg) *' : 'Umubare Wasaruwe (kg) *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                NumberField(
                  controller: _quantityController,
                  label: isEnglish ? 'Quantity (kg)' : 'Umubare (kg)',
                  hint: isEnglish ? 'Enter quantity in kilograms' : 'Andika umubare muri kilogramu',
                  prefixIcon: Icons.shopping_basket,
                  enabled: !_isLoading,
                  allowDecimal: true,
                  minValue: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isEnglish ? 'Please enter quantity' : 'Andika umubare';
                    }
                    final quantity = double.tryParse(value);
                    if (quantity == null || quantity <= 0) {
                      return isEnglish ? 'Invalid quantity' : 'Umubare si mwiza';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    isEnglish
                        ? 'Expected yield: ~${_expectedYield.toStringAsFixed(0)} kg'
                        : 'Umusaruro wari utezwe: ~${_expectedYield.toStringAsFixed(0)} kg',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ),
                const SizedBox(height: 24),

                // Quality
                Text(
                  isEnglish ? 'Bean Quality *' : 'Ireme ry\'Ibishyimbo *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _quality,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.star),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _qualityOptions.map((option) {
                    return DropdownMenuItem(
                      value: option['value'],
                      child: Text(isEnglish ? option['en']! : option['rw']!),
                    );
                  }).toList(),
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _quality = value!;
                          });
                        },
                ),
                const SizedBox(height: 24),

                // Notes
                Text(
                  isEnglish ? 'Notes (Optional)' : 'Ibisobanuro (Ntabwo byakenewe)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                TextAreaField(
                  controller: _notesController,
                  label: isEnglish ? 'Harvest notes' : 'Ibisobanuro by\'isarura',
                  hint: isEnglish
                      ? 'Add any notes about the harvest (optional)'
                      : 'Ongeraho ibisobanuro by\'isarura (ntabwo byakenewe)',
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
                  text: isEnglish ? 'Record Harvest' : 'Andika Isarura',
                  onPressed: _isLoading ? null : _recordHarvest,
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
