import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:store_x/app/modules/favourite/view/components/favorite_item_widget.dart';
import 'package:store_x/app/services/services.dart';

class FavoritesListWidget extends StatelessWidget {
  const FavoritesListWidget({
    super.key,
    required this.favoritesService,
  });

  final SqliteFavoritesService favoritesService;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${favoritesService.favoriteProducts.length} Items in Favorites',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView.builder(
              itemCount: favoritesService.favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = favoritesService.favoriteProducts[index];
                return FavoriteItemWidget( favoritesService:SqliteFavoritesService() , product: product, index: index,);
              },
            ),
          ),
        ],
      ),
    );
  }
}
