import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:outdoor_therapy/features/views/auth/forgot_password.dart';


class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff030712),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                children: [

                  const SizedBox(height: 20),

                  /// Icon Container
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

                  const SizedBox(height: 16),

                  /// Title
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      color: Color(0xfff9fafb),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Start your journey to better sleep",
                    style: TextStyle(
                      color: Color(0xff6a7282),
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Name Row
                  Row(
                    children: [
                      Expanded(
                        child: buildInput("First Name"),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: buildInput("Last Name"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  buildInput("Email", icon: Icons.email_outlined),

                  const SizedBox(height: 16),

                  buildInput("Phone", icon: Icons.phone),

                  const SizedBox(height: 16),

                  buildInput("Password",
                      icon: Icons.lock_outline, isPassword: true),

                  const SizedBox(height: 16),

                  buildInput("Confirm Password",
                      icon: Icons.lock_outline, isPassword: true),

                  const SizedBox(height: 24),

                  /// Sign Up Button
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
                        Get.offAll(()=>ForgotPasswordScreen());

                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Divider OR
                  Row(
                    children: const [
                      Expanded(
                        child: Divider(color: Color(0xff4a5565)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "OR",
                          style: TextStyle(
                            color: Color(0xff4a5565),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Color(0xff4a5565)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Google Button
                  socialButton(
                    icon: Icons.g_mobiledata,
                    text: "Continue with Google",
                  ),

                  const SizedBox(height: 12),

                  /// Apple Button
                  socialButton(
                    icon: Icons.apple,
                    text: "Continue with Apple",
                  ),

                  const SizedBox(height: 20),

                  /// Login text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(color: Color(0xffa1a1a1)),
                      ),
                      Text(
                        "Login",
                        style: TextStyle(color: Color(0xfffafafa)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Input Field
  static Widget buildInput(
      String label, {
        IconData? icon,
        bool isPassword = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xfffafafa),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon:
            icon != null ? Icon(icon, color: const Color(0xff6a7282)) : null,
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
              borderSide: const BorderSide(color: Color(0xff615fff)),
            ),
          ),
        ),
      ],
    );
  }

  /// Social Button
  static Widget socialButton({
    required IconData icon,
    required String text,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xff101828),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xff1e2939)),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(color: Color(0xfffafafa), fontSize: 14),
            )
          ],
        ),
      ),
    );
  }
}