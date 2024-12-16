import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore

class HabitDays extends StatefulWidget {
  const HabitDays({Key? key}) : super(key: key);

  @override
  State<HabitDays> createState() => _HabitDaysState();
}

class _HabitDaysState extends State<HabitDays> {
  final List<bool> _selectedDays =
      List.generate(7, (_) => true); // All selected by default
  final List<String> _days = ['Sa', 'M', 'T', 'W', 'Th', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    _fetchHabitDays(); // Fetch habit days from Firestore when the screen is initialized
  }

  // Fetch the habit days from Firestore
  void _fetchHabitDays() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('habits')
            .doc('habit_days')
            .get();

        if (snapshot.exists) {
          List<String> savedDays = List<String>.from(snapshot['days'] ?? []);
          setState(() {
            // Update individual elements of _selectedDays
            for (int i = 0; i < _days.length; i++) {
              _selectedDays[i] = savedDays.contains(_days[i]);
            }
          });
        }
      } catch (e) {
        print("Error fetching habit days: $e");
      }
    }
  }

  // Save the habit days to Firestore
  void _saveHabitDays() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('habits')
            .doc('habit_days')
            .set({
          'days': _selectedDays
              .asMap()
              .entries
              .where((entry) => entry.value)
              .map((entry) => _days[entry.key])
              .toList(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Habit days updated successfully!')),
        );
      } catch (e) {
        print("Error saving habit days: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update habit days.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in. Please log in first.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            _saveHabitDays(); // Save habit days when navigating back
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Habit Days",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
     
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                "Everyday",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                _days.length,
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDays[index] = !_selectedDays[index];
                    });
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _selectedDays[index]
                          ? Colors.blue
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _days[index],
                      style: TextStyle(
                        color:
                            _selectedDays[index] ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _saveHabitDays,
              child: const Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
