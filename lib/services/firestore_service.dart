import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/cooperative_model.dart';
import '../models/aggregator_model.dart';
import '../models/institution_model.dart';
import '../models/agro_dealer_model.dart';
import '../models/seed_producer_model.dart';
import '../models/order_model.dart';
import '../models/transaction_model.dart';
import '../models/notification_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== USER OPERATIONS ====================

  Future<void> createUser(UserModel user) async {
    await _firestore
        .collection(AppConstants.collectionUsers)
        .doc(user.id)
        .set(user.toFirestore());
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.collectionUsers)
        .doc(userId)
        .update(data);
  }

  // ==================== COOPERATIVE OPERATIONS ====================

  Future<void> createCooperative(CooperativeModel cooperative) async {
    await _firestore
        .collection(AppConstants.collectionCooperatives)
        .doc(cooperative.id)
        .set(cooperative.toFirestore());
  }

  Future<CooperativeModel?> getCooperative(String cooperativeId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionCooperatives)
          .doc(cooperativeId)
          .get();

      if (doc.exists) {
        return CooperativeModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting cooperative: $e');
      return null;
    }
  }

  Future<void> updateCooperative(
      String cooperativeId, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.collectionCooperatives)
        .doc(cooperativeId)
        .update(data);
  }

  // Get cooperatives by district
  Stream<List<CooperativeModel>> getCooperativesByDistrict(String district) {
    return _firestore
        .collection(AppConstants.collectionCooperatives)
        .where('location.district', isEqualTo: district)
        .where('availableForSale', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CooperativeModel.fromFirestore(doc)).toList());
  }

  // Get available cooperatives with filters
  Stream<List<CooperativeModel>> getAvailableCooperatives({
    String? district,
    double? minQuantity,
    DateTime? harvestDateFrom,
    DateTime? harvestDateTo,
  }) {
    Query query = _firestore
        .collection(AppConstants.collectionCooperatives)
        .where('availableForSale', isEqualTo: true);

    if (district != null) {
      query = query.where('location.district', isEqualTo: district);
    }

    return query.snapshots().map((snapshot) {
      var cooperatives =
          snapshot.docs.map((doc) => CooperativeModel.fromFirestore(doc)).toList();

      // Apply additional filters in memory
      if (minQuantity != null) {
        cooperatives = cooperatives
            .where((c) =>
                c.harvestInfo != null && c.harvestInfo!.actualQuantity >= minQuantity)
            .toList();
      }

      if (harvestDateFrom != null && harvestDateTo != null) {
        cooperatives = cooperatives.where((c) {
          final harvestDate = c.harvestInfo?.harvestDate;
          return harvestDate != null &&
              harvestDate.isAfter(harvestDateFrom) &&
              harvestDate.isBefore(harvestDateTo);
        }).toList();
      }

      return cooperatives;
    });
  }

  // ==================== AGGREGATOR OPERATIONS ====================

  Future<void> createAggregator(AggregatorModel aggregator) async {
    await _firestore
        .collection(AppConstants.collectionAggregators)
        .doc(aggregator.id)
        .set(aggregator.toFirestore());
  }

  Future<AggregatorModel?> getAggregator(String aggregatorId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionAggregators)
          .doc(aggregatorId)
          .get();

      if (doc.exists) {
        return AggregatorModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting aggregator: $e');
      return null;
    }
  }

  Future<void> updateAggregator(
      String aggregatorId, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.collectionAggregators)
        .doc(aggregatorId)
        .update(data);
  }

  Stream<List<AggregatorModel>> getAggregatorsByServiceArea(String district) {
    return _firestore
        .collection(AppConstants.collectionAggregators)
        .where('serviceAreas', arrayContains: district)
        .where('isVerified', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AggregatorModel.fromFirestore(doc)).toList());
  }

  // ==================== INSTITUTION OPERATIONS ====================

  Future<void> createInstitution(InstitutionModel institution) async {
    await _firestore
        .collection(AppConstants.collectionInstitutions)
        .doc(institution.id)
        .set(institution.toFirestore());
  }

  Future<InstitutionModel?> getInstitution(String institutionId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionInstitutions)
          .doc(institutionId)
          .get();

      if (doc.exists) {
        return InstitutionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting institution: $e');
      return null;
    }
  }

  Future<void> updateInstitution(
      String institutionId, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.collectionInstitutions)
        .doc(institutionId)
        .update(data);
  }

  // ==================== AGRO-DEALER OPERATIONS ====================

  Future<void> createAgroDealer(AgroDealerModel agroDealer) async {
    await _firestore
        .collection(AppConstants.collectionAgroDealers)
        .doc(agroDealer.id)
        .set(agroDealer.toFirestore());
  }

  Future<AgroDealerModel?> getAgroDealer(String agroDealerId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionAgroDealers)
          .doc(agroDealerId)
          .get();

      if (doc.exists) {
        return AgroDealerModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting agro-dealer: $e');
      return null;
    }
  }

  Future<void> updateAgroDealer(
      String agroDealerId, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.collectionAgroDealers)
        .doc(agroDealerId)
        .update(data);
  }

  Stream<List<AgroDealerModel>> getVerifiedAgroDealers() {
    return _firestore
        .collection(AppConstants.collectionAgroDealers)
        .where('isVerified', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AgroDealerModel.fromFirestore(doc)).toList());
  }

  // ==================== SEED PRODUCER OPERATIONS ====================

  Future<void> createSeedProducer(SeedProducerModel seedProducer) async {
    await _firestore
        .collection(AppConstants.collectionSeedProducers)
        .doc(seedProducer.id)
        .set(seedProducer.toFirestore());
  }

  Future<SeedProducerModel?> getSeedProducer(String seedProducerId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionSeedProducers)
          .doc(seedProducerId)
          .get();

      if (doc.exists) {
        return SeedProducerModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting seed producer: $e');
      return null;
    }
  }

  Future<void> updateSeedProducer(
      String seedProducerId, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.collectionSeedProducers)
        .doc(seedProducerId)
        .update(data);
  }

  // ==================== ORDER OPERATIONS ====================

  Future<String> createOrder(OrderModel order) async {
    final docRef = await _firestore
        .collection(AppConstants.collectionOrders)
        .add(order.toFirestore());
    return docRef.id;
  }

  Future<OrderModel?> getOrder(String orderId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionOrders)
          .doc(orderId)
          .get();

      if (doc.exists) {
        return OrderModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting order: $e');
      return null;
    }
  }

  Future<void> updateOrder(String orderId, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.collectionOrders)
        .doc(orderId)
        .update(data);
  }

  // Get orders for a user (as buyer or seller)
  Stream<List<OrderModel>> getUserOrders(String userId, {String? status}) {
    Query query = _firestore
        .collection(AppConstants.collectionOrders)
        .where('buyerId', isEqualTo: userId);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.orderBy('requestDate', descending: true).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  Stream<List<OrderModel>> getSellerOrders(String userId, {String? status}) {
    Query query = _firestore
        .collection(AppConstants.collectionOrders)
        .where('sellerId', isEqualTo: userId);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.orderBy('requestDate', descending: true).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  // ==================== TRANSACTION OPERATIONS ====================

  Future<String> createTransaction(TransactionModel transaction) async {
    final docRef = await _firestore
        .collection(AppConstants.collectionTransactions)
        .add(transaction.toFirestore());
    return docRef.id;
  }

  Future<TransactionModel?> getTransaction(String transactionId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionTransactions)
          .doc(transactionId)
          .get();

      if (doc.exists) {
        return TransactionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting transaction: $e');
      return null;
    }
  }

  // Get traceability chain for a batch
  Future<TraceabilityChain?> getTraceabilityChain(String batchNumber) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.collectionTransactions)
          .where('batchNumber', isEqualTo: batchNumber)
          .orderBy('date')
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final transactions = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();

      return TraceabilityChain(
        batchNumber: batchNumber,
        transactions: transactions,
        createdAt: transactions.first.date,
      );
    } catch (e) {
      debugPrint('Error getting traceability chain: $e');
      return null;
    }
  }

  // ==================== NOTIFICATION OPERATIONS ====================

  Future<String> createNotification(NotificationModel notification) async {
    final docRef = await _firestore
        .collection(AppConstants.collectionNotifications)
        .add(notification.toFirestore());
    return docRef.id;
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore
        .collection(AppConstants.collectionNotifications)
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection(AppConstants.collectionNotifications)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection(AppConstants.collectionNotifications)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  Stream<int> getUnreadNotificationCount(String userId) {
    return _firestore
        .collection(AppConstants.collectionNotifications)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ==================== UTILITY METHODS ====================

  // Generate unique verification code
  String generateVerificationCode() {
    return DateTime.now().millisecondsSinceEpoch.toString().substring(7);
  }

  // Generate batch number
  String generateBatchNumber(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$prefix-$timestamp';
  }
}
