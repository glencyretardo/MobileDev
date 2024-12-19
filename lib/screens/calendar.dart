import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HorizontalCalendar extends StatefulWidget {
  final DateTime initialDate; // Initial date selected by the user
  final Function(DateTime) onDateSelected; // Callback for date selection
  final String userId; // Add userId parameter

  HorizontalCalendar({
    Key? key,
    required this.initialDate,
    required this.onDateSelected,
    required this.userId, // Pass userId here
  }) : super(key: key);

  @override
  _HorizontalCalendarState createState() => _HorizontalCalendarState();
}

class _HorizontalCalendarState extends State<HorizontalCalendar> {
  final ScrollController scrollController = ScrollController();
  DateTime? firstHabitDate;

  @override
  void initState() {
    super.initState();
    _fetchFirstHabitDate(); // Fetch the first habit's creation date on init
  }

  // Fetch the earliest habit's creation date from Firestore
  Future<void> _fetchFirstHabitDate() async {
    try {
      String userId = widget.userId; // Use the actual user ID from the widget

      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId) // The user ID should be dynamic, not hardcoded
          .collection('habits')
          .orderBy('createdAt', descending: false) // Order by createdAt
          .limit(1)
          .get()
          .timeout(Duration(seconds: 10)); // Set a timeout for the query

      // Check if the query returned any documents
      if (snapshot.docs.isNotEmpty) {
        Timestamp timestamp = snapshot.docs.first['createdAt'];
        setState(() {
          firstHabitDate =
              timestamp.toDate(); // Set the first habit's creation date
        });
        print("First habit date fetched: $firstHabitDate");

        // Ensure that the first visible item is today's date
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToToday();
        });
      } else {
        print("No habits found in the Firestore collection.");
        setState(() {
          firstHabitDate = DateTime.now(); // Fallback if no habits are found
        });
      }
    } catch (e) {
      // Handle timeout or any other errors
      print("Error fetching first habit date: $e");
      setState(() {
        firstHabitDate = DateTime.now(); // Fallback for testing
      });
    }
  }

  // Scroll to the position where today's date is visible
  void _scrollToToday() {
    if (firstHabitDate != null) {
      DateTime today = DateTime.now();
      int daysFromFirstHabit = today.difference(firstHabitDate!).inDays;

      // Adjust scroll position by adding 30 for the days before the first habit date
      double position =
          (daysFromFirstHabit + 30) * 60.0; // 60.0 is the width of each item
      scrollController.jumpTo(position); // Jump to the calculated position
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    int daysFromFirstHabit =
        firstHabitDate != null ? today.difference(firstHabitDate!).inDays : 0;

    // Total days visible (30 days before and after the first habit date, plus today)
    int totalDays = daysFromFirstHabit + 61;

    return SizedBox(
      height: 80,
      child: firstHabitDate == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: totalDays, // Total number of days visible
              itemBuilder: (context, index) {
                DateTime date = firstHabitDate!.add(
                    Duration(days: index - 30)); // Adjust for scrolling range
                bool isSelected = date.day == widget.initialDate.day &&
                    date.month == widget.initialDate.month &&
                    date.year == widget.initialDate.year;

                bool isToday = date.day == today.day &&
                    date.month == today.month &&
                    date.year == today.year;

                bool isBeforeFirstHabit =
                    firstHabitDate != null && date.isBefore(firstHabitDate!);

                return GestureDetector(
                  onTap: isBeforeFirstHabit
                      ? null // Disable selection for dates before the first habit date
                      : () {
                          widget.onDateSelected(
                              date); // Trigger the callback with the selected date
                        },
                  child: Container(
                    width: 60,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isToday
                          ? Colors
                              .blue // Highlight today's date with blue color
                          : isSelected
                              ? Colors.orange // Selected date with orange color
                              : isBeforeFirstHabit
                                  ? Colors.grey // Disable color for past dates
                                  : Colors.grey[
                                      200], // Default color for other dates
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
                            color: isToday || isSelected
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          date.day.toString(), // Day number
                          style: TextStyle(
                            fontSize: 14,
                            color: isToday || isSelected
                                ? Colors.white
                                : Colors.black,
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
