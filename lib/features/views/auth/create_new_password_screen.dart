import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/features/views/auth/sign_in_screen.dart';

import '../../../core/app_colors.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Password validation states
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    setState(() {
      String password = _newPasswordController.text;
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
    });
  }

  bool get _isPasswordValid => _hasMinLength && _hasUppercase && _hasNumber;

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      if (!_isPasswordValid) {
        Get.snackbar(
          'Invalid Password',
          'Please make sure your password meets all requirements',
          backgroundColor: const Color(0xff101828),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
          borderRadius: 12,
          icon: const Icon(Icons.error_outline, color: AppColors.primaryColor),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        // Show success message and navigate
        Get.snackbar(
          'Success!',
          'Your password has been reset successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
          borderRadius: 12,
        );

        // Navigate to login screen after 1 second
        Future.delayed(const Duration(seconds: 1), () {
          Get.offAll(()=>SignInScreen());
        });
      });
    }
  }

  void _cancel() {
    Get.back();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff030712),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xffE8EBF2), size: 20),
          onPressed: () => Get.back(),
        ),

        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    /// Title
                    Column(
                      children: [
                        SvgPicture.asset(
                          'assets/images/logo.svg',
                          width: 80,
                          height: 80,
                          fit: BoxFit.scaleDown,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Create New Password",
                              style: TextStyle(
                                fontSize: 24,
                                color: Color(0xfff9fafb),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// Description
                    const Text(
                      "Your new password must be different from your previous password.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xff9AA4B2),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// New Password Field
                    const Text(
                      "New Password",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xffE8EBF2),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff101828),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xff364153),
                        ),
                      ),
                      child: TextFormField(
                        controller: _newPasswordController,
                        obscureText: !_isNewPasswordVisible,
                        style: const TextStyle(
                          color: Color(0xfff9fafb),
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter new password",
                          hintStyle: const TextStyle(
                            color: Color(0xff6a7282),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isNewPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xff6a7282),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _isNewPasswordVisible = !_isNewPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Confirm Password Field
                    const Text(
                      "Confirm Password",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xffE8EBF2),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff101828),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xff364153),
                        ),
                      ),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        style: const TextStyle(
                          color: Color(0xfff9fafb),
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: "Confirm new password",
                          hintStyle: const TextStyle(
                            color: Color(0xff6a7282),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xff6a7282),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Password Requirements
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Your password must contain:",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xffE8EBF2),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildRequirementItem(
                            "At least 8 characters",
                            _hasMinLength,
                          ),
                          const SizedBox(height: 8),
                          _buildRequirementItem(
                            "1 uppercase letter",
                            _hasUppercase,
                          ),
                          const SizedBox(height: 8),
                          _buildRequirementItem(
                            "1 number",
                            _hasNumber,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// Buttons Row
                    Row(
                      children: [
                        /// Reset Password Button
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _isLoading ? null : _resetPassword,
                              child: _isLoading
                                  ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                "Reset Password",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        /// Cancel Button
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                side: const BorderSide(
                                  color: Color(0xff364153),
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _isLoading ? null : _cancel,
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xffE8EBF2),
                                ),
                              ),
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
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: isMet
              ? const Icon(
            Icons.circle,
            size: 6,
            color: AppColors.whiteColor,
          )
              : null,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isMet ? AppColors.checkingColorTrue : AppColors.checkingColorFalse,
          ),
        ),
      ],
    );
  }
}