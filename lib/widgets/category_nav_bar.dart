// lib/widgets/category_nav_bar.dart
import 'package:flutter/material.dart';

class CategoryNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CategoryNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,

      // --- Minimalist, modern bottom nav ---
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey.shade600,
      backgroundColor: Colors.white,
      elevation: 8,

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.library_music),
          label: "All",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: "Favourites",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Ministers",
        ),
      ],
    );
  }
}