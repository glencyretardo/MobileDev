import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:habify_3/transaction/addHabit.dart';
import 'calendar.dart';
import 'package:habify_3/transaction/editHabit.dart';

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedFilter = "ALL";
  DateTime selectedDate = DateTime.now(); // To track the selected date
  String selectedDateString = DateFormat('yyyy-MM-dd')
      .format(DateTime.now()); // Declare selectedDateString

  @override
  void initState() {
    super.initState();
    selectedDateString = DateFormat('yyyy-MM-dd').format(selectedDate);
    testFirestoreQuery(); // Call the debug function here
  }

  void testFirestoreQuery() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users') // First, access the 'users' collection
          .doc(widget.userId) // Then, access the specific user's document
          .collection('habits') // Finally, access the 'habits' subcollection
          .get();

      print("DEBUG: Found ${snapshot.docs.length} habits");
      for (var doc in snapshot.docs) {
        print("Habit Name: ${doc['habitName']}, Color: ${doc['color']}");
      }

      if (snapshot.docs.isEmpty) {
        print("No habits found for this user.");
      }
    } catch (e) {
      print("Error fetching habits: $e");
    }
  }

  void _showHabitDetails(BuildContext context, DocumentSnapshot habit) {
    // List of all days of the week
    List<String> allDays = ['M', 'T', 'W', 'Th', 'F', 'Sa', 'Su'];

    // Get the days from Firestore
    List<String> habitDays = List<String>.from(habit['days'] ?? []);

    // Check if the number of selected days matches all 7 days
    String repetition = habitDays.length == 7
        ? 'Everyday'
        : (habitDays.isEmpty ? 'Not Set' : habitDays.join(', '));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            habit['habitName'],
            style: TextStyle(fontSize: 25),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Repetition: $repetition', style: TextStyle(fontSize: 16)),
              Text(
                'Time: ${habit['time'] ?? 'Not Set'}',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Notes: ${habit['note'] ?? 'No notes'}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDeleteOptions(BuildContext context, DocumentSnapshot habit) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditHabitPage(
                      userId: widget.userId,
                      habit: habit, // Pass the habit document here
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, habit);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, DocumentSnapshot habit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete this? It will permanently delete the data and cannot be restored.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userId)
                    .collection('habits')
                    .doc(habit.id)
                    .delete();
                Navigator.of(context).pop();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/habify_logo.png',
                      height: 100, // Adjust the size of the logo
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddHabitPage()),
                    );
                  },
                  icon: Icon(
                    Icons.add,
                    size: 40,
                    color: Color.fromARGB(255, 82, 137, 137),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Calendar Widget
          HorizontalCalendar(
            initialDate: selectedDate,
            onDateSelected: (date) {
              setState(() {
                selectedDate = date;
              });
            },
            userId: widget.userId, // Pass userId here
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 32.0, bottom: 32.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 160,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      isExpanded: true,
                      dropdownColor: Colors.grey[200],
                      icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                      items: [
                        DropdownMenuItem(
                          value: "ALL",
                          child: Text(
                            "ALL",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "ANYTIME",
                          child: Text(
                            "ANYTIME",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "MORNING",
                          child: Text(
                            "MORNING",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "AFTERNOON",
                          child: Text(
                            "AFTERNOON",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "EVENING",
                          child: Text(
                            "EVENING",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedFilter = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .collection('habits') // Filter habits by selected day
                  .orderBy('createdAt',
                      descending:
                          false) // Ensure habits are ordered by creation date
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Something went wrong!"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No habits found."));
                }

                final dayInitials = ["S", "M", "T", "W", "Th", "F", "Sa"];
                final selectedDayIndex = selectedDate.weekday % 7;
                final selectedDayInitial = dayInitials[selectedDayIndex];

                final habits = snapshot.data!.docs;

                final filteredHabits = habits.where((habit) {
                  final days = habit['days'] ?? [];
                  final createdAt =
                      (habit['createdAt'] as Timestamp?)?.toDate();
                  final habitTime = habit['time'] ??
                      ''; // Time field (MORNING, AFTERNOON, EVENING, ANYTIME)

                  if (days is List) {
                    bool isCreatedBeforeOrOnSelectedDate = createdAt == null ||
                        createdAt.isBefore(selectedDate) ||
                        createdAt.isAtSameMomentAs(selectedDate);

                    bool isSelectedDay = days.contains(selectedDayInitial);

                    bool isTimeMatch = selectedFilter == "ALL" ||
                        selectedFilter == "ANYTIME" ||
                        habitTime.toUpperCase() ==
                            (selectedFilter ?? "").toUpperCase();

                    return isCreatedBeforeOrOnSelectedDate &&
                        isSelectedDay &&
                        isTimeMatch;
                  }
                  return false;
                }).toList();

                // Sorting logic
                final sortedHabits = [...filteredHabits]..sort((a, b) {
                    final isCompletedA =
                        (a['completionStatus']?[selectedDateString] ?? false);
                    final isCompletedB =
                        (b['completionStatus']?[selectedDateString] ?? false);
                    return isCompletedA == isCompletedB
                        ? 0
                        : (isCompletedA ? 1 : -1);
                  });

                if (sortedHabits.isEmpty) {
                  return Center(
                      child: Text("No habits for the selected filter."));
                }

                return ListView.builder(
                  itemCount: sortedHabits.length,
                  itemBuilder: (context, index) {
                    final habit = sortedHabits[index];
                    final habitName = habit['habitName'];
                    int colorValue = habit['color'];
                    Map<String, dynamic> completionStatus =
                        habit['completionStatus'] ?? {};

                    bool isFutureDate = selectedDate.isAfter(DateTime.now());

                    if (!completionStatus.containsKey(selectedDateString)) {
                      completionStatus[selectedDateString] = false;
                    }

                    bool isCompleted =
                        completionStatus[selectedDateString] ?? false;

                    Color habitColor =
                        isCompleted ? Colors.grey[200]! : Color(colorValue);

                    return GestureDetector(
                      onTap: () => _showHabitDetails(context, habit),
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: habitColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 12.0),
                          child: Row(
                            children: [
                              if (!isFutureDate)
                                Checkbox(
                                  value: isCompleted,
                                  onChanged: (value) async {
                                    try {
                                      completionStatus[selectedDateString] =
                                          value;
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.userId)
                                          .collection('habits')
                                          .doc(habit.id)
                                          .update({
                                        'completionStatus': completionStatus
                                      });
                                    } catch (e) {
                                      print('Failed to update completion: $e');
                                    }
                                  },
                                ),
                              Expanded(
                                child: Text(
                                  habitName,
                                  style: TextStyle(
                                    color: isCompleted
                                        ? Colors.black45
                                        : Colors.white,
                                    fontSize: 16,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    _showEditDeleteOptions(context, habit),
                                child: Icon(
                                  Icons.more_horiz,
                                  color: isCompleted
                                      ? Colors.black45
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
