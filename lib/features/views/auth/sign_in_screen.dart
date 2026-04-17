/**
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/features/views/auth/forgot_password.dart';
import 'package:outdoor_therapy/features/views/auth/sign_up_screen.dart';

import '../../../core/app_colors.dart';
import 'controller/sign_in_screen_controller.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final SignInScreenController controller = Get.put(SignInScreenController());

    return Scaffold(
      backgroundColor: const Color(0xff030712),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Top Icon - Fixed SVG implementation
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xff101828),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: SvgPicture.asset(
                      'assets/images/logo.svg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.scaleDown,
                      placeholderBuilder: (BuildContext context) => Container(
                        padding: const EdgeInsets.all(16.0),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xff615fff),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Title
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xfff9fafb),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Sign in to continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.lightGreyColor,
                  ),
                ),

                const SizedBox(height: 40),

                /// Error message display
                Obx(() {
                  if (controller.generalErrorMessage.value.isNotEmpty) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.generalErrorMessage.value,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),

                /// Email
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email",
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Obx(() => TextField(
                  controller: controller.emailController,
                  style: const TextStyle(color: AppColors.whiteColor),
                  decoration: InputDecoration(
                    hintText: "your@email.com",
                    hintStyle: const TextStyle(color: AppColors.lightGreyColor),
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.lightGreyColor),
                    filled: true,
                    fillColor: const Color(0xff101828),
                    errorText: controller.emailError.value.isEmpty ? null : controller.emailError.value,
                    errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xff364153)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xff364153)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                )),

                const SizedBox(height: 20),

                /// Password
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Password",
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Obx(() => TextField(
                  controller: controller.passwordController,
                  obscureText: !controller.isPasswordVisible.value,
                  style: const TextStyle(color: AppColors.whiteColor),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.lightGreyColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.lightGreyColor,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                    filled: true,
                    fillColor: const Color(0xff101828),
                    errorText: controller.passwordError.value.isEmpty ? null : controller.passwordError.value,
                    errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xff364153)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xff364153)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xff615fff), width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                )),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => const ForgotPasswordScreen());
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Color(0xff615fff),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// Sign In Button
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff615fff),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                      controller.loginUser();
                    },
                    child: controller.isLoading.value
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )),

                const SizedBox(height: 30),

                /// Divider
                Row(
                  children: const [
                    Expanded(
                      child: Divider(color: Color(0xff4a5565), thickness: 1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "OR",
                        style: TextStyle(color: AppColors.lightGreyColor),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Color(0xff4a5565), thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// Google Button
                GestureDetector(
                  onTap: () => controller.continueWithGoogle(),
                  child: socialButton(
                    icon: Icons.g_mobiledata,
                    text: "Continue with Google",
                  ),
                ),

                const SizedBox(height: 10),

                /// Apple Button
                GestureDetector(
                  onTap: () => controller.continueWithApple(),
                  child: socialButton(
                    icon: Icons.apple,
                    text: "Continue with Apple",
                  ),
                ),

                const SizedBox(height: 30),

                /// Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: AppColors.lightGreyColor),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const SignUpScreen());
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Color(0xff615fff),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget socialButton({required IconData icon, required String text}) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xff101828),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xff364153)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/










///
///
///
/// todo:: fixing overflow
///
///
///



import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/features/views/auth/forgot_password.dart';
import 'package:outdoor_therapy/features/views/auth/sign_up_screen.dart';

import '../../../core/app_colors.dart';
import 'controller/sign_in_screen_controller.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final SignInScreenController controller = Get.put(SignInScreenController());

    return Scaffold(
      backgroundColor: const Color(0xff030712),
      resizeToAvoidBottomInset: true, // This helps with keyboard handling
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),

                        /// Top Icon
                        Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xff101828),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: SvgPicture.asset(
                              'assets/images/logo.svg',
                              width: 50,
                              height: 50,
                              fit: BoxFit.scaleDown,
                              placeholderBuilder: (BuildContext context) => Container(
                                padding: const EdgeInsets.all(16.0),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xff615fff),
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// Title
                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xfff9fafb),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "Sign in to continue",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.lightGreyColor,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        /// Error message display
                        Obx(() {
                          if (controller.generalErrorMessage.value.isNotEmpty) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      controller.generalErrorMessage.value,
                                      style: const TextStyle(color: Colors.red, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),

                        /// Email
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Email",
                            style: TextStyle(
                              color: AppColors.whiteColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Obx(() => TextField(
                          controller: controller.emailController,
                          style: const TextStyle(color: AppColors.whiteColor),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: "your@email.com",
                            hintStyle: const TextStyle(color: AppColors.lightGreyColor),
                            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.lightGreyColor),
                            filled: true,
                            fillColor: const Color(0xff101828),
                            errorText: controller.emailError.value.isEmpty ? null : controller.emailError.value,
                            errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xff364153)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xff364153)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        )),

                        const SizedBox(height: 20),

                        /// Password
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Password",
                            style: TextStyle(
                              color: AppColors.whiteColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Obx(() => TextField(
                          controller: controller.passwordController,
                          obscureText: !controller.isPasswordVisible.value,
                          style: const TextStyle(color: AppColors.whiteColor),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (value) {
                            controller.loginUser();
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.lightGreyColor),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordVisible.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.lightGreyColor,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                            filled: true,
                            fillColor: const Color(0xff101828),
                            errorText: controller.passwordError.value.isEmpty ? null : controller.passwordError.value,
                            errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xff364153)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xff364153)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xff615fff), width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        )),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => const ForgotPasswordScreen());
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Color(0xff615fff),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        /// Sign In Button
                        Obx(() => SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff615fff),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                              controller.loginUser();
                            },
                            child: controller.isLoading.value
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )),

                        const SizedBox(height: 30),

                        /// Divider
                        Row(
                          children: const [
                            Expanded(
                              child: Divider(color: Color(0xff4a5565), thickness: 1),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "OR",
                                style: TextStyle(color: AppColors.lightGreyColor),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Color(0xff4a5565), thickness: 1),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// Google Button
                        GestureDetector(
                          onTap: () => controller.continueWithGoogle(),
                          child: socialButton(
                            icon: Icons.g_mobiledata,
                            text: "Continue with Google",
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// Apple Button
                        GestureDetector(
                          onTap: () => controller.continueWithApple(),
                          child: socialButton(
                            icon: Icons.apple,
                            text: "Continue with Apple",
                          ),
                        ),

                        const SizedBox(height: 30),

                        /// Sign Up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(color: AppColors.lightGreyColor),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                Get.to(() => const SignUpScreen());
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Color(0xff615fff),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget socialButton({required IconData icon, required String text}) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xff101828),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xff364153)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}