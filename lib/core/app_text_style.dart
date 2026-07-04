import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyle {
  AppTextStyle._();

  static TextStyle get ARIAL_White {
    return TextStyle(
      fontFamily: 'ARIAL',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.textWhite,
    );
  }

  static TextStyle get ARIAL_Black {
    return TextStyle(
      fontFamily: 'ARIAL',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.textBlack,
    );
  }

  static TextStyle get ARIAL_Grey {
    return TextStyle(
      fontFamily: 'ARIAL',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.textGrey,
    );
  }
}