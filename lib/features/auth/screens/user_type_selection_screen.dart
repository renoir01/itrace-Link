import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/localization_service.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('select_user_type')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              localization.toggleLanguage();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildUserTypeCard(
                      context,
                      icon: Icons.business,
                      title: localization.isEnglish
                          ? 'Seed Producer'
                          : 'Umushoramari w\'Imbuto',
                      description: localization.isEnglish
                          ? 'Research institutions and seed companies producing certified iron-biofortified beans'
                          : 'Ibigo by\'ubushakashatsi n\'amasosiyete atanga imbuto zemejwe z\'ibishyimbo bigize iron',
                      userType: AppConstants.userTypeSeedProducer,
                    ),
                    const SizedBox(height: 12),
                    _buildUserTypeCard(
                      context,
                      icon: Icons.store,
                      title: localization.isEnglish
                          ? 'Agro-Dealer'
                          : 'Ucuruza Imbuto',
                      description: localization.isEnglish
                          ? 'Input suppliers who stock and sell certified iron-biofortified bean seeds'
                          : 'Abagurisha ibikoresho by\'ubuhinzi bakunda no kugurisha imbuto z\'ibishyimbo bigize iron',
                      userType: AppConstants.userTypeAgroDealer,
                    ),
                    const SizedBox(height: 12),
                    _buildUserTypeCard(
                      context,
                      icon: Icons.people,
                      title: localization.isEnglish
                          ? 'Farmer Cooperative'
                          : 'Koperative y\'Abahinzi',
                      description: localization.isEnglish
                          ? 'Bean farmers organized in cooperatives growing iron-biofortified beans'
                          : 'Abahinzi b\'ibishyimbo bateraniye mu koperative bahinga ibishyimbo bigize iron',
                      userType: AppConstants.userTypeFarmer,
                    ),
                    const SizedBox(height: 12),
                    _buildUserTypeCard(
                      context,
                      icon: Icons.local_shipping,
                      title: localization.isEnglish
                          ? 'Aggregator'
                          : 'Uwegeranya',
                      description: localization.isEnglish
                          ? 'Traders who collect beans from cooperatives and sell in bulk to institutions'
                          : 'Abacuruzi bakusanya ibishyimbo mu koperative bagurisha amasosiyete',
                      userType: AppConstants.userTypeAggregator,
                    ),
                    const SizedBox(height: 12),
                    _buildUserTypeCard(
                      context,
                      icon: Icons.account_balance,
                      title: localization.isEnglish
                          ? 'School / Hospital'
                          : 'Ishuri / Ibitaro',
                      description: localization.isEnglish
                          ? 'Schools with feeding programs and hospitals purchasing iron beans in bulk'
                          : 'Amashuri afite gahunda zo kurisha n\'ibitaro biguza ibishyimbo mu bunini',
                      userType: AppConstants.userTypeInstitution,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.go('/login');
                },
                child: Text(
                  localization.isEnglish
                      ? 'Already have an account? Login'
                      : 'Usanzwe ufite konti? Injira',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String userType,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.go('/registration', extra: userType);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
