import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "theme/app_theme.dart";
import "services/auth_service.dart";
import "services/data_service.dart";
import "screens/login/login_screen.dart";
import "screens/home/home_screen.dart";
import "screens/calendar/calendar_screen.dart";
import "screens/resources/resources_screen.dart";
import "screens/news/news_screen.dart";
import "screens/profile/profile_screen.dart";
import "screens/ai/ai_screen.dart";
import "screens/social/social_screen.dart";

late AuthService _authService;
late DataService _dataService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://dsiyyucdnlmangtbjrsi.supabase.co',
    anonKey: 'sb_publishable_a7HGhZQlo2UV-k4zfPVxvg_2cS52ina',
  );
  
  _authService = AuthService();
  await _authService.init();
  _dataService = DataService(Supabase.instance.client);
  
  runApp(const FBLAApp());
}

class FBLAApp extends StatelessWidget {
  const FBLAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FBLA Member Engagement",
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: _authService.isLoggedIn ? const MainApp() : const LoginScreen(),
      routes: {
        "/home": (_) => const MainApp(),
        "/login": (_) => const LoginScreen(),
      },
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  final _screens = const [
    HomeScreen(),
    AiScreen(),
    CalendarScreen(),
    NewsScreen(),
    SocialScreen(),
    ResourcesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy),
            label: "AI",
          ),
          NavigationDestination(
            icon: Icon(Icons.event),
            label: "Calendar",
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper),
            label: "News",
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: "Social",
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books),
            label: "Resources",
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}