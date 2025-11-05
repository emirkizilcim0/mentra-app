// It consists of routes of the application.

import 'package:flutter/material.dart';
import 'package:mentra_app/chat_page.dart';
import 'splash_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'profile_page.dart';
import 'test_page.dart';
import 'info_page.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashPage(),
    '/home': (context) => const HomePage(),
    '/login': (context) => const LoginPage(),
    '/signup': (context) => const SignupPage(),
    '/profile': (context) => const ProfilePage(),
    '/testPage': (context) => const MbtiTestPage(),
    '/chatPage': (context) => const ChatPage(),
    '/infoPage': (context) => const InfoPage(),
  };
}
