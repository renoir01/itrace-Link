import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/order_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/localization_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/custom_card.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});

  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
  final _firestoreService = FirestoreService();

  bool _isLoading = true;
  String? _errorMessage;
  List<OrderModel> _orders = [];
  String _filterStatus = 'all'; // all, pending, accepted, completed, rejected

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
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

      // Load orders where farmer is the seller
      final ordersStream = _firestoreService.getUserOrders(userId);

      ordersStream.listen((orders) {
        if (mounted) {
          setState(() {
            _orders = orders;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load orders: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<OrderModel> get _filteredOrders {
    if (_filterStatus == 'all') {
      return _orders;
    }
    return _orders.where((order) => order.status == _filterStatus).toList();
  }

  Map<String, int> get _orderStats {
    return {
      'pending': _orders.where((o) => o.status == 'pending').length,
      'accepted': _orders.where((o) => o.status == 'accepted').length,
      'completed': _orders.where((o) => o.status == 'completed').length,
      'rejected': _orders.where((o) => o.status == 'rejected').length,
    };
  }

  double get _totalRevenue {
    return _orders
        .where((o) => o.status == 'completed')
        .fold(0.0, (sum, order) => sum + order.totalPrice);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(double amount) {
    return 'RWF ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  void _navigateToOrderDetails(OrderModel order) {
    context.push('/orders/${order.id}', extra: order).then((_) => _loadOrders());
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationService>();
    final isEnglish = localization.isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'My Orders' : 'Amacupa Yanjye'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: isEnglish ? 'Refresh' : 'Ongera utangire',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading orders...')
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadOrders,
                )
              : Column(
                  children: [
                    // Summary Cards
                    Container(
                      height: 120,
                      margin: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              title: isEnglish ? 'Pending' : 'Bitegerejwe',
                              value: _orderStats['pending'].toString(),
                              icon: Icons.access_time,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryCard(
                              title: isEnglish ? 'Accepted' : 'Byemewe',
                              value: _orderStats['accepted'].toString(),
                              icon: Icons.check_circle,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryCard(
                              title: isEnglish ? 'Completed' : 'Byarangiye',
                              value: _orderStats['completed'].toString(),
                              icon: Icons.done_all,
                              color: AppTheme.successGreen,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Revenue Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryGreen,
                            AppTheme.primaryGreen.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEnglish ? 'Total Revenue' : 'Amafaranga Yose',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatCurrency(_totalRevenue),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter Chips
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: isEnglish ? 'All' : 'Byose',
                              count: _orders.length,
                              isSelected: _filterStatus == 'all',
                              onTap: () {
                                setState(() {
                                  _filterStatus = 'all';
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: isEnglish ? 'Pending' : 'Bitegerejwe',
                              count: _orderStats['pending']!,
                              isSelected: _filterStatus == 'pending',
                              onTap: () {
                                setState(() {
                                  _filterStatus = 'pending';
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: isEnglish ? 'Accepted' : 'Byemewe',
                              count: _orderStats['accepted']!,
                              isSelected: _filterStatus == 'accepted',
                              onTap: () {
                                setState(() {
                                  _filterStatus = 'accepted';
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: isEnglish ? 'Completed' : 'Byarangiye',
                              count: _orderStats['completed']!,
                              isSelected: _filterStatus == 'completed',
                              onTap: () {
                                setState(() {
                                  _filterStatus = 'completed';
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: isEnglish ? 'Rejected' : 'Byanze',
                              count: _orderStats['rejected']!,
                              isSelected: _filterStatus == 'rejected',
                              onTap: () {
                                setState(() {
                                  _filterStatus = 'rejected';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Orders List
                    Expanded(
                      child: _filteredOrders.isEmpty
                          ? EmptyStateWidget(
                              icon: Icons.shopping_basket,
                              title: isEnglish ? 'No Orders Found' : 'Nta macupa Yabonetse',
                              message: isEnglish
                                  ? 'You have no orders matching this filter'
                                  : 'Nta macupa ufite y\'ubu',
                            )
                          : RefreshIndicator(
                              onRefresh: _loadOrders,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredOrders.length,
                                itemBuilder: (context, index) {
                                  final order = _filteredOrders[index];
                                  return OrderCard(
                                    order: order,
                                    onTap: () => _navigateToOrderDetails(order),
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
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
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.3) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
