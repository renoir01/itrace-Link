import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class SeedProducerModel {
  final String id;
  final String userId;
  final String organizationName;
  final String registrationNumber;
  final AddressModel address;
  final String contactPerson;
  final String phone;
  final String email;
  final List<String> seedVarieties;
  final String certificationNumber;
  final double productionCapacity; // in kg per season
  final List<String> authorizedDealerIds; // References to agro-dealers
  final String? profileImageUrl;
  final bool isVerified;
  final DateTime createdAt;

  SeedProducerModel({
    required this.id,
    required this.userId,
    required this.organizationName,
    required this.registrationNumber,
    required this.address,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.seedVarieties,
    required this.certificationNumber,
    required this.productionCapacity,
    this.authorizedDealerIds = const [],
    this.profileImageUrl,
    this.isVerified = false,
    required this.createdAt,
  });

  factory SeedProducerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SeedProducerModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      organizationName: data['organizationName'] ?? '',
      registrationNumber: data['registrationNumber'] ?? '',
      address: AddressModel.fromMap(data['address'] ?? {}),
      contactPerson: data['contactPerson'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      seedVarieties: List<String>.from(data['seedVarieties'] ?? []),
      certificationNumber: data['certificationNumber'] ?? '',
      productionCapacity: (data['productionCapacity'] ?? 0).toDouble(),
      authorizedDealerIds: List<String>.from(data['authorizedDealerIds'] ?? []),
      profileImageUrl: data['profileImageUrl'],
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'organizationName': organizationName,
      'registrationNumber': registrationNumber,
      'address': address.toMap(),
      'contactPerson': contactPerson,
      'phone': phone,
      'email': email,
      'seedVarieties': seedVarieties,
      'certificationNumber': certificationNumber,
      'productionCapacity': productionCapacity,
      'authorizedDealerIds': authorizedDealerIds,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  SeedProducerModel copyWith({
    String? organizationName,
    String? registrationNumber,
    AddressModel? address,
    String? contactPerson,
    String? phone,
    String? email,
    List<String>? seedVarieties,
    String? certificationNumber,
    double? productionCapacity,
    List<String>? authorizedDealerIds,
    String? profileImageUrl,
    bool? isVerified,
  }) {
    return SeedProducerModel(
      id: id,
      userId: userId,
      organizationName: organizationName ?? this.organizationName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      address: address ?? this.address,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      seedVarieties: seedVarieties ?? this.seedVarieties,
      certificationNumber: certificationNumber ?? this.certificationNumber,
      productionCapacity: productionCapacity ?? this.productionCapacity,
      authorizedDealerIds: authorizedDealerIds ?? this.authorizedDealerIds,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
    );
  }

  int get totalAuthorizedDealers => authorizedDealerIds.length;
}
