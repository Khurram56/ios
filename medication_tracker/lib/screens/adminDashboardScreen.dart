import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:medication_tracker/screens/ViewMedicationHistoryScreen.dart';
import 'package:medication_tracker/screens/admin_userdata_screen.dart';
import 'add_caregiver.dart';
import 'package:http/http.dart' as http;

import 'assign_caregiver_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String token;

  AdminDashboardScreen({required this.token});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<dynamic> caregivers = [];
  List<dynamic> users = [];
  String? selectedCaregiverId;
  String? selectedUserId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUsersAndCaregivers();

  }

  // Fetch users and caregivers from the backend
  Future<void> fetchUsersAndCaregivers() async {
    final url = Uri.parse('http://192.168.1.2:3000/api/simple-caregivers/fetch-users-caregivers');

    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          users = data['users'];
          caregivers = data['caregivers'];
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Assign caregiver to user
  Future<void> assignCaregiverToUser(String caregiverId, String userId) async {
    final url = Uri.parse('http://192.168.1.2:3000/api/simple-caregivers/assign-caregiver');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'caregiverId': caregiverId,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Caregiver assigned successfully!')),
        );
        fetchUsersAndCaregivers(); // Refresh data
      } else {
        throw Exception('Failed to assign caregiver');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }


  // Build dropdown UI for caregiver and user assignment
  Widget _buildDropdownForAssignCaregiver() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: selectedCaregiverId ?? "", // Use empty string if null
          items: caregivers.map((caregiver) {
            return DropdownMenuItem<String>(
              value: caregiver['_id'] ?? "", // Ensure it's not null
              child: Text(caregiver['caregiverName'] ?? 'Unknown Caregiver'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCaregiverId = value;
            });
          },
          decoration: InputDecoration(labelText: 'Select Caregiver'),
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: selectedUserId ?? "", // Use empty string if null
          items: users.map((user) {
            return DropdownMenuItem<String>(
              value: user['_id'] ?? "", // Ensure it's not null
              child: Text(user['name'] ?? 'Unknown User'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedUserId = value;
            });
          },
          decoration: InputDecoration(labelText: 'Select User'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (selectedCaregiverId != null && selectedUserId != null) {
              assignCaregiverToUser(selectedCaregiverId!, selectedUserId!);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please select both caregiver and user.')),
              );
            }
          },
          child: Text('Assign Caregiver'),
        ),
      ],
    );
  }


  // Build the UI with loading indicator or grid of options
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of items in a row
            crossAxisSpacing: 10.0, // Space between columns
            mainAxisSpacing: 10.0, // Space between rows
          ),
          children: [
            _buildDashboardCard(
              icon: Icons.person_add_alt_1,
              title: 'Add Caregiver',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCaregiverScreen(
                      token: widget.token,
                      isAssignMode: false,
                    ),
                  ),
                );
              },
            ),
            // Inside your AdminDashboardScreen
            _buildDashboardCard(
              icon: Icons.person_search,
              title: 'Assign Caregiver',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignCaregiverScreen(
                      token: widget.token,  // Pass token for authentication
                    ),
                  ),
                );
              },
            ),

            _buildDashboardCard(
              icon: Icons.history,
              title: 'View User Data',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminUserDataScreen(
                      token: widget.token,  // Pass token for authentication
                    ),
                  ),
                );
                // Navigate to medication history screen
              },
            ),
            _buildDashboardCard(
              icon: Icons.insert_chart,
              title: 'View Users',
              color: Colors.purple,
              onTap: () {
                // Navigate to logs or reports screen
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
