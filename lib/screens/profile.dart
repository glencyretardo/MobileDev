import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:provider/provider.dart'; // Import Provider
import 'custom_bottom_navigation_bar.dart';
import 'history_page.dart';
import 'home_page.dart';
import 'package:habify_3/providers/auth_provider.dart'; // Import AuthProvider
import 'package:habify_3/transaction/time_period.dart'; // Import AuthProvider
import 'package:habify_3/transaction/editProfilePage.dart'; // Import AuthProvider

class ProfilePage extends StatefulWidget {
  final String userId; // Add userId as a parameter

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _profileImageUrl; // To store the profile image URL from Firestore
  String _username = ''; // To store the username from Firestore
  String _email = ''; // To store the email from Firestore
  bool _isLoading = true; // To track loading state

  // Fetch user data (username, email, and profile image) from Firestore
  void _getUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      setState(() {
        _username = userDoc['username'] ?? 'Username';
        _email = userDoc['email'] ?? 'user@example.com';
        _profileImageUrl =
            userDoc['profileImage']; // Assuming profileImage is a URL
        _isLoading = false; // Data has been fetched, stop loading
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false; // Stop loading if there is an error
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData(); // Fetch user data when the page is initialized
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white, // bg color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // If still loading, show a progress indicator
                _isLoading
                    ? CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        child: CircularProgressIndicator(),
                      )
                    : GestureDetector(
                        onTap: () {
                          // Optionally, add functionality to pick a new profile picture here.
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _profileImageUrl != null
                              ? (_profileImageUrl!.startsWith('assets/')
                                  ? AssetImage(_profileImageUrl!)
                                      as ImageProvider
                                  : NetworkImage(_profileImageUrl!))
                              : AssetImage('assets/icons/default_profile.png'),
                          child: _profileImageUrl == null
                              ? Icon(Icons.account_circle,
                                  size: 50,
                                  color: Colors.grey) // Placeholder icon
                              : null,
                        ),
                      ),

                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    _username, // Display the username from Firestore
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            _buildClickablePanel('Edit Profile', Icons.edit, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EditProfilePage(userId: widget.userId)),
              );
            }),
            SizedBox(height: 15),
            _buildClickablePanel('Time Period', Icons.access_time, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        TimePeriodPage(userId: widget.userId)),
              );
            }),
            SizedBox(height: 15),
            _buildClickablePanel('Sign Out', Icons.logout, () {
              _confirmSignOut(context);
            }),
          ],
        ),
      ),
    );
  }

  // Widget for clickable panels
  Widget _buildClickablePanel(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700]),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }

  // Confirm Sign-Out
  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              authProvider.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login', // Replace with your login route
                (route) => false, // Remove all previous routes
              );
            },
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
