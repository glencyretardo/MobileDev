import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:habify_3/transaction/addHabit.dart';
import 'calendar.dart';

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedFilter = "ALL";

  @override
  void initState() {
    super.initState();
    testFirestoreQuery(); // Call the debug function here
  }

  void testFirestoreQuery() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('habits')
          .where('userId', isEqualTo: widget.userId)
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

  // Function to show the habit details in a dialog
  void _showHabitDetails(BuildContext context, DocumentSnapshot habit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(habit['habitName']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Repetition: ${habit['days'] ?? 'Not Set'}'),
              Text('Time: ${habit['time'] ?? 'Not Set'}'),
              Text('Notes: ${habit['note'] ?? 'No notes'}'),
              Text(
                  'Status: ${habit['isCompleted'] ? 'Completed' : 'Not Completed'}'),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddHabitPage()),
                    );
                  },
                  icon: Icon(
                    Icons.add,
                    size: 40,
                    color: Color(0xFFEEAA3C),
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
          HorizontalCalendar(),
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 32.0,
              bottom: 32.0,
            ),
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
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black,
                      ),
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
                  .collection('habits')
                  .orderBy('createdAt', descending: false)
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

                final habits = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    final habitName = habit['habitName'];
                    int colorValue = habit['color'];
                    bool isCompleted = habit['isCompleted'] ?? false;
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
                              Checkbox(
                                value: isCompleted,
                                onChanged: (value) {
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.userId)
                                      .collection('habits')
                                      .doc(habit.id)
                                      .update({'isCompleted': value});

                                  setState(() {});
                                },
                              ),
                              Expanded(
                                child: Text(
                                  habitName,
                                  style: TextStyle(
                                    color: isCompleted
                                        ? Colors.black45
                                        : Colors.white,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.more_horiz,
                                color:
                                    isCompleted ? Colors.black45 : Colors.white,
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
          ),
        ],
      ),
    );
  }
}

//repitition edit butangan everyday
