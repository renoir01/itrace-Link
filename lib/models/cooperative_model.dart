import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class CooperativeModel {
  final String id;
  final String userId;
  final String cooperativeName;
  final String registrationNumber;
  final int numberOfMembers;
  final AddressModel location;
  final String contactPerson;
  final String phone;
  final String email;
  final String? profileImageUrl;
  final List<String> documents;
  final AgroDealerPurchase? agroDealerPurchase;
  final PlantingInfo? plantingInfo;
  final HarvestInfo? harvestInfo;
  final double totalArea; // hectares, sum of all plantings
  final List<PlantingRecord> plantingRecords;
  final List<HarvestRecord> harvestRecords;
  final double pricePerKg;
  final bool availableForSale;
  final bool isVerified;
  final double rating;
  final double totalSales;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CooperativeModel({
    required this.id,
    this.userId = '',
    required this.cooperativeName,
    required this.registrationNumber,
    required this.numberOfMembers,
    required this.location,
    required this.contactPerson,
    required this.phone,
    this.email = '',
    this.profileImageUrl,
    this.documents = const [],
    this.agroDealerPurchase,
    this.plantingInfo,
    this.harvestInfo,
    this.totalArea = 0.0,
    this.plantingRecords = const [],
    this.harvestRecords = const [],
    this.pricePerKg = 0.0,
    this.availableForSale = false,
    this.isVerified = false,
    this.rating = 0.0,
    this.totalSales = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory CooperativeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CooperativeModel(
      id: doc.id,
      userId: data['userId'] ?? doc.id,
      cooperativeName: data['cooperativeName'] ?? '',
      registrationNumber: data['registrationNumber'] ?? '',
      numberOfMembers: data['numberOfMembers'] ?? 0,
      location: AddressModel.fromMap(
          Map<String, dynamic>.from(data['location'] ?? {})),
      contactPerson: data['contactPerson'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      documents: List<String>.from(data['documents'] ?? []),
      agroDealerPurchase: data['agroDealerPurchase'] != null
          ? AgroDealerPurchase.fromMap(
              Map<String, dynamic>.from(data['agroDealerPurchase']))
          : null,
      plantingInfo: data['plantingInfo'] != null
          ? PlantingInfo.fromMap(Map<String, dynamic>.from(data['plantingInfo']))
          : null,
      harvestInfo: data['harvestInfo'] != null
          ? HarvestInfo.fromMap(Map<String, dynamic>.from(data['harvestInfo']))
          : null,
      totalArea: (data['totalArea'] ?? 0).toDouble(),
      plantingRecords: (data['plantingRecords'] as List<dynamic>? ?? [])
          .map((e) => PlantingRecord.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      harvestRecords: (data['harvestRecords'] as List<dynamic>? ?? [])
          .map((e) => HarvestRecord.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      pricePerKg: (data['pricePerKg'] ?? 0).toDouble(),
      availableForSale: data['availableForSale'] ?? false,
      isVerified: data['isVerified'] ?? false,
      rating: (data['rating'] ?? 0).toDouble(),
      totalSales: (data['totalSales'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId.isEmpty ? id : userId,
      'cooperativeName': cooperativeName,
      'registrationNumber': registrationNumber,
      'numberOfMembers': numberOfMembers,
      'location': location.toMap(),
      'contactPerson': contactPerson,
      'phone': phone,
      'email': email,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'documents': documents,
      if (agroDealerPurchase != null)
        'agroDealerPurchase': agroDealerPurchase!.toMap(),
      if (plantingInfo != null) 'plantingInfo': plantingInfo!.toMap(),
      if (harvestInfo != null) 'harvestInfo': harvestInfo!.toMap(),
      'totalArea': totalArea,
      'plantingRecords': plantingRecords.map((e) => e.toMap()).toList(),
      'harvestRecords': harvestRecords.map((e) => e.toMap()).toList(),
      'pricePerKg': pricePerKg,
      'availableForSale': availableForSale,
      'isVerified': isVerified,
      'rating': rating,
      'totalSales': totalSales,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
    };
  }

  CooperativeModel copyWith({
    String? cooperativeName,
    String? registrationNumber,
    int? numberOfMembers,
    AddressModel? location,
    String? contactPerson,
    String? phone,
    String? email,
    String? profileImageUrl,
    List<String>? documents,
    AgroDealerPurchase? agroDealerPurchase,
    PlantingInfo? plantingInfo,
    HarvestInfo? harvestInfo,
    double? totalArea,
    List<PlantingRecord>? plantingRecords,
    List<HarvestRecord>? harvestRecords,
    double? pricePerKg,
    bool? availableForSale,
    bool? isVerified,
    double? rating,
    double? totalSales,
    DateTime? updatedAt,
  }) {
    return CooperativeModel(
      id: id,
      userId: userId,
      cooperativeName: cooperativeName ?? this.cooperativeName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      numberOfMembers: numberOfMembers ?? this.numberOfMembers,
      location: location ?? this.location,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      documents: documents ?? this.documents,
      agroDealerPurchase: agroDealerPurchase ?? this.agroDealerPurchase,
      plantingInfo: plantingInfo ?? this.plantingInfo,
      harvestInfo: harvestInfo ?? this.harvestInfo,
      totalArea: totalArea ?? this.totalArea,
      plantingRecords: plantingRecords ?? this.plantingRecords,
      harvestRecords: harvestRecords ?? this.harvestRecords,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      availableForSale: availableForSale ?? this.availableForSale,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      totalSales: totalSales ?? this.totalSales,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AgroDealerPurchase {
  final String dealerId;
  final String seedBatch;
  final double quantity;
  final DateTime purchaseDate;

  AgroDealerPurchase({
    required this.dealerId,
    required this.seedBatch,
    required this.quantity,
    required this.purchaseDate,
  });

  factory AgroDealerPurchase.fromMap(Map<String, dynamic> map) {
    return AgroDealerPurchase(
      dealerId: map['dealerId'] ?? '',
      seedBatch: map['seedBatch'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      purchaseDate: (map['purchaseDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dealerId': dealerId,
      'seedBatch': seedBatch,
      'quantity': quantity,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
    };
  }
}

class PlantingInfo {
  final DateTime plantingDate;
  final double landArea;
  final DateTime expectedHarvestDate;

  PlantingInfo({
    required this.plantingDate,
    required this.landArea,
    required this.expectedHarvestDate,
  });

  factory PlantingInfo.fromMap(Map<String, dynamic> map) {
    return PlantingInfo(
      plantingDate: (map['plantingDate'] as Timestamp).toDate(),
      landArea: (map['landArea'] ?? 0).toDouble(),
      expectedHarvestDate: (map['expectedHarvestDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantingDate': Timestamp.fromDate(plantingDate),
      'landArea': landArea,
      'expectedHarvestDate': Timestamp.fromDate(expectedHarvestDate),
    };
  }
}

class HarvestInfo {
  final double expectedQuantity;
  final double actualQuantity;
  final DateTime? harvestDate;
  final String storageLocation;

  HarvestInfo({
    required this.expectedQuantity,
    required this.actualQuantity,
    this.harvestDate,
    required this.storageLocation,
  });

  factory HarvestInfo.fromMap(Map<String, dynamic> map) {
    return HarvestInfo(
      expectedQuantity: (map['expectedQuantity'] ?? 0).toDouble(),
      actualQuantity: (map['actualQuantity'] ?? 0).toDouble(),
      harvestDate: map['harvestDate'] != null
          ? (map['harvestDate'] as Timestamp).toDate()
          : null,
      storageLocation: map['storageLocation'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'expectedQuantity': expectedQuantity,
      'actualQuantity': actualQuantity,
      if (harvestDate != null) 'harvestDate': Timestamp.fromDate(harvestDate!),
      'storageLocation': storageLocation,
    };
  }
}


/// One planting event registered by a cooperative.
class PlantingRecord {
  final String id;
  final String beanVariety;
  final double areaPlanted; // hectares
  final DateTime plantingDate;
  final DateTime expectedHarvestDate;
  final String status; // 'active' | 'harvested'
  final String? notes;

  PlantingRecord({
    required this.id,
    required this.beanVariety,
    required this.areaPlanted,
    required this.plantingDate,
    required this.expectedHarvestDate,
    this.status = 'active',
    this.notes,
  });

  factory PlantingRecord.fromMap(Map<String, dynamic> map) {
    return PlantingRecord(
      id: map['id'] ?? '',
      beanVariety: map['beanVariety'] ?? '',
      areaPlanted: (map['areaPlanted'] ?? 0).toDouble(),
      plantingDate: (map['plantingDate'] as Timestamp).toDate(),
      expectedHarvestDate: (map['expectedHarvestDate'] as Timestamp).toDate(),
      status: map['status'] ?? 'active',
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'beanVariety': beanVariety,
      'areaPlanted': areaPlanted,
      'plantingDate': Timestamp.fromDate(plantingDate),
      'expectedHarvestDate': Timestamp.fromDate(expectedHarvestDate),
      'status': status,
      if (notes != null) 'notes': notes,
    };
  }

  PlantingRecord copyWith({String? status, String? notes}) {
    return PlantingRecord(
      id: id,
      beanVariety: beanVariety,
      areaPlanted: areaPlanted,
      plantingDate: plantingDate,
      expectedHarvestDate: expectedHarvestDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

/// One harvest recorded against a planting.
class HarvestRecord {
  final String id;
  final String plantingId;
  final String beanVariety;
  final double quantity; // kg
  final DateTime harvestDate;
  final String quality; // excellent | good | fair | poor
  final bool isAvailable;
  final String? notes;

  HarvestRecord({
    required this.id,
    required this.plantingId,
    required this.beanVariety,
    required this.quantity,
    required this.harvestDate,
    this.quality = 'good',
    this.isAvailable = true,
    this.notes,
  });

  factory HarvestRecord.fromMap(Map<String, dynamic> map) {
    return HarvestRecord(
      id: map['id'] ?? '',
      plantingId: map['plantingId'] ?? '',
      beanVariety: map['beanVariety'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      harvestDate: (map['harvestDate'] as Timestamp).toDate(),
      quality: map['quality'] ?? 'good',
      isAvailable: map['isAvailable'] ?? true,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plantingId': plantingId,
      'beanVariety': beanVariety,
      'quantity': quantity,
      'harvestDate': Timestamp.fromDate(harvestDate),
      'quality': quality,
      'isAvailable': isAvailable,
      if (notes != null) 'notes': notes,
    };
  }
}
