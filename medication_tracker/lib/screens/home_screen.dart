import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/notification_service.dart';
import 'ViewMedicationHistoryScreen.dart';
import 'add_caregiver.dart';
import 'add_medication_screen.dart';
import 'edit_medication_screen.dart';
import 'caregiver_registration_screen.dart'; // Import the caregiver registration screen

class HomeScreen extends StatefulWidget {
  final String username;
  final String token;

  HomeScreen({required this.username, required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  List<dynamic> _medications = [];

  @override
  void initState() {
    super.initState();
    _fetchMedications();
  }

  Future<void> _fetchMedications() async {
    final url = Uri.parse('http://192.168.1.2:3000/api/medications');
    try {
      setState(() {
        _isLoading = true;
      });
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final medications = jsonDecode(response.body);
        setState(() {
          _medications = medications.map((medication) {
            medication['remainingSpecificTimes'] =
            List<String>.from(medication['specificTimes']);
            return medication;
          }).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch medications')),
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

  void _navigateToEditScreen(Map<String, dynamic> medication) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditMedicationScreen(
              token: widget.token,
              medication: medication,
            ),
      ),
    ).then((_) => _fetchMedications());
  }

  Future<void> _deleteMedication(String id) async {
    final url = Uri.parse('http://192.168.1.2:3000/api/medication/$id');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Medication deleted successfully!')),
        );
        _fetchMedications(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete medication')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $error')),
      );
    }
  }

  void _handleAction(String action, Map<String, dynamic> medication) async {
    final String medicationId = medication['_id'];
    final String specificTime = medication['remainingSpecificTimes']?.first ?? '';

    if (action == 'acknowledged') {
      _logMedicationStatus(
        'acknowledged',
        medicationId,
        medication['name'],
        DateTime.now().toIso8601String(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message Acknowledged!')),
      );
    } else if (action == 'snoozed') {
      final snoozeTime = DateTime.now().add(Duration(minutes: 5));
      NotificationService.scheduleMedicationReminder(
        snoozeTime.hashCode,
        'Snoozed Medication Reminder',
        'Reminder: It\'s time to take ${medication['name']} (${medication['dosage']})',
        snoozeTime,
        medicationId,
      );

      _logMedicationStatus(
        'snoozed',
        medicationId,
        medication['name'],
        DateTime.now().toIso8601String(),
        nextNotificationTime: snoozeTime.toIso8601String(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification snoozed for 5 minutes!')),
      );
    } else if (action == 'missed') {
      _logMedicationStatus(
        'missed',
        medicationId,
        medication['name'],
        DateTime.now().toIso8601String(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Medication marked as missed.')),
      );
    }
  }

  Future<void> _logMedicationStatus(String action, String medicationId, String medicationName, String timestamp, {String? nextNotificationTime}) async {
    final url = Uri.parse('http://192.168.1.2:3000/api/logMedicationStatus');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'action': action,
          'notificationId': medicationId,
          'medicationName': medicationName,
          'timestamp': timestamp,
          'nextNotificationTime': nextNotificationTime,
        }),
      );

      if (response.statusCode == 200) {
        print('[DEBUG] Medication status logged successfully.');
      } else {
        print('[ERROR] Failed to log medication status: ${response.body}');
      }
    } catch (error) {
      print('[ERROR] Logging medication status failed: $error');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication Tracker'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome User Section
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${widget.username}',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Add Caregiver Button (Placed Below the User's Name)
                ],
              ),
            ),

            // Medication List Section
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _medications.isEmpty
                  ? Center(
                child: Text(
                  'No Medications Found',
                  style: TextStyle(fontSize: 18.0, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _medications.length,
                itemBuilder: (context, index) {
                  final medication = _medications[index];
                  return Card(
                    elevation: 4.0,
                    margin: EdgeInsets.only(bottom: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16.0),
                      title: Text(
                        medication['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dosage: ${medication['dosage']}'),
                          Text('Frequency: ${medication['frequency']}'),
                          Text(
                            'Remaining Times: ${medication['remainingSpecificTimes']?.join(", ")}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    _handleAction('acknowledged', medication),
                                child: Text('Acknowledge'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                                ),
                              ),
                              SizedBox(width: 8.0),
                              ElevatedButton(
                                onPressed: () =>
                                    _handleAction('snoozed', medication),
                                child: Text('Snooze'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                                ),
                              ),
                              SizedBox(width: 8.0),
                              ElevatedButton(
                                onPressed: () =>
                                    _handleAction('missed', medication),
                                child: Text('Missed'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (String result) {
                          if (result == 'Edit') {
                            _navigateToEditScreen(medication);
                          } else if (result == 'Delete') {
                            _deleteMedication(medication['_id']);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'Edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem<String>(
                            value: 'Delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16.0),

            // Add Medication, View History, and Add Caregiver Buttons in One Line
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Add Medication Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedicationScreen(
                          token: widget.token,
                        ),
                      ),
                    ).then((_) => _fetchMedications());
                  },
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Add Medication',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                ),

                // View Medication History Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ViewMedicationHistoryScreen(token: widget.token),
                      ),
                    );
                  },
                  child: Text(
                    'View Medication History',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
