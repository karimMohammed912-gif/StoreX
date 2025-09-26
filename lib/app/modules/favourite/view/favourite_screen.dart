import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_x/app/modules/favourite/view/components/empty_state_widget.dart';
import 'package:store_x/app/modules/favourite/view/components/favorites_list_widget.dart';
import 'package:store_x/app/services/services.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  final SqliteFavoritesService favoritesService =
      Get.find<SqliteFavoritesService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Favorites',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () => favoritesService.favoriteProducts.isEmpty
            ? EmptyStateWidget()
            : FavoritesListWidget(favoritesService: favoritesService),
      ),
    );
  }

  // Removed obsolete local mutators; favorites are managed by SqliteFavoritesService
}
