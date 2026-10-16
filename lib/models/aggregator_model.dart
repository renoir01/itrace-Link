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
  final String? tinNumber;
  final String contactPerson;
  final double currentInventory;
  final List<String> documents;
  final int completedOrders;
  final DateTime? updatedAt;
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
    this.tinNumber,
    this.contactPerson = '',
    this.currentInventory = 0.0,
    this.documents = const [],
    this.completedOrders = 0,
    this.updatedAt,
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
      tinNumber: data['tinNumber'],
      contactPerson: data['contactPerson'] ?? '',
      currentInventory: (data['currentInventory'] ?? 0).toDouble(),
      documents: List<String>.from(data['documents'] ?? []),
      completedOrders: data['completedOrders'] ?? 0,
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
      'storageCapacity': storageCapacity,
      'transportCapacity': transportCapacity,
      'serviceAreas': serviceAreas,
      'rating': rating,
      'totalOrders': totalOrders,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      if (tinNumber != null) 'tinNumber': tinNumber,
      'contactPerson': contactPerson,
      'currentInventory': currentInventory,
      'documents': documents,
      'completedOrders': completedOrders,
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
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
    String? tinNumber,
    String? contactPerson,
    double? currentInventory,
    List<String>? documents,
    int? completedOrders,
    DateTime? updatedAt,
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
      tinNumber: tinNumber ?? this.tinNumber,
      contactPerson: contactPerson ?? this.contactPerson,
      currentInventory: currentInventory ?? this.currentInventory,
      documents: documents ?? this.documents,
      completedOrders: completedOrders ?? this.completedOrders,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt,
    );
  }
}
