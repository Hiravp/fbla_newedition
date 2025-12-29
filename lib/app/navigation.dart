import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/resources/resources_screen.dart';
import '../screens/news/news_screen.dart';
import '../screens/social/social_screen.dart';
import '../screens/ai/ai_screen.dart';
import '../screens/games/games_screen.dart';
import '../screens/login/login_screen.dart';

class AppNavigation {
  static final routes = <String, WidgetBuilder>{
    '/': (_) => const HomeScreen(),
    '/profile': (_) => const ProfileScreen(),
    '/calendar': (_) => const CalendarScreen(),
    '/resources': (_) => const ResourcesScreen(),
    '/news': (_) => const NewsScreen(),
    '/social': (_) => const SocialScreen(),
    '/ai': (_) => const AiScreen(),
    '/games': (_) => const GamesScreen(),
    '/login': (_) => const LoginScreen(),
  };
}
