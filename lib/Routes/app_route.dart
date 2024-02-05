import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terminal_demo/Screens/economiccalender_scree.dart';
import 'package:terminal_demo/Screens/home_screen.dart';
import 'package:terminal_demo/Screens/login_screen.dart';
import '../Screens/coin_screen.dart';
import '../Screens/error_screen.dart';
import '../Screens/profile_screen.dart';

class AppRoutes {
  Route<dynamic> onGeneratedRoutes(RouteSettings settings) {
    switch (settings.name) {
      case HomeScreen.routeName:
        return PageTransition(
          child: const HomeScreen(),
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 300),
          reverseDuration: const Duration(milliseconds: 300),
        );
      case ProfileScreen.routeName:
        return PageTransition(
          child: const ProfileScreen(),
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 300),
          reverseDuration: const Duration(milliseconds: 300),
        );
      case Login_Screen.routeName:
        var index = settings.arguments as Login_Screen;
        return PageTransition(
          child: Login_Screen(
            isFromSplash: index.isFromSplash,
          ),
          type: PageTransitionType.bottomToTop,
          duration: const Duration(milliseconds: 300),
          reverseDuration: const Duration(milliseconds: 300),
        );
      case EconomicCalenderScreen.routeName:
        return PageTransition(
          child: const EconomicCalenderScreen(),
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 300),
          reverseDuration: const Duration(milliseconds: 300),
        );
        case Coin_Screen.routeName:
        return PageTransition(
          child: const Coin_Screen(),
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 300),
          reverseDuration: const Duration(milliseconds: 300),
        );
      default:
        return PageTransition(
          child: const ErrorScreen(),
          type: PageTransitionType.leftToRight,
          duration: const Duration(milliseconds: 300),
          reverseDuration: const Duration(milliseconds: 300),
        );
    }
  }
}
