import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class OrderModel {
  final String id;
  final String orderType;
  final String buyerId;
  final String sellerId;
  final double quantity;
  final double pricePerKg;
  final double totalAmount;
  final DateTime requestDate;
  final DateTime expectedDeliveryDate;
  final String status;
  final AddressModel deliveryLocation;
  final String paymentStatus;
  final String? buyerName;
  final String? sellerName;

  OrderModel({
    required this.id,
    required this.orderType,
    required this.buyerId,
    required this.sellerId,
    required this.quantity,
    required this.pricePerKg,
    required this.totalAmount,
    required this.requestDate,
    required this.expectedDeliveryDate,
    required this.status,
    required this.deliveryLocation,
    required this.paymentStatus,
    this.buyerName,
    this.sellerName,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      orderType: data['orderType'] ?? '',
      buyerId: data['buyerId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      quantity: (data['quantity'] ?? 0).toDouble(),
      pricePerKg: (data['pricePerKg'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      requestDate: (data['requestDate'] as Timestamp).toDate(),
      expectedDeliveryDate:
          (data['expectedDeliveryDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      deliveryLocation: AddressModel.fromMap(data['deliveryLocation'] ?? {}),
      paymentStatus: data['paymentStatus'] ?? 'pending',
      buyerName: data['buyerName'],
      sellerName: data['sellerName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderType': orderType,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'quantity': quantity,
      'pricePerKg': pricePerKg,
      'totalAmount': totalAmount,
      'requestDate': Timestamp.fromDate(requestDate),
      'expectedDeliveryDate': Timestamp.fromDate(expectedDeliveryDate),
      'status': status,
      'deliveryLocation': deliveryLocation.toMap(),
      'paymentStatus': paymentStatus,
      if (buyerName != null) 'buyerName': buyerName,
      if (sellerName != null) 'sellerName': sellerName,
    };
  }

  OrderModel copyWith({
    String? orderType,
    String? buyerId,
    String? sellerId,
    double? quantity,
    double? pricePerKg,
    double? totalAmount,
    DateTime? requestDate,
    DateTime? expectedDeliveryDate,
    String? status,
    AddressModel? deliveryLocation,
    String? paymentStatus,
    String? buyerName,
    String? sellerName,
  }) {
    return OrderModel(
      id: id,
      orderType: orderType ?? this.orderType,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      quantity: quantity ?? this.quantity,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      totalAmount: totalAmount ?? this.totalAmount,
      requestDate: requestDate ?? this.requestDate,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      status: status ?? this.status,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      buyerName: buyerName ?? this.buyerName,
      sellerName: sellerName ?? this.sellerName,
    );
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  bool get isPaid => paymentStatus == 'paid';
  bool get isPaymentPending => paymentStatus == 'pending';
}
