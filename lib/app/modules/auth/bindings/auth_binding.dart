import 'package:get/get.dart';
import 'package:store_x/app/modules/auth/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Keep a single instance across the app so auth state isn't reset on route rebuilds
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
  }
}


