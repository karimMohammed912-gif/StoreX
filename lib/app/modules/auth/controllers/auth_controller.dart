import 'dart:developer';

import 'package:get/get.dart';
import 'package:store_x/app/modules/auth/user_model/user_model.dart';
import 'package:store_x/app/networking/api.dart';
import 'package:store_x/app/services/session_service.dart';
import 'package:store_x/app/services/sqlite_favorites_service.dart';
import 'package:store_x/app/modules/home/controllers/home_controller.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final agreeToTerms = false.obs;
  final SessionService _session = SessionService();

  bool get isLoggedIn => currentUser.value != null;
  

  @override
  void onInit() {
    super.onInit();
    _restoreSessionSync();
  }

  @override
  void onReady() {
    super.onReady();
    log('isLoggedIn at the controller: $isLoggedIn');
  }

  void _restoreSessionSync() {
    _session.loadUser().then((user) {
      if (user != null) {
        currentUser.value = user;
        Api.setAuthToken(user.accessToken);
        log('Session restored for user: ${user.email}');
      } else {
        log('No session found');
        currentUser.value = null;
      }
      // Trigger UI update after session restoration
      update();
    }).catchError((e) {
      log('Error restoring session: $e');
      currentUser.value = null;
      update();
    });
  }

  Future<void> login({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Missing fields',
        'Email and password are required',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    isLoading.value = true;
    try {
      final user = await Api.login(email, password);
      currentUser.value = user;
      await _session.saveUser(user);
      Api.setAuthToken(user.accessToken);
      
      // Reset favorites service for new user session
      try {
        final favoritesService = Get.find<SqliteFavoritesService>();
        await favoritesService.resetForNewUser();
        print('Favorites service reset for new user: ${user.email}');
      } catch (e) {
        print('Error resetting favorites service: $e');
      }
      
      // Reset home controller if it exists
      try {
        if (Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();
          homeController.reset();
          print('HomeController reset for new session');
        }
      } catch (e) {
        print('HomeController not yet initialized or error: $e');
      }
      
      // Navigate to home after setting user
      if (Get.currentRoute != '/') {
        Get.offAllNamed('/');
      } else {
        // Force rebuild of root decision by re-triggering route
        Get.offAllNamed('/');
      }
    } catch (e) {
      Get.snackbar(
        'Login failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    currentUser.value = null;
    await _session.clear();
    
    // Clear favorites when user logs out
    try {
      final favoritesService = Get.find<SqliteFavoritesService>();
      await favoritesService.clearAllFavorites();
      print('Favorites cleared on logout');
    } catch (e) {
      print('Error clearing favorites on logout: $e');
    }
    
    if (Get.currentRoute != '/auth') {
      Get.offAllNamed('/auth');
    }
  }
}