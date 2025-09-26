import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductPrice extends StatelessWidget {
  final double originalPrice;
  final double discountPercentage;

  const ProductPrice({
    super.key,
    required this.originalPrice,
    required this.discountPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '\$${originalPrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(width: 12.w),
        // Text(
        //   '\$${originalPrice.toStringAsFixed(2)}',
        //   style: TextStyle(
        //     fontSize: 18.sp,
        //     color: Colors.grey[500],
        //     decoration: TextDecoration.lineThrough,
        //   ),
        // ),
        SizedBox(width: 6.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '${discountPercentage.toInt()}% OFF',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
        ),
      ],
    );
  }
}
