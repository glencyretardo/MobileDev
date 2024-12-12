import 'package:flutter/material.dart';
import 'profile.dart';
import 'history_page.dart';
import 'calendar.dart';
import 'package:habify_3/transaction/addHabit.dart';
import 'package:intl/intl.dart';
import 'custom_bottom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedFilter = "ALL"; // State variable to store the selected value

  @override
  Widget build(BuildContext context) {
    final String userName = "User"; // Replace with dynamic data

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
          HorizontalCalendar(), // Custom calendar widget
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 32.0),
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
                      value: selectedFilter, // Bind the state variable
                      isExpanded: true,
                      dropdownColor: Color(0xFFEEAA3C),
                      elevation: 0, // removes the shadow
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
                          selectedFilter = value; // Update the state
                        });
                        print("Selected: $value");
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child:
                  Text("Today's Page Content"), // Replace with actual content
            ),
          ),
        ],
      ),
    );
  }
}
