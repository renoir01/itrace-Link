import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String userType;
  final String email;
  final String phone;
  final String language;
  final bool isVerified;
  final DateTime createdAt;
  final String? displayName;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.userType,
    this.email = '',
    required this.phone,
    this.language = 'en',
    this.isVerified = false,
    required this.createdAt,
    this.displayName,
    this.lastLoginAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      userType: data['userType'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      language: data['language'] ?? 'en',
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      displayName: data['displayName'],
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userType': userType,
      'email': email,
      'phone': phone,
      'language': language,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      if (displayName != null) 'displayName': displayName,
      if (lastLoginAt != null) 'lastLoginAt': Timestamp.fromDate(lastLoginAt!),
    };
  }

  UserModel copyWith({
    String? userType,
    String? email,
    String? phone,
    String? language,
    bool? isVerified,
    DateTime? createdAt,
    String? displayName,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id,
      userType: userType ?? this.userType,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      language: language ?? this.language,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      displayName: displayName ?? this.displayName,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

class AddressModel {
  final String district;
  final String sector;
  final String cell;
  final String? address; // street / facility address (free text)
  final GeoPoint? gps;

  AddressModel({
    required this.district,
    this.sector = '',
    this.cell = '',
    this.address,
    this.gps,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      district: map['district'] ?? '',
      sector: map['sector'] ?? '',
      cell: map['cell'] ?? '',
      address: map['address'],
      gps: map['gps'] as GeoPoint?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'district': district,
      'sector': sector,
      'cell': cell,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (gps != null) 'gps': gps,
    };
  }

  /// Human readable one-line description, skipping empty parts.
  String get displayText {
    final parts = [address, cell, sector, district]
        .whereType<String>()
        .where((p) => p.trim().isNotEmpty)
        .toList();
    return parts.join(', ');
  }
}
