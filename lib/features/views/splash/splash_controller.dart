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
}