import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';

class StripePaymentService extends GetxService {
  static const String _publishableKey =
      ''; // Replace with your test publishable key
  static const String _secretKey = ''; // Replace with your test secret key

  final GetConnect _client = GetConnect(timeout: const Duration(seconds: 20));

  /// Optional backend base URL that creates PaymentIntents and returns
  /// { client_secret, id, amount, currency }
  String? paymentBackendBaseUrl;
  @override
  void onInit() {
    super.onInit();
    _initializeStripe();
  }

  void _initializeStripe() {
    Stripe.publishableKey = _publishableKey;
  }

  /// Initialize Stripe with custom keys
  Future<void> initializeStripe({required String publishableKey}) async {
    Stripe.publishableKey = publishableKey;
  }

  /// Configure your dev backend base URL
  void configureBackend({required String baseUrl}) {
    paymentBackendBaseUrl = baseUrl;
  }

  /// Create a payment intent on your backend
  /// This method should call your backend API to create a payment intent
  Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final int amountInMinor = (amount * 100).round();

      // If a backend is configured, call it; otherwise return a simulated intent
      if (paymentBackendBaseUrl != null && paymentBackendBaseUrl!.isNotEmpty) {
        final String normalized = paymentBackendBaseUrl!.endsWith('/')
            ? paymentBackendBaseUrl!.substring(
                0,
                paymentBackendBaseUrl!.length - 1,
              )
            : paymentBackendBaseUrl!;
        final String url = '$normalized/create-payment-intent';
        final response = await _client.post(
          'https://api.stripe.com/v1/payment_intents',
          {
            'amount': amountInMinor.toString(),
            'currency': currency,
            'automatic_payment_methods[enabled]': 'true',
            if (metadata != null)
              ...metadata.map((k, v) => MapEntry('metadata[$k]', v.toString())),
          },
          headers: {
            'Authorization': 'Bearer ' + _secretKey, // test secret key
          },
          contentType: 'application/x-www-form-urlencoded',
        );

        if (response.isOk &&
            response.body is Map &&
            response.body['client_secret'] != null) {
          final Map body = response.body;
          return {
            'client_secret': body['client_secret'],
            'id': body['id'],
            'amount': body['amount'],
            'currency': body['currency'],
            'status': body['status'],
          };
        }


        return null;
      }

      // Simulated response for development without backend
      return {
        'client_secret': _secretKey,
        'id': 'pi_test_1234567890abcdef',
        'amount': amountInMinor,
        'currency': currency,
        'status': 'requires_payment_method',
      };
    } catch (e) {
      print('Error creating payment intent: $e');
      return null;
    }
  }

  /// Process payment with Stripe using Payment Sheet (Recommended approach)
  Future<PaymentResult> processPayment({
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
          // cud them if you have customer management
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

  /// Process payment with saved payment method using Payment Sheet
  Future<PaymentResult> processPaymentWithSavedMethod({
    required String paymentMethodId,
    required double amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final paymentIntent = await createPaymentIntent(
        amount: amount,
        currency: currency,
        metadata: metadata,
      );

      if (paymentIntent == null) {
        return PaymentResult.failure('Failed to create payment intent');
      }

      // Initialize payment sheet with saved payment method
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Store X',
          // You can specify default payment method here
          // defaultPaymentMethod: paymentMethodId,
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

  /// Create a payment method (for saving cards)
  Future<PaymentMethod?> createPaymentMethod({
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cvc,
    String? cardholderName,
  }) async {
    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(name: cardholderName),
          ),
        ),
      );
      return paymentMethod;
    } catch (e) {
      print('Error creating payment method: $e');
      return null;
    }
  }

  /// Present payment sheet for easier payment processing
  Future<PaymentResult> presentPaymentSheet({
    required double amount,
    required String currency,
    Map<String, dynamic>? metadata,
    String? customerId,
    String? customerEphemeralKeySecret,
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
    return PaymentResult._(isSuccess: false, errorMessage: errorMessage);
  }
}
