import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimePeriodPage extends StatefulWidget {
  final String userId; // User ID to access the correct Firestore document

  const TimePeriodPage({Key? key, required this.userId}) : super(key: key);

  @override
  _TimePeriodPageState createState() => _TimePeriodPageState();
}

class _TimePeriodPageState extends State<TimePeriodPage> {
  // Initialize timePeriods as an empty map
  Map<String, TimeOfDay> timePeriods = {};

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true; // Flag to show loading indicator

  // Define the desired order of the time periods
  final List<String> periodOrder = [
    'Morning',
    'Afternoon',
    'Evening',
    'End of the Day'
  ];

  @override
  void initState() {
    super.initState();
    _loadTimePeriodsFromFirestore();
  }

  Future<void> _loadTimePeriodsFromFirestore() async {
    try {
      final documentSnapshot = await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('time_period')
          .get();

      if (documentSnapshot.docs.isNotEmpty) {
        final Map<String, TimeOfDay> fetchedTimePeriods = {};
        for (var doc in documentSnapshot.docs) {
          final data = doc.data();
          fetchedTimePeriods[data['name']] =
              _convertStringToTimeOfDay(data['time']);
        }

        setState(() {
          timePeriods = fetchedTimePeriods;
          _isLoading = false; // Data has been fetched, set loading to false
        });
      } else {
        setState(() {
          _isLoading =
              false; // Set loading flag to false even if no data is fetched
        });
      }
    } catch (e) {
      print('Error loading time periods: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateTimeInFirestore(String period, TimeOfDay time) async {
    try {
      final timeString = _convertTimeOfDayToString(time);

      await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('time_period')
          .doc(period)
          .set({
        'name': period,
        'time': timeString,
      });

      print('Time for $period updated to $timeString in Firestore.');
    } catch (e) {
      print('Error updating time in Firestore: $e');
    }
  }

  String _convertTimeOfDayToString(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  TimeOfDay _convertStringToTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _selectTime(String period) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: timePeriods[period] ?? const TimeOfDay(hour: 7, minute: 0),
    );

    if (pickedTime != null && pickedTime != timePeriods[period]) {
      setState(() {
        timePeriods[period] = pickedTime;
      });
      _updateTimeInFirestore(period, pickedTime);
    }
  }

  Widget _buildTimeRow(
      String title, String subtitle, TimeOfDay time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F3F0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '${time.format(context)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.black54),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Time Periods',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add space above the containers
                const SizedBox(height: 20),

                // Use a Flexible to allow ListView to take the remaining space
                Flexible(
                  child: ListView(
                    children: periodOrder.map((period) {
                      if (timePeriods.containsKey(period)) {
                        TimeOfDay time = timePeriods[period]!;

                        return _buildTimeRow(
                          period,
                          period == 'End of the Day' ? 'Ends at' : 'Starts at',
                          time,
                          () => _selectTime(period),
                        );
                      } else {
                        return Container(); // Or some placeholder widget
                      }
                    }).toList(),
                  ),
                ),

                // Add space between the containers and the button
                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Save changes and navigate back to profile
                      Navigator.pop(context); // Go back to profile
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Color.fromARGB(255, 82, 137, 137),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 50), // Space after the button
              ],
            ),
    );
  }
}
