import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String? email; // Optional: to show which email the code was sent to
  const VerifyCodeScreen({super.key, this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _canResend = false;
    _secondsRemaining = 60;
    Future.delayed(const Duration(seconds: 1), _tickTimer);
  }

  void _tickTimer() {
    if (_secondsRemaining > 0) {
      setState(() {
        _secondsRemaining--;
      });
      Future.delayed(const Duration(seconds: 1), _tickTimer);
    } else {
      setState(() {
        _canResend = true;
      });
    }
  }

  void _verifyCode() {
    // Get the complete OTP code
    String otpCode = _otpControllers.map((controller) => controller.text).join();

    if (otpCode.length < 6) {
      Get.snackbar(
        'Incomplete Code',
        'Please enter the complete 6-digit verification code',
        backgroundColor: const Color(0xff101828),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Color(0xff615fff)),
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

      // Show success dialog
      _showVerificationSuccess();
    });
  }

  void _resendCode() {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate resend API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      _startResendTimer();

      Get.snackbar(
        'Code Resent',
        'A new verification code has been sent to your ${widget.email ?? 'email'}',
        backgroundColor: const Color(0xff101828),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle_outline, color: Color(0xff615fff)),
      );
    });
  }

  void _showVerificationSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xff101828),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xff1A1F2E),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xff615fff),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Verification Successful",
                  style: TextStyle(
                    color: Color(0xfff9fafb),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your email has been verified successfully. You can now reset your password.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xff9AA4B2),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff615fff),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to reset password screen
                      // Get.to(() => const ResetPasswordScreen());
                    },
                    child: const Text(
                      "Continue to Reset Password",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
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
        title: const Text(
          "Verify Code",
          style: TextStyle(
            color: Color(0xffF9FAFB),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Lock Icon
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

                const SizedBox(height: 24),

                /// Title
                const Text(
                  "Verify Code",
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xfff9fafb),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                /// Description
                Text(
                  widget.email != null
                      ? "Enter the 6-digit verification code sent to ${widget.email} to continue."
                      : "Enter the 6-digit verification code sent to your email or phone to continue.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff9AA4B2),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                /// OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 50,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xff101828),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _otpControllers[index].text.isNotEmpty
                              ? const Color(0xff615fff)
                              : const Color(0xff364153),
                          width: _otpControllers[index].text.isNotEmpty ? 2 : 1,
                        ),
                      ),
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        style: const TextStyle(
                          color: Color(0xfff9fafb),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {}); // Update border color

                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 32),

                /// Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff615fff),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _verifyCode,
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
                      "Verify Code",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// Resend Section
                Column(
                  children: [
                    const Text(
                      "Didn't receive the code?",
                      style: TextStyle(
                        color: Color(0xff6a7282),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!_canResend)
                      Text(
                        "You can resend it in $_secondsRemaining seconds",
                        style: const TextStyle(
                          color: Color(0xff9AA4B2),
                          fontSize: 13,
                        ),
                      ),
                    if (_canResend)
                      GestureDetector(
                        onTap: _resendCode,
                        child: const Text(
                          "Resend",
                          style: TextStyle(
                            color: Color(0xff615fff),
                            fontSize: 14,
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
}