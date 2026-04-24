/**
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
          Get.offAll(() => const MainBottomNav());
        } else {
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
}*/











import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/network/app_url.dart';
import '../../../../core/network/network_caller_dio.dart';
import '../../../../core/network/network_response_dio.dart';
import '../../../../core/network/secure_storage_service.dart';
import '../../../../model/login_request_model.dart';
import '../../../../model/login_response_model.dart';
import '../../../views/bottom_nav/main_bottom_nav.dart';

class SignInScreenController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final RxBool isLoading = false.obs;
  final RxBool isGoogleSigningIn = false.obs;
  final RxBool isAppleSigningIn = false.obs;
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

  // ── Email Login ────────────────────────────────────────────────────────────
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

          if (loginResponse.token != null && loginResponse.token!.isNotEmpty) {
            await SecureStorageService.instance
                .saveAccessToken(loginResponse.token!);
            debugPrint('🔑 Token saved: ${loginResponse.token}');

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

          if (loginResponse.data != null) {
            await SecureStorageService.instance
                .saveUserData(loginResponse.data!.toJson());
            debugPrint('👤 User data saved: ${loginResponse.data!.email}');
          }

          Get.offAll(() => const MainBottomNav());
        } else {
          Get.offAll(() => const MainBottomNav());
        }
      } else {
        String errorMsg = response.errorMessage ??
            'Login failed. Please check your credentials.';

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

  // ── Google Sign-In ─────────────────────────────────────────────────────────
  Future<void> continueWithGoogle() async {
    if (isGoogleSigningIn.value) return;

    isGoogleSigningIn.value = true;
    generalErrorMessage.value = '';

    try {
      debugPrint('🔐 Starting Google Sign-In...');

      // Step 1: Google sign-in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('❌ Google Sign-In cancelled by user');
        isGoogleSigningIn.value = false;
        return;
      }

      debugPrint('✅ Google user: ${googleUser.email}');

      // Step 2: Get Google auth tokens
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      debugPrint('🔑 Google accessToken: ${googleAuth.accessToken}');
      debugPrint('🔑 Google idToken: ${googleAuth.idToken}');

      // Step 3: Sign into Firebase to get a fresh Firebase idToken
      // (Backend uses Firebase Admin SDK to verify this token)
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _firebaseAuth.signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Firebase sign-in returned null user');
      }

      debugPrint('✅ Firebase user: ${firebaseUser.email}');

      // Step 4: Get fresh Firebase ID token
      // forceRefresh=true ensures we get a valid, non-expired token
      final String? firebaseIdToken =
      await firebaseUser.getIdToken(true);

      if (firebaseIdToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      debugPrint('🔑 Firebase idToken obtained (length: ${firebaseIdToken.length})');

      // Step 5: Send Firebase idToken to backend
      await _sendTokenToBackend(firebaseIdToken);

    } catch (e) {
      debugPrint('❌ Google Sign-In error: $e');
      generalErrorMessage.value = 'Google sign-in failed. Please try again.';
      Get.snackbar(
        'Sign-In Failed',
        'Google sign-in failed. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      isGoogleSigningIn.value = false;
    }
  }

  // ── Send Firebase idToken to backend ──────────────────────────────────────
  Future<void> _sendTokenToBackend(String firebaseIdToken) async {
    try {
      debugPrint('📤 Sending Firebase idToken to backend...');
      debugPrint('🌐 Endpoint: ${AppUrl.googleLogin}');

      final NetworkResponseDio response = await _networkCaller.postRequest(
        AppUrl.googleLogin,
        body: {'idToken': firebaseIdToken},
        isLogin: true,
      );

      debugPrint('📡 Status: ${response.statusCode}');
      debugPrint('📡 Success: ${response.isSuccess}');
      debugPrint('📡 Data: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        final jsonResponse = response.jsonResponse!;

        // ✅ Extract backend JWT — same structure as email login
        // data.tokens.access.token
        String? authToken;
        try {
          final data = jsonResponse['data'];
          if (data != null && data['tokens'] != null) {
            authToken = data['tokens']['access']['token'];
          }
        } catch (_) {}

        // Fallback token fields
        authToken ??= jsonResponse['token'] ??
            jsonResponse['accessToken'] ??
            jsonResponse['data']?['token'];

        if (authToken != null && authToken.isNotEmpty) {
          await SecureStorageService.instance.saveAccessToken(authToken);
          debugPrint('🔑 Backend token saved successfully');

          final saved = await SecureStorageService.instance.getAccessToken();
          debugPrint(
              '✅ Token verified: ${saved != null ? "OK (${saved.length} chars)" : "FAILED"}');
        } else {
          debugPrint('⚠️ No token in backend response: $jsonResponse');
          generalErrorMessage.value =
          'Google sign-in succeeded but no token received. Please try again.';
          isGoogleSigningIn.value = false;
          return;
        }

        // Save user data
        try {
          final data = jsonResponse['data'];
          if (data != null && data['user'] != null) {
            await SecureStorageService.instance
                .saveUserData(Map<String, dynamic>.from(data['user']));
            debugPrint('👤 User data saved from backend');
          }
        } catch (_) {}

        Get.offAll(() => const MainBottomNav());
      } else {
        // ✅ Backend rejected — show error, do NOT navigate
        debugPrint('❌ Backend rejected token');
        debugPrint('❌ Error: ${response.errorMessage}');
        debugPrint('❌ Response: ${response.jsonResponse}');

        final errMsg = response.jsonResponse?['message']?.toString() ??
            response.errorMessage ??
            'Google sign-in failed. Please try again.';

        generalErrorMessage.value = errMsg;
        Get.snackbar(
          'Sign-In Failed',
          errMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
        isGoogleSigningIn.value = false;
      }
    } catch (e) {
      debugPrint('❌ Error calling backend: $e');
      generalErrorMessage.value =
      'An error occurred during Google sign-in. Please try again.';
      Get.snackbar(
        'Error',
        'An error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      isGoogleSigningIn.value = false;
    } finally {
      isGoogleSigningIn.value = false;
    }
  }

  // ── Sign out ───────────────────────────────────────────────────────────────
  Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      await SecureStorageService.instance.clearAll();
      debugPrint('✅ Signed out');
    } catch (e) {
      debugPrint('❌ Error signing out: $e');
    }
  }

  void clearForm() {
    emailController.clear();
    passwordController.clear();
    emailError.value = '';
    passwordError.value = '';
    generalErrorMessage.value = '';
  }

  // ── Apple Sign-In (coming soon) ────────────────────────────────────────────
  Future<void> continueWithApple() async {
    if (isAppleSigningIn.value) return;
    isAppleSigningIn.value = true;
    Get.snackbar('Info', 'Apple sign-in coming soon',
        snackPosition: SnackPosition.TOP);
    await Future.delayed(const Duration(seconds: 1));
    isAppleSigningIn.value = false;
  }
}