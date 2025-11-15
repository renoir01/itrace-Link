import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/cooperative_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/localization_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/custom_button.dart';

class HarvestManagementScreen extends StatefulWidget {
  const HarvestManagementScreen({super.key});

  @override
  State<HarvestManagementScreen> createState() => _HarvestManagementScreenState();
}

class _HarvestManagementScreenState extends State<HarvestManagementScreen> {
  final _firestoreService = FirestoreService();

  bool _isLoading = true;
  String? _errorMessage;
  CooperativeModel? _cooperative;
  String _filterStatus = 'all'; // all, pending, completed

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<PlantingRecord> get _filteredPlantings {
    if (_cooperative == null) return [];

    final plantings = _cooperative!.plantingRecords;

    if (_filterStatus == 'all') {
      return plantings;
    } else if (_filterStatus == 'pending') {
      return plantings.where((p) => p.status == 'active').toList();
    } else {
      return plantings.where((p) => p.status == 'harvested').toList();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppTheme.primaryGreen;
      case 'harvested':
        return AppTheme.successGreen;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status, bool isEnglish) {
    switch (status) {
      case 'active':
        return isEnglish ? 'Growing' : 'Irakura';
      case 'harvested':
        return isEnglish ? 'Harvested' : 'Byasaruwe';
      case 'failed':
        return isEnglish ? 'Failed' : 'Byanze';
      default:
        return status;
    }
  }

  Future<void> _navigateToUpdateHarvest(PlantingRecord planting) async {
    // Navigate to update harvest screen
    final result = await context.push('/farmer/update-harvest', extra: planting);

    // Reload data if harvest was updated
    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationService>();
    final isEnglish = localization.isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'Harvest Management' : 'Gucunga Isarura'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: isEnglish ? 'Refresh' : 'Ongera utangire',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading harvests...')
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadData,
                )
              : Column(
                  children: [
                    // Summary Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryGreen,
                            AppTheme.primaryGreen.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _SummaryItem(
                                icon: Icons.agriculture,
                                label: isEnglish ? 'Total Area' : 'Ubuso bwose',
                                value: '${_cooperative!.totalArea.toStringAsFixed(2)} ha',
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              _SummaryItem(
                                icon: Icons.grass,
                                label: isEnglish ? 'Active Plantings' : 'Ibyahingwe',
                                value: _cooperative!.plantingRecords
                                    .where((p) => p.status == 'active')
                                    .length
                                    .toString(),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              _SummaryItem(
                                icon: Icons.shopping_basket,
                                label: isEnglish ? 'Harvests' : 'Isarura',
                                value: _cooperative!.harvestRecords.length.toString(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Filter Chips
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          _FilterChip(
                            label: isEnglish ? 'All' : 'Byose',
                            isSelected: _filterStatus == 'all',
                            onTap: () {
                              setState(() {
                                _filterStatus = 'all';
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: isEnglish ? 'Growing' : 'Irakura',
                            isSelected: _filterStatus == 'pending',
                            onTap: () {
                              setState(() {
                                _filterStatus = 'pending';
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: isEnglish ? 'Harvested' : 'Byasaruwe',
                            isSelected: _filterStatus == 'completed',
                            onTap: () {
                              setState(() {
                                _filterStatus = 'completed';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Planting List
                    Expanded(
                      child: _filteredPlantings.isEmpty
                          ? EmptyStateWidget(
                              icon: Icons.agriculture,
                              title: isEnglish ? 'No Plantings Found' : 'Nta byahingwe Byabonetse',
                              message: isEnglish
                                  ? 'Start by registering your first planting'
                                  : 'Tangira wandika ibyahingwe byawe bya mbere',
                              actionLabel: isEnglish ? 'Register Planting' : 'Andika Ibyahingwe',
                              onAction: () => context.push('/farmer/register-planting'),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadData,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredPlantings.length,
                                itemBuilder: (context, index) {
                                  final planting = _filteredPlantings[index];
                                  return _PlantingCard(
                                    planting: planting,
                                    isEnglish: isEnglish,
                                    formatDate: _formatDate,
                                    getStatusColor: _getStatusColor,
                                    getStatusText: _getStatusText,
                                    onTap: () {
                                      if (planting.status == 'active') {
                                        _navigateToUpdateHarvest(planting);
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/farmer/register-planting').then((_) => _loadData()),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add),
        label: Text(isEnglish ? 'New Planting' : 'Ibyahingwe Bishya'),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _PlantingCard extends StatelessWidget {
  final PlantingRecord planting;
  final bool isEnglish;
  final String Function(DateTime) formatDate;
  final Color Function(String) getStatusColor;
  final String Function(String, bool) getStatusText;
  final VoidCallback onTap;

  const _PlantingCard({
    required this.planting,
    required this.isEnglish,
    required this.formatDate,
    required this.getStatusColor,
    required this.getStatusText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntilHarvest = planting.expectedHarvestDate.difference(DateTime.now()).inDays;
    final isReadyForHarvest = daysUntilHarvest <= 7 && planting.status == 'active';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isReadyForHarvest
            ? BorderSide(color: AppTheme.successGreen, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bean Variety
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.grass,
                            color: AppTheme.primaryGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                planting.beanVariety,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${planting.areaPlanted.toStringAsFixed(2)} ha',
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
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: getStatusColor(planting.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: getStatusColor(planting.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      getStatusText(planting.status, isEnglish),
                      style: TextStyle(
                        color: getStatusColor(planting.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: _DateInfo(
                      icon: Icons.calendar_today,
                      label: isEnglish ? 'Planted' : 'Byatewe',
                      date: formatDate(planting.plantingDate),
                    ),
                  ),
                  Expanded(
                    child: _DateInfo(
                      icon: Icons.event,
                      label: isEnglish ? 'Expected' : 'Byitezwe',
                      date: formatDate(planting.expectedHarvestDate),
                    ),
                  ),
                ],
              ),

              // Days until harvest (for active plantings)
              if (planting.status == 'active') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isReadyForHarvest
                        ? AppTheme.successGreen.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isReadyForHarvest ? Icons.check_circle : Icons.timer,
                        color: isReadyForHarvest ? AppTheme.successGreen : Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          daysUntilHarvest > 0
                              ? (isEnglish
                                  ? '$daysUntilHarvest days until harvest'
                                  : 'Iminsi $daysUntilHarvest mbere yo gusarura')
                              : (isEnglish ? 'Ready for harvest!' : 'Byiteguye gusarurwa!'),
                          style: TextStyle(
                            color: isReadyForHarvest ? AppTheme.successGreen : Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (planting.status == 'active')
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                    ],
                  ),
                ),
              ],

              // Notes
              if (planting.notes != null && planting.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  planting.notes!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DateInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String date;

  const _DateInfo({
    required this.icon,
    required this.label,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              date,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
