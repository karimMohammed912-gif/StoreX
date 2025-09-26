import 'dart:async';
import 'package:get/get.dart';
import 'package:store_x/app/data/repositories/search_repo.dart';

class SearchController extends GetxController {
  SearchController(this._repo);

  final SearchRepo _repo;

  final query = ''.obs;
  final isLoading = false.obs;
  final error = RxnString();
  final results = <dynamic>[].obs;

  Timer? _debounce;

  void onQueryChanged(String value) {
    query.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    final q = query.value.trim();
    if (q.isEmpty) {
      results.clear();
      error.value = null;
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    error.value = null;
    final either = await _repo.searchProducts(q);
    either.fold((failure) {
      error.value = failure.message;
      results.clear();
    }, (items) {
      results.assignAll(items);
    });
    isLoading.value = false;
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}


