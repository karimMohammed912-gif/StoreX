import 'package:flutter/material.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_x/app/utils/home_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(35.r),
              bottomRight: Radius.circular(35.r),
            ),
          ),
          backgroundColor: Colors.black,
          elevation: 0,
          title: Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Text(
              'StoreX',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Get.toNamed('/search');
              },
              icon: Icon(size: 30.sp, Icons.search, color: Colors.white),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: PageView.builder(
          itemCount: homeWidgets.length,
          physics: const NeverScrollableScrollPhysics(),
          controller: PageController(initialPage: selectedIndex),
          itemBuilder: (context, index) {
            index = selectedIndex;
            return homeWidgets[index];
          },
        ),
      ),
      bottomNavigationBar: FloatingNavbar(
        itemBorderRadius: 20.sp,
        iconSize: 25.sp,
        borderRadius: 20.sp,
        margin: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),

        items: [
          FloatingNavbarItem(icon: Icons.home_rounded),
          FloatingNavbarItem(icon: Icons.search),
          FloatingNavbarItem(icon: Icons.favorite),
          FloatingNavbarItem(icon: Icons.person),
        ],

        currentIndex: selectedIndex,
        onTap: (int val) {
          setState(() {
            selectedIndex = val;
          });
        },
      ),
    );
  }
}
