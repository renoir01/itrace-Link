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
  final DateTime createdAt;

  AgroDealerModel({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.licenseNumber,
    required this.location,
    required this.phone,
    required this.email,
    required this.seedProducerId,
    this.inventory = const [],
    this.profileImageUrl,
    this.isVerified = false,
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
