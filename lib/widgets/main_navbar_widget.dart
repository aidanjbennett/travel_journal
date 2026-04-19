import 'package:flutter/material.dart';

class MainNavbar extends StatelessWidget {
  final int currentIndex;

  const MainNavbar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        if (currentIndex != 0) {
          Navigator.pushReplacementNamed(context, '/home');
        }
        break;
      case 1:
        if (currentIndex != 1) {
          Navigator.pushReplacementNamed(context, '/entries');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Entries'),
      ],
    );
  }
}
