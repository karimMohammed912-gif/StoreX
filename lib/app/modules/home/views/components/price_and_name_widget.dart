import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_x/app/data/models/home_model/product.dart';
import 'package:store_x/app/services/sqlite_favorites_service.dart';

class PriceAndNameWidget extends StatelessWidget {
  const PriceAndNameWidget({super.key, required this.product});
  final Product? product;

  @override
  Widget build(BuildContext context) {
    final SqliteFavoritesService favoritesService =
        Get.find<SqliteFavoritesService>();

    return Row(
      children: [
        SizedBox(width: 10.w),
        Column(
          children: [
            Text(
              "${product?.price?.toString()}\$",
              style: TextStyle(fontSize: 15.sp, color: Colors.green),
            ),
            SizedBox(
              width: 90.w,
              child: Text(
                product?.title ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Spacer(),
        Obx(() {
          final bool isFavorite = favoritesService.favoriteProducts.any(
            (p) => p.id == product?.id,
          );
          return IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
              size: 25.sp,
            ),
            onPressed: () async {
              await favoritesService.toggleFavorite(product);
            },
          );
        }),
      ],
    );
  }
}
