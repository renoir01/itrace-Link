import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String userType;
  final String email;
  final String phone;
  final String language;
  final bool isVerified;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.userType,
    required this.email,
    required this.phone,
    required this.language,
    required this.isVerified,
    required this.createdAt,
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
      createdAt: (data['createdAt'] as Timestamp).toDate(),
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
    };
  }

  UserModel copyWith({
    String? userType,
    String? email,
    String? phone,
    String? language,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id,
      userType: userType ?? this.userType,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      language: language ?? this.language,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AddressModel {
  final String district;
  final String sector;
  final String cell;
  final GeoPoint? gps;

  AddressModel({
    required this.district,
    required this.sector,
    required this.cell,
    this.gps,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      district: map['district'] ?? '',
      sector: map['sector'] ?? '',
      cell: map['cell'] ?? '',
      gps: map['gps'] as GeoPoint?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'district': district,
      'sector': sector,
      'cell': cell,
      if (gps != null) 'gps': gps,
    };
  }
}
