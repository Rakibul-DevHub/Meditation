/**

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/features/views/auth/verify_code_screen.dart';
import 'controller/sign_up_screen_controller.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final SignUpScreenController controller = Get.put(SignUpScreenController());

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

                  /// Name Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildInput(
                              "First Name",
                              controller: controller.firstNameController,
                              errorText: controller.firstNameError,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildInput(
                              "Last Name",
                              controller: controller.lastNameController,
                              errorText: controller.lastNameError,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  buildInput(
                    "Email",
                    icon: Icons.email_outlined,
                    controller: controller.emailController,
                    errorText: controller.emailError,
                  ),

                  const SizedBox(height: 16),

                  buildInput(
                    "Phone",
                    icon: Icons.phone,
                    controller: controller.phoneController,
                    errorText: controller.phoneError,
                    isOptional: true,
                  ),

                  const SizedBox(height: 16),

                  Obx(() => buildInput(
                    "Password",
                    icon: Icons.lock_outline,
                    isPassword: !controller.isPasswordVisible.value,
                    controller: controller.passwordController,
                    errorText: controller.passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xff6a7282),
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  )),

                  const SizedBox(height: 16),

                  Obx(() => buildInput(
                    "Confirm Password",
                    icon: Icons.lock_outline,
                    isPassword: !controller.isConfirmPasswordVisible.value,
                    controller: controller.confirmPasswordController,
                    errorText: controller.confirmPasswordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xff6a7282),
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                  )),

                  const SizedBox(height: 24),

                  /// Sign Up Button
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
                        controller.registerUser();
                        Get.to(()=>VerifyCodeScreen());
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
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )),

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
                  GestureDetector(
                    onTap: () => controller.continueWithGoogle(),
                    child: socialButton(
                      icon: Icons.g_mobiledata,
                      text: "Continue with Google",
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Apple Button
                  GestureDetector(
                    onTap: () => controller.continueWithApple(),
                    child: socialButton(
                      icon: Icons.apple,
                      text: "Continue with Apple",
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Login text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: Color(0xffa1a1a1)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.back(); // Go back to login screen
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Color(0xfffafafa)),
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
      ),
    );
  }

  /// Input Field (Updated to use controller and error handling)
  static Widget buildInput(
      String label, {
        IconData? icon,
        bool isPassword = false,
        required TextEditingController controller,
        required RxString errorText,
        bool isOptional = false,
        Widget? suffixIcon,
      }) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xfffafafa),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isOptional)
              const Text(
                " (Optional)",
                style: TextStyle(
                  color: Color(0xff6a7282),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, color: const Color(0xff6a7282))
                : null,
            suffixIcon: suffixIcon,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            errorText: errorText.value.isEmpty ? null : errorText.value,
            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ));
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


*/



















import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/features/views/auth/verify_code_screen.dart';
import 'controller/sign_up_screen_controller.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final SignUpScreenController controller = Get.put(SignUpScreenController());

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

                  /// Name Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildInput(
                              "First Name",
                              controller: controller.firstNameController,
                              errorText: controller.firstNameError,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildInput(
                              "Last Name",
                              controller: controller.lastNameController,
                              errorText: controller.lastNameError,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  buildInput(
                    "Email",
                    icon: Icons.email_outlined,
                    controller: controller.emailController,
                    errorText: controller.emailError,
                  ),

                  const SizedBox(height: 16),

                  buildInput(
                    "Phone",
                    icon: Icons.phone,
                    controller: controller.phoneController,
                    errorText: controller.phoneError,
                    isOptional: true,
                  ),

                  const SizedBox(height: 16),

                  Obx(() => buildInput(
                    "Password",
                    icon: Icons.lock_outline,
                    isPassword: !controller.isPasswordVisible.value,
                    controller: controller.passwordController,
                    errorText: controller.passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xff6a7282),
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  )),

                  const SizedBox(height: 16),

                  Obx(() => buildInput(
                    "Confirm Password",
                    icon: Icons.lock_outline,
                    isPassword: !controller.isConfirmPasswordVisible.value,
                    controller: controller.confirmPasswordController,
                    errorText: controller.confirmPasswordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xff6a7282),
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                  )),

                  const SizedBox(height: 24),

                  /// Sign Up Button
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
                          : () async {
                        // Get email before registration
                        final String userEmail = controller.emailController.text.trim();
                        debugPrint('📧 User email for verification: $userEmail');

                        // Perform registration
                        await controller.registerUser();

                        // Check if registration was successful
                        if (controller.registrationSuccess.value) {
                          debugPrint('✅ Registration successful, navigating to verify screen with email: $userEmail');
                          // Navigate to verify screen with email
                          Get.to(
                                () => VerifyCodeScreen(
                              email: userEmail,
                            ),
                          );
                        } else {
                          debugPrint('❌ Registration failed, not navigating to verify screen');
                        }
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
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )),

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
                  GestureDetector(
                    onTap: () => controller.continueWithGoogle(),
                    child: socialButton(
                      icon: Icons.g_mobiledata,
                      text: "Continue with Google",
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Apple Button
                  GestureDetector(
                    onTap: () => controller.continueWithApple(),
                    child: socialButton(
                      icon: Icons.apple,
                      text: "Continue with Apple",
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Login text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: Color(0xffa1a1a1)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.back(); // Go back to login screen
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Color(0xfffafafa)),
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
      ),
    );
  }

  /// Input Field
  static Widget buildInput(
      String label, {
        IconData? icon,
        bool isPassword = false,
        required TextEditingController controller,
        required RxString errorText,
        bool isOptional = false,
        Widget? suffixIcon,
      }) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xfffafafa),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isOptional)
              const Text(
                " (Optional)",
                style: TextStyle(
                  color: Color(0xff6a7282),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, color: const Color(0xff6a7282))
                : null,
            suffixIcon: suffixIcon,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            errorText: errorText.value.isEmpty ? null : errorText.value,
            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ));
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


