/**
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/app_url.dart';
import '../../../../core/network/network_caller_dio.dart';
import '../../../../core/network/network_response_dio.dart';
import '../../../../model/login_request_model.dart';
import '../../../../model/login_response_model.dart';
import '../../../views/bottom_nav/main_bottom_nav.dart';

class SignInScreenController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // Form loading state
  final RxBool isLoading = false.obs;

  // Password visibility
  final RxBool isPasswordVisible = false.obs;

  // Form field controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Error messages
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString generalErrorMessage = ''.obs;

  @override
  void onClose() {
    // Dispose controllers to avoid memory leaks
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Validate form fields
  bool validateForm() {
    bool isValid = true;

    // Clear previous errors
    emailError.value = '';
    passwordError.value = '';
    generalErrorMessage.value = '';

    // Validate Email
    if (emailController.text.trim().isEmpty) {
      emailError.value = 'Email is required';
      isValid = false;
    } else if (!GetUtils.isEmail(emailController.text.trim())) {
      emailError.value = 'Please enter a valid email address';
      isValid = false;
    }

    // Validate Password
    if (passwordController.text.isEmpty) {
      passwordError.value = 'Password is required';
      isValid = false;
    } else if (passwordController.text.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
      isValid = false;
    }

    return isValid;
  }

  // Login user
  Future<void> loginUser() async {
    // Validate form before making API call
    if (!validateForm()) {
      return;
    }

    // Set loading state
    isLoading.value = true;
    generalErrorMessage.value = '';

    try {
      // Create request model
      final LoginRequestModel request = LoginRequestModel(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Log the request
      debugPrint('🚀 Making POST request to: ${AppUrl.login}');
      debugPrint('📧 Email: ${request.email}');
      debugPrint('🔐 Password: ${request.password}');

      // Make API call
      final NetworkResponseDio response = await _networkCaller.postRequest(
        AppUrl.login,
        body: request.toJson(),
        isLogin: true,
      );

      debugPrint('📡 Response status code: ${response.statusCode}');
      debugPrint('📡 Response isSuccess: ${response.isSuccess}');
      debugPrint('📡 Response data: ${response.jsonResponse}');

      // Handle response
      if (response.isSuccess && (response.statusCode == 200 || response.statusCode == 201)) {
        // Parse success response
        if (response.jsonResponse != null) {
          final LoginResponseModel loginResponse =
          LoginResponseModel.fromJson(response.jsonResponse!);

          // Save token locally (you can use shared_preferences or get_storage)
          if (loginResponse.token != null) {
            await saveToken(loginResponse.token!);
            debugPrint('🔑 Token saved: ${loginResponse.token}');
          }

          // Save user data if needed
          if (loginResponse.data != null) {
            await saveUserData(loginResponse.data!);
          }

          // Show success message
          Get.snackbar(
            'Success',
            loginResponse.message ?? 'Login successful!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
          );

          // Navigate to home screen
          Get.offAll(() => const MainBottomNav());
        } else {
          // Success without response body
          Get.snackbar(
            'Success',
            'Login successful!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );

          // Navigate to home screen
          Get.offAll(() => const MainBottomNav());
        }
      } else {
        // Handle error response
        String errorMsg = response.errorMessage ?? 'Login failed. Please check your credentials.';

        // Try to extract message from response
        if (response.jsonResponse != null) {
          if (response.jsonResponse!.containsKey('message')) {
            errorMsg = response.jsonResponse!['message'].toString();
          } else if (response.jsonResponse!.containsKey('error')) {
            errorMsg = response.jsonResponse!['error'].toString();
          }
        }

        generalErrorMessage.value = errorMsg;

        // Show error message
        Get.snackbar(
          'Login Failed',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      // Handle unexpected errors
      debugPrint('❌ Login error: $e');
      generalErrorMessage.value = 'An unexpected error occurred. Please try again.';
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      // Reset loading state
      isLoading.value = false;
    }
  }

  // Save token (implement with your preferred storage method)
  Future<void> saveToken(String token) async {
    // Example using shared_preferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('auth_token', token);

    // Or using GetStorage
    // final box = GetStorage();
    // await box.write('auth_token', token);

    debugPrint('Token saved: $token');
  }

  // Save user data (implement with your preferred storage method)
  Future<void> saveUserData(LoginData userData) async {
    // Example using shared_preferences or GetStorage
    debugPrint('User data saved: ${userData.email}');
  }

  // Clear form fields
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    emailError.value = '';
    passwordError.value = '';
    generalErrorMessage.value = '';
  }

  // Social login methods
  Future<void> continueWithGoogle() async {
    Get.snackbar(
      'Info',
      'Google sign-in coming soon',
      snackPosition: SnackPosition.TOP,
    );
  }

  Future<void> continueWithApple() async {
    Get.snackbar(
      'Info',
      'Apple sign-in coming soon',
      snackPosition: SnackPosition.TOP,
    );
  }
}*/


































import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/app_url.dart';
import '../../../../core/network/network_caller_dio.dart';
import '../../../../core/network/network_response_dio.dart';
import '../../../../core/network/secure_storage_service.dart';
import '../../../../model/login_request_model.dart';
import '../../../../model/login_response_model.dart';
import '../../../views/bottom_nav/main_bottom_nav.dart';

class SignInScreenController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString generalErrorMessage = ''.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  bool validateForm() {
    bool isValid = true;

    emailError.value = '';
    passwordError.value = '';
    generalErrorMessage.value = '';

    if (emailController.text.trim().isEmpty) {
      emailError.value = 'Email is required';
      isValid = false;
    } else if (!GetUtils.isEmail(emailController.text.trim())) {
      emailError.value = 'Please enter a valid email address';
      isValid = false;
    }

    if (passwordController.text.isEmpty) {
      passwordError.value = 'Password is required';
      isValid = false;
    } else if (passwordController.text.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
      isValid = false;
    }

    return isValid;
  }

  Future<void> loginUser() async {
    if (!validateForm()) return;

    isLoading.value = true;
    generalErrorMessage.value = '';

    try {
      final LoginRequestModel request = LoginRequestModel(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      debugPrint('🚀 POST: ${AppUrl.login}');
      debugPrint('📧 Email: ${request.email}');

      final NetworkResponseDio response = await _networkCaller.postRequest(
        AppUrl.login,
        body: request.toJson(),
        isLogin: true,
      );

      debugPrint('📡 Status: ${response.statusCode}');
      debugPrint('📡 Success: ${response.isSuccess}');
      debugPrint('📡 Data: ${response.jsonResponse}');

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        if (response.jsonResponse != null) {
          final LoginResponseModel loginResponse =
          LoginResponseModel.fromJson(response.jsonResponse!);

          // ✅ Save token using SecureStorageService
          if (loginResponse.token != null && loginResponse.token!.isNotEmpty) {
            await SecureStorageService.instance
                .saveAccessToken(loginResponse.token!);
            debugPrint('🔑 Token saved: ${loginResponse.token}');

            // ✅ Verify token was saved correctly
            final savedToken =
            await SecureStorageService.instance.getAccessToken();
            debugPrint(
                '✅ Token verified: ${savedToken != null ? "OK (${savedToken.length} chars)" : "FAILED"}');
          } else {
            debugPrint('⚠️ Token is null or empty in response');
            generalErrorMessage.value =
            'Login succeeded but no token received. Please try again.';
            isLoading.value = false;
            return;
          }

          // ✅ Save user data using SecureStorageService
          if (loginResponse.data != null) {
            await SecureStorageService.instance
                .saveUserData(loginResponse.data!.toJson());
            debugPrint('👤 User data saved: ${loginResponse.data!.email}');
          }

          Get.snackbar(
            'Success',
            loginResponse.message ?? 'Login successful!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
          );

          Get.offAll(() => const MainBottomNav());
        } else {
          // Success but no body — navigate anyway
          Get.snackbar(
            'Success',
            'Login successful!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          Get.offAll(() => const MainBottomNav());
        }
      } else {
        String errorMsg =
            response.errorMessage ?? 'Login failed. Please check your credentials.';

        if (response.jsonResponse != null) {
          if (response.jsonResponse!.containsKey('message')) {
            errorMsg = response.jsonResponse!['message'].toString();
          } else if (response.jsonResponse!.containsKey('error')) {
            errorMsg = response.jsonResponse!['error'].toString();
          }
        }

        generalErrorMessage.value = errorMsg;

        Get.snackbar(
          'Login Failed',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      debugPrint('❌ Login error: $e');
      generalErrorMessage.value =
      'An unexpected error occurred. Please try again.';
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    emailController.clear();
    passwordController.clear();
    emailError.value = '';
    passwordError.value = '';
    generalErrorMessage.value = '';
  }

  Future<void> continueWithGoogle() async {
    Get.snackbar(
      'Info',
      'Google sign-in coming soon',
      snackPosition: SnackPosition.TOP,
    );
  }

  Future<void> continueWithApple() async {
    Get.snackbar(
      'Info',
      'Apple sign-in coming soon',
      snackPosition: SnackPosition.TOP,
    );
  }
}