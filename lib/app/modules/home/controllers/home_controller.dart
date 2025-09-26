// lib/app/modules/home/controllers/home_controller.dart
import 'package:get/get.dart';
import 'package:store_x/app/data/models/home_model/home_model.dart';
import 'package:store_x/app/data/repositories/home_repo.dart';

class HomeController extends GetxController {
  HomeController(this._repo);
  final HomeRepo _repo;

  final isLoading = false.obs;
  final error = RxnString();
  final data = Rxn<HomeModel>();
  final selectedCategory = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchHome(); // default fetch
  }

  Future<void> fetchHome({String? category}) async {
    isLoading.value = true;
    error.value = null;
    selectedCategory.value = category ?? 'smartphones'; // fallback
    final result = await _repo.getHomeData(category: selectedCategory.value);

    result.fold(
      (failure) {
        error.value = failure.message;
        data.value = null;
      },
      (home) {
        data.value = home;
      },
    );

    isLoading.value = false;
  }

  bool get hasError => error.value != null;
  bool get hasData => data.value != null;
}
