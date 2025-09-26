import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_x/app/modules/profile/view/components/stat_item_widget.dart';
import 'package:store_x/app/modules/profile/view/profile_screen.dart';
import 'package:store_x/app/services/sqlite_favorites_service.dart';

class ProfileStatsWidget extends StatelessWidget {
  const ProfileStatsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final SqliteFavoritesService favs = Get.find<SqliteFavoritesService>();
    return Obx(
      () => Container(
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child:StatItemWidget(
         
         
          label: favs.favoriteCount.toString(), value: 'Favorites', icon: Icons.favorite_outline,
        ),
      ),
    );
  }
}
