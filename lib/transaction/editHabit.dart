import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class EditHabitPage extends StatefulWidget {
  final String userId;
  final DocumentSnapshot habit;

  const EditHabitPage({Key? key, required this.userId, required this.habit})
      : super(key: key);

  @override
  _EditHabitPageState createState() => _EditHabitPageState();
}

class _EditHabitPageState extends State<EditHabitPage> {
  late TextEditingController _habitNameController;
  late TextEditingController _noteController;
  late String _selectedTime;
  late List<String> _selectedDays;
  late Color _selectedColor;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _habitNameController =
        TextEditingController(text: widget.habit['habitName']);
    _noteController = TextEditingController(text: widget.habit['note']);
    _selectedColor = Color(widget.habit['color'] ?? Colors.red.value);
    _selectedTime = widget.habit['time'] ?? 'Anytime';
    _selectedDays = List<String>.from(widget.habit['days'] ?? []);
  }

  @override
  void dispose() {
    _habitNameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveEdits() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('habits')
        .doc(widget.habit.id)
        .update({
      'habitName': _habitNameController.text,
      'note': _noteController.text,
      'time': _selectedTime,
      'days': _selectedDays,
      'color': _selectedColor.value,
    }).then((_) {
      Navigator.pop(context);
    }).catchError((error) {
      print("Failed to update habit: $error");
    });
  }

  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick a Color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  _selectedColor = color;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Habit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Habit Name Field
              TextFormField(
                controller: _habitNameController,
                decoration: InputDecoration(labelText: 'Habit Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a habit name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Color Panel
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
                              color: _selectedColor,
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
              SizedBox(height: 16),

              // DO IT AT Title
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
                    icon: Icon(Icons.more_vert, color: Colors.black),
                    onPressed:
                        () {}, // Placeholder for additional functionality
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
                    value: _selectedTime,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTime = newValue!;
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
              SizedBox(height: 16),

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

              // Repeat Days
              Text('Repeat Days'),
              Wrap(
                spacing: 8.0,
                children: ['S', 'M', 'T', 'W', 'Th', 'F', 'Sa']
                    .map((day) => ChoiceChip(
                          label: Text(day),
                          selected: _selectedDays.contains(day),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedDays.add(day);
                              } else {
                                _selectedDays.remove(day);
                              }
                            });
                          },
                        ))
                    .toList(),
              ),
              SizedBox(height: 16),
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

              // Note Field inside a box
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _noteController,
                  decoration: InputDecoration(border: InputBorder.none),
                  style: TextStyle(fontSize: 16),
                  maxLines: null,
                ),
              ),
              SizedBox(height: 30),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _saveEdits();
                  }
                },
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
