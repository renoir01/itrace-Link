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
  final int numberOfBeneficiaries;
  final double? budget;
  final List<String> documents;
  final int totalOrders;
  final int completedOrders;
  final double totalSpent;
  final DateTime? updatedAt;
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
    this.numberOfBeneficiaries = 0,
    this.budget,
    this.documents = const [],
    this.totalOrders = 0,
    this.completedOrders = 0,
    this.totalSpent = 0.0,
    this.updatedAt,
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
      numberOfBeneficiaries: data['numberOfBeneficiaries'] ?? 0,
      budget: (data['budget'] as num?)?.toDouble(),
      documents: List<String>.from(data['documents'] ?? []),
      totalOrders: data['totalOrders'] ?? 0,
      completedOrders: data['completedOrders'] ?? 0,
      totalSpent: (data['totalSpent'] ?? 0).toDouble(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
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
      'numberOfBeneficiaries': numberOfBeneficiaries,
      if (budget != null) 'budget': budget,
      'documents': documents,
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'totalSpent': totalSpent,
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
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
    int? numberOfBeneficiaries,
    double? budget,
    List<String>? documents,
    int? totalOrders,
    int? completedOrders,
    double? totalSpent,
    DateTime? updatedAt,
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
      numberOfBeneficiaries: numberOfBeneficiaries ?? this.numberOfBeneficiaries,
      budget: budget ?? this.budget,
      documents: documents ?? this.documents,
      totalOrders: totalOrders ?? this.totalOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt,
    );
  }
}
