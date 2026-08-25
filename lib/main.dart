// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/sermons_screen.dart';
import 'screens/songs_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/hymns_screen.dart';
import 'screens/player_screen.dart';
import 'screens/playlist_screen.dart';
import 'screens/playlist_detail_screen.dart';
import 'theme/app_theme.dart';
import 'services/audio_service.dart';
import 'widgets/mini_player.dart';

void main() {
  runApp(const GospelDashboardApp());
}

class GospelDashboardApp extends StatelessWidget {
  const GospelDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,

      // IMPORTANT: Do NOT wrap Scaffold here.
      // Instead wrap each routed page inside a global shell.
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case '/':
            page = const SplashToHome();
            break;
          case '/sermons':
            page = const SermonsScreen();
            break;
          case '/songs':
            page = const SongsScreen();
            break;
          case '/messages':
            page = const MessagesScreen();
            break;
          case '/hymns':
            page = const HymnsScreen();
            break;
          case '/player':
            page = PlayerScreen(audio: AudioService());
            break;
          case '/playlist':
            page = const PlaylistScreen();
            break;
          case '/playlist/detail':
            page = const PlaylistDetailScreen();
            break;
          default:
            page = const HomeScreen();
        }

        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => GlobalShell(child: page),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 250),
        );
      },
    );
  }
}

class GlobalShell extends StatelessWidget {
  final Widget child;
  const GlobalShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final audio = AudioService();
    final routeName = ModalRoute.of(context)?.settings.name;
    final isPlayerScreen = routeName == '/player';

    return Scaffold(
      body: Stack(
        children: [
          child,

          // Reactive global mini-player
          StreamBuilder<void>(
            stream: audio.stateStream,
            builder: (context, _) {
              if (isPlayerScreen || audio.currentUrl == null) {
                return const SizedBox.shrink();
              }

              return Positioned(
                left: 0,
                right: 0,
                bottom: 60,
                child: MiniPlayer(audio: audio),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Splash screen
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
      duration: const Duration(milliseconds: 800),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: const HomeScreen(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}