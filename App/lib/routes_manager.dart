// It consists of routes of the application.

import 'package:flutter/material.dart';
import 'package:mentra_app/chat_page.dart';
import 'package:mentra_app/diary_write_page.dart';
import 'package:mentra_app/diary_detail_page.dart';
import 'splash_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'profile_page.dart';
import 'test_page.dart';
import 'info_page.dart';
import 'mbti/result_screen.dart';
import 'mbti/personality_data.dart';
import 'bar_widgets/custom_header.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashPage(),
    '/home': (context) => const HomePage(),
    '/login': (context) => const LoginPage(),
    '/signup': (context) => const SignupPage(),
    '/profile': (context) => const ProfilePage(),
    '/testPage': (context) => const MbtiTestPage(),
    '/chatPage': (context) => const ChatPage(),
    '/diaryWrite': (context) => const DiaryWritePage(),
    '/MyCustomFont': (context) => const CustomHeader(),
    '/splash': (context) => const SplashPage(),
    '/diaryDetail': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return DiaryDetailPage(diaryEntry: args);
    },
    '/infoPage': (context) => const InfoPage(),
    '/resultPage': (context) => ResultScreen(
      onRetakeTest: () {
        // Just for testing — go back or show a snackbar
        print("Retake test pressed!");
      },
      borderRadius: BorderRadius.circular(12),
      scores: {
        'E': 12,
        'I': 8,
        'N': 15,
        'S': 5,
        'T': 10,
        'F': 14,
        'J': 9,
        'P': 11,
      },
    ),
  };
}
