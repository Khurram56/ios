import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/notification_service.dart';

class MedicationScreen extends StatefulWidget {
  final String token;

  MedicationScreen({required this.token});

  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _specificTimesController = TextEditingController();
  bool _isLoading = false;
  List<dynamic> _medications = [];

  @override
  void initState() {
    super.initState();
  }


  Future<void> _addMedication() async {
    final url = Uri.parse('http://192.168.1.2:3000/api/medication');
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'dosage': _dosageController.text,
          'frequency': _frequencyController.text,
          'specificTimes': _specificTimesController.text
              .split(',')
              .map((e) => e.trim())
              .toList(),
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> medication = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Medication added successfully!')),
        );

        final specificTimes = _specificTimesController.text
            .split(',')
            .map((e) => e.trim())
            .toList();
        for (var time in specificTimes) {
          DateTime notificationTime = DateTime.parse(time);
          NotificationService.scheduleMedicationReminder(
            notificationTime.hashCode,
            'Medication Reminder',
            'It\'s time to take ${_nameController.text} (${_dosageController
                .text})',
            notificationTime,
            medication['_id'],
          );
        }

        _nameController.clear();
        _dosageController.clear();
        _frequencyController.clear();
        _specificTimesController.clear();
      } else {
        final error =
            jsonDecode(response.body)['error'] ?? 'Failed to add medication';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Medications'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medication Name Input
            Text(
              'Add New Medication',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Medication Name',
                prefixIcon: Icon(Icons.medical_services, color: Colors.purple),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Medication name is required.';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),

            // Dosage Input
            TextFormField(
              controller: _dosageController,
              decoration: InputDecoration(
                labelText: 'Dosage',
                prefixIcon: Icon(Icons.vaccines, color: Colors.purple),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Dosage is required.';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),

            // Frequency Input
            TextFormField(
              controller: _frequencyController,
              decoration: InputDecoration(
                labelText: 'Frequency (e.g., daily, weekly)',
                prefixIcon: Icon(Icons.repeat, color: Colors.purple),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Frequency is required.';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),

            // Specific Times Input
            TextFormField(
              controller: _specificTimesController,
              decoration: InputDecoration(
                labelText: 'Specific Times',
                hintText: 'e.g., 2024-11-27T08:00:00,2024-11-27T14:00:00',
                prefixIcon: Icon(Icons.access_time, color: Colors.purple),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Specific times are required.';
                }
                final times = value.split(',');
                final iso8601Regex = RegExp(
                    r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?Z?$');
                for (var time in times) {
                  if (!iso8601Regex.hasMatch(time.trim())) {
                    return 'Invalid format. Use ISO 8601 format (e.g., 2024-11-27T08:00:00).';
                  }
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),

            // Add Medication Button
            Align(
              alignment: Alignment.center,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton.icon(
                onPressed: _addMedication,
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Add Medication',
                  style: TextStyle(color: Colors.white), // Set text color to white
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, // Button background color
                  foregroundColor: Colors.white, // Ensure text and icon color are white
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 16.0,
                  ),
                  textStyle: TextStyle(fontSize: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              )
              ,
            ),
            SizedBox(height: 24.0),


            SizedBox(height: 16.0),

            // Medication List Section

          ],
        ),
      ),
    );
  }
}