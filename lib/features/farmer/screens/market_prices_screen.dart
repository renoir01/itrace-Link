import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/localization_service.dart';
import '../../../widgets/loading_widget.dart';

// Mock market price data (in production, fetch from Firestore/API)
class MarketPrice {
  final String beanVariety;
  final double currentPrice;
  final double previousPrice;
  final DateTime lastUpdated;
  final String district;

  MarketPrice({
    required this.beanVariety,
    required this.currentPrice,
    required this.previousPrice,
    required this.lastUpdated,
    required this.district,
  });

  double get priceChange => currentPrice - previousPrice;
  double get priceChangePercent => (priceChange / previousPrice) * 100;
  bool get isPriceIncreasing => priceChange > 0;
}

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  bool _isLoading = false;
  String _selectedDistrict = 'all';

  // Mock market prices (in production, fetch from Firestore)
  final List<MarketPrice> _marketPrices = [
    MarketPrice(
      beanVariety: 'RWR 2245 (High Iron)',
      currentPrice: 850,
      previousPrice: 820,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
      district: 'Kigali',
    ),
    MarketPrice(
      beanVariety: 'MAC 42 (High Iron)',
      currentPrice: 830,
      previousPrice: 850,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 3)),
      district: 'Kigali',
    ),
    MarketPrice(
      beanVariety: 'RWR 10 (High Iron)',
      currentPrice: 840,
      previousPrice: 830,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
      district: 'Eastern Province',
    ),
    MarketPrice(
      beanVariety: 'RWV 1129 (High Iron)',
      currentPrice: 860,
      previousPrice: 840,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 4)),
      district: 'Eastern Province',
    ),
    MarketPrice(
      beanVariety: 'MAC 44 (High Iron)',
      currentPrice: 870,
      previousPrice: 870,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 5)),
      district: 'Northern Province',
    ),
    MarketPrice(
      beanVariety: 'RWR 2245 (High Iron)',
      currentPrice: 845,
      previousPrice: 830,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
      district: 'Southern Province',
    ),
  ];

  List<String> get _districts {
    final districts = _marketPrices.map((p) => p.district).toSet().toList();
    districts.sort();
    return ['all', ...districts];
  }

  List<MarketPrice> get _filteredPrices {
    if (_selectedDistrict == 'all') {
      return _marketPrices;
    }
    return _marketPrices.where((p) => p.district == _selectedDistrict).toList();
  }

  Map<String, double> get _priceStats {
    final prices = _filteredPrices.map((p) => p.currentPrice).toList();
    if (prices.isEmpty) {
      return {'average': 0, 'highest': 0, 'lowest': 0};
    }

    final average = prices.reduce((a, b) => a + b) / prices.length;
    final highest = prices.reduce((a, b) => a > b ? a : b);
    final lowest = prices.reduce((a, b) => a < b ? a : b);

    return {'average': average, 'highest': highest, 'lowest': lowest};
  }

  String _formatCurrency(double amount) {
    return 'RWF ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  String _formatTimeAgo(DateTime dateTime, bool isEnglish) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return isEnglish
          ? '${difference.inMinutes} min ago'
          : 'Iminota ${difference.inMinutes} ishize';
    } else if (difference.inHours < 24) {
      return isEnglish ? '${difference.inHours}h ago' : 'Amasaha ${difference.inHours} ashize';
    } else {
      return isEnglish ? '${difference.inDays}d ago' : 'Iminsi ${difference.inDays} ishize';
    }
  }

  Future<void> _refreshPrices() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocalizationService>().isEnglish
                ? 'Prices updated'
                : 'Ibiciro byavuguruwe',
          ),
          backgroundColor: AppTheme.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationService>();
    final isEnglish = localization.isEnglish;
    final stats = _priceStats;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'Market Prices' : 'Ibiciro by\'Isoko'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryGreen,
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshPrices,
            tooltip: isEnglish ? 'Refresh prices' : 'Vugurura ibiciro',
          ),
        ],
      ),
      body: Column(
        children: [
          // Price Stats
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: isEnglish ? 'Average' : 'Ikigereranyo',
                  value: _formatCurrency(stats['average']!),
                  icon: Icons.show_chart,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                _StatItem(
                  label: isEnglish ? 'Highest' : 'Kinini',
                  value: _formatCurrency(stats['highest']!),
                  icon: Icons.trending_up,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                _StatItem(
                  label: isEnglish ? 'Lowest' : 'Gito',
                  value: _formatCurrency(stats['lowest']!),
                  icon: Icons.trending_down,
                ),
              ],
            ),
          ),

          // District Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEnglish ? 'Filter by District' : 'Hitamo Akarere',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _districts.map((district) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _FilterChip(
                          label: district == 'all'
                              ? (isEnglish ? 'All Districts' : 'Uturere twose')
                              : district,
                          isSelected: _selectedDistrict == district,
                          onTap: () {
                            setState(() {
                              _selectedDistrict = district;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Info Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isEnglish
                        ? 'Prices are updated hourly and may vary by location'
                        : 'Ibiciro bivugururwa buri saha kandi birashobora gutandukana',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Market Prices List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshPrices,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredPrices.length,
                itemBuilder: (context, index) {
                  final price = _filteredPrices[index];
                  return _PriceCard(
                    price: price,
                    isEnglish: isEnglish,
                    formatCurrency: _formatCurrency,
                    formatTimeAgo: _formatTimeAgo,
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
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
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

class _PriceCard extends StatelessWidget {
  final MarketPrice price;
  final bool isEnglish;
  final String Function(double) formatCurrency;
  final String Function(DateTime, bool) formatTimeAgo;

  const _PriceCard({
    required this.price,
    required this.isEnglish,
    required this.formatCurrency,
    required this.formatTimeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final changeColor = price.isPriceIncreasing ? Colors.green : Colors.red;
    final changeIcon = price.isPriceIncreasing ? Icons.trending_up : Icons.trending_down;

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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        price.beanVariety,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            price.district,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Price Change Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: changeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(changeIcon, color: changeColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${price.priceChangePercent >= 0 ? '+' : ''}${price.priceChangePercent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: changeColor,
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

            // Price Information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Current Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnglish ? 'Current Price' : 'Igiciro cy\'Ubu',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatCurrency(price.currentPrice)}/kg',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),

                // Previous Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isEnglish ? 'Previous' : 'Gishize',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatCurrency(price.previousPrice)}/kg',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Last Updated
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  '${isEnglish ? 'Updated' : 'Vyavuguruwe'} ${formatTimeAgo(price.lastUpdated, isEnglish)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
