import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/auth_service.dart';
import '../../../services/localization_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final localization = context.watch<LocalizationService>();
    final userModel = authService.userModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('dashboard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              localization.toggleLanguage();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userModel?.email ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userModel?.userType ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(localization.translate('profile')),
              onTap: () {
                // TODO: Navigate to profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(localization.translate('settings')),
              onTap: () {
                // TODO: Navigate to settings
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                localization.translate('logout'),
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await authService.logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      localization.isEnglish
                          ? 'Welcome to iTraceLink!'
                          : 'Murakaza neza kuri iTraceLink!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localization.isEnglish
                          ? 'Your digital solution for biofortified beans traceability'
                          : 'Igisubizo cyawe cya digitale cyo gukurikirana ibishyimbo bigize iron',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localization.isEnglish ? 'Quick Actions' : 'Ibikorwa Byihuse',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildUserSpecificActions(context, userModel?.userType),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSpecificActions(BuildContext context, String? userType) {
    final isEnglish = context.read<LocalizationService>().isEnglish;

    if (userType == AppConstants.userTypeFarmer) {
      final actions = <_QuickAction>[
        _QuickAction(
          Icons.grass,
          isEnglish ? 'Register Planting' : 'Andika Ibyahingwe',
          '/farmer/register-planting',
        ),
        _QuickAction(
          Icons.agriculture,
          isEnglish ? 'Harvest Management' : 'Gucunga Isarura',
          '/farmer/harvest-management',
        ),
        _QuickAction(
          Icons.receipt_long,
          isEnglish ? 'My Orders' : 'Amacupa Yanjye',
          '/farmer/orders',
        ),
        _QuickAction(
          Icons.history,
          isEnglish ? 'Sales History' : 'Amateka y\'Ibicuruzwa',
          '/farmer/sales-history',
        ),
        _QuickAction(
          Icons.trending_up,
          isEnglish ? 'Market Prices' : 'Ibiciro by\'Isoko',
          '/farmer/market-prices',
        ),
      ];

      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: actions
            .map((a) => Card(
                  child: InkWell(
                    onTap: () => context.push(a.route),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(a.icon, size: 36, color: AppTheme.primaryGreen),
                          const SizedBox(height: 8),
                          Text(
                            a.label,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      );
    }

    // The other roles' screens are not built yet (see IMPLEMENTATION_STATUS.md).
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          isEnglish
              ? 'Your tools are coming soon.'
              : 'Ibikoresho byawe biraza vuba.',
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String route;

  const _QuickAction(this.icon, this.label, this.route);
}
