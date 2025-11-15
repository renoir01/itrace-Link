import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/constants/app_constants.dart';

class SmsService {
  final String _apiKey = dotenv.env['AFRICASTALKING_API_KEY'] ?? '';
  final String _username = dotenv.env['AFRICASTALKING_USERNAME'] ?? '';
  final String _senderId = dotenv.env['AFRICASTALKING_SENDER_ID'] ?? 'iTraceLink';
  final String _baseUrl = 'https://api.africastalking.com/version1/messaging';

  // ==================== SEND SMS ====================

  /// Send SMS to a single recipient
  Future<bool> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'apiKey': _apiKey,
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'username': _username,
          'to': _formatPhoneNumber(phoneNumber),
          'message': message,
          'from': _senderId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        debugPrint('SMS sent successfully: $data');
        return true;
      } else {
        debugPrint('SMS sending failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending SMS: $e');
      return false;
    }
  }

  /// Send SMS to multiple recipients
  Future<Map<String, bool>> sendBulkSMS({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    final results = <String, bool>{};

    for (final phoneNumber in phoneNumbers) {
      final success = await sendSMS(
        phoneNumber: phoneNumber,
        message: message,
      );
      results[phoneNumber] = success;
    }

    return results;
  }

  // ==================== OTP OPERATIONS ====================

  /// Send OTP SMS
  Future<bool> sendOTP({
    required String phoneNumber,
    required String otp,
    required String languageCode,
  }) async {
    final message = languageCode == 'en'
        ? AppConstants.smsOtpEn.replaceAll('{code}', otp)
        : AppConstants.smsOtpRw.replaceAll('{code}', otp);

    return await sendSMS(
      phoneNumber: phoneNumber,
      message: message,
    );
  }

  /// Generate OTP code (6 digits)
  String generateOTP() {
    final random = DateTime.now().millisecondsSinceEpoch % 1000000;
    return random.toString().padLeft(6, '0');
  }

  // ==================== ORDER NOTIFICATIONS ====================

  /// Send new order notification to farmer
  Future<bool> sendOrderNotification({
    required String phoneNumber,
    required String aggregatorName,
    required double quantity,
    required double price,
    required DateTime deliveryDate,
    required String languageCode,
  }) async {
    final template = languageCode == 'en'
        ? AppConstants.smsOrderNotificationEn
        : AppConstants.smsOrderNotificationRw;

    final message = template
        .replaceAll('{aggregatorName}', aggregatorName)
        .replaceAll('{quantity}', quantity.toStringAsFixed(0))
        .replaceAll('{price}', price.toStringAsFixed(0))
        .replaceAll('{date}', _formatDate(deliveryDate));

    return await sendSMS(
      phoneNumber: phoneNumber,
      message: message,
    );
  }

  /// Send order accepted notification to aggregator
  Future<bool> sendOrderAcceptedNotification({
    required String phoneNumber,
    required String coopName,
    required double quantity,
    required DateTime collectionDate,
    required String location,
    required String languageCode,
  }) async {
    final template = languageCode == 'en'
        ? AppConstants.smsOrderAcceptedEn
        : AppConstants.smsOrderAcceptedRw;

    final message = template
        .replaceAll('{coopName}', coopName)
        .replaceAll('{quantity}', quantity.toStringAsFixed(0))
        .replaceAll('{date}', _formatDate(collectionDate))
        .replaceAll('{location}', location);

    return await sendSMS(
      phoneNumber: phoneNumber,
      message: message,
    );
  }

  /// Send order rejected notification
  Future<bool> sendOrderRejectedNotification({
    required String phoneNumber,
    required String coopName,
    required double quantity,
    required String reason,
    required String languageCode,
  }) async {
    final message = languageCode == 'en'
        ? '$coopName declined your order for ${quantity.toStringAsFixed(0)}kg. Reason: $reason. Try another cooperative on iTraceLink.'
        : '$coopName yanze itungo ryawe rya ${quantity.toStringAsFixed(0)}kg. Impamvu: $reason. Gerageza ikindi koperative kuri iTraceLink.';

    return await sendSMS(
      phoneNumber: phoneNumber,
      message: message,
    );
  }

  // ==================== PAYMENT NOTIFICATIONS ====================

  /// Send payment confirmation SMS
  Future<bool> sendPaymentConfirmation({
    required String phoneNumber,
    required double amount,
    required double quantity,
    required String transactionId,
    required String languageCode,
  }) async {
    final message = languageCode == 'en'
        ? 'Payment received: ${amount.toStringAsFixed(0)} RWF for ${quantity.toStringAsFixed(0)}kg beans. Transaction ID: $transactionId. Thank you!'
        : 'Amafaranga yakiriye: ${amount.toStringAsFixed(0)} RWF kuri ${quantity.toStringAsFixed(0)}kg ibishyimbo. Nimero: $transactionId. Murakoze!';

    return await sendSMS(
      phoneNumber: phoneNumber,
      message: message,
    );
  }

  // ==================== GENERAL NOTIFICATIONS ====================

  /// Send account verification notification
  Future<bool> sendVerificationNotification({
    required String phoneNumber,
    required bool isApproved,
    required String languageCode,
  }) async {
    final message = isApproved
        ? (languageCode == 'en'
            ? 'Your iTraceLink account has been verified! You can now access all features. Welcome aboard!'
            : 'Konti yawe ya iTraceLink yemejwe! Ubu ushobora gukoresha ibiranga byose. Murakaza neza!')
        : (languageCode == 'en'
            ? 'Your iTraceLink account is pending verification. You will be notified once approved.'
            : 'Kugenzura konti yawe ya iTraceLink birakomeje. Uzamenyeshwa iyo byemejwe.');

    return await sendSMS(
      phoneNumber: phoneNumber,
      message: message,
    );
  }

  /// Send harvest reminder
  Future<bool> sendHarvestReminder({
    required String phoneNumber,
    required DateTime expectedHarvestDate,
    required String languageCode,
  }) async {
    final daysUntil = expectedHarvestDate.difference(DateTime.now()).inDays;

    final message = languageCode == 'en'
        ? 'Reminder: Your iron beans harvest is expected in $daysUntil days (${_formatDate(expectedHarvestDate)}). Prepare your storage! - iTraceLink'
        : 'Ibutsa: Ibishyimbo byawe bigomba gusarurwa mu minsi $daysUntil (${_formatDate(expectedHarvestDate)}). Witegure kubika! - iTraceLink';

    return await sendSMS(
      phoneNumber: phoneNumber,
      message: message,
    );
  }

  /// Send low inventory alert to agro-dealer
  Future<bool> sendLowInventoryAlert({
    required String phoneNumber,
    required double currentQuantity,
    required String languageCode,
  }) async {
    final message = languageCode == 'en'
        ? 'Low inventory alert! You have only ${currentQuantity.toStringAsFixed(0)}kg of seeds left. Please restock soon. - iTraceLink'
        : 'Ibutsa ryo kubura imbuto! Usigaye ufite ${currentQuantity.toStringAsFixed(0)}kg gusa. Ongera uzane vuba. - iTraceLink';

    return await sendSMS(
      phoneNumber: phoneNumber,
      message: message,
    );
  }

  /// Send custom message
  Future<bool> sendCustomMessage({
    required String phoneNumber,
    required String message,
  }) async {
    return await sendSMS(
      phoneNumber: phoneNumber,
      message: message,
    );
  }

  // ==================== UTILITY METHODS ====================

  /// Format phone number to international format
  String _formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // If starts with 0, replace with country code
    if (cleaned.startsWith('0')) {
      cleaned = '250${cleaned.substring(1)}';
    }

    // If doesn't start with country code, add it
    if (!cleaned.startsWith('250') && !cleaned.startsWith('+250')) {
      cleaned = '250$cleaned';
    }

    // Ensure it starts with +
    if (!cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
    }

    return cleaned;
  }

  /// Format date for SMS (dd/MM/yyyy)
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Validate phone number format (Rwanda)
  bool isValidRwandaPhone(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Should be 12 digits total (250 + 9 digits)
    // Or 10 digits starting with 07
    // Or 9 digits starting with 7
    return cleaned.length == 12 ||
        (cleaned.length == 10 && cleaned.startsWith('07')) ||
        (cleaned.length == 9 && cleaned.startsWith('7'));
  }

  /// Check if SMS service is configured
  bool get isConfigured {
    return _apiKey.isNotEmpty && _username.isNotEmpty;
  }

  /// Get SMS balance (requires separate API call)
  Future<double?> getSmsBalance() async {
    // TODO: Implement balance check API
    // This would require a different endpoint
    return null;
  }

  // ==================== RETRY LOGIC ====================

  /// Send SMS with retry logic
  Future<bool> sendSMSWithRetry({
    required String phoneNumber,
    required String message,
    int maxRetries = 3,
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      final success = await sendSMS(
        phoneNumber: phoneNumber,
        message: message,
      );

      if (success) {
        return true;
      }

      // Wait before retry (exponential backoff)
      if (i < maxRetries - 1) {
        await Future.delayed(Duration(seconds: (i + 1) * 2));
      }
    }

    return false;
  }
}
