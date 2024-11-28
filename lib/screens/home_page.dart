import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'custom_bottom_navigation_bar.dart'; // Import the reusable nav bar

class HomePage extends StatelessWidget {
  final String userName = "Clarize"; // Replace with dynamic data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, $userName!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      DateFormat('MMMM d, yyyy').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    // Add action for the plus button
                  },
                  icon: Icon(
                    Icons.add,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // One-week calendar
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                DateTime today = DateTime.now();
                DateTime date = today.subtract(
                  Duration(days: today.weekday - 1 - index),
                ); // Start from Sunday
                bool isToday = date.day == today.day &&
                    date.month == today.month &&
                    date.year == today.year;

                return GestureDetector(
                  onTap: () {
                    // Add functionality to handle date tap
                    print(
                        "Selected date: ${DateFormat('yyyy-MM-dd').format(date)}");
                  },
                  child: Container(
                    width: 60,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isToday ? Colors.blue : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E')
                              .format(date), // Day abbreviation (e.g., Sun)
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isToday ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          date.day.toString(), // Date number
                          style: TextStyle(
                            fontSize: 14,
                            color: isToday ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to create habit screen or trigger create habit logic
                  print("Create New Habit button clicked!");
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text("Create New Habit"),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0, // Highlight 'Today' tab by default
        onTap: (index) {
          // Handle navigation between tabs
          print("Selected Tab: $index");
        },
      ),
    );
  }
}
