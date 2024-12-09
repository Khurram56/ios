import 'package:flutter/material.dart';
import 'package:medication_tracker/screens/adminLoginScreen.dart';
import 'package:medication_tracker/screens/login_screen.dart';
import 'package:medication_tracker/screens/caregiver_login_screen.dart'; // Import Caregiver Login Screen
import 'package:medication_tracker/screens/runupscreen.dart';
import 'helpers/notification_helper.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data
  tz.initializeTimeZones();

  // Initialize Flutter Local Notifications
  await NotificationHelper.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medication Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // Set RunUpScreen as initial route
      routes: {
        '/': (context) => RunUpScreen(), // RunUpScreen entry point
        '/userLogin': (context) => LoginScreen(), // User login screen
        '/caregiverLogin': (context) => CaregiverLoginScreen(), // Caregiver login screen
        '/adminLogin': (context) => AdminLoginScreen(),  // Ensure this route exists
      },
    );
  }
}