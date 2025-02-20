import 'package:cloud_firestore/cloud_firestore.dart';

class StreakCalculator {
  final FirebaseFirestore firestore;

  StreakCalculator({FirebaseFirestore? firestoreInstance})
      : firestore = firestoreInstance ?? FirebaseFirestore.instance;

  Future<int> calculateStreak(String userId) async {
    try {
      // Step 1: Fetch all habits for the user
      QuerySnapshot habitSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .get();

      print("Fetched habitSnapshot: ${habitSnapshot.docs.length} habits found");
         print("Debug: Streak calculation started for user $userId");
      Map<String, bool> aggregatedCompletion = {};

      // Step 2: Aggregate completionStatus from all habits
      for (var habit in habitSnapshot.docs) {
        var completionStatus = habit['completionStatus'];

        if (completionStatus is Map<String, dynamic>) {
          completionStatus.forEach((date, status) {
            // Parse the date string into DateTime and ensure it's sorted
            DateTime parsedDate = DateTime.parse(date);

            print("Parsed Date: $parsedDate, Status: $status");

            aggregatedCompletion[date] = aggregatedCompletion.containsKey(date)
                ? aggregatedCompletion[date]! && status
                : status;
          });
        } else {
          print(
              "No valid completionStatus found for habit: ${habit['habitName']}");
        }
      }

      // Print the completionStatus and other details for debugging
      habitSnapshot.docs.forEach((habit) {
        print("Habit ID: ${habit.id}");
        print("Completion Status: ${habit['completionStatus']}");

        // Checking if 'completionStatus' is a valid map
        if (habit['completionStatus'] is Map<String, dynamic>) {
          print("Valid completionStatus map found.");
        } else {
          print("Invalid or missing completionStatus.");
        }

        // Habit details for debugging
        print("Habit Name: ${habit['habitName']}, Color: ${habit['color']}");
      });

      // Step 3: Calculate the streak
      List<DateTime> sortedDates = aggregatedCompletion.keys
          .map((date) => DateTime.parse(date))
          .toList()
        ..sort((a, b) => b.compareTo(a)); // Sort dates in descending order

      print("Sorted Dates: $sortedDates"); // Debug the sorted dates

      int streak = 0;
      DateTime today = DateTime.now();

      // Step 4: Calculate streak
      // Step 4: Calculate streak
      for (int i = 0; i < sortedDates.length; i++) {
        DateTime currentDate = sortedDates[i];
        DateTime expectedDate = today.subtract(Duration(days: streak));

        // Normalize both dates to midnight for comparison
        DateTime normalizedCurrentDate =
            DateTime(currentDate.year, currentDate.month, currentDate.day);
        DateTime normalizedExpectedDate =
            DateTime(expectedDate.year, expectedDate.month, expectedDate.day);

        // Debug logs to verify the date comparison
        print(
            "Comparing Current Date: $normalizedCurrentDate, Expected Date: $normalizedExpectedDate");

        // Ensure the status is `true` for the current date
        String currentDateString = normalizedCurrentDate
            .toIso8601String()
            .split('T')[0]; // Convert to 'YYYY-MM-DD'
        if (normalizedCurrentDate.isAtSameMomentAs(normalizedExpectedDate)) {
          if (aggregatedCompletion[currentDateString] == true) {
            streak++;
            print("Streak incremented to: $streak");
          } else {
            print("Completion status for $currentDateString is not true");
            break; // Stop the streak if the status is false
          }
        } else {
          break; // Stop the streak if the dates are not consecutive
        }
      }

      print("Final streak: $streak");

      return streak; // Return the streak length
    } catch (e) {
      print("Error calculating streak: $e");
      return 0; // Return 0 if there was an error
    }
  }
}
