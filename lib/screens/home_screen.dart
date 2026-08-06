import 'package:flutter/material.dart';
import 'sermons_screen.dart';
import 'songs_screen.dart';
import 'messages_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _card(BuildContext context, String title, Widget screen, IconData icon) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontSize: 20)),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gospel Dashboard")),
      body: ListView(
        children: [
          _card(context, "Sermons", const SermonsScreen(), Icons.menu_book),
          _card(context, "Songs", const SongsScreen(), Icons.music_note),
          _card(context, "Messages", const MessagesScreen(), Icons.message),
        ],
      ),
    );
  }
}