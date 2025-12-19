// It consists of routes of the application.

import 'package:flutter/material.dart';

import 'package:mentra_app/pages/chat/chat_page.dart';
import 'package:mentra_app/pages/dairy/detail/dairy_detail_page.dart';
import 'package:mentra_app/pages/dairy/write/dairy_write_page.dart';
import 'package:mentra_app/pages/home/home_page.dart';
import 'package:mentra_app/pages/info/info_page.dart';
import 'package:mentra_app/pages/login/login_page.dart';
import 'package:mentra_app/pages/mood/mood_graph_page.dart';
import 'package:mentra_app/pages/profile/profile_page.dart';
import 'package:mentra_app/pages/signup/signup_page.dart';
import 'package:mentra_app/pages/splash/splash_page.dart';
import 'package:mentra_app/pages/test/mbti_test_page.dart';

import 'mbti/result_screen.dart';
import 'mbti/personality_data.dart';

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

    '/diaryDetail': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return DiaryDetailPage(diaryEntry: args);
    },
    '/infoPage': (context) => const InfoPage(),
    '/resultPage': (context) => ResultScreen(mbtiResult: ''),
    '/moodGraph': (context) => const MoodGraphPage(),
  };
}
