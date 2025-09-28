import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';



class StripePaymentService extends GetxService {
  // Test keys for development - replace with your actual test keys
  static const String _publishableKey = 'Your Own publishable Key';
  static const String _secretKey = 'Your Own secret Key';
  
  final Dio _dio = Dio();

  @override
  void onInit() {
    super.onInit();
    _initializeStripe();
  }

  void _initializeStripe() {
    Stripe.publishableKey = _publishableKey;
  }

  /// Create a payment intent using Stripe API
  Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final int amountInMinor = (amount * 100).round();

      // Create payment intent using Stripe API
      final response = await _dio.post(
        'https://api.stripe.com/v1/payment_intents',
        data: {
          'amount': amountInMinor,
          'currency': currency,
          'automatic_payment_methods[enabled]': true,
          if (metadata != null) 'metadata': metadata,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_secretKey',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {
          'client_secret': response.data['client_secret'],
          'id': response.data['id'],
          'amount': response.data['amount'],
          'currency': response.data['currency'],
          'status': response.data['status'],
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Present payment sheet for payment processing
  Future<PaymentResult> presentPaymentSheet({
    required double amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Create payment intent
      final paymentIntent = await createPaymentIntent(
        amount: amount,
        currency: currency,
        metadata: metadata,
      );

      if (paymentIntent == null) {
        return PaymentResult.failure('Failed to create payment intent');
      }

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Store X',
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      return PaymentResult.success(
        paymentIntentId: paymentIntent['id'],
        amount: amount,
        currency: currency,
      );
    } catch (e) {
      if (e is StripeException) {
        return PaymentResult.failure('Payment failed: ${e.error.message}');
      }
      return PaymentResult.failure('Payment error: ${e.toString()}');
    }
  }
}

/// Payment result class
class PaymentResult {
  final bool isSuccess;
  final String? paymentIntentId;
  final double? amount;
  final String? currency;
  final String? errorMessage;

  PaymentResult._({
    required this.isSuccess,
    this.paymentIntentId,
    this.amount,
    this.currency,
    this.errorMessage,
  });

  factory PaymentResult.success({
    required String paymentIntentId,
    required double amount,
    required String currency,
  }) {
    return PaymentResult._(
      isSuccess: true,
      paymentIntentId: paymentIntentId,
      amount: amount,
      currency: currency,
    );
  }

  factory PaymentResult.failure(String errorMessage) {
    return PaymentResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}
