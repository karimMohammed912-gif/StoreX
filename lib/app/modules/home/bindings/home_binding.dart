// lib/app/modules/home/bindings/home_binding.dart
import 'package:get/get.dart';
import 'package:store_x/app/data/repositories/home_repo.dart';
import 'package:store_x/app/modules/home/controllers/home_controller.dart';
import 'package:store_x/app/networking/api.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Api>(() => Api());
    Get.lazyPut<HomeRepo>(() => HomeRepo());
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<HomeRepo>()),
      fenix: true, // Keep controller alive and reusable
    );
  }
}
