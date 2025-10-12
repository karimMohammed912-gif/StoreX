import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_x/app/modules/home/controllers/home_controller.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      "all",
      "beauty",
      "fragrances",
      "furniture",
      "groceries",
      "home-decoration",
      "kitchen-accessories",
      "laptops",
      "mens-shirts",
      "mens-shoes",
      "mens-watches",
      "mobile-accessories",
      "motorcycle",
      "skin-care",
      "smartphones",
      "sports-accessories",
      "sunglasses",
      "tablets",
      "tops",
      "vehicle",
      "womens-bags",
      "womens-dresses",
      "womens-jewellery",
      "womens-shoes",
      "womens-watches",
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: GetBuilder<HomeController>(
        builder: (homeController) {
          return Obx(() {
            final selectedCategory = homeController.selectedCategory.value ?? 'all';
            return Row(
              children: List.generate(categories.length, (index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    label: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                    selected: isSelected,
                    selectedColor: Colors.black,
                    backgroundColor: Colors.grey.shade200,
                    onSelected: (val) {
                      homeController.fetchHome(category: category);
                    },
                  ),
                );
              }),
            );
          });
        },
      ),
    );
  }
}
