import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_x/app/modules/auth/controllers/auth_controller.dart';
import 'package:store_x/app/modules/auth/view/components/field_widget.dart';
import 'package:store_x/app/modules/auth/view/components/login_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthController auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              Text(
                ' Login To StoreX ',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6.h),
              Text(
                'Create your account to get started in just a few steps. Join us today and unlock full access instantly.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
              ),
              SizedBox(height: 16.h),

              FieldWidget(
                hint: 'Username',
                controller: emailController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                obscure: false,
              ),
              SizedBox(height: 10.h),
              FieldWidget(
                hint: 'Password',
                controller: passwordController,
                obscure: true,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.visiblePassword,
              ),
              SizedBox(height: 10.h),

              Row(
                children: [
                  Obx(
                    () => Checkbox(
                      value: auth.agreeToTerms.value,
                      onChanged: (v) => auth.agreeToTerms.value = v ?? false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'I confirm that I am 18 years or older and agree to the Terms & Conditions below.',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: LoginButton(
                    auth: auth,
                    emailController: emailController,
                    passwordController: passwordController,
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
