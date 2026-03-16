import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:outdoor_therapy/features/views/auth/sign_in_screen.dart';
import 'package:outdoor_therapy/features/views/bottom_nav/main_bottom_nav.dart';
import 'package:outdoor_therapy/features/views/home/home_screen.dart';
import 'package:outdoor_therapy/features/views/now_playing/now_playing_screen.dart';

import 'features/views/onboard/onboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // home: OnboardingScreen(),
      home: MainBottomNav(),
    );
  }
}