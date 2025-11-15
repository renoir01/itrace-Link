import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String type; // order, payment, alert, verification
  final String titleEn;
  final String titleRw;
  final String messageEn;
  final String messageRw;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedEntityId; // Order ID, Transaction ID, etc.
  final String? relatedEntityType; // 'order', 'transaction', 'user'
  final Map<String, dynamic>? data; // Additional data

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.titleEn,
    required this.titleRw,
    required this.messageEn,
    required this.messageRw,
    this.isRead = false,
    required this.createdAt,
    this.relatedEntityId,
    this.relatedEntityType,
    this.data,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final message = data['message'] as Map<String, dynamic>?;

    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? 'alert',
      titleEn: message?['titleEn'] ?? data['title']?['en'] ?? '',
      titleRw: message?['titleRw'] ?? data['title']?['rw'] ?? '',
      messageEn: message?['en'] ?? '',
      messageRw: message?['rw'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      relatedEntityId: data['relatedEntityId'] ?? data['relatedEntity'],
      relatedEntityType: data['relatedEntityType'],
      data: data['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'message': {
        'titleEn': titleEn,
        'titleRw': titleRw,
        'en': messageEn,
        'rw': messageRw,
      },
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      if (relatedEntityId != null) 'relatedEntityId': relatedEntityId,
      if (relatedEntityType != null) 'relatedEntityType': relatedEntityType,
      if (data != null) 'data': data,
    };
  }

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      type: type,
      titleEn: titleEn,
      titleRw: titleRw,
      messageEn: messageEn,
      messageRw: messageRw,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      relatedEntityId: relatedEntityId,
      relatedEntityType: relatedEntityType,
      data: data,
    );
  }

  // Get title in specified language
  String getTitle(String languageCode) {
    return languageCode == 'en' ? titleEn : titleRw;
  }

  // Get message in specified language
  String getMessage(String languageCode) {
    return languageCode == 'en' ? messageEn : messageRw;
  }

  // Notification type helpers
  bool get isOrderNotification => type == 'order';
  bool get isPaymentNotification => type == 'payment';
  bool get isAlertNotification => type == 'alert';
  bool get isVerificationNotification => type == 'verification';

  // Get icon based on type
  String get icon {
    switch (type) {
      case 'order':
        return '📦';
      case 'payment':
        return '💰';
      case 'alert':
        return '⚠️';
      case 'verification':
        return '✅';
      default:
        return '🔔';
    }
  }

  // Get relative time (e.g., "2 hours ago")
  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${(difference.inDays / 30).floor()}mo ago';
    }
  }
}

// Notification Factory for creating common notification types
class NotificationFactory {
  // Order notification
  static NotificationModel createOrderNotification({
    required String userId,
    required String orderId,
    required String buyerName,
    required double quantity,
    required double price,
    required DateTime deliveryDate,
  }) {
    return NotificationModel(
      id: '',
      userId: userId,
      type: 'order',
      titleEn: 'New Order',
      titleRw: 'Itungo Rishya',
      messageEn:
          'New order from $buyerName: ${quantity}kg @ ${price} RWF/kg. Delivery: ${deliveryDate.toString().split(' ')[0]}',
      messageRw:
          'Itungo rishya rya $buyerName: ${quantity}kg @ ${price} RWF/kg. Itariki: ${deliveryDate.toString().split(' ')[0]}',
      createdAt: DateTime.now(),
      relatedEntityId: orderId,
      relatedEntityType: 'order',
      data: {
        'buyerName': buyerName,
        'quantity': quantity,
        'price': price,
        'deliveryDate': deliveryDate.toIso8601String(),
      },
    );
  }

  // Order accepted notification
  static NotificationModel createOrderAcceptedNotification({
    required String userId,
    required String orderId,
    required String sellerName,
    required double quantity,
    required DateTime collectionDate,
    required String location,
  }) {
    return NotificationModel(
      id: '',
      userId: userId,
      type: 'order',
      titleEn: 'Order Accepted',
      titleRw: 'Itungo Ryemewe',
      messageEn:
          '$sellerName accepted your order for ${quantity}kg. Collection: ${collectionDate.toString().split(' ')[0]} at $location',
      messageRw:
          '$sellerName yemeye itungo ryawe rya ${quantity}kg. Kugarurira: ${collectionDate.toString().split(' ')[0]} kuri $location',
      createdAt: DateTime.now(),
      relatedEntityId: orderId,
      relatedEntityType: 'order',
      data: {
        'sellerName': sellerName,
        'quantity': quantity,
        'collectionDate': collectionDate.toIso8601String(),
        'location': location,
      },
    );
  }

  // Payment received notification
  static NotificationModel createPaymentNotification({
    required String userId,
    required String transactionId,
    required double amount,
    required double quantity,
  }) {
    return NotificationModel(
      id: '',
      userId: userId,
      type: 'payment',
      titleEn: 'Payment Received',
      titleRw: 'Amafaranga Yakiriye',
      messageEn:
          'Payment received: ${amount} RWF for ${quantity}kg beans. Transaction ID: $transactionId',
      messageRw:
          'Amafaranga yakiriye: ${amount} RWF kuri ${quantity}kg ibishyimbo. Nimero: $transactionId',
      createdAt: DateTime.now(),
      relatedEntityId: transactionId,
      relatedEntityType: 'transaction',
      data: {
        'amount': amount,
        'quantity': quantity,
      },
    );
  }

  // Verification approved notification
  static NotificationModel createVerificationNotification({
    required String userId,
    required bool isApproved,
  }) {
    return NotificationModel(
      id: '',
      userId: userId,
      type: 'verification',
      titleEn: isApproved ? 'Account Verified' : 'Verification Pending',
      titleRw: isApproved ? 'Konti Yemejwe' : 'Kugenzura Birakomeje',
      messageEn: isApproved
          ? 'Your account has been verified. You can now access all features.'
          : 'Your account verification is pending. You will be notified once approved.',
      messageRw: isApproved
          ? 'Konti yawe yemejwe. Ubu ushobora gukoresha ibiranga byose.'
          : 'Kugenzura konti yawe birakomeje. Uzamenyeshwa iyo byemejwe.',
      createdAt: DateTime.now(),
      relatedEntityId: userId,
      relatedEntityType: 'user',
      data: {
        'isApproved': isApproved,
      },
    );
  }
}
