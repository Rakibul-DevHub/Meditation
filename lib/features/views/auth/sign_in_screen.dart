import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:outdoor_therapy/features/views/auth/forgot_password.dart';
import 'package:outdoor_therapy/features/views/auth/sign_up_screen.dart';

import '../../../core/app_colors.dart';
import '../home/home_screen.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

                TextField(
                  style: const TextStyle(color: AppColors.whiteColor),
                  decoration: InputDecoration(
                    hintText: "your@email.com",
                    hintStyle: const TextStyle(color: AppColors.lightGreyColor),
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.lightGreyColor),
                    filled: true,
                    fillColor: const Color(0xff101828),
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
                  ),
                ),

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

                TextField(
                  obscureText: true,
                  style: const TextStyle(color: AppColors.whiteColor),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.lightGreyColor),
                    suffixIcon: const Icon(Icons.visibility_off, color: AppColors.lightGreyColor),
                    filled: true,
                    fillColor: const Color(0xff101828),
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
                  ),
                ),

                const SizedBox(height: 10),

                 Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: (){
                      Get.to(()=> ForgotPasswordScreen());
                    },
                    child: Text(
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
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff615fff),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Get.to(()=>HomeScreen());
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

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
                socialButton(
                  icon: Icons.g_mobiledata,
                  text: "Continue with Google",
                ),

                const SizedBox(height: 10),

                /// Apple Button
                socialButton(
                  icon: Icons.apple,
                  text: "Continue with Apple",
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
                        Get.to(()=>SignUpScreen());
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
}