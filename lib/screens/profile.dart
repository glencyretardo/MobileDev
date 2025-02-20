import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'custom_bottom_navigation_bar.dart';
import 'history_page.dart';
import 'home_page.dart';
import 'package:habify_3/providers/auth_provider.dart';
import 'package:habify_3/transaction/time_period.dart';
import 'package:habify_3/transaction/editProfilePage.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _profileImageUrl;
  String _username = '';
  String _email = '';
  bool _isLoading = true;

  void _getUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      setState(() {
        _username = userDoc['username'] ?? 'Username';
        _email = userDoc['email'] ?? 'user@example.com';
        _profileImageUrl = userDoc['profileImage'];
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileHeader(),
              SizedBox(height: 20),
              Divider(color: Colors.grey[300], thickness: 1),
              SizedBox(height: 20),
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
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        _isLoading
            ? CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                child: CircularProgressIndicator(),
              )
            : CircleAvatar(
                radius: 50,
                backgroundImage: _profileImageUrl != null
                    ? (_profileImageUrl!.startsWith('assets/')
                        ? AssetImage(_profileImageUrl!) as ImageProvider
                        : NetworkImage(_profileImageUrl!))
                    : AssetImage('assets/icons/default_profile.png'),
                child: _profileImageUrl == null
                    ? Icon(Icons.account_circle, size: 50, color: Colors.grey)
                    : null,
              ),
        SizedBox(height: 10),
        Text(
          _username,
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: 5),
        Text(
          _email,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildClickablePanel(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.teal, size: 24),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              authProvider.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
