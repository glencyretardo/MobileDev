import 'package:flutter/material.dart';
import 'package:habify_3/transaction/streak.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatefulWidget {
  final String userId;

  const HistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int selectedTabIndex = 0;
  final streakCalculator = StreakCalculator();

  // Declare variables to cache the data
  Map<String, dynamic>? _weeklyCompletionData;
  Future<QuerySnapshot>? _habitData;

  @override
  void initState() {
    super.initState();
    // Load habit data only once
    _habitData = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('habits')
        .get();

    // Load weekly completion data only if it's not already cached
    if (_weeklyCompletionData == null) {
      _loadWeeklyCompletionData();
    }
  }

  // Load weekly completion data and cache it
  Future<void> _loadWeeklyCompletionData() async {
    try {
      final data = await _getWeeklyCompletion(widget.userId);
      setState(() {
        _weeklyCompletionData = data;
        print("Debug: Weekly completion data loaded: $_weeklyCompletionData");
      });
    } catch (e) {
      print("Error loading weekly completion data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "History",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildTabBar(),
            const SizedBox(height: 8),

            // Conditionally show the Stat Row and Calendar only for Achievements tab
            if (selectedTabIndex == 0) ...[
              Padding(
                padding:
                    const EdgeInsets.only(top: 40.0), // Move stat boxes down
                child: _weeklyCompletionData == null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _statBox("CURRENT STREAK", "Loading..."),
                          const SizedBox(height: 16), // Spacing between boxes
                          _statBox("WEEKLY COMPLETION RATE", "Loading..."),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _statBox("CURRENT STREAK",
                              "${_weeklyCompletionData?['streak']}"),
                          const SizedBox(height: 16),
                          _statBox("WEEKLY COMPLETION RATE",
                              "${_weeklyCompletionData?['completed']}/${_weeklyCompletionData?['total']}"),
                        ],
                      ),
              ),
              const SizedBox(height: 8),
              _buildCalendarHeader(),
              const SizedBox(height: 8),
            ],

            Container(
              height: MediaQuery.of(context).size.height *
                  0.7, // Limit to 70% of screen height
              child: selectedTabIndex == 1
                  ? _buildAllHabitsWidget()
                  : CalendarGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[300]!.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _folderTab("Achievements", 0),
          _folderTab("All Habits", 1),
        ],
      ),
    );
  }

  Widget _folderTab(String title, int index) {
    bool isSelected = selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Color.fromARGB(255, 82, 137, 137)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllHabitsWidget() {
    return FutureBuilder<QuerySnapshot>(
      future: _habitData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No habits found.",
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          );
        }

        final habits = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habitName = habits[index]['habitName'] ?? 'Unnamed Habit';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  habitName,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _statBox(String title, String value) {
    return Container(
      width: 300, // Smaller fixed width for compact design
      height: 60, // Reduced height
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 8), // Compact padding
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF8E1),
            Color(0xFFA0CBCB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4, // Subtle shadow for a smaller box
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12, // Smaller font size for title
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4), // Tiny spacing between title and value
          Text(
            value,
            style: const TextStyle(
              fontSize: 16, // Bold and slightly larger for emphasis
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Text(
        "${_monthName(DateTime.now().month)} ${DateTime.now().year}",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }

  Future<Map<String, dynamic>> _getWeeklyCompletion(String userId) async {
    try {
      QuerySnapshot habitSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('habits')
          .get();

      print(
          "Debug: Habit snapshot fetched with ${habitSnapshot.docs.length} habits.");

      int totalHabits = habitSnapshot.docs.length * 7;
      int completedHabits = 0;

      DateTime today = DateTime.now();
      DateTime oneWeekAgo = today.subtract(Duration(days: 7));

      for (var habit in habitSnapshot.docs) {
        Map<String, dynamic> completionStatus = habit['completionStatus'] ?? {};
        print(
            "Debug: CompletionStatus for habit ${habit.id}: $completionStatus");

        completionStatus.forEach((date, status) {
          DateTime habitDate = DateTime.parse(date);
          if (habitDate.isAfter(oneWeekAgo) &&
              habitDate.isBefore(today.add(Duration(days: 1)))) {
            if (status == true) {
              completedHabits++;
            }
          }
        });
      }
      print(
          "Debug: Total habits = $totalHabits, Completed habits = $completedHabits");

      int streak = await streakCalculator.calculateStreak(userId);
      print("Debug: Calculated streak = $streak");
      return {
        'streak': await streakCalculator.calculateStreak(userId),
        'completed': completedHabits,
        'total': totalHabits,
      };
    } catch (e) {
      print("Error fetching weekly completion: $e");
      return {'streak': 0, 'completed': 0, 'total': 0};
    }
  }
}

class CalendarGrid extends StatelessWidget {
  final List<String> daysOfWeek = [
    "SUN",
    "MON",
    "TUE",
    "WED",
    "THU",
    "FRI",
    "SAT"
  ];
  final DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    int currentYear = now.year;
    int currentMonth = now.month;
    int daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
    int startDay = DateTime(currentYear, currentMonth, 1).weekday % 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: daysOfWeek
                .map((day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          Wrap(
            children: List.generate(startDay + daysInMonth, (index) {
              if (index < startDay) {
                return const SizedBox(width: 40, height: 40);
              } else {
                int day = index - startDay + 1;
                bool isToday = day == now.day;

                return Container(
                  margin: const EdgeInsets.all(4),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isToday
                        ? const Color.fromARGB(255, 82, 137, 137)
                        : Colors.grey[200],
                    shape: BoxShape.circle,
                    boxShadow: isToday
                        ? [
                            const BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      "$day",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isToday
                            ? Colors.white
                            : Colors.black87.withOpacity(0.7),
                      ),
                    ),
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
