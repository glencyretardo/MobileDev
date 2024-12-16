import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TimePeriodsScreen(),
    );
  }
}

class TimePeriodsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            // Close the screen action
          },
        ),
        title: const Text(
          "Time Periods",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          TimePeriodTile(
            title: "Morning",
            description: "Starts at",
            time: "7:00",
          ),
          TimePeriodTile(
            title: "Afternoon",
            description: "Starts at",
            time: "13:00",
          ),
          TimePeriodTile(
            title: "Evening",
            description: "Starts at",
            time: "18:00",
          ),
          TimePeriodTile(
            title: "End of the Day",
            description: "Ends at",
            time: "21:59",
          ),
        ],
      ),
    );
  }
}

class TimePeriodTile extends StatelessWidget {
  final String title;
  final String description;
  final String time;

  const TimePeriodTile({
    Key? key,
    required this.title,
    required this.description,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          subtitle: Text(
            "$description $time",
            style: const TextStyle(fontSize: 16.0, color: Colors.black54),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
          onTap: () {
            // Handle tap action
          },
        ),
      ),
    );
  }
}
