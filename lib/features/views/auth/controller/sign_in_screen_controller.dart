/**
import 'dart:io';
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

  // ✅ IMPORTANT: Use WEB client ID from Google Cloud Console
  // Go to: Firebase Console → Project Settings → General
  // → Your apps → Web app → OAuth client ID
  // OR: Google Cloud Console → APIs & Services → Credentials
  // → OAuth 2.0 Client IDs → type "Web application"
  static const String _webClientId =
      '118678777351-6n4i380nl469ok1kacmum4q0nt6hp3pd.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: _webClientId,
  );

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final RxBool isLoading = false.obs;
  final RxBool isGoogleSigningIn = false.obs;
  final RxBool isAppleSigningIn = false.obs;
  final RxBool isPasswordVisible = false.obs;

  final TextEditingController emailController = TextEditingController(text: 'user1@yopmail.com');
  final TextEditingController passwordController = TextEditingController(text: 'Asdfasdf1');

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

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        if (response.jsonResponse != null) {
          final LoginResponseModel loginResponse = LoginResponseModel.fromJson(
            response.jsonResponse!,
          );

          // ── Extract and save access token ──
          if (loginResponse.token != null && loginResponse.token!.isNotEmpty) {
            await SecureStorageService.instance.saveAccessToken(
              loginResponse.token!,
            );
            debugPrint('🔑 Access token saved');
          } else {
            generalErrorMessage.value =
            'Login succeeded but no access token received. Please try again.';
            isLoading.value = false;
            return;
          }

          // ── Extract and save refresh token ──
          try {
            final data = response.jsonResponse?['data'];
            if (data != null && data['tokens'] != null) {
              final refreshToken = data['tokens']['refresh']?['token'];
              if (refreshToken != null && refreshToken.isNotEmpty) {
                await SecureStorageService.instance.saveRefreshToken(refreshToken);
                debugPrint('🔄 Refresh token saved');
              }
            }
          } catch (e) {
            debugPrint('⚠️ Could not extract refresh token: $e');
          }

          // ── Save user data ──
          if (loginResponse.data != null) {
            await SecureStorageService.instance.saveUserData(
              loginResponse.data!.toJson(),
            );
            debugPrint('👤 User data saved');
          }

          Get.offAll(() => const MainBottomNav());
        } else {
          Get.offAll(() => const MainBottomNav());
        }
      } else {
        String errorMsg =
            response.errorMessage ??
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
          snackPosition: SnackPosition.BOTTOM,
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

  // ── Google Sign-In ──────────────────────────────────────────────────────────
  Future<void> continueWithGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn(
        scopes: ['email', 'profile'],
      ).signOut();

      final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn(
        scopes: ['email', 'profile'],
      ).signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult = await FirebaseAuth.instance
            .signInWithCredential(credential);
        final User? user = authResult.user;

        debugPrint('👤 Google user: ${user?.email}');

        await _sendTokenToBackend(await user?.getIdToken() ?? 'Unknown Token');
      }
    } catch (e) {
      debugPrint('❌ Google sign-in error: $e');
      generalErrorMessage.value = 'Google sign-in failed. Please try again.';
      Get.snackbar(
        'Sign-In Failed',
        'Google sign-in failed. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isGoogleSigningIn.value = false;
    }
  }

  // ── Send Firebase Token to Backend ──────────────────────────────────────────
  Future<void> _sendTokenToBackend(String firebaseIdToken) async {
    try {
      isGoogleSigningIn.value = true;
      debugPrint('📤 Sending Firebase idToken to backend...');
      debugPrint('🌐 Endpoint: ${AppUrl.googleLogin}');

      final NetworkResponseDio response = await _networkCaller.postRequest(
        AppUrl.googleLogin,
        body: {'idToken': firebaseIdToken},
        isLogin: true,
      );

      debugPrint('📡 Status: ${response.statusCode}');
      debugPrint('📡 Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final jsonResponse = response.jsonResponse!;

        // ── Extract access token ──
        String? authToken;
        try {
          final data = jsonResponse['data'];
          if (data != null && data['tokens'] != null) {
            authToken = data['tokens']['access']?['token'];
          }
        } catch (_) {}

        authToken ??=
            jsonResponse['token'] ??
                jsonResponse['accessToken'] ??
                jsonResponse['data']?['token'];

        if (authToken != null && authToken.isNotEmpty) {
          await SecureStorageService.instance.saveAccessToken(authToken);
          debugPrint('🔑 Access token saved');
        } else {
          generalErrorMessage.value =
          'Google sign-in succeeded but no access token received. Please try again.';
          isGoogleSigningIn.value = false;
          return;
        }

        // ── Extract and save refresh token ──
        try {
          final data = jsonResponse['data'];
          if (data != null && data['tokens'] != null) {
            final refreshToken = data['tokens']['refresh']?['token'];
            if (refreshToken != null && refreshToken.isNotEmpty) {
              await SecureStorageService.instance.saveRefreshToken(refreshToken);
              debugPrint('🔄 Refresh token saved');
            }
          }
        } catch (e) {
          debugPrint('⚠️ Could not extract refresh token: $e');
        }

        // ── Save user data ──
        try {
          final data = jsonResponse['data'];
          if (data != null && data['user'] != null) {
            await SecureStorageService.instance.saveUserData(
              Map<String, dynamic>.from(data['user']),
            );
            debugPrint('👤 User data saved');
          }
        } catch (_) {}

        Get.offAll(() => const MainBottomNav());
      } else {
        final errMsg =
            response.jsonResponse?['message']?.toString() ??
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
      }
    } on SocketException {
      generalErrorMessage.value = 'No internet connection. Please check your network.';
      Get.snackbar(
        'Network Error',
        'No internet connection. Please check your network.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      debugPrint('❌ Backend error: $e');
      generalErrorMessage.value = 'An unexpected error occurred. Please try again.';
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
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
      debugPrint('✅ Signed out and cleared all tokens');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
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
    Get.snackbar(
      'Info',
      'Apple sign-in coming soon',
      snackPosition: SnackPosition.TOP,
    );
    await Future.delayed(const Duration(seconds: 1));
    isAppleSigningIn.value = false;
  }
}*/







import 'dart:io';
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
// ✅ ADD THIS IMPORT
import '../../../views/home/home_screen_controller.dart';

class SignInScreenController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // ✅ IMPORTANT: Use WEB client ID from Google Cloud Console
  // Go to: Firebase Console → Project Settings → General
  // → Your apps → Web app → OAuth client ID
  // OR: Google Cloud Console → APIs & Services → Credentials
  // → OAuth 2.0 Client IDs → type "Web application"
  static const String _webClientId =
      '118678777351-6n4i380nl469ok1kacmum4q0nt6hp3pd.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: _webClientId,
  );

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final RxBool isLoading = false.obs;
  final RxBool isGoogleSigningIn = false.obs;
  final RxBool isAppleSigningIn = false.obs;
  final RxBool isPasswordVisible = false.obs;

  final TextEditingController emailController = TextEditingController(text: 'user1@yopmail.com');
  final TextEditingController passwordController = TextEditingController(text: 'Asdfasdf1');

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

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        if (response.jsonResponse != null) {
          final LoginResponseModel loginResponse = LoginResponseModel.fromJson(
            response.jsonResponse!,
          );

          // ── Extract and save access token ──
          if (loginResponse.token != null && loginResponse.token!.isNotEmpty) {
            await SecureStorageService.instance.saveAccessToken(
              loginResponse.token!,
            );
            debugPrint('🔑 Access token saved');
          } else {
            generalErrorMessage.value =
            'Login succeeded but no access token received. Please try again.';
            isLoading.value = false;
            return;
          }

          // ── Extract and save refresh token ──
          try {
            final data = response.jsonResponse?['data'];
            if (data != null && data['tokens'] != null) {
              final refreshToken = data['tokens']['refresh']?['token'];
              if (refreshToken != null && refreshToken.isNotEmpty) {
                await SecureStorageService.instance.saveRefreshToken(refreshToken);
                debugPrint('🔄 Refresh token saved');
              }
            }
          } catch (e) {
            debugPrint('⚠️ Could not extract refresh token: $e');
          }

          // ── Save user data ──
          if (loginResponse.data != null) {
            await SecureStorageService.instance.saveUserData(
              loginResponse.data!.toJson(),
            );
            debugPrint('👤 User data saved');
          }

          // ✅ Navigate to home and refresh data
          await _navigateToHomeAndRefresh();
        } else {
          await _navigateToHomeAndRefresh();
        }
      } else {
        String errorMsg =
            response.errorMessage ??
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
          snackPosition: SnackPosition.BOTTOM,
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

  // ── Navigate to Home and Refresh Data ────────────────────────────────────
  Future<void> _navigateToHomeAndRefresh() async {
    // Navigate to main bottom nav
    Get.offAll(() => const MainBottomNav());

    // Wait for navigation to complete and widget tree to build
    await Future.delayed(const Duration(milliseconds: 500));

    // Find and refresh the home controller
    try {
      // ✅ Now HomeScreenController is imported, so we can use it directly
      if (Get.isRegistered<HomeScreenController>()) {
        final homeController = Get.find<HomeScreenController>();
        await homeController.refreshAfterSignIn();
        debugPrint('✅ Home data refreshed after sign-in');
      } else {
        debugPrint('⚠️ HomeScreenController not registered yet');
      }
    } catch (e) {
      debugPrint('⚠️ Could not refresh home data: $e');
    }
  }

  // ── Google Sign-In ──────────────────────────────────────────────────────────
  Future<void> continueWithGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn(
        scopes: ['email', 'profile'],
      ).signOut();

      final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn(
        scopes: ['email', 'profile'],
      ).signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult = await FirebaseAuth.instance
            .signInWithCredential(credential);
        final User? user = authResult.user;

        debugPrint('👤 Google user: ${user?.email}');

        await _sendTokenToBackend(await user?.getIdToken() ?? 'Unknown Token');
      }
    } catch (e) {
      debugPrint('❌ Google sign-in error: $e');
      generalErrorMessage.value = 'Google sign-in failed. Please try again.';
      Get.snackbar(
        'Sign-In Failed',
        'Google sign-in failed. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isGoogleSigningIn.value = false;
    }
  }

  // ── Send Firebase Token to Backend ──────────────────────────────────────────
  Future<void> _sendTokenToBackend(String firebaseIdToken) async {
    try {
      isGoogleSigningIn.value = true;
      debugPrint('📤 Sending Firebase idToken to backend...');
      debugPrint('🌐 Endpoint: ${AppUrl.googleLogin}');

      final NetworkResponseDio response = await _networkCaller.postRequest(
        AppUrl.googleLogin,
        body: {'idToken': firebaseIdToken},
        isLogin: true,
      );

      debugPrint('📡 Status: ${response.statusCode}');
      debugPrint('📡 Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final jsonResponse = response.jsonResponse!;

        // ── Extract access token ──
        String? authToken;
        try {
          final data = jsonResponse['data'];
          if (data != null && data['tokens'] != null) {
            authToken = data['tokens']['access']?['token'];
          }
        } catch (_) {}

        authToken ??=
            jsonResponse['token'] ??
                jsonResponse['accessToken'] ??
                jsonResponse['data']?['token'];

        if (authToken != null && authToken.isNotEmpty) {
          await SecureStorageService.instance.saveAccessToken(authToken);
          debugPrint('🔑 Access token saved');
        } else {
          generalErrorMessage.value =
          'Google sign-in succeeded but no access token received. Please try again.';
          isGoogleSigningIn.value = false;
          return;
        }

        // ── Extract and save refresh token ──
        try {
          final data = jsonResponse['data'];
          if (data != null && data['tokens'] != null) {
            final refreshToken = data['tokens']['refresh']?['token'];
            if (refreshToken != null && refreshToken.isNotEmpty) {
              await SecureStorageService.instance.saveRefreshToken(refreshToken);
              debugPrint('🔄 Refresh token saved');
            }
          }
        } catch (e) {
          debugPrint('⚠️ Could not extract refresh token: $e');
        }

        // ── Save user data ──
        try {
          final data = jsonResponse['data'];
          if (data != null && data['user'] != null) {
            await SecureStorageService.instance.saveUserData(
              Map<String, dynamic>.from(data['user']),
            );
            debugPrint('👤 User data saved');
          }
        } catch (_) {}

        // ✅ Navigate to home and refresh data
        await _navigateToHomeAndRefresh();
      } else {
        final errMsg =
            response.jsonResponse?['message']?.toString() ??
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
      }
    } on SocketException {
      generalErrorMessage.value = 'No internet connection. Please check your network.';
      Get.snackbar(
        'Network Error',
        'No internet connection. Please check your network.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      debugPrint('❌ Backend error: $e');
      generalErrorMessage.value = 'An unexpected error occurred. Please try again.';
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
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
      debugPrint('✅ Signed out and cleared all tokens');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
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
    Get.snackbar(
      'Info',
      'Apple sign-in coming soon',
      snackPosition: SnackPosition.TOP,
    );
    await Future.delayed(const Duration(seconds: 1));
    isAppleSigningIn.value = false;
  }
}