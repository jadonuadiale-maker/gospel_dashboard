import 'package:flutter/material.dart';
import 'sermons_screen.dart';
import 'songs_screen.dart';
import 'messages_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // --- CategoryCard: visually intentional card component ---
  Widget _categoryCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required Widget screen,
  }) {
    return InkWell(
      // ripple feedback
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      ),
      child: Container(
        // card styling
        margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              offset: Offset(0, 3),
              color: Colors.black12,
            ),
          ],
        ),
        child: Row(
          children: [
            // category icon
            Icon(icon, size: 42, color: accent),

            const SizedBox(width: 16),

            // title + subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gospel Dashboard")),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          _categoryCard(
            context: context,
            title: "Sermons",
            subtitle: "Explore sermons",
            icon: Icons.menu_book,
            accent: Colors.amber.shade400,
            screen: const SermonsScreen(),
          ),
          _categoryCard(
            context: context,
            title: "Songs",
            subtitle: "Listen to worship songs",
            icon: Icons.music_note,
            accent: Colors.tealAccent.shade400,
            screen: const SongsScreen(),
          ),
          _categoryCard(
            context: context,
            title: "Messages",
            subtitle: "Inspirational messages",
            icon: Icons.message,
            accent: Colors.indigoAccent.shade400,
            screen: const MessagesScreen(),
          ),
        ],
      ),
    );
  }
}