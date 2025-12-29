import 'package:flutter/material.dart';

// FIXED IMPORTS — match your folder structure
import 'screens/home/home_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/resources/resources_screen.dart';
import 'screens/news/news_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() {
  runApp(const FBLAApp());
}

class FBLAApp extends StatefulWidget {
  const FBLAApp({super.key});

  @override
  State<FBLAApp> createState() => _FBLAAppState();
}

class _FBLAAppState extends State<FBLAApp> {
  int _selectedIndex = 0;

  // FIXED — screens now match the corrected imports
  final _screens = const [
    HomeScreen(),
    CalendarScreen(),
    ResourcesScreen(),
    NewsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FBLA Member App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0052CC)),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.event), label: 'Calendar'),
            NavigationDestination(icon: Icon(Icons.menu_book), label: 'Resources'),
            NavigationDestination(icon: Icon(Icons.campaign), label: 'News'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
