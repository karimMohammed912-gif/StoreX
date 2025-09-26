import 'package:get/get.dart';
import '../data/models/home_model/product.dart';
import 'stripe_payment_service.dart';
import 'sqlite_favorites_service.dart';

/// Example controller showing how to use the payment and favorites services
class ExampleUsageController extends GetxController {
  final StripePaymentService _stripeService = Get.find<StripePaymentService>();
  final SqliteFavoritesService _favoritesService =
      Get.find<SqliteFavoritesService>();

  // Observable for UI updates
  final RxBool isProcessingPayment = false.obs;
  final RxString paymentStatus = ''.obs;

  /// Example: Process a payment for a product using Payment Sheet
  Future<void> processProductPayment(Product product) async {
    if (product.price == null) {
      paymentStatus.value = 'Product price not available';
      return;
    }

    isProcessingPayment.value = true;
    paymentStatus.value = 'Processing payment...';

    try {
      final result = await _stripeService.processPayment(
        amount: product.price!,
        currency: 'usd',
        metadata: {
          'product_id': product.id.toString(),
          'product_title': product.title ?? '',
        },
      );

      if (result.isSuccess) {
        paymentStatus.value = 'Payment successful!';
        // Add to favorites after successful payment
        await _favoritesService.addToFavorites(product);
      } else {
        paymentStatus.value = 'Payment failed: ${result.errorMessage}';
      }
    } catch (e) {
      paymentStatus.value = 'Payment error: $e';
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// Example: Process payment with Payment Sheet (alternative method)
  Future<void> processPaymentWithSheet(Product product) async {
    if (product.price == null) {
      paymentStatus.value = 'Product price not available';
      return;
    }

    isProcessingPayment.value = true;
    paymentStatus.value = 'Opening payment sheet...';

    try {
      final result = await _stripeService.presentPaymentSheet(
        amount: product.price!,
        currency: 'usd',
        metadata: {
          'product_id': product.id.toString(),
          'product_title': product.title ?? '',
        },
      );

      if (result.isSuccess) {
        paymentStatus.value = 'Payment successful!';
        await _favoritesService.addToFavorites(product);
      } else {
        paymentStatus.value = 'Payment failed: ${result.errorMessage}';
      }
    } catch (e) {
      paymentStatus.value = 'Payment error: $e';
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// Example: Toggle favorite status
  Future<void> toggleFavorite(Product product) async {
    if (product.id == null) return;

    final success = await _favoritesService.toggleFavorite(product);
    if (success) {
      final isFavorite = _favoritesService.favoriteProducts.any(
        (p) => p.id == product.id,
      );
      print('Product ${isFavorite ? 'added to' : 'removed from'} favorites');
    }
  }

  /// Example: Get favorite products count
  int get favoriteCount => _favoritesService.favoriteCount;

  /// Example: Search favorites
  List<Product> searchFavorites(String query) {
    return _favoritesService.searchFavorites(query);
  }

  /// Example: Get favorites by category
  List<Product> getFavoritesByCategory(String category) {
    return _favoritesService.getFavoritesByCategory(category);
  }

  /// Example: Clear all favorites
  Future<void> clearAllFavorites() async {
    final success = await _favoritesService.clearAllFavorites();
    if (success) {
      print('All favorites cleared');
    }
  }
}
