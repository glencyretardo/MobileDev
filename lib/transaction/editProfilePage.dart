import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;

  EditProfilePage({required this.userId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String? _selectedImage;
  String _email = ''; // Email fetched from Firestore
  String _username = ''; // Username fetched from Firestore
  String? _imagePath; // Saved profile image path from Firestore
  bool _isLoading = true; // Add loading indicator

  final List<String> _imageList = [
    'assets/icons/icon1.png',
    'assets/icons/icon2.png',
    'assets/icons/icon3.png',
    'assets/icons/icon4.png',
    'assets/icons/icon5.png',
  ];

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _username = userDoc['username'] ?? 'No Username';
          _email = userDoc['email'] ?? 'No Email';
          _imagePath = userDoc['profileImage'];
          _selectedImage = _imagePath ?? _imageList[0];
          _isLoading = false; // Data loaded
        });
      } else {
        throw Exception("User not found in Firestore.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Stop loading even on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'username': _username,
        'profileImage': _selectedImage ?? '', // Save the selected image
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    backgroundColor:
    Colors.white;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        centerTitle: true,
        //backgroundColor: const Color(0xFFEEAA3C),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select your profile picture',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildProfilePictureSelector(),
                    SizedBox(height: 30),
                    TextFormField(
                      initialValue: _email,
                      readOnly: true, // Email is not editable
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                            fontSize: 20,
                            color: const Color.fromARGB(255, 14, 52, 52)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 82, 137, 137)),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      initialValue: _username,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(
                          fontSize: 20,
                          color: const Color.fromARGB(255, 14, 52, 52),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: const Color(0xFFEEAA3C)),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _username = value;
                        });
                      },
                    ),
                    SizedBox(height: 50),
                    Center(
                      child: ElevatedButton(
                        onPressed:
                            _saveProfile, // Functionality remains unchanged
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity,
                              50), // Full width button like TextButton
                          backgroundColor: Color.fromARGB(
                              255, 82, 137, 137), // Button background color
                          foregroundColor:
                              Colors.white, // Text color set to white
                          padding: EdgeInsets.symmetric(
                              horizontal: 100, vertical: 16), // Custom padding
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30), // Rounded corners
                          ),
                        ),
                        child: const Text(
                          'Save', // Button text
                          style: TextStyle(
                            fontSize: 18, // Font size
                            fontWeight: FontWeight.bold, // Bold text
                            color: Colors
                                .white, // Make sure this is not overriding foregroundColor
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfilePictureSelector() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imageList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedImage = _imageList[index];
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: _selectedImage == _imageList[index]
                    ? Border.all(
                        color: Color.fromARGB(255, 82, 137, 137),
                        width: 3,
                      )
                    : null,
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(_imageList[index]),
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          );
        },
      ),
    );
  }
}
