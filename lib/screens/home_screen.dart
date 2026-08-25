// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // --- CategoryCard: reusable card for each category ---
  Widget _categoryCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required String routeName,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Container(
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
            Icon(icon, size: 42, color: accent),
            const SizedBox(width: 16),
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
            routeName: '/sermons',
          ),
          _categoryCard(
            context: context,
            title: "Songs",
            subtitle: "Listen to worship songs",
            icon: Icons.music_note,
            accent: Colors.tealAccent.shade400,
            routeName: '/songs',
          ),
          _categoryCard(
            context: context,
            title: "Messages",
            subtitle: "Inspirational messages",
            icon: Icons.message,
            accent: Colors.indigoAccent.shade400,
            routeName: '/messages',
          ),
          _categoryCard(
            context: context,
            title: "Hymns",
            subtitle: "Classic worship hymns",
            icon: Icons.library_music,
            accent: Colors.greenAccent.shade400,
            routeName: '/hymns',   // NEW
          ),
        ],
      ),
    );
  }
}