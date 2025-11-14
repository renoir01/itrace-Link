import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }

    return card;
  }
}

// Order card
class OrderCard extends StatelessWidget {
  final String orderId;
  final String buyerName;
  final double quantity;
  final double pricePerKg;
  final String status;
  final DateTime requestDate;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.buyerName,
    required this.quantity,
    required this.pricePerKg,
    required this.status,
    required this.requestDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  buyerName,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusChip(status: status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.shopping_bag, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                '${quantity.toStringAsFixed(0)} kg',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 24),
              Icon(Icons.attach_money, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                '${pricePerKg.toStringAsFixed(0)} RWF/kg',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                _formatDate(requestDate),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Farmer/Cooperative card
class FarmerCard extends StatelessWidget {
  final String name;
  final String location;
  final double availableQuantity;
  final double pricePerKg;
  final DateTime? harvestDate;
  final String? imageUrl;
  final VoidCallback? onTap;

  const FarmerCard({
    super.key,
    required this.name,
    required this.location,
    required this.availableQuantity,
    required this.pricePerKg,
    this.harvestDate,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
            child: imageUrl == null
                ? const Icon(Icons.agriculture, size: 30, color: AppTheme.primaryGreen)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${availableQuantity.toStringAsFixed(0)} kg',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${pricePerKg.toStringAsFixed(0)} RWF/kg',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}

// Notification card
class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String timeAgo;
  final bool isRead;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isRead = false,
    this.icon = Icons.notifications,
    this.iconColor = AppTheme.primaryGreen,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      color: isRead ? null : AppTheme.primaryGreen.withOpacity(0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
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

// Status chip
class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = AppTheme.warningYellow.withOpacity(0.2);
        textColor = Colors.orange[900]!;
        break;
      case 'accepted':
      case 'completed':
      case 'delivered':
        backgroundColor = AppTheme.successGreen.withOpacity(0.2);
        textColor = AppTheme.successGreen;
        break;
      case 'rejected':
      case 'cancelled':
        backgroundColor = AppTheme.errorRed.withOpacity(0.2);
        textColor = AppTheme.errorRed;
        break;
      case 'in_transit':
      case 'processing':
        backgroundColor = AppTheme.accentBlue.withOpacity(0.2);
        textColor = AppTheme.accentBlue;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// Info card
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const InfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, size: 32, color: iconColor ?? AppTheme.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
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
