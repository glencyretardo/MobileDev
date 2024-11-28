import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:habify_3/screens/loginPage.dart'; // Import your login page here

void main() {
  testWidgets('LoginPage has email, password fields, and login button',
      (WidgetTester tester) async {
    // Build the LoginPage widget and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    // Verify that the email field is present.
    expect(find.byType(TextField),
        findsNWidgets(2)); // Assuming two text fields (email and password)

    // Verify that there is a 'Log In' button.
    expect(find.text('Log In'), findsOneWidget);

    // Verify 'Forgot Password?' link is present.
    expect(find.text('Forgot Password?'), findsOneWidget);

    // Verify 'Sign Up' link is present.
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
