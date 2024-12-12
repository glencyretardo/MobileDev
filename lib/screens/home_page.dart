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
                    size: 30,
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
            padding: const EdgeInsets.only(left: 16.0, top: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 150,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFEEAA3C),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      isExpanded: true,
                      dropdownColor: Color(0xFFEEAA3C),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: "ALL",
                          child: Text(
                            "ALL",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "ANYTIME",
                          child: Text(
                            "ANYTIME",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "MORNING",
                          child: Text(
                            "MORNING",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "AFTERNOON",
                          child: Text(
                            "AFTERNOON",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "EVENING",
                          child: Text(
                            "EVENING",
                            style: TextStyle(color: Colors.white, fontSize: 14),
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
                  .collection('users') // Target the 'users' collection
                  .doc(widget.userId) // Get the specific user document
                  .collection('habits') // Get the 'habits' subcollection
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
                        isCompleted ? Colors.grey : Color(colorValue);

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: habitColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          children: [
                            // Checkbox placed to the left, outside the box
                            Checkbox(
                              value: isCompleted,
                              onChanged: (value) {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(widget.userId)
                                    .collection('habits')
                                    .doc(habit.id)
                                    .update({'isCompleted': value});

                                setState(() {
                                  // Trigger a rebuild after the state update
                                });
                              },
                            ),
                            // Habit Name Text
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
                          ],
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
