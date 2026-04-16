import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/app_url.dart';
import '../../../../core/network/network_caller_dio.dart';
import '../../../../core/network/network_response_dio.dart';
import '../../../../model/registraion_response_model.dart';
import '../../../../model/registration_request_model.dart';

class SignUpScreenController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // Form loading state
  final RxBool isLoading = false.obs;

  // Form field controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Error messages for form fields
  final RxString firstNameError = ''.obs;
  final RxString lastNameError = ''.obs;
  final RxString emailError = ''.obs;
  final RxString phoneError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString confirmPasswordError = ''.obs;

  // General error message
  final RxString generalErrorMessage = ''.obs;

  // Password visibility
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  @override
  void onClose() {
    // Dispose controllers to avoid memory leaks
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Validate form fields
  bool validateForm() {
    bool isValid = true;

    // Clear previous errors
    firstNameError.value = '';
    lastNameError.value = '';
    emailError.value = '';
    phoneError.value = '';
    passwordError.value = '';
    confirmPasswordError.value = '';
    generalErrorMessage.value = '';

    // Validate First Name
    if (firstNameController.text.trim().isEmpty) {
      firstNameError.value = 'First name is required';
      isValid = false;
    } else if (firstNameController.text.trim().length < 2) {
      firstNameError.value = 'First name must be at least 2 characters';
      isValid = false;
    }

    // Validate Last Name
    if (lastNameController.text.trim().isEmpty) {
      lastNameError.value = 'Last name is required';
      isValid = false;
    } else if (lastNameController.text.trim().length < 2) {
      lastNameError.value = 'Last name must be at least 2 characters';
      isValid = false;
    }

    // Validate Email
    if (emailController.text.trim().isEmpty) {
      emailError.value = 'Email is required';
      isValid = false;
    } else if (!GetUtils.isEmail(emailController.text.trim())) {
      emailError.value = 'Please enter a valid email address';
      isValid = false;
    }

    // Validate Phone (optional - adjust as needed)
    if (phoneController.text.trim().isNotEmpty) {
      if (phoneController.text.trim().length < 10) {
        phoneError.value = 'Please enter a valid phone number';
        isValid = false;
      }
    }

    // Validate Password
    if (passwordController.text.isEmpty) {
      passwordError.value = 'Password is required';
      isValid = false;
    } else if (passwordController.text.length < 8) {
      passwordError.value = 'Password must be at least 8 characters';
      isValid = false;
    } else if (!RegExp(r'^(?=.*[A-Z])(?=.*[0-9])').hasMatch(passwordController.text)) {
      passwordError.value = 'Password must contain at least one uppercase letter and one number';
      isValid = false;
    }

    // Validate Confirm Password
    if (confirmPasswordController.text.isEmpty) {
      confirmPasswordError.value = 'Please confirm your password';
      isValid = false;
    } else if (passwordController.text != confirmPasswordController.text) {
      confirmPasswordError.value = 'Passwords do not match';
      isValid = false;
    }

    return isValid;
  }

  // Register user
  Future<void> registerUser() async {
    // Validate form before making API call
    if (!validateForm()) {
      return;
    }

    // Set loading state
    isLoading.value = true;
    generalErrorMessage.value = '';

    try {
      // Create request model
      final RegistrationRequestModel request = RegistrationRequestModel(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        role: 'user',
      );

      // Log the URL being used
      debugPrint('🚀 Making POST request to: ${AppUrl.registration}');

      // Make API call with the correct URL from AppUrl
      final NetworkResponseDio response = await _networkCaller.postRequest(
        AppUrl.registration, // Use the actual URL from AppUrl class
        body: request.toJson(),
        isLogin: false,
      );

      // Handle response
      if (response.isSuccess && (response.statusCode == 200 || response.statusCode == 201)) {
        // Parse success response
        if (response.jsonResponse != null) {
          final RegistrationResponseModel registrationResponse =
          RegistrationResponseModel.fromJson(response.jsonResponse!);

          // Show success message
          Get.snackbar(
            'Success',
            registrationResponse.message ?? 'Registration successful!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );

          // Clear form after successful registration
          clearForm();

          // Navigate to login or OTP screen
          // Get.offAll(() => LoginScreen());
        } else {
          // Success without response body
          Get.snackbar(
            'Success',
            'Registration successful!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          clearForm();
        }
      } else {
        // Handle error response
        String errorMsg = response.errorMessage ?? 'Registration failed. Please try again.';

        // Check if we have more detailed error from response
        if (response.jsonResponse != null) {
          final RegistrationResponseModel errorResponse =
          RegistrationResponseModel.fromJson(response.jsonResponse!);
          if (errorResponse.message != null && errorResponse.message!.isNotEmpty) {
            errorMsg = errorResponse.message!;
          }
        }

        generalErrorMessage.value = errorMsg;

        // Show error message
        Get.snackbar(
          'Registration Failed',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      // Handle unexpected errors
      debugPrint('Registration error: $e');
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

  // Clear form fields
  void clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    firstNameError.value = '';
    lastNameError.value = '';
    emailError.value = '';
    phoneError.value = '';
    passwordError.value = '';
    confirmPasswordError.value = '';
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
}