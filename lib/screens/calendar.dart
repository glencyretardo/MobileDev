import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HorizontalCalendar extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final String userId;

  HorizontalCalendar({
    Key? key,
    required this.initialDate,
    required this.onDateSelected,
    required this.userId,
  }) : super(key: key);

  @override
  _HorizontalCalendarState createState() => _HorizontalCalendarState();
}

class _HorizontalCalendarState extends State<HorizontalCalendar> {
  final ScrollController scrollController = ScrollController();
  DateTime? firstHabitDate;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    _fetchFirstHabitDate();
  }

  Future<void> _fetchFirstHabitDate() async {
    try {
      String userId = widget.userId;

      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('habits')
          .orderBy('createdAt', descending: false)
          .limit(1)
          .get()
          .timeout(Duration(seconds: 10));

      if (snapshot.docs.isNotEmpty) {
        Timestamp timestamp = snapshot.docs.first['createdAt'];
        setState(() {
          firstHabitDate = timestamp.toDate();
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToToday();
        });
      } else {
        setState(() {
          firstHabitDate = DateTime.now();
        });
      }
    } catch (e) {
      setState(() {
        firstHabitDate = DateTime.now();
      });
    }
  }

  void _scrollToToday() {
    if (firstHabitDate != null) {
      DateTime today = DateTime.now();
      int daysFromFirstHabit = today.difference(firstHabitDate!).inDays;

      double position = (daysFromFirstHabit - 3) * 50.0; // Center "today"
      if (position < 0) {
        position = 0; // Prevent negative scroll positions
      }
      scrollController.jumpTo(position);
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime startDate =
        firstHabitDate ?? today; // Start from first habit date or today
    int totalDays =
        today.difference(startDate).inDays + 30; // Include past and future days

    return Column(
      children: [
        // Header displaying the selected date
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            DateFormat('MMMM d').format(selectedDate),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: firstHabitDate == null
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: totalDays,
                  itemBuilder: (context, index) {
                    DateTime date = startDate.add(Duration(days: index));
                    bool isSelected = date.day == selectedDate.day &&
                        date.month == selectedDate.month &&
                        date.year == selectedDate.year;

                    bool isToday = date.day == today.day &&
                        date.month == today.month &&
                        date.year == today.year;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                        });
                        widget.onDateSelected(date);
                      },
                      child: Container(
                        width: 50,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isToday
                              ? Color(0xFFA0CBCB)
                              : isSelected
                                  ? const Color.fromARGB(255, 82, 137, 137)
                                  : const Color.fromARGB(255, 238, 238, 238),
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isToday ? 'Today' : DateFormat('E').format(date),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isToday || isSelected
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
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
        ),
      ],
    );
  }
}
