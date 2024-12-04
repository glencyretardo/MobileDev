import 'package:flutter/material.dart';
import 'package:habify_3/screens/loginPage.dart'; // Import the loginPage file
import 'package:habify_3/screens/home_page.dart'; // Import the homePage file for navigation
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Main entry point of the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(HabifyApp());
}

// Main widget for the app that extends StatelessWidget
class HabifyApp extends StatelessWidget {
  const HabifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide the debug banner
      title: 'Habify', // Title of the app
      theme: ThemeData(
        primarySwatch: Colors.green, // Set the primary theme color to green
      ),
      initialRoute: '/', // Home page route
      routes: {
        '/': (context) => SplashScreen(), // SplashScreen route
        '/login': (context) => LoginPage(), // LoginPage route
        '/home': (context) => HomePage(), // HomePage route after login
      },
    );
  }
}

// SplashScreen widget
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

// State class for the SplashScreen
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to LoginPage after a 2-second delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/login'); // Navigate to login
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color of splash screen
      body: Center(
        child: Image.asset('assets/splash_logo.png'), // Display splash logo
      ),
    );
  }
}
