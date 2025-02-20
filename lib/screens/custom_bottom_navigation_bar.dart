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
      color: Colors.white, // Changed background color to white
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // "Today" Navigation Item
          IconButton(
            onPressed: () => onNavItemTapped(0),
            icon: Icon(
              Icons.calendar_today,
              color: selectedIndex == 0
                  ? Color.fromARGB(255, 82, 137, 137)
                  : Colors.grey, // Uniform active color
            ),
          ),
          // "History" Navigation Item
          IconButton(
            onPressed: () => onNavItemTapped(1),
            icon: Icon(
              Icons.history,
              color: selectedIndex == 1
                  ? Colors.teal
                  : Colors.grey, // Uniform active color
            ),
          ),
          // "Me" Navigation Item
          IconButton(
            onPressed: () => onNavItemTapped(2),
            icon: Icon(
              Icons.person,
              color: selectedIndex == 2
                  ? Colors.teal
                  : Colors.grey, // Uniform active color
            ),
          ),
        ],
      ),
    );
  }
}
