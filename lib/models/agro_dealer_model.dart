import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class AgroDealerModel {
  final String id;
  final String userId;
  final String businessName;
  final String licenseNumber;
  final AddressModel location;
  final String phone;
  final String email;
  final String seedProducerId; // Reference to seed producer
  final List<SeedInventory> inventory;
  final String? profileImageUrl;
  final bool isVerified;
  final String? tinNumber;
  final String contactPerson;
  final List<String> authorizedSeedProducers;
  final List<String> documents;
  final double rating;
  final double totalSales;
  final DateTime? updatedAt;
  final DateTime createdAt;

  AgroDealerModel({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.licenseNumber,
    required this.location,
    required this.phone,
    required this.email,
    this.seedProducerId = '',
    this.inventory = const [],
    this.profileImageUrl,
    this.isVerified = false,
    this.tinNumber,
    this.contactPerson = '',
    this.authorizedSeedProducers = const [],
    this.documents = const [],
    this.rating = 0.0,
    this.totalSales = 0.0,
    this.updatedAt,
    required this.createdAt,
  });

  factory AgroDealerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AgroDealerModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      businessName: data['businessName'] ?? '',
      licenseNumber: data['licenseNumber'] ?? '',
      location: AddressModel.fromMap(data['location'] ?? {}),
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      seedProducerId: data['seedProducerId'] ?? '',
      inventory: (data['inventory'] as List<dynamic>?)
              ?.map((item) => SeedInventory.fromMap(item))
              .toList() ??
          [],
      profileImageUrl: data['profileImageUrl'],
      isVerified: data['isVerified'] ?? false,
      tinNumber: data['tinNumber'],
      contactPerson: data['contactPerson'] ?? '',
      authorizedSeedProducers: List<String>.from(data['authorizedSeedProducers'] ?? []),
      documents: List<String>.from(data['documents'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      totalSales: (data['totalSales'] ?? 0).toDouble(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'businessName': businessName,
      'licenseNumber': licenseNumber,
      'location': location.toMap(),
      'phone': phone,
      'email': email,
      'seedProducerId': seedProducerId,
      'inventory': inventory.map((item) => item.toMap()).toList(),
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      if (tinNumber != null) 'tinNumber': tinNumber,
      'contactPerson': contactPerson,
      'authorizedSeedProducers': authorizedSeedProducers,
      'documents': documents,
      'rating': rating,
      'totalSales': totalSales,
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AgroDealerModel copyWith({
    String? businessName,
    String? licenseNumber,
    AddressModel? location,
    String? phone,
    String? email,
    String? seedProducerId,
    List<SeedInventory>? inventory,
    String? profileImageUrl,
    bool? isVerified,
    String? tinNumber,
    String? contactPerson,
    List<String>? authorizedSeedProducers,
    List<String>? documents,
    double? rating,
    double? totalSales,
    DateTime? updatedAt,
  }) {
    return AgroDealerModel(
      id: id,
      userId: userId,
      businessName: businessName ?? this.businessName,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      seedProducerId: seedProducerId ?? this.seedProducerId,
      inventory: inventory ?? this.inventory,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      tinNumber: tinNumber ?? this.tinNumber,
      contactPerson: contactPerson ?? this.contactPerson,
      authorizedSeedProducers: authorizedSeedProducers ?? this.authorizedSeedProducers,
      documents: documents ?? this.documents,
      rating: rating ?? this.rating,
      totalSales: totalSales ?? this.totalSales,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt,
    );
  }

  // Get total inventory quantity
  double get totalInventoryQuantity {
    return inventory.fold(0.0, (sum, item) => sum + item.quantity);
  }

  // Check if inventory is low (less than 100kg total)
  bool get isInventoryLow => totalInventoryQuantity < 100;
}

class SeedInventory {
  final String seedVariety;
  final double quantity; // in kg
  final String batchNumber;
  final DateTime expiryDate;
  final double pricePerKg;

  SeedInventory({
    required this.seedVariety,
    required this.quantity,
    required this.batchNumber,
    required this.expiryDate,
    required this.pricePerKg,
  });

  factory SeedInventory.fromMap(Map<String, dynamic> map) {
    return SeedInventory(
      seedVariety: map['seedVariety'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      batchNumber: map['batchNumber'] ?? '',
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      pricePerKg: (map['pricePerKg'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'seedVariety': seedVariety,
      'quantity': quantity,
      'batchNumber': batchNumber,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'pricePerKg': pricePerKg,
    };
  }

  // Check if seed is expired or expiring soon (within 30 days)
  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isExpiringSoon =>
      DateTime.now().isAfter(expiryDate.subtract(const Duration(days: 30)));

  String get status {
    if (isExpired) return 'expired';
    if (isExpiringSoon) return 'expiring_soon';
    return 'good';
  }
}
