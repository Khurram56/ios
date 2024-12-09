import 'package:flutter/material.dart';

class RunUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50], // Light background for contrast
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Title
              Text(
                'Medication Tracker',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 8.0),
              // Subtitle
              Text(
                'Choose your role to get started',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 40.0),
              // User Login Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/userLogin'); // Navigate to User Login Screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                ),
                child: Text(
                  'User',
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
              SizedBox(height: 20.0),
              // Caregiver Login Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/caregiverLogin'); // Navigate to Caregiver Login Screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                ),
                child: Text(
                  'Caregiver',
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
              SizedBox(height: 20.0),
              // Admin Login Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/adminLogin'); // Navigate to Admin Login Screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                ),
                child: Text(
                  'Admin',
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
              SizedBox(height: 40.0),
              // Footer
              Text(
                'Helping you stay on track with your medications',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
