import 'package:flutter/material.dart';

class ReminderScreen extends StatelessWidget {
  final String medicationDetails;

  const ReminderScreen({required this.medicationDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Reminder Details:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(medicationDetails),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Acknowledge'),
            ),
          ],
        ),
      ),
    );
  }
}
