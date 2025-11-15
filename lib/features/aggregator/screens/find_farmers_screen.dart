import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/cooperative_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/localization_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/custom_card.dart';

class FindFarmersScreen extends StatefulWidget {
  const FindFarmersScreen({super.key});

  @override
  State<FindFarmersScreen> createState() => _FindFarmersScreenState();
}

class _FindFarmersScreenState extends State<FindFarmersScreen> {
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<CooperativeModel> _allCooperatives = [];
  List<CooperativeModel> _filteredCooperatives = [];

  // Filter states
  String? _selectedDistrict;
  double? _minQuantity;
  String? _selectedVariety;
  String _sortBy = 'distance'; // distance, price, quantity, rating

  // Districts for filtering
  final List<String> _districts = [
    'Kigali',
    'Eastern Province',
    'Northern Province',
    'Southern Province',
    'Western Province',
  ];

  // Bean varieties
  final List<String> _varieties = [
    'All Varieties',
    'RWR 2245 (High Iron)',
    'MAC 42 (High Iron)',
    'RWR 10 (High Iron)',
    'RWV 1129 (High Iron)',
    'MAC 44 (High Iron)',
  ];

  @override
  void initState() {
    super.initState();
    _loadFarmers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFarmers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get all cooperatives with available harvests
      final cooperativesStream = _firestoreService.getAvailableCooperatives(
        district: _selectedDistrict,
        minQuantity: _minQuantity,
      );

      cooperativesStream.listen((cooperatives) {
        if (mounted) {
          setState(() {
            _allCooperatives = cooperatives;
            _applyFilters();
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load farmers: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    var filtered = List<CooperativeModel>.from(_allCooperatives);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((coop) {
        return coop.cooperativeName.toLowerCase().contains(query) ||
            coop.location['district']?.toLowerCase().contains(query) == true;
      }).toList();
    }

    // Apply variety filter
    if (_selectedVariety != null && _selectedVariety != 'All Varieties') {
      filtered = filtered.where((coop) {
        return coop.harvestRecords.any((harvest) =>
          harvest.beanVariety == _selectedVariety && harvest.isAvailable
        );
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'price':
        filtered.sort((a, b) => _getAveragePrice(a).compareTo(_getAveragePrice(b)));
        break;
      case 'quantity':
        filtered.sort((a, b) => _getTotalAvailable(b).compareTo(_getTotalAvailable(a)));
        break;
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'distance':
      default:
        // Would use GPS distance in production
        break;
    }

    setState(() {
      _filteredCooperatives = filtered;
    });
  }

  double _getTotalAvailable(CooperativeModel coop) {
    return coop.harvestRecords
        .where((h) => h.isAvailable)
        .fold(0.0, (sum, harvest) => sum + harvest.quantity);
  }

  double _getAveragePrice(CooperativeModel coop) {
    // Mock price calculation (in production, get from market data)
    return 850.0;
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        selectedDistrict: _selectedDistrict,
        minQuantity: _minQuantity,
        selectedVariety: _selectedVariety,
        sortBy: _sortBy,
        districts: _districts,
        varieties: _varieties,
        onApply: (district, quantity, variety, sort) {
          setState(() {
            _selectedDistrict = district;
            _minQuantity = quantity;
            _selectedVariety = variety;
            _sortBy = sort;
          });
          _loadFarmers();
        },
        onReset: () {
          setState(() {
            _selectedDistrict = null;
            _minQuantity = null;
            _selectedVariety = null;
            _sortBy = 'distance';
          });
          _loadFarmers();
        },
      ),
    );
  }

  void _navigateToCooperativeDetails(CooperativeModel cooperative) {
    context.push('/aggregator/cooperative/${cooperative.id}', extra: cooperative);
  }

  String _formatCurrency(double amount) {
    return 'RWF ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationService>();
    final isEnglish = localization.isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'Find Farmers' : 'Shakisha Abahinzi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFarmers,
            tooltip: isEnglish ? 'Refresh' : 'Ongera utangire',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: isEnglish ? 'Search cooperatives...' : 'Shakisha ikoperative...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _applyFilters();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) => _applyFilters(),
                  ),
                ),
                const SizedBox(width: 12),
                // Filter Button
                Container(
                  decoration: BoxDecoration(
                    color: (_selectedDistrict != null || _minQuantity != null || _selectedVariety != null)
                        ? AppTheme.primaryGreen
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: (_selectedDistrict != null || _minQuantity != null || _selectedVariety != null)
                          ? Colors.white
                          : Colors.black87,
                    ),
                    onPressed: _showFilters,
                    tooltip: isEnglish ? 'Filters' : 'Muyunguruzi',
                  ),
                ),
              ],
            ),
          ),

          // Results Count & Sort
          if (!_isLoading && _filteredCooperatives.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEnglish
                        ? '${_filteredCooperatives.length} cooperatives found'
                        : 'Ikoperative ${_filteredCooperatives.length} zabonetse',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showFilters,
                    icon: const Icon(Icons.sort, size: 18),
                    label: Text(
                      isEnglish ? 'Sort by: $_sortBy' : 'Itondekanya: $_sortBy',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),

          // Cooperatives List
          Expanded(
            child: _isLoading
                ? const LoadingWidget(message: 'Loading cooperatives...')
                : _errorMessage != null
                    ? ErrorDisplay(
                        message: _errorMessage!,
                        onRetry: _loadFarmers,
                      )
                    : _filteredCooperatives.isEmpty
                        ? EmptyStateWidget(
                            icon: Icons.search_off,
                            title: isEnglish ? 'No Farmers Found' : 'Nta bahinzi Babonetse',
                            message: isEnglish
                                ? 'Try adjusting your search or filters'
                                : 'Gerageza guhindura ishakisha cyangwa muyunguruzi',
                            actionLabel: isEnglish ? 'Reset Filters' : 'Subiramo Muyunguruzi',
                            onAction: () {
                              setState(() {
                                _selectedDistrict = null;
                                _minQuantity = null;
                                _selectedVariety = null;
                                _sortBy = 'distance';
                                _searchController.clear();
                              });
                              _loadFarmers();
                            },
                          )
                        : RefreshIndicator(
                            onRefresh: _loadFarmers,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filteredCooperatives.length,
                              itemBuilder: (context, index) {
                                final cooperative = _filteredCooperatives[index];
                                final location = '${cooperative.location['district']}, ${cooperative.location['sector']}';
                                return FarmerCard(
                                  name: cooperative.cooperativeName,
                                  location: location,
                                  availableQuantity: _getTotalAvailable(cooperative),
                                  pricePerKg: _getAveragePrice(cooperative),
                                  imageUrl: cooperative.profileImageUrl,
                                  onTap: () => _navigateToCooperativeDetails(cooperative),
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

class _FilterBottomSheet extends StatefulWidget {
  final String? selectedDistrict;
  final double? minQuantity;
  final String? selectedVariety;
  final String sortBy;
  final List<String> districts;
  final List<String> varieties;
  final Function(String?, double?, String?, String) onApply;
  final VoidCallback onReset;

  const _FilterBottomSheet({
    required this.selectedDistrict,
    required this.minQuantity,
    required this.selectedVariety,
    required this.sortBy,
    required this.districts,
    required this.varieties,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String? _district;
  late double? _quantity;
  late String? _variety;
  late String _sort;

  @override
  void initState() {
    super.initState();
    _district = widget.selectedDistrict;
    _quantity = widget.minQuantity;
    _variety = widget.selectedVariety;
    _sort = widget.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationService>();
    final isEnglish = localization.isEnglish;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEnglish ? 'Filters & Sort' : 'Muyunguruzi na Gushungura',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onReset();
                    Navigator.pop(context);
                  },
                  child: Text(isEnglish ? 'Reset' : 'Subiramo'),
                ),
              ],
            ),
          ),
          const Divider(),

          // Filters Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // District Filter
                Text(
                  isEnglish ? 'District' : 'Akarere',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: Text(isEnglish ? 'All' : 'Byose'),
                      selected: _district == null,
                      onSelected: (selected) {
                        setState(() {
                          _district = null;
                        });
                      },
                      selectedColor: AppTheme.primaryGreen.withOpacity(0.3),
                    ),
                    ...widget.districts.map((district) {
                      return FilterChip(
                        label: Text(district),
                        selected: _district == district,
                        onSelected: (selected) {
                          setState(() {
                            _district = selected ? district : null;
                          });
                        },
                        selectedColor: AppTheme.primaryGreen.withOpacity(0.3),
                      );
                    }).toList(),
                  ],
                ),
                const SizedBox(height: 24),

                // Variety Filter
                Text(
                  isEnglish ? 'Bean Variety' : 'Ubwoko bw\'Ibishyimbo',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _variety ?? 'All Varieties',
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: widget.varieties.map((variety) {
                    return DropdownMenuItem(
                      value: variety,
                      child: Text(variety),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _variety = value == 'All Varieties' ? null : value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Sort By
                Text(
                  isEnglish ? 'Sort By' : 'Itondekanya',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(isEnglish ? 'Distance' : 'Intera'),
                      selected: _sort == 'distance',
                      onSelected: (selected) {
                        setState(() {
                          _sort = 'distance';
                        });
                      },
                      selectedColor: AppTheme.primaryGreen.withOpacity(0.3),
                    ),
                    ChoiceChip(
                      label: Text(isEnglish ? 'Price' : 'Igiciro'),
                      selected: _sort == 'price',
                      onSelected: (selected) {
                        setState(() {
                          _sort = 'price';
                        });
                      },
                      selectedColor: AppTheme.primaryGreen.withOpacity(0.3),
                    ),
                    ChoiceChip(
                      label: Text(isEnglish ? 'Quantity' : 'Umubare'),
                      selected: _sort == 'quantity',
                      onSelected: (selected) {
                        setState(() {
                          _sort = 'quantity';
                        });
                      },
                      selectedColor: AppTheme.primaryGreen.withOpacity(0.3),
                    ),
                    ChoiceChip(
                      label: Text(isEnglish ? 'Rating' : 'Amanota'),
                      selected: _sort == 'rating',
                      onSelected: (selected) {
                        setState(() {
                          _sort = 'rating';
                        });
                      },
                      selectedColor: AppTheme.primaryGreen.withOpacity(0.3),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_district, _quantity, _variety, _sort);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isEnglish ? 'Apply Filters' : 'Emera Muyunguruzi',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
