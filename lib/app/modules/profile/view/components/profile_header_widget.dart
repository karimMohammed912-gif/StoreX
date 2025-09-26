import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_x/app/modules/auth/controllers/auth_controller.dart';

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find<AuthController>();
    return Obx(() {
      final user = auth.currentUser.value;
      final String displayName =
          ((user?.firstName ?? '').trim().isNotEmpty ||
              (user?.lastName ?? '').trim().isNotEmpty)
          ? ('${user?.firstName ?? ''} ${user?.lastName ?? ''}').trim()
          : (user?.username ?? 'Guest');
      final String email = user?.email ?? 'guest@example.com';
      final String? image = user?.image;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24.r),
            bottomRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          children: [
            // Profile Picture
            Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey[200]!, width: 3),
                image: image != null && image.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (image == null || image.isEmpty)
                  ? Center(
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(height: 16.h),

            // Name and Email
            Text(
              displayName,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              email,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 8.h),

            // Edit Profile Button
           
          ],
        ),
      );
    });
  }
}
