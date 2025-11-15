import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Specific empty states

class NoOrdersEmpty extends StatelessWidget {
  final VoidCallback? onCreateOrder;

  const NoOrdersEmpty({super.key, this.onCreateOrder});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.shopping_bag_outlined,
      title: 'No Orders Yet',
      message: 'You don\'t have any orders at the moment. Start by browsing available products.',
      actionLabel: onCreateOrder != null ? 'Browse Products' : null,
      onAction: onCreateOrder,
    );
  }
}

class NoNotificationsEmpty extends StatelessWidget {
  const NoNotificationsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.notifications_none,
      title: 'No Notifications',
      message: 'You\'re all caught up! No new notifications at this time.',
    );
  }
}

class NoSearchResultsEmpty extends StatelessWidget {
  final String? searchQuery;

  const NoSearchResultsEmpty({super.key, this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: searchQuery != null
          ? 'No results found for "$searchQuery". Try different keywords.'
          : 'No results found. Try adjusting your search.',
    );
  }
}

class NoFarmersAvailableEmpty extends StatelessWidget {
  final VoidCallback? onRefresh;

  const NoFarmersAvailableEmpty({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.agriculture,
      title: 'No Farmers Available',
      message: 'No farmers with iron beans are available at the moment. Check back later.',
      actionLabel: onRefresh != null ? 'Refresh' : null,
      onAction: onRefresh,
    );
  }
}
