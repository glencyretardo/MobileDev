// custom_bottom_navigation_bar.dart

import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onNavItemTapped;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onNavItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.green[100],
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // "Today" Navigation Item
          IconButton(
            onPressed: () => onNavItemTapped(0),
            icon: Icon(
              Icons.calendar_today,
              color: selectedIndex == 0 ? Colors.green : Colors.grey,
            ),
          ),
          // "History" Navigation Item
          IconButton(
            onPressed: () => onNavItemTapped(1),
            icon: Icon(
              Icons.history,
              color: selectedIndex == 1 ? Colors.green : Colors.grey,
            ),
          ),
          // "Me" Navigation Item
          IconButton(
            onPressed: () => onNavItemTapped(2),
            icon: Icon(
              Icons.person,
              color: selectedIndex == 2 ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
