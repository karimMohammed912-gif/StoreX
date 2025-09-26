// generate a router config file
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_x/app/modules/home/bindings/home_binding.dart';
import 'package:store_x/app/modules/details/view/details_screen.dart';
import 'package:store_x/app/modules/home/views/home_screen.dart';
import 'package:store_x/app/modules/search/view/search_screen.dart';
import 'package:store_x/app/modules/search/bindings/search_binding.dart';
import 'package:store_x/app/modules/auth/bindings/auth_binding.dart';
import 'package:store_x/app/modules/auth/controllers/auth_controller.dart';
import 'package:store_x/app/modules/auth/view/auth_screen.dart';

bool get isLoggedIn => Get.isRegistered<AuthController>() && Get.find<AuthController>().isLoggedIn;

final routes = [
  GetPage(
    name: '/',
    page: () => isLoggedIn ? const HomeScreen() : const AuthScreen(),
    bindings: [HomeBinding(), AuthBinding()],
  ),
  GetPage(
    name: '/details',
    page: () => SafeArea(child: DetailsScreen()),
  ),
  GetPage(
    name: '/search',
    page: () => SafeArea(child: const SearchScreen()),
    bindings: [SearchBinding()],
  ),
  GetPage(
    name: '/auth',
    page: () => const AuthScreen(),
    binding: AuthBinding(),
  ),
];
