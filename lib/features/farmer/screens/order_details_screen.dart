import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/order_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/localization_service.dart';
import '../../../services/sms_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final _firestoreService = FirestoreService();
  final _smsService = SmsService();

  bool _isLoading = true;
  bool _isUpdating = false;
  String? _errorMessage;
  OrderModel? _order;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final order = await _firestoreService.getOrder(widget.orderId);

      if (order == null) {
        throw Exception('Order not found');
      }

      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load order: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptOrder() async {
    setState(() {
      _isUpdating = true;
      _errorMessage = null;
    });

    try {
      final updatedOrder = _order!.copyWith(
        status: 'accepted',
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateOrder(updatedOrder);

      // Send SMS notification to buyer
      final localization = context.read<LocalizationService>();
      await _smsService.sendOrderNotification(
        phoneNumber: _order!.buyerId, // This should be buyer's phone
        aggregatorName: _order!.sellerId, // This should be seller's name
        quantity: _order!.quantity,
        languageCode: localization.isEnglish ? 'en' : 'rw',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localization.isEnglish
                ? 'Order accepted successfully!'
                : 'Igicupa cyemewe neza!',
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );

      context.pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to accept order: ${e.toString()}';
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _rejectOrder() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          context.read<LocalizationService>().isEnglish
              ? 'Reject Order?'
              : 'Anga Igicupa?',
        ),
        content: Text(
          context.read<LocalizationService>().isEnglish
              ? 'Are you sure you want to reject this order? This action cannot be undone.'
              : 'Uzi neza ko ushaka kwanga iri gicupa? Ibi ntibizasubizwa inyuma.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              context.read<LocalizationService>().isEnglish ? 'Cancel' : 'Kureka',
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              context.read<LocalizationService>().isEnglish ? 'Reject' : 'Anga',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isUpdating = true;
      _errorMessage = null;
    });

    try {
      final updatedOrder = _order!.copyWith(
        status: 'rejected',
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateOrder(updatedOrder);

      if (!mounted) return;

      final localization = context.read<LocalizationService>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localization.isEnglish
                ? 'Order rejected'
                : 'Igicupa cyanzwe',
          ),
          backgroundColor: Colors.red,
        ),
      );

      context.pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to reject order: ${e.toString()}';
          _isUpdating = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(double amount) {
    return 'RWF ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'in_transit':
        return Colors.purple;
      case 'completed':
        return AppTheme.successGreen;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status, bool isEnglish) {
    switch (status) {
      case 'pending':
        return isEnglish ? 'Pending' : 'Bitegerejwe';
      case 'accepted':
        return isEnglish ? 'Accepted' : 'Byemewe';
      case 'in_transit':
        return isEnglish ? 'In Transit' : 'Mu rugendo';
      case 'completed':
        return isEnglish ? 'Completed' : 'Byarangiye';
      case 'cancelled':
        return isEnglish ? 'Cancelled' : 'Byahagaritswe';
      case 'rejected':
        return isEnglish ? 'Rejected' : 'Byanzwe';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationService>();
    final isEnglish = localization.isEnglish;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEnglish ? 'Order Details' : 'Ibisobanuro by\'Igicupa'),
        ),
        body: const LoadingWidget(message: 'Loading order...'),
      );
    }

    if (_errorMessage != null && _order == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEnglish ? 'Order Details' : 'Ibisobanuro by\'Igicupa'),
        ),
        body: ErrorDisplay(
          message: _errorMessage!,
          onRetry: _loadOrder,
        ),
      );
    }

    final statusColor = _getStatusColor(_order!.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'Order Details' : 'Ibisobanuro by\'Igicupa'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [statusColor, statusColor.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    _order!.status == 'completed'
                        ? Icons.check_circle
                        : _order!.status == 'rejected' || _order!.status == 'cancelled'
                            ? Icons.cancel
                            : Icons.access_time,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getStatusText(_order!.status, isEnglish),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEnglish ? 'Order #${_order!.id.substring(0, 8)}' : 'Igicupa #${_order!.id.substring(0, 8)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Order Information
            _SectionTitle(title: isEnglish ? 'Order Information' : 'Amakuru y\'Igicupa'),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _InfoRow(
                  label: isEnglish ? 'Bean Variety' : 'Ubwoko bw\'Ibishyimbo',
                  value: _order!.beanVariety ?? 'N/A',
                  icon: Icons.grass,
                ),
                _InfoRow(
                  label: isEnglish ? 'Quantity' : 'Umubare',
                  value: '${_order!.quantity.toStringAsFixed(0)} kg',
                  icon: Icons.shopping_basket,
                ),
                _InfoRow(
                  label: isEnglish ? 'Price per kg' : 'Igiciro kuri kg',
                  value: _formatCurrency(_order!.pricePerKg),
                  icon: Icons.attach_money,
                ),
                _InfoRow(
                  label: isEnglish ? 'Total Price' : 'Igiciro cyose',
                  value: _formatCurrency(_order!.totalPrice),
                  icon: Icons.account_balance_wallet,
                  isHighlighted: true,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Buyer Information
            _SectionTitle(title: isEnglish ? 'Buyer Information' : 'Amakuru y\'Umucuruzi'),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _InfoRow(
                  label: isEnglish ? 'Buyer ID' : 'Irangamuntu',
                  value: _order!.buyerId.substring(0, 12) + '...',
                  icon: Icons.person,
                ),
                if (_order!.deliveryAddress != null)
                  _InfoRow(
                    label: isEnglish ? 'Delivery Address' : 'Aho Kugeza',
                    value: _order!.deliveryAddress!,
                    icon: Icons.location_on,
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Dates
            _SectionTitle(title: isEnglish ? 'Timeline' : 'Ibihe'),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _InfoRow(
                  label: isEnglish ? 'Created' : 'Ryakozwe',
                  value: _formatDate(_order!.createdAt),
                  icon: Icons.calendar_today,
                ),
                if (_order!.deliveryDate != null)
                  _InfoRow(
                    label: isEnglish ? 'Delivery Date' : 'Itariki yo Gutanga',
                    value: _formatDate(_order!.deliveryDate!),
                    icon: Icons.event,
                  ),
                _InfoRow(
                  label: isEnglish ? 'Last Updated' : 'Ryavuguruwe',
                  value: _formatDate(_order!.updatedAt),
                  icon: Icons.update,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Notes
            if (_order!.notes != null && _order!.notes!.isNotEmpty) ...[
              _SectionTitle(title: isEnglish ? 'Notes' : 'Ibisobanuro'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _order!.notes!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
            ],

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

            // Action Buttons (only for pending orders)
            if (_order!.status == 'pending') ...[
              CustomButton(
                text: isEnglish ? 'Accept Order' : 'Kwemera Igicupa',
                onPressed: _isUpdating ? null : _acceptOrder,
                isLoading: _isUpdating,
                icon: Icons.check_circle,
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: isEnglish ? 'Reject Order' : 'Kwanga Igicupa',
                onPressed: _isUpdating ? null : _rejectOrder,
                type: ButtonType.outline,
                icon: Icons.cancel,
              ),
            ],

            // Contact Support Button
            if (_order!.status != 'pending') ...[
              CustomButton(
                text: isEnglish ? 'Contact Support' : 'Hamagara Ubufasha',
                onPressed: () {
                  // TODO: Implement contact support
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEnglish
                            ? 'Support contact feature coming soon'
                            : 'Ubufasha buzaza vuba',
                      ),
                    ),
                  );
                },
                type: ButtonType.outline,
                icon: Icons.support_agent,
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isHighlighted;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppTheme.primaryGreen.withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isHighlighted ? AppTheme.primaryGreen : Colors.grey.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                    color: isHighlighted ? AppTheme.primaryGreen : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
