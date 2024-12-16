import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:habify_3/providers/auth_provider.dart' as CustomAuthProvider;
import 'package:habify_3/screens/loginPage.dart';
import 'package:habify_3/screens/dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //debugPaintSizeEnabled = true; // Enable debug mode

  runApp(
    ChangeNotifierProvider(
      create: (context) => CustomAuthProvider.AuthProvider(),
      child: const HabifyApp(),
    ),
  );
}

class HabifyApp extends StatelessWidget {
  const HabifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habify',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const LoginPage(), // Start the app with the LoginPage
      routes: {
        '/login': (context) => LoginPage(),
        // Navigate to Dashboard after login
        '/dashboard': (context) {
          final authProvider =
              Provider.of<CustomAuthProvider.AuthProvider>(context);
          final userId = authProvider.currentUser?.uid ?? '';
          return DashboardPage(userId: userId);
        },
      },
    );
  }
}
