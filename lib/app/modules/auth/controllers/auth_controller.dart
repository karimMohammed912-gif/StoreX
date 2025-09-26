import 'package:get/get.dart';
import 'package:store_x/app/modules/auth/user_model/user_model.dart';
import 'package:store_x/app/networking/api.dart';
import 'package:store_x/app/services/session_service.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final agreeToTerms = false.obs;
  final SessionService _session = SessionService();

  bool get isLoggedIn => currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final user = await _session.loadUser();
    if (user != null) {
      currentUser.value = user;
      Api.setAuthToken(user.accessToken);
    }
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
    if (Get.currentRoute != '/auth') {
      Get.offAllNamed('/auth');
    }
  }
}
