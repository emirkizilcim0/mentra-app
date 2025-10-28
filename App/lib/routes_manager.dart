// It consists of routes of the application.

import 'package:flutter/material.dart';
import 'splash_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'profile_page.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashPage(),
    '/home': (context) => const HomePage(),
    '/login': (context) => const LoginPage(),
    '/signup': (context) => const SignupPage(),
    '/profile': (context) => const ProfilePage(),
  };
}
