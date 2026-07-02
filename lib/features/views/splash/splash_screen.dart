
import 'package:get/get.dart';
import 'splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:outdoor_therapy/core/app_colors.dart';

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

  final SplashController splashController = Get.put(SplashController());

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _iconAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _textAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    /// 🔥 navigation handled by controller
    splashController.handleNavigation();
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
            SlideTransition(
              position: _iconAnimation,
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/logoIcon_1.svg',
                    width: 40,
                    height: 60,
                  ),
                ],
              ),
            ),

            SlideTransition(
              position: _textAnimation,
              child: SvgPicture.asset(
                'assets/icons/logoIcon_2.svg',
                width: 40,
                height: 60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



