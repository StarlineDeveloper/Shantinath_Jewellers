import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF3c0000);
  static const Color primaryLightColor = Color(0xffbeb2b2);
  static const Color secondaryColor = Color(0xFFcba74e);
  static const Color secondaryLightColor = Color(0xffc0b76d);
  static const Color botomNavColor = Color(0xFF231f20);
  static const Color secondaryTextColor = Color(0xFF333333);
  static const Color hintColor = Color(0xFFC6C6C6);
  static const Color hintColorLight = Color(0xA8CCCCCC);
  static const Color bg = Color(0xfff8f2f2);
  static const Color defaultColor = Colors.white;
  static const Color textColor = Colors.black;
  static const Color green = Colors.green;
  static const Color red = Colors.red;
  static const Color transparent = Colors.transparent;

  static const boxShadow = BoxShadow(
    color: AppColors.hintColorLight,
    blurRadius: 40,
    offset: Offset(0, 10),
    spreadRadius: 0,
  );
  static const primaryGradient=LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.secondaryColor,
      AppColors.secondaryLightColor,

    ],
  );
}
