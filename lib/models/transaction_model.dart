import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String type; // seed_sale, bean_sale, bean_collection, bean_delivery
  final String fromActorId; // User ID of seller/sender
  final String fromActorType; // User type
  final String toActorId; // User ID of buyer/receiver
  final String toActorType; // User type
  final String? orderId; // If related to an order
  final double quantity; // in kg
  final double amount; // in RWF
  final DateTime date;
  final String verificationCode; // Unique code for verification
  final String? batchNumber; // For traceability
  final Map<String, dynamic>? metadata; // Additional data (quality, photos, etc.)
  final bool isVerified;

  TransactionModel({
    required this.id,
    required this.type,
    required this.fromActorId,
    required this.fromActorType,
    required this.toActorId,
    required this.toActorType,
    this.orderId,
    required this.quantity,
    required this.amount,
    required this.date,
    required this.verificationCode,
    this.batchNumber,
    this.metadata,
    this.isVerified = false,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      type: data['type'] ?? '',
      fromActorId: data['fromActorId'] ?? '',
      fromActorType: data['fromActorType'] ?? '',
      toActorId: data['toActorId'] ?? '',
      toActorType: data['toActorType'] ?? '',
      orderId: data['orderId'],
      quantity: (data['quantity'] ?? 0).toDouble(),
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      verificationCode: data['verificationCode'] ?? '',
      batchNumber: data['batchNumber'],
      metadata: data['metadata'] as Map<String, dynamic>?,
      isVerified: data['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'fromActorId': fromActorId,
      'fromActorType': fromActorType,
      'toActorId': toActorId,
      'toActorType': toActorType,
      if (orderId != null) 'orderId': orderId,
      'quantity': quantity,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'verificationCode': verificationCode,
      if (batchNumber != null) 'batchNumber': batchNumber,
      if (metadata != null) 'metadata': metadata,
      'isVerified': isVerified,
    };
  }

  // Helper getters for transaction types
  bool get isSeedSale => type == 'seed_sale';
  bool get isBeanSale => type == 'bean_sale';
  bool get isBeanCollection => type == 'bean_collection';
  bool get isBeanDelivery => type == 'bean_delivery';

  // Get formatted amount
  String get formattedAmount => '${amount.toStringAsFixed(0)} RWF';

  // Get formatted quantity
  String get formattedQuantity => '${quantity.toStringAsFixed(1)} kg';
}

// Traceability Chain Model
class TraceabilityChain {
  final String batchNumber;
  final List<TransactionModel> transactions;
  final DateTime createdAt;

  TraceabilityChain({
    required this.batchNumber,
    required this.transactions,
    required this.createdAt,
  });

  // Get the complete chain from seed to institution
  List<ChainStep> get steps {
    final steps = <ChainStep>[];

    for (var i = 0; i < transactions.length; i++) {
      final transaction = transactions[i];
      steps.add(ChainStep(
        stepNumber: i + 1,
        actorId: transaction.fromActorId,
        actorType: transaction.fromActorType,
        action: _getActionDescription(transaction.type),
        date: transaction.date,
        quantity: transaction.quantity,
        verificationCode: transaction.verificationCode,
        isVerified: transaction.isVerified,
      ));
    }

    // Add final recipient
    if (transactions.isNotEmpty) {
      final lastTransaction = transactions.last;
      steps.add(ChainStep(
        stepNumber: steps.length + 1,
        actorId: lastTransaction.toActorId,
        actorType: lastTransaction.toActorType,
        action: 'Received',
        date: lastTransaction.date,
        quantity: lastTransaction.quantity,
        verificationCode: lastTransaction.verificationCode,
        isVerified: lastTransaction.isVerified,
      ));
    }

    return steps;
  }

  String _getActionDescription(String type) {
    switch (type) {
      case 'seed_sale':
        return 'Seed supplied';
      case 'bean_sale':
        return 'Beans sold';
      case 'bean_collection':
        return 'Beans collected';
      case 'bean_delivery':
        return 'Beans delivered';
      default:
        return 'Transaction';
    }
  }

  bool get isFullyVerified => transactions.every((t) => t.isVerified);
}

class ChainStep {
  final int stepNumber;
  final String actorId;
  final String actorType;
  final String action;
  final DateTime date;
  final double quantity;
  final String verificationCode;
  final bool isVerified;

  ChainStep({
    required this.stepNumber,
    required this.actorId,
    required this.actorType,
    required this.action,
    required this.date,
    required this.quantity,
    required this.verificationCode,
    required this.isVerified,
  });

  String get actorTypeDisplay {
    switch (actorType) {
      case 'seed_producer':
        return 'Seed Producer';
      case 'agro_dealer':
        return 'Agro-Dealer';
      case 'farmer':
        return 'Farmer Cooperative';
      case 'aggregator':
        return 'Aggregator';
      case 'institution':
        return 'Institution';
      default:
        return actorType;
    }
  }

  String get icon {
    switch (actorType) {
      case 'seed_producer':
        return '🏭';
      case 'agro_dealer':
        return '🏪';
      case 'farmer':
        return '👨‍🌾';
      case 'aggregator':
        return '🚚';
      case 'institution':
        return '🏥';
      default:
        return '📦';
    }
  }
}
