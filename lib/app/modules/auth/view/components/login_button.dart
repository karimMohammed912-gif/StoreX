import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_x/app/modules/auth/controllers/auth_controller.dart';
import 'package:store_x/app/services/session_service.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
    required this.auth,
    required this.emailController,
    required this.passwordController,
  });

  final AuthController auth;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Obx(() => ElevatedButton(
                  onPressed: auth.isLoading.value
                      ? null
                      : () async {
                          if (!auth.agreeToTerms.value) {
                            Get.snackbar(
                              'Agreement required',
                              'Please agree to the Terms & Conditions',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          await auth.login(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );

                          if (auth.isLoggedIn) {
                            SessionService().saveUser(auth.currentUser.value!);
                            print('isLoggedIn: ${auth.isLoggedIn}');
                            Get.toNamed('/');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ),
                  child: auth.isLoading.value
                      ? SizedBox(
                          height: 20.w,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ));
  }
}
