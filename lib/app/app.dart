import 'package:flutter/material.dart';
import 'navigation.dart';
import '../theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FBLA New Edition',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: AppNavigation.routes,
    );
  }
}
