/**
import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/core/network/secure_storage_service.dart';
import '../bottom_nav/main_bottom_nav.dart';
import '../onboard/onboard_screen.dart';

class SplashController extends GetxController {
  Future<void> handleNavigation() async {
    /// wait for splash animation + hold time
    await Future.delayed(const Duration(milliseconds: 2500));

    final token = await SecureStorageService.instance.getAccessToken();

    if (token != null && token.isNotEmpty) {
      Get.offAll(
            () => const MainBottomNav(),
        transition: Transition.fade,
        duration: const Duration(milliseconds: 600),
      );
    } else {
      Get.offAll(
            () => const OnboardingScreen(),
        transition: Transition.downToUp,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }
}*/







import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/core/network/secure_storage_service.dart';
import 'package:outdoor_therapy/core/network/token_refresh_service.dart';
import '../bottom_nav/main_bottom_nav.dart';
import '../onboard/onboard_screen.dart';

class SplashController extends GetxController {
  Future<void> handleNavigation() async {
    /// wait for splash animation + hold time
    await Future.delayed(const Duration(milliseconds: 2500));

    final accessToken = await SecureStorageService.instance.getAccessToken();
    final refreshToken = await SecureStorageService.instance.getRefreshToken();

    // No session at all — straight to onboarding/login.
    if (accessToken == null || accessToken.isEmpty || refreshToken == null || refreshToken.isEmpty) {
      _goToOnboarding();
      return;
    }

    // Splash is the one safe moment to proactively refresh: there's no
    // in-flight request to interrupt, and the user is already waiting on
    // this screen anyway. This guarantees the session starts with a
    // genuinely fresh access token instead of betting that the old one
    // still has time left on it.
    final refreshed = await TokenRefreshService.instance.refreshAccessToken();

    if (refreshed) {
      Get.offAll(
            () => const MainBottomNav(),
        transition: Transition.fade,
        duration: const Duration(milliseconds: 600),
      );
    } else {
      // Refresh token is invalid/expired/revoked — there's no recovering
      // from this without signing in again.
      await SecureStorageService.instance.clearAll();
      _goToOnboarding();
    }
  }

  void _goToOnboarding() {
    Get.offAll(
          () => const OnboardingScreen(),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }
}