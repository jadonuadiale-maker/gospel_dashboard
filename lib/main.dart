import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GospelDashboardApp());
}

class GospelDashboardApp extends StatelessWidget {
  const GospelDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashToHome(),
    );
  }
}

class SplashToHome extends StatefulWidget {
  const SplashToHome({super.key});

  @override
  State<SplashToHome> createState() => _SplashToHomeState();
}

class _SplashToHomeState extends State<SplashToHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),   // Fade duration
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,                       // Smooth curve
    );

    _controller.forward();                           // Start fade
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: const HomeScreen(),                     // Your dashboard
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}