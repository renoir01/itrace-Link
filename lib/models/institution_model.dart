import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class InstitutionModel {
  final String id;
  final String userId;
  final String institutionName;
  final String institutionType; // 'school' or 'hospital'
  final String registrationNumber;
  final AddressModel location;
  final String contactPerson;
  final String phone;
  final String email;
  final double monthlyRequirement; // in kg
  final String paymentTerms;
  final String? profileImageUrl;
  final bool isVerified;
  final DateTime createdAt;

  InstitutionModel({
    required this.id,
    required this.userId,
    required this.institutionName,
    required this.institutionType,
    required this.registrationNumber,
    required this.location,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.monthlyRequirement,
    required this.paymentTerms,
    this.profileImageUrl,
    this.isVerified = false,
    required this.createdAt,
  });

  factory InstitutionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InstitutionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      institutionName: data['institutionName'] ?? '',
      institutionType: data['institutionType'] ?? 'school',
      registrationNumber: data['registrationNumber'] ?? '',
      location: AddressModel.fromMap(data['location'] ?? {}),
      contactPerson: data['contactPerson'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      monthlyRequirement: (data['monthlyRequirement'] ?? 0).toDouble(),
      paymentTerms: data['paymentTerms'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'institutionName': institutionName,
      'institutionType': institutionType,
      'registrationNumber': registrationNumber,
      'location': location.toMap(),
      'contactPerson': contactPerson,
      'phone': phone,
      'email': email,
      'monthlyRequirement': monthlyRequirement,
      'paymentTerms': paymentTerms,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isSchool => institutionType == 'school';
  bool get isHospital => institutionType == 'hospital';

  InstitutionModel copyWith({
    String? institutionName,
    String? institutionType,
    String? registrationNumber,
    AddressModel? location,
    String? contactPerson,
    String? phone,
    String? email,
    double? monthlyRequirement,
    String? paymentTerms,
    String? profileImageUrl,
    bool? isVerified,
  }) {
    return InstitutionModel(
      id: id,
      userId: userId,
      institutionName: institutionName ?? this.institutionName,
      institutionType: institutionType ?? this.institutionType,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      location: location ?? this.location,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      monthlyRequirement: monthlyRequirement ?? this.monthlyRequirement,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
    );
  }
}
