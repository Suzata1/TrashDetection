import 'package:flutter/material.dart';
import 'home_page.dart';
import 'splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => SplashScreen(),
    home: (context) => HomePage(),
  };
}