import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/notification_service.dart';

class EditMedicationScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> medication;

  EditMedicationScreen({required this.token, required this.medication});

  @override
  _EditMedicationScreenState createState() => _EditMedicationScreenState();
}

class _EditMedicationScreenState extends State<EditMedicationScreen> {
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _frequencyController;
  late TextEditingController _specificTimesController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication['name']);
    _dosageController = TextEditingController(text: widget.medication['dosage']);
    _frequencyController =
        TextEditingController(text: widget.medication['frequency']);
    _specificTimesController = TextEditingController(
      text: widget.medication['specificTimes']?.join(', ') ?? '',
    );
  }

  Future<void> _updateMedication() async {
    final url = Uri.parse(
        'http://192.168.1.2:3000/api/medication/${widget.medication['_id']}');
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.put(
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

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Medication updated successfully!')),
        );

        // Cancel existing notifications for this medication
        NotificationService.cancelReminder(widget.medication['_id'].hashCode);

        // Schedule updated notifications
        final specificTimes = _specificTimesController.text
            .split(',')
            .map((e) => e.trim())
            .toList();
        for (var time in specificTimes) {
          try {
            DateTime notificationTime = DateTime.parse(time);
            NotificationService.scheduleMedicationReminder(
              widget.medication['_id'].hashCode + notificationTime.hashCode, // Unique ID for each notification
              'Medication Reminder',
              'It\'s time to take ${_nameController.text} (${_dosageController.text})',
              notificationTime,
              widget.medication['_id'], // Use the medication ID from the widget
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid time format: $time')),
            );
          }
        }

        Navigator.pop(context);
      } else {
        final error =
            jsonDecode(response.body)['error'] ?? 'Failed to update medication';
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
        title: Text('Edit Medication'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // Add form validation
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Text(
                'Medication Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 16.0),

              // Medication Name Input
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
                  labelText: 'Frequency',
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
                  hintText: 'e.g. 2024-11-27T08:00:00,2024-11-27T14:00:00',
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
                  // Validate ISO 8601 format for each time
                  final times = value.split(',');
                  final iso8601Regex = RegExp(
                      r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?Z?$');
                  for (var time in times) {
                    if (!iso8601Regex.hasMatch(time.trim())) {
                      return 'Invalid format. Use ISO 8601 format (e.g. 2024-11-27T08:00:00).';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),

              // Update Button
              Align(
                alignment: Alignment.center,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton.icon(
                  onPressed: _updateMedication,
                  icon: Icon(Icons.update, color: Colors.white),
                  label: Text(
                    'Update Medication',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 16.0),
                    textStyle: TextStyle(fontSize: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }}
