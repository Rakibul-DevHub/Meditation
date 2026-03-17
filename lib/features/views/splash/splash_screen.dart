import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../onboard/onboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToOnboard();
  }

  Future<void> _navigateToOnboard() async {
    await Future.delayed(const Duration(seconds: 3), () {});

    // Navigate with bottom-to-up transition
    Get.offAll(
          () => const OnboardingScreen(),
      transition: Transition.downToUp, // This gives top-to-bottom
      // For bottom-to-up, we use custom transition
      duration: const Duration(milliseconds: 1400 ),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/gif/outdoor_therapy.gif',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}