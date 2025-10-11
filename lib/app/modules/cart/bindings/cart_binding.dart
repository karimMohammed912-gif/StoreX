import 'package:get/get.dart';
import 'package:store_x/app/modules/cart/controllers/cart_controller.dart';
import 'package:store_x/app/services/sqlite_cart_service.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize cart service if not already done
    if (!Get.isRegistered<SqliteCartService>()) {
      Get.put<SqliteCartService>(SqliteCartService());
    }
    
    // Initialize cart controller
    Get.lazyPut<CartController>(() => CartController());
  }
}

