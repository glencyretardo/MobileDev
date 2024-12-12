import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:habify_3/screens/home_page.dart';
import 'time_period.dart';
import 'habit_days.dart';

class AddHabitPage extends StatefulWidget {
  @override
  _AddHabitPageState createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  Color selectedColor = Colors.blue; // Default color
  String selectedTime = "Anytime"; // Default dropdown value
  final TextEditingController habitNameController = TextEditingController();

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

  void _navigateToTimePeriods() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              TimePeriodsScreen()), // Navigate to the TimePeriodsScreen
    );
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Habit Name Field
            Container(
              width: 250,
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Habit Name",
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
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
                  color: Color(0xFFBFDAB1), // Light green background
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

            // DO IT AT Title with Three Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "DO IT AT",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEEAA3C), // Yellow-orange color
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert,
                      color: Colors.black), // Three dots icon
                  onPressed: _navigateToTimePeriods, // Action when clicked
                ),
              ],
            ),
            SizedBox(height: 8),
            // DO IT AT Panel with Dropdown
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFBFDAB1), // Light green background
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true, // Expands dropdown to fill the container
                  value: selectedTime,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTime = newValue!;
                    });
                  },
                  items: <String>["Anytime", "Morning", "Afternoon", "Evening"]
                      .map<DropdownMenuItem<String>>((String value) {
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
                color: Color(0xFFEEAA3C), // Yellow-orange color
              ),
            ),
            SizedBox(height: 8),
            // REPEAT Panel
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const HabitDays(), // Navigate to HabitDays
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFBFDAB1), // Light green background
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Habit Days",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    Row(
                      children: [
                        Text(
                          "Everyday",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
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
            // NOTE Title
            Text(
              "NOTE",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEEAA3C), // Yellow-orange color
              ),
            ),
            SizedBox(height: 8),
            // NOTE Panel
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFBFDAB1), // Light green background
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: 17, horizontal: 16),
              child: TextField(
                maxLines: 2,
                decoration: InputDecoration.collapsed(
                  hintText: "Write a note...",
                  hintStyle: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ),
            Spacer(),
            // Save Button
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text('Save Habit'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
