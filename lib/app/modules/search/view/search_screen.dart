import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:store_x/app/modules/search/controllers/search_controller.dart';
import 'package:store_x/app/modules/home/views/components/custom_grid.dart';
import 'package:store_x/app/data/repositories/search_repo.dart';

class SearchScreen extends GetView<SearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SearchRepo>()) {
      Get.put(SearchRepo());
    }
    if (!Get.isRegistered<SearchController>()) {
      Get.put(SearchController(Get.find<SearchRepo>()));
    }
    final controller = this.controller;

    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            onChanged: controller.onQueryChanged,
            decoration: const InputDecoration(
              hintText: 'Search products',
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value != null) {
          return Center(child: Text(controller.error.value!));
        }
        if (controller.results.isEmpty) {
          return const Center(child: Text('Start typing to search products'));
        }
        return GridView.builder(
  
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 2,
            crossAxisSpacing: .2,
            childAspectRatio: 0.75,
          ),
          itemCount: controller.results.length,
          itemBuilder: (context, index) {
            final product = controller.results[index];
            return CustomGrid(product: product);
          },
        );
      }),
    );
  }
}
