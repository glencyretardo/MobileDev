import 'package:flutter/material.dart';
import 'package:habify_3/screens/loginPage.dart'; // import the loginPage file for navigation
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// main entry point of the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(HabifyApp());
}

// main widget for the app that extends StatelessWidget
class HabifyApp extends StatelessWidget {
  const HabifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // hides the debug banner
      title: 'Habify', // title of the app
      theme: ThemeData(
        primarySwatch: Colors.green, // sets the primary theme color to green
      ),
      home:
          SplashScreen(), // displays the SplashScreen widget as the initial page
    );
  }
}

// splashScreen widget which extends StatefulWidget to manage state
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

// state class for the SplashScreen
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // navigate to LoginPage after a 2-second delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage()), // navigate to the login page
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // background color of the splash screen
      body: Center(
        // displays the splash logo image in the center of the screen
        child: Image.asset('assets/splash_logo.png'),
      ),
    );
  }
}
