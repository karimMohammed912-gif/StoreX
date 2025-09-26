import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_x/app/data/models/home_model/product.dart';
import 'package:store_x/app/modules/home/views/components/price_and_name_widget.dart';

class CustomGrid extends StatelessWidget {
  const CustomGrid({super.key, required this.product});
  final Product? product;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed("/details", arguments: product),
      child: Container(
        margin: EdgeInsets.all(8.sp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.sp),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.star, size: 22.sp, color: Colors.amber),
                SizedBox(width: 3.w),
                Text(
                  product?.rating.toString() ?? '4.5',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 5),
              ],
            ),

            Container(
              height: 100.h,
              width: 100.w,
              color: Colors.white,
              child: CachedNetworkImage(
                imageUrl: product?.thumbnail ?? '',
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(height: 5.h),
            PriceAndNameWidget(product: product),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }
}
