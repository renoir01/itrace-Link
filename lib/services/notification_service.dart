import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // Get FCM token
    _fcmToken = await _messaging.getToken();
    debugPrint('FCM Token: $_fcmToken');

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      debugPrint('FCM Token refreshed: $newToken');
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.notification?.title}');
    // Handle notification display in app
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('Background message opened: ${message.notification?.title}');
    // Handle navigation when user taps notification
  }

  // Save FCM token to user document
  Future<void> saveFCMToken(String userId) async {
    if (_fcmToken != null) {
      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .update({'fcmToken': _fcmToken});
    }
  }

  // Create notification document
  Future<void> createNotification({
    required String userId,
    required String type,
    required Map<String, String> message,
    String? relatedEntityId,
  }) async {
    await _firestore.collection(AppConstants.collectionNotifications).add({
      'userId': userId,
      'type': type,
      'message': message,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      if (relatedEntityId != null) 'relatedEntity': relatedEntityId,
    });
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection(AppConstants.collectionNotifications)
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Get unread notification count
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection(AppConstants.collectionNotifications)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get user notifications
  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection(AppConstants.collectionNotifications)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }
}

// Top-level function for background message handler
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.notification?.title}');
}
