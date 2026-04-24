import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/core/app_colors.dart';
import 'package:outdoor_therapy/core/network/secure_storage_service.dart';

import '../bottom_nav/main_bottom_nav.dart';
import '../onboard/onboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _iconAnimation;
  late Animation<Offset> _textAnimation;

  @override
  void initState() {
    super.initState();

    /// Animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    /// Icon from LEFT
    _iconAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    /// Text from RIGHT
    _textAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    /// 🔥 Check auth + navigate
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    /// wait for animation + hold
    await Future.delayed(const Duration(milliseconds: 2500));

    final token =
    await SecureStorageService.instance.getAccessToken();

    if (token != null) {
      /// ✅ USER LOGGED IN
      Get.offAll(
            () => const MainBottomNav(),
        transition: Transition.topLevel,
        duration: const Duration(milliseconds: 600),
      );
    } else {
      /// ❌ NOT LOGGED IN
      Get.offAll(
            () => const OnboardingScreen(),
        transition: Transition.downToUp,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// ICON
            SlideTransition(
              position: _iconAnimation,
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/logoIcon.svg',
                    width: 50,
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),

            /// TEXT
            SlideTransition(
              position: _textAnimation,
              child: Text(
                "Outdoor Therapy",
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 50,
                  fontFamily: 'Allison-Regular',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}