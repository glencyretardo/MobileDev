import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HorizontalCalendar extends StatelessWidget {
  final ScrollController scrollController = ScrollController();

  HorizontalCalendar() {
    // Automatically center the view to today's date after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      double todayIndex =
          30; // Today is the center of the range (30 days before + today)
      double scrollPosition = todayIndex * 76; // 60 width + 8 margin * 2
      scrollController.jumpTo(scrollPosition);
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();

    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 61, // Total: 30 days before + today + 30 days after
        itemBuilder: (context, index) {
          DateTime date = today.subtract(Duration(days: 30 - index));
          bool isToday = date.day == today.day &&
              date.month == today.month &&
              date.year == today.year;

          return GestureDetector(
            onTap: () {
              // Handle date tap
              print("Selected date: ${DateFormat('yyyy-MM-dd').format(date)}");
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
                    DateFormat('E').format(date), // Day abbreviation
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isToday ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    date.day.toString(), // Day number
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
    );
  }
}
