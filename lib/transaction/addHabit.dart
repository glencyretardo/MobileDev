import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:habify_3/screens/dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package for data storage
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication

class AddHabitPage extends StatefulWidget {
  @override
  _AddHabitPageState createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  Color selectedColor = Colors.blue; // Default color
  String selectedTime = "Anytime"; // Default dropdown value
  final TextEditingController habitNameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  List<String> selectedDays = []; // Store the selected days for Repeat

  // Days of the week to display in the popup (with initials)
  final List<String> allDays = ["M", "T", "W", "Th", "F", "Sa", "S"];

  @override
  void initState() {
    super.initState();
  }

  // Function to open the popup dialog for selecting days
  void _openDaysSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Days'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: allDays.asMap().entries.map((entry) {
                  int index = entry.key;
                  String day = entry.value;
                  return CheckboxListTile(
                    title: Text(day),
                    value: selectedDays.contains(day),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          selectedDays.add(day);
                        } else {
                          selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Done'),
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Display the selected days or "Everyday" if all days are selected
  String _getRepeatText() {
    if (selectedDays.length == 7) {
      return "Everyday";
    } else if (selectedDays.isEmpty) {
      return "No days selected";
    } else {
      return selectedDays.join(", ");
    }
  }

  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick a Color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Select'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveHabit() async {
    String habitName = habitNameController.text;
    String note = noteController.text;

    if (habitName.isNotEmpty && selectedDays.isNotEmpty) {
      try {
        // Get the current logged-in user
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Generate completionStatus for the next 30 days
          Map<String, bool> completionStatus = {};
          DateTime today = DateTime.now();
          for (int i = 0; i < 30; i++) {
            String date =
                today.add(Duration(days: i)).toIso8601String().split('T')[0];
            completionStatus[date] = false;
          }
          // Save the habit under the logged-in user's UID
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid) // Use the logged-in user's UID
              .collection('habits')
              .add({
            'habitName': habitName,
            'color': selectedColor.value, // Storing color as integer value
            'time': selectedTime,
            'days': selectedDays, // Storing the selected days
            'note': note,
            'completionStatus': completionStatus, // Add the map here
            'createdAt': FieldValue.serverTimestamp(),
          });

          // After saving, navigate to HomePage and pass the userId
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DashboardPage(userId: user.uid), // Pass the userId here
            ),
          );
        } else {
          // If user is not logged in, show an error
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('User not logged in! Please log in first.'),
            backgroundColor: Colors.red,
          ));
        }
      } catch (e) {
        // Handle errors here
        print("Error saving habit: $e");
      }
    } else {
      // If fields are incomplete, show an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all fields and select habit days'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // Correctly wrap the body content here
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Habit Name Field
              Container(
                width: 250,
                child: TextField(
                  controller: habitNameController,
                  decoration: InputDecoration(
                    hintText: "Habit Name",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                    suffixIcon: Icon(Icons.edit, color: Colors.black),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
              // COLOR Panel
              GestureDetector(
                onTap: _openColorPicker,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Color",
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: selectedColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // DO IT AT Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "DO IT AT",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEEAA3C),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.black),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: 8),
              // DO IT AT Panel with Dropdown
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedTime,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTime = newValue!;
                      });
                    },
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                    items: <String>[
                      "Anytime",
                      "Morning",
                      "Afternoon",
                      "Evening"
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // REPEAT Title
              Text(
                "REPEAT",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEEAA3C),
                ),
              ),
              SizedBox(height: 8),
              // REPEAT Panel with updated text based on selection
              GestureDetector(
                onTap: _openDaysSelectionDialog,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getRepeatText(),
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Note Field
              Text(
                "NOTE",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEEAA3C),
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                  style: TextStyle(fontSize: 16),
                  onChanged: (text) {
                    setState(() {});
                  },
                ),
              ),
              SizedBox(height: 30),
              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _saveHabit,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    backgroundColor: Color(0xFFEEAA3C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Save Habit",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
