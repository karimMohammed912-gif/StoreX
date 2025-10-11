import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_x/app/modules/cart/controllers/cart_controller.dart';
import 'package:store_x/app/modules/cart/view/components/cart_item_widget.dart';
import 'package:store_x/app/modules/cart/view/components/empty_cart_widget.dart';
import 'package:store_x/app/modules/cart/view/components/cart_summary_widget.dart';

class CartScreen extends GetView<CartController> {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          Obx(() => controller.cartItems.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _showClearCartDialog(context),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return const EmptyCartWidget();
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = controller.cartItems[index];
                  return CartItemWidget(
                    cartItem: cartItem,
                    onIncrement: () =>
                        controller.incrementQuantity(cartItem.product.id!),
                    onDecrement: () =>
                        controller.decrementQuantity(cartItem.product.id!),
                    onRemove: () =>
                        controller.removeFromCart(cartItem.product.id!),
                  );
                },
              ),
            ),
            CartSummaryWidget(
              subtotal: controller.subtotal,
              discount: controller.totalDiscount,
              total: controller.total,
              onCheckout: controller.proceedToCheckout,
            ),
          ],
        );
      }),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearCart();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

