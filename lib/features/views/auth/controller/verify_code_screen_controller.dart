/**
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/app_url.dart';
import '../../../../core/network/network_caller_dio.dart';
import '../../../../core/network/network_response_dio.dart';
import '../create_new_password_screen.dart';


class VerifyCodeController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // OTP Controllers and Focus Nodes
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  // Reactive state variables
  final RxBool isLoading = false.obs;
  final RxInt secondsRemaining = 60.obs;
  final RxBool canResend = false.obs;
  final RxString email = ''.obs; // Make email reactive

  // Timer
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startResendTimer();
  }

  @override
  void onClose() {
    // Dispose all controllers and focus nodes
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    // Cancel timer
    _timer?.cancel();
    super.onClose();
  }

  void setEmail(String value) {
    email.value = value;
  }

  void _startResendTimer() {
    canResend.value = false;
    secondsRemaining.value = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  // Handle OTP input change
  void onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  // Get complete OTP code
  String getOtpCode() {
    return otpControllers.map((controller) => controller.text).join();
  }

  // Clear OTP fields
  void clearOtp() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    if (focusNodes.isNotEmpty) {
      focusNodes[0].requestFocus();
    }
  }

  // Verify OTP Code
  Future<void> verifyCode() async {
    String otpCode = getOtpCode();

    // Validate OTP
    if (otpCode.length < 6) {
      Get.snackbar(
        'Invalid Code',
        'Please enter the complete 6-digit verification code',
        backgroundColor: const Color(0xff101828),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline, color: Color(0xff615fff)),
      );
      return;
    }

    // Validate email
    if (email.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Email address is missing. Please try again.',
        backgroundColor: const Color(0xff101828),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Color(0xff615fff)),
      );
      return;
    }

    isLoading.value = true;

    try {
      // Prepare the request body exactly as specified
      Map<String, dynamic> requestBody = {
        "email": email.value,
        "code": otpCode,
      };

      debugPrint('🔐 Verifying OTP - Request body: $requestBody');

      // Make API call to verify OTP
      final NetworkResponseDio response = await _networkCaller.postRequest(
        AppUrl.verifyEmailOtp,
        body: requestBody,
        isLogin: false,
      );

      debugPrint('📡 Response status code: ${response.statusCode}');
      debugPrint('📡 Response isSuccess: ${response.isSuccess}');
      debugPrint('📡 Response data: ${response.jsonResponse}');

      // Handle response
      if (response.isSuccess) {
        // Show success message
        Get.snackbar(
          'Success',
          'Email verified successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        // Navigate to create new password screen
        Get.offAll(
              () => const CreateNewPasswordScreen(),
          arguments: {
            'email': email.value,
            'isVerified': true,
          },
        );
      } else {
        // Handle error response
        String errorMsg = response.errorMessage ?? 'Verification failed. Please check your code and try again.';

        // Try to extract message from response if available
        if (response.jsonResponse != null) {
          if (response.jsonResponse!.containsKey('message')) {
            errorMsg = response.jsonResponse!['message'].toString();
          } else if (response.jsonResponse!.containsKey('error')) {
            errorMsg = response.jsonResponse!['error'].toString();
          }
        }

        // Show error message
        Get.snackbar(
          'Verification Failed',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
          borderRadius: 12,
          duration: const Duration(seconds: 4),
        );

        // Clear OTP fields on failure for retry
        clearOtp();
      }
    } catch (e) {
      debugPrint('❌ Verification error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Resend OTP Code
  Future<void> resendCode() async {
    if (!canResend.value) return;

    // Validate email
    if (email.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Email address is missing. Please try again.',
        backgroundColor: const Color(0xff101828),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Color(0xff615fff)),
      );
      return;
    }

    isLoading.value = true;

    try {
      // Prepare the request body for resend
      Map<String, dynamic> requestBody = {
        "email": email.value,
      };

      debugPrint('🔄 Resending OTP - Request body: $requestBody');

      // Make API call to resend OTP
      final NetworkResponseDio response = await _networkCaller.postRequest(
        AppUrl.resendEmailOtp,
        body: requestBody,
        isLogin: false,
      );

      debugPrint('📡 Resend response status: ${response.statusCode}');

      // Handle response
      if (response.isSuccess) {
        // Show success message
        Get.snackbar(
          'Code Sent',
          'A new verification code has been sent to your email.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        // Clear OTP fields
        clearOtp();

        // Restart timer
        _startResendTimer();
      } else {
        // Handle error response
        String errorMsg = response.errorMessage ?? 'Failed to resend code. Please try again.';

        if (response.jsonResponse != null) {
          if (response.jsonResponse!.containsKey('message')) {
            errorMsg = response.jsonResponse!['message'].toString();
          }
        }

        Get.snackbar(
          'Failed to Resend',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint('❌ Resend error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate back
  void goBack() {
    Get.back();
  }
}*/











import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/app_url.dart';
import '../../../../core/network/network_caller_dio.dart';
import '../../../../core/network/network_response_dio.dart';
import '../create_new_password_screen.dart';

class VerifyCodeController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // OTP Controllers and Focus Nodes
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  // Reactive state variables
  final RxBool isLoading = false.obs;
  final RxInt secondsRemaining = 60.obs;
  final RxBool canResend = false.obs;
  final RxString email = ''.obs;

  // Timer
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startResendTimer();
  }

  @override
  void onClose() {
    // Dispose all controllers and focus nodes
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    // Cancel timer
    _timer?.cancel();
    super.onClose();
  }

  void setEmail(String value) {
    email.value = value;
    debugPrint('📧 Email set in VerifyCodeController: ${email.value}');
  }

  void _startResendTimer() {
    canResend.value = false;
    secondsRemaining.value = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  // Handle OTP input change
  void onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  // Get complete OTP code
  String getOtpCode() {
    return otpControllers.map((controller) => controller.text).join();
  }

  // Clear OTP fields
  void clearOtp() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    if (focusNodes.isNotEmpty) {
      focusNodes[0].requestFocus();
    }
  }

  // Verify OTP Code
  Future<void> verifyCode() async {
    String otpCode = getOtpCode();

    // Validate OTP
    if (otpCode.length < 6) {
      Get.snackbar(
        'Invalid Code',
        'Please enter the complete 6-digit verification code',
        backgroundColor: const Color(0xff101828),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline, color: Color(0xff615fff)),
      );
      return;
    }

    // Validate email
    if (email.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Email address is missing. Please try again.',
        backgroundColor: const Color(0xff101828),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Color(0xff615fff)),
      );
      return;
    }

    isLoading.value = true;

    try {
      // Prepare the request body exactly as specified
      Map<String, dynamic> requestBody = {
        "email": email.value,
        "code": otpCode,
      };

      debugPrint('🔐 Verifying OTP - Request body: $requestBody');

      // Make API call to verify OTP
      final NetworkResponseDio response = await _networkCaller.postRequest(
        AppUrl.verifyEmailOtp,
        body: requestBody,
        isLogin: false,
      );

      debugPrint('📡 Response status code: ${response.statusCode}');
      debugPrint('📡 Response isSuccess: ${response.isSuccess}');
      debugPrint('📡 Response data: ${response.jsonResponse}');

      // Handle response
      if (response.isSuccess) {
        // Show success message
        Get.snackbar(
          'Success',
          'Email verified successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        // Navigate to create new password screen
        Get.offAll(
              () => const CreateNewPasswordScreen(),
          arguments: {
            'email': email.value,
            'isVerified': true,
          },
        );
      } else {
        // Handle error response
        String errorMsg = response.errorMessage ?? 'Verification failed. Please check your code and try again.';

        // Try to extract message from response if available
        if (response.jsonResponse != null) {
          if (response.jsonResponse!.containsKey('message')) {
            errorMsg = response.jsonResponse!['message'].toString();
          } else if (response.jsonResponse!.containsKey('error')) {
            errorMsg = response.jsonResponse!['error'].toString();
          }
        }

        // Show error message
        Get.snackbar(
          'Verification Failed',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
          borderRadius: 12,
          duration: const Duration(seconds: 4),
        );

        // Clear OTP fields on failure for retry
        clearOtp();
      }
    } catch (e) {
      debugPrint('❌ Verification error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Resend OTP Code
  Future<void> resendCode() async {
    if (!canResend.value) return;

    // Validate email
    if (email.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Email address is missing. Please try again.',
        backgroundColor: const Color(0xff101828),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Color(0xff615fff)),
      );
      return;
    }

    isLoading.value = true;

    try {
      // Prepare the request body for resend
      Map<String, dynamic> requestBody = {
        "email": email.value,
      };

      debugPrint('🔄 Resending OTP - Request body: $requestBody');

      // Make API call to resend OTP
      final NetworkResponseDio response = await _networkCaller.postRequest(
        AppUrl.resendEmailOtp,
        body: requestBody,
        isLogin: false,
      );

      debugPrint('📡 Resend response status: ${response.statusCode}');

      // Handle response
      if (response.isSuccess) {
        // Show success message
        Get.snackbar(
          'Code Sent',
          'A new verification code has been sent to your email.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        // Clear OTP fields
        clearOtp();

        // Restart timer
        _startResendTimer();
      } else {
        // Handle error response
        String errorMsg = response.errorMessage ?? 'Failed to resend code. Please try again.';

        if (response.jsonResponse != null) {
          if (response.jsonResponse!.containsKey('message')) {
            errorMsg = response.jsonResponse!['message'].toString();
          }
        }

        Get.snackbar(
          'Failed to Resend',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint('❌ Resend error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate back
  void goBack() {
    Get.back();
  }
}