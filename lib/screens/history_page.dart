import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final String userId; // Add userId as a parameter

  const HistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'History Page for User: $userId', // Display the userId to confirm it's being passed
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
