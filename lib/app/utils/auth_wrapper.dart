// generate a router config file

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_x/app/modules/auth/controllers/auth_controller.dart';
import 'package:store_x/app/modules/auth/view/auth_screen.dart';
import 'package:store_x/app/modules/home/views/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      init: Get.find<AuthController>(),
      builder: (authController) {
        // Show loading while session is being restored
        if (authController.currentUser.value == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return authController.isLoggedIn ? const HomeScreen() : const AuthScreen();
      },
    );
  }
}
