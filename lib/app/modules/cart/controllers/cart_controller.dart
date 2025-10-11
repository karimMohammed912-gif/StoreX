import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_x/app/data/models/cart_model/cart_item.dart';
import 'package:store_x/app/data/models/home_model/product.dart';
import 'package:store_x/app/services/sqlite_cart_service.dart';
import 'package:store_x/app/services/stripe_payment_service.dart';

class CartController extends GetxController {
  final SqliteCartService _cartService = Get.find<SqliteCartService>();
  final StripePaymentService _stripeService = Get.find<StripePaymentService>();

  // Getters from service
  List<CartItem> get cartItems => _cartService.cartItems;
  int get itemCount => _cartService.itemCount;
  int get totalQuantity => _cartService.totalQuantity;
  double get subtotal => _cartService.subtotal;
  double get totalDiscount => _cartService.totalDiscount;
  double get total => _cartService.total;

  // Add product to cart
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    final success = await _cartService.addToCart(product, quantity: quantity);
    if (success) {
      Get.snackbar(
        'Added to Cart',
        '${product.title} has been added to your cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to add product to cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Remove product from cart
  Future<void> removeFromCart(int productId) async {
    final success = await _cartService.removeFromCart(productId);
    if (success) {
      Get.snackbar(
        'Removed from Cart',
        'Product has been removed from your cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Increment quantity
  Future<void> incrementQuantity(int productId) async {
    await _cartService.incrementQuantity(productId);
  }

  // Decrement quantity
  Future<void> decrementQuantity(int productId) async {
    await _cartService.decrementQuantity(productId);
  }

  // Update quantity
  Future<void> updateQuantity(int productId, int newQuantity) async {
    await _cartService.updateQuantity(productId, newQuantity);
  }

  // Check if product is in cart
  bool isInCart(int productId) {
    return _cartService.isInCart(productId);
  }

  // Get cart item quantity
  int getCartItemQuantity(int productId) {
    return _cartService.getCartItemQuantity(productId);
  }

  // Clear cart
  Future<void> clearCart() async {
    final success = await _cartService.clearCart();
    if (success) {
      Get.snackbar(
        'Cart Cleared',
        'All items have been removed from your cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Proceed to checkout
  Future<void> proceedToCheckout() async {
    if (cartItems.isEmpty) {
      Get.snackbar(
        'Empty Cart',
        'Please add items to your cart before checkout',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final double amount = total;
    if (amount <= 0) {
      Get.snackbar(
        'Invalid amount',
        'Total must be greater than 0',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'Processing',
      'Creating payment... Please wait',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(milliseconds: 800),
    );

    try {
      // Prepare metadata with cart items
      final Map<String, dynamic> metadata = {
        'item_count': cartItems.length.toString(),
        'total_quantity': totalQuantity.toString(),
        'subtotal': subtotal.toStringAsFixed(2),
        'discount': totalDiscount.toStringAsFixed(2),
      };

      // Add product IDs and titles to metadata
      for (int i = 0; i < cartItems.length; i++) {
        final item = cartItems[i];
        metadata['product_${i + 1}_id'] = (item.product.id ?? '').toString();
        metadata['product_${i + 1}_title'] = item.product.title ?? '';
        metadata['product_${i + 1}_qty'] = item.quantity.toString();
      }

      // Debug: log amount and cart info
      // ignore: avoid_print
      print(
        'Checkout tapped: amount=${amount.toString()}, items=${cartItems.length}',
      );

      // Process payment
      final result = await _stripeService.presentPaymentSheet(
        amount: amount,
        currency: 'usd',
        metadata: metadata,
      );

      if (result.isSuccess) {
        Get.snackbar(
          'Payment Successful',
          'Paid \$${amount.toStringAsFixed(2)}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Clear cart after successful payment
        await clearCart();
      } else {
        Get.snackbar(
          'Payment Failed',
          result.errorMessage ?? 'Unknown error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error processing payment: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

