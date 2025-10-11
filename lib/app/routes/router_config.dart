// generate a router config file
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_x/app/modules/home/bindings/home_binding.dart';
import 'package:store_x/app/modules/details/view/details_screen.dart';
import 'package:store_x/app/modules/search/view/search_screen.dart';
import 'package:store_x/app/modules/search/bindings/search_binding.dart';
import 'package:store_x/app/modules/auth/bindings/auth_binding.dart';
import 'package:store_x/app/modules/auth/view/auth_screen.dart';
import 'package:store_x/app/modules/cart/view/cart_screen.dart';
import 'package:store_x/app/modules/cart/bindings/cart_binding.dart';
import 'package:store_x/app/utils/auth_wrapper.dart';

final routes = [
  GetPage(
    name: '/',
    page: () => const AuthWrapper(),
    bindings: [AuthBinding(), HomeBinding()],
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
  GetPage(
    name: '/cart',
    page: () => SafeArea(child: const CartScreen()),
    binding: CartBinding(),
  ),
];
