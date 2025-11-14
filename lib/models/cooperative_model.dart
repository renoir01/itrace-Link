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
  final AgroDealerPurchase? agroDealerPurchase;
  final PlantingInfo? plantingInfo;
  final HarvestInfo? harvestInfo;
  final double pricePerKg;
  final bool availableForSale;

  CooperativeModel({
    required this.id,
    required this.userId,
    required this.cooperativeName,
    required this.registrationNumber,
    required this.numberOfMembers,
    required this.location,
    required this.contactPerson,
    required this.phone,
    this.agroDealerPurchase,
    this.plantingInfo,
    this.harvestInfo,
    required this.pricePerKg,
    required this.availableForSale,
  });

  factory CooperativeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CooperativeModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      cooperativeName: data['cooperativeName'] ?? '',
      registrationNumber: data['registrationNumber'] ?? '',
      numberOfMembers: data['numberOfMembers'] ?? 0,
      location: AddressModel.fromMap(data['location'] ?? {}),
      contactPerson: data['contactPerson'] ?? '',
      phone: data['phone'] ?? '',
      agroDealerPurchase: data['agroDealerPurchase'] != null
          ? AgroDealerPurchase.fromMap(data['agroDealerPurchase'])
          : null,
      plantingInfo: data['plantingInfo'] != null
          ? PlantingInfo.fromMap(data['plantingInfo'])
          : null,
      harvestInfo: data['harvestInfo'] != null
          ? HarvestInfo.fromMap(data['harvestInfo'])
          : null,
      pricePerKg: (data['pricePerKg'] ?? 0).toDouble(),
      availableForSale: data['availableForSale'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'cooperativeName': cooperativeName,
      'registrationNumber': registrationNumber,
      'numberOfMembers': numberOfMembers,
      'location': location.toMap(),
      'contactPerson': contactPerson,
      'phone': phone,
      if (agroDealerPurchase != null)
        'agroDealerPurchase': agroDealerPurchase!.toMap(),
      if (plantingInfo != null) 'plantingInfo': plantingInfo!.toMap(),
      if (harvestInfo != null) 'harvestInfo': harvestInfo!.toMap(),
      'pricePerKg': pricePerKg,
      'availableForSale': availableForSale,
    };
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
