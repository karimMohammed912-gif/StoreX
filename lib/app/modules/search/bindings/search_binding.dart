import 'package:get/get.dart';
import 'package:store_x/app/data/repositories/search_repo.dart';
import 'package:store_x/app/modules/search/controllers/search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchRepo>(() => SearchRepo());
    Get.lazyPut<SearchController>(() => SearchController(Get.find<SearchRepo>()));
  }
}


