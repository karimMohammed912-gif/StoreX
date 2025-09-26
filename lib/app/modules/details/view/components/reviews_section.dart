import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:store_x/app/data/models/home_model/review.dart';

class ReviewsSection extends StatelessWidget {
  final int reviewCount;
  final List<Review>? reviews;

  const ReviewsSection({
    super.key,
    required this.reviewCount,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews ($reviewCount)',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        ...reviews!
            .map(
              (review) => _buildReviewItem(
                review.reviewerName,
                review.rating,
                review.comment,
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildReviewItem(String? name, int? rating, String? comment) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name ?? 'Anonymous',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 8.w),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < (rating ?? 0) ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 14.sp,
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            comment ?? '',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
