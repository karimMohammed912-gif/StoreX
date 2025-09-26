import 'package:flutter/cupertino.dart';
import 'package:store_x/app/modules/favourite/view/favourite_screen.dart';
import 'package:store_x/app/modules/home/views/components/home_body.dart';
import 'package:store_x/app/modules/profile/view/profile_screen.dart';
import 'package:store_x/app/modules/search/view/search_screen.dart';

List<Widget> homeWidgets = [
  HomeBody(),
  SearchScreen(),
  FavouriteScreen(),
  ProfileScreen(),
];
