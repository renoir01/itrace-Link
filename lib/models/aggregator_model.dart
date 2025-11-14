import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class AggregatorModel {
  final String id;
  final String userId;
  final String businessName;
  final String licenseNumber;
  final AddressModel location;
  final String phone;
  final String email;
  final double storageCapacity; // in kg
  final double transportCapacity; // in kg
  final List<String> serviceAreas; // districts covered
  final double rating;
  final int totalOrders;
  final String? profileImageUrl;
  final bool isVerified;
  final DateTime createdAt;

  AggregatorModel({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.licenseNumber,
    required this.location,
    required this.phone,
    required this.email,
    required this.storageCapacity,
    required this.transportCapacity,
    required this.serviceAreas,
    this.rating = 0.0,
    this.totalOrders = 0,
    this.profileImageUrl,
    this.isVerified = false,
    required this.createdAt,
  });

  factory AggregatorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AggregatorModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      businessName: data['businessName'] ?? '',
      licenseNumber: data['licenseNumber'] ?? '',
      location: AddressModel.fromMap(data['location'] ?? {}),
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      storageCapacity: (data['storageCapacity'] ?? 0).toDouble(),
      transportCapacity: (data['transportCapacity'] ?? 0).toDouble(),
      serviceAreas: List<String>.from(data['serviceAreas'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      totalOrders: data['totalOrders'] ?? 0,
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
      'storageCapacity': storageCapacity,
      'transportCapacity': transportCapacity,
      'serviceAreas': serviceAreas,
      'rating': rating,
      'totalOrders': totalOrders,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AggregatorModel copyWith({
    String? businessName,
    String? licenseNumber,
    AddressModel? location,
    String? phone,
    String? email,
    double? storageCapacity,
    double? transportCapacity,
    List<String>? serviceAreas,
    double? rating,
    int? totalOrders,
    String? profileImageUrl,
    bool? isVerified,
  }) {
    return AggregatorModel(
      id: id,
      userId: userId,
      businessName: businessName ?? this.businessName,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      storageCapacity: storageCapacity ?? this.storageCapacity,
      transportCapacity: transportCapacity ?? this.transportCapacity,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
    );
  }
}
