import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:store_x/app/modules/home/controllers/home_controller.dart';
import 'package:store_x/app/modules/home/views/components/category_chip_widget.dart';
import 'package:store_x/app/modules/home/views/components/custom_grid.dart';

class HomeBody extends StatelessWidget {
  HomeBody({super.key});
  final HomeController homeController = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(child: CategoryChips()),
        Obx(
          () => SliverGrid.builder(
            itemCount: homeController.data.value?.products?.length ?? 0,

            itemBuilder: (context, index) {
              final product = homeController.data.value?.products?[index];
              return CustomGrid(product: product);
            },

            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 2,
              crossAxisSpacing: .2,
              childAspectRatio: 0.75,
            ),
          ),
        ),
      ],
    );
  }
}
