import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/order_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/localization_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/empty_state_widget.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final _firestoreService = FirestoreService();

  bool _isLoading = true;
  String? _errorMessage;
  List<OrderModel> _completedOrders = [];
  String _filterPeriod = 'all'; // all, this_month, last_month, this_year

  @override
  void initState() {
    super.initState();
    _loadSalesHistory();
  }

  Future<void> _loadSalesHistory() async {
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

      // Load completed orders only
      final ordersStream = _firestoreService.getUserOrders(userId, status: 'completed');

      ordersStream.listen((orders) {
        if (mounted) {
          setState(() {
            _completedOrders = orders;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load sales history: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<OrderModel> get _filteredOrders {
    final now = DateTime.now();

    switch (_filterPeriod) {
      case 'this_month':
        return _completedOrders.where((order) {
          return order.createdAt.year == now.year && order.createdAt.month == now.month;
        }).toList();

      case 'last_month':
        final lastMonth = DateTime(now.year, now.month - 1);
        return _completedOrders.where((order) {
          return order.createdAt.year == lastMonth.year &&
              order.createdAt.month == lastMonth.month;
        }).toList();

      case 'this_year':
        return _completedOrders.where((order) {
          return order.createdAt.year == now.year;
        }).toList();

      default:
        return _completedOrders;
    }
  }

  Map<String, double> get _salesStats {
    final filtered = _filteredOrders;
    final totalRevenue = filtered.fold(0.0, (sum, order) => sum + order.totalPrice);
    final totalQuantity = filtered.fold(0.0, (sum, order) => sum + order.quantity);
    final averagePrice = filtered.isEmpty ? 0.0 : totalRevenue / totalQuantity;

    return {
      'totalRevenue': totalRevenue,
      'totalQuantity': totalQuantity,
      'averagePrice': averagePrice,
      'orderCount': filtered.length.toDouble(),
    };
  }

  String _formatCurrency(double amount) {
    return 'RWF ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationService>();
    final isEnglish = localization.isEnglish;
    final stats = _salesStats;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'Sales History' : 'Amateka y\'Ibicuruzwa'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSalesHistory,
            tooltip: isEnglish ? 'Refresh' : 'Ongera utangire',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading sales...')
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadSalesHistory,
                )
              : Column(
                  children: [
                    // Stats Overview
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
                              _StatItem(
                                label: isEnglish ? 'Total Sales' : 'Igicuruzwa cyose',
                                value: _formatCurrency(stats['totalRevenue']!),
                                icon: Icons.account_balance_wallet,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(
                                label: isEnglish ? 'Quantity Sold' : 'Ibisaruwe',
                                value: '${stats['totalQuantity']!.toStringAsFixed(0)} kg',
                                icon: Icons.shopping_basket,
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              _StatItem(
                                label: isEnglish ? 'Avg Price/kg' : 'Igiciro/kg',
                                value: _formatCurrency(stats['averagePrice']!),
                                icon: Icons.attach_money,
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              _StatItem(
                                label: isEnglish ? 'Orders' : 'Amacupa',
                                value: stats['orderCount']!.toStringAsFixed(0),
                                icon: Icons.receipt_long,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Filter Chips
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: isEnglish ? 'All Time' : 'Igihe cyose',
                              isSelected: _filterPeriod == 'all',
                              onTap: () {
                                setState(() {
                                  _filterPeriod = 'all';
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: isEnglish ? 'This Month' : 'Uku kwezi',
                              isSelected: _filterPeriod == 'this_month',
                              onTap: () {
                                setState(() {
                                  _filterPeriod = 'this_month';
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: isEnglish ? 'Last Month' : 'Ukwezi gushize',
                              isSelected: _filterPeriod == 'last_month',
                              onTap: () {
                                setState(() {
                                  _filterPeriod = 'last_month';
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: isEnglish ? 'This Year' : 'Uyu mwaka',
                              isSelected: _filterPeriod == 'this_year',
                              onTap: () {
                                setState(() {
                                  _filterPeriod = 'this_year';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sales List
                    Expanded(
                      child: _filteredOrders.isEmpty
                          ? EmptyStateWidget(
                              icon: Icons.history,
                              title: isEnglish ? 'No Sales History' : 'Nta mateka y\'Igicuruzwa',
                              message: isEnglish
                                  ? 'No completed sales for this period'
                                  : 'Nta bicuruzwa byarangiye muri iki gihe',
                            )
                          : RefreshIndicator(
                              onRefresh: _loadSalesHistory,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredOrders.length,
                                itemBuilder: (context, index) {
                                  final order = _filteredOrders[index];
                                  return _SaleCard(
                                    order: order,
                                    isEnglish: isEnglish,
                                    formatDate: _formatDate,
                                    formatCurrency: _formatCurrency,
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
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

class _SaleCard extends StatelessWidget {
  final OrderModel order;
  final bool isEnglish;
  final String Function(DateTime) formatDate;
  final String Function(double) formatCurrency;

  const _SaleCard({
    required this.order,
    required this.isEnglish,
    required this.formatDate,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.beanVariety ?? 'Iron Beans',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatDate(order.createdAt),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.successGreen,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.successGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isEnglish ? 'Completed' : 'Byarangiye',
                        style: const TextStyle(
                          color: AppTheme.successGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DetailItem(
                  label: isEnglish ? 'Quantity' : 'Umubare',
                  value: '${order.quantity.toStringAsFixed(0)} kg',
                  icon: Icons.shopping_basket,
                ),
                _DetailItem(
                  label: isEnglish ? 'Price/kg' : 'Igiciro/kg',
                  value: formatCurrency(order.pricePerKg),
                  icon: Icons.attach_money,
                ),
                _DetailItem(
                  label: isEnglish ? 'Total' : 'Igiciro cyose',
                  value: formatCurrency(order.totalPrice),
                  icon: Icons.account_balance_wallet,
                  isHighlighted: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isHighlighted;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: isHighlighted ? AppTheme.primaryGreen : Colors.grey.shade600,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
            color: isHighlighted ? AppTheme.primaryGreen : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
