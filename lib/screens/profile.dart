import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
  File? _profileImage;

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Fetch the current user's information (this could be a placeholder for now)
    final String username = authProvider.currentUser?.displayName ?? 'Username';
    final String email = authProvider.currentUser?.email ?? 'user@example.com';

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
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : AssetImage('assets/default_profile.jpg')
                            as ImageProvider,
                    child: _profileImage == null
                        ? Icon(Icons.add_a_photo, size: 30, color: Colors.grey)
                        : null,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    username, // Display the user's name here
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
