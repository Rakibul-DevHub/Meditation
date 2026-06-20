import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/features/views/auth/forgot_password.dart';
import 'package:outdoor_therapy/features/views/auth/sign_up_screen.dart';
import '../../../core/app_colors.dart';
import 'controller/sign_in_screen_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final SignInScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(SignInScreenController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff030712),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints:
                  BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),

                          /// Logo
                          Center(
                            child: Container(
                              height: 64,
                              width: 64,
                              decoration: const BoxDecoration(
                                color: Color(0xff101828),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/images/logo.svg',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.scaleDown,
                                  placeholderBuilder: (_) =>
                                  const CircularProgressIndicator(
                                    color: Color(0xff615fff),
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

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


                          /// Email label
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

                          /// Email field
                          Obx(() => TextField(
                            controller: _controller.emailController,
                            style: const TextStyle(
                                color: AppColors.whiteColor),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            enabled: !_controller.isLoading.value,
                            decoration: InputDecoration(
                              hintText: "your@email.com",
                              hintStyle: const TextStyle(
                                  color: AppColors.lightGreyColor),
                              prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: AppColors.lightGreyColor),
                              filled: true,
                              fillColor: const Color(0xff101828),
                              errorText:
                              _controller.emailError.value.isEmpty
                                  ? null
                                  : _controller.emailError.value,
                              errorStyle: const TextStyle(
                                  color: Colors.red, fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Color(0xff364153)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Color(0xff364153)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: AppColors.primaryColor,
                                    width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 2),
                              ),
                              contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                          )),

                          const SizedBox(height: 20),

                          /// Password label
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

                          /// Password field
                          Obx(() => TextField(
                            controller: _controller.passwordController,
                            obscureText:
                            !_controller.isPasswordVisible.value,
                            style: const TextStyle(
                                color: AppColors.whiteColor),
                            textInputAction: TextInputAction.done,
                            enabled: !_controller.isLoading.value,
                            onSubmitted: (_) {
                              if (!_controller.isLoading.value) {
                                _controller.loginUser();
                              }
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline,
                                  color: AppColors.lightGreyColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _controller.isPasswordVisible.value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.lightGreyColor,
                                ),
                                onPressed:
                                _controller.isLoading.value
                                    ? null
                                    : _controller
                                    .togglePasswordVisibility,
                              ),
                              filled: true,
                              fillColor: const Color(0xff101828),
                              errorText: _controller
                                  .passwordError.value.isEmpty
                                  ? null
                                  : _controller.passwordError.value,
                              errorStyle: const TextStyle(
                                  color: Colors.red, fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Color(0xff364153)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Color(0xff364153)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Color(0xff615fff), width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 2),
                              ),
                              contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                          )),

                          const SizedBox(height: 10),

                          /// Forgot password
                          Obx(() => Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: _controller.isLoading.value
                                  ? null
                                  : () => Get.to(
                                      () =>
                                  const ForgotPasswordScreen()),
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: _controller.isLoading.value
                                      ? Colors.grey
                                      : const Color(0xff615fff),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )),

                          const SizedBox(height: 30),

                          /// Sign In button
                          Obx(() => SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xff615fff),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: (_controller.isLoading.value ||
                                  _controller
                                      .isGoogleSigningIn.value)
                                  ? null
                                  : _controller.loginUser,
                              child: _controller.isLoading.value
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
                          const Row(
                            children: [
                              Expanded(
                                  child: Divider(
                                      color: Color(0xff4a5565),
                                      thickness: 1)),
                              Padding(
                                padding:
                                EdgeInsets.symmetric(horizontal: 10),
                                child: Text("OR",
                                    style: TextStyle(
                                        color: AppColors.lightGreyColor)),
                              ),
                              Expanded(
                                  child: Divider(
                                      color: Color(0xff4a5565),
                                      thickness: 1)),
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// Google button
                          Obx(() => GestureDetector(
                            onTap: (_controller.isLoading.value ||
                                _controller.isGoogleSigningIn.value)
                                ? null
                                : _controller.continueWithGoogle,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xff101828),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xff364153)),
                              ),
                              child: Center(
                                child: _controller
                                    .isGoogleSigningIn.value
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                  CircularProgressIndicator(
                                    color: Color(0xff615fff),
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    // ✅ No SVG asset needed
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration:
                                      const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'G',
                                          style: TextStyle(
                                            color: Color(
                                                0xff4285F4),
                                            fontSize: 14,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Continue with Google",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight:
                                        FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )),

                          const SizedBox(height: 10),

                          /// Apple button
                          Obx(() => GestureDetector(
                            onTap: (_controller.isLoading.value ||
                                _controller.isAppleSigningIn.value)
                                ? null
                                : _controller.continueWithApple,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xff101828),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xff364153)),
                              ),
                              child: Center(
                                child:
                                _controller.isAppleSigningIn.value
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                  CircularProgressIndicator(
                                    color: Color(0xff615fff),
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    // ✅ No SVG asset needed
                                    Icon(Icons.apple,
                                        color: Colors.white,
                                        size: 22),
                                    SizedBox(width: 12),
                                    Text(
                                      "Continue with Apple",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight:
                                        FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )),

                          const SizedBox(height: 30),

                          /// Sign Up
                          Obx(() => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account?",
                                style: TextStyle(
                                    color: AppColors.lightGreyColor),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: (_controller.isLoading.value ||
                                    _controller
                                        .isGoogleSigningIn.value)
                                    ? null
                                    : () => Get.to(
                                        () => const SignUpScreen()),
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: (_controller.isLoading.value ||
                                        _controller
                                            .isGoogleSigningIn.value)
                                        ? Colors.grey
                                        : const Color(0xff615fff),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          )),

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
      ),
    );
  }
}