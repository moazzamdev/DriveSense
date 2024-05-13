import 'package:asaf/animations/onboarding.dart';
import 'package:asaf/auth_screens/email_verfication.dart';
import 'package:asaf/screens/homepage.dart';
import 'package:asaf/services/startscreen.dart';
import 'package:flutter/material.dart';
import 'splash.dart';

class PageRouteNames {
  static const String login = '/login';
  static const String home = '/SplashScreen';
  static const String verify = '/VerifyScreen';
  static const String start = '/StartScreen';
  static const String onboarding = '/onboarding';
}

const TextStyle textStyle = TextStyle(
  color: Colors.black,
  fontSize: 13.0,
  decoration: TextDecoration.none,
);

Map<String, WidgetBuilder> routes = {
  PageRouteNames.login: (context) => const SplashScreen(),
  PageRouteNames.home: (context) => const HomePage(),
  PageRouteNames.verify: (context) => EmailVerfication(),
  PageRouteNames.start: (context) => StartScreen(),
  PageRouteNames.onboarding: (context) => OnBoarding()
};

class UserInfo {
  String id = '';
  String name = '';

  UserInfo({
    required this.id,
    required this.name,
  });

  bool get isEmpty => id.isEmpty;

  UserInfo.empty();
}

UserInfo currentUser = UserInfo.empty();
const String cacheUserIDKey = 'cache_user_id_key';
