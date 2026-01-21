import 'package:flutter/material.dart';
import 'core/screens/splash_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const LibraTechApp());
}

class LibraTechApp extends StatelessWidget {
  const LibraTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LibraTech',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
