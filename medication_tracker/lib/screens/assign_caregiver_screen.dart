// AssignCaregiverScreen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AssignCaregiverScreen extends StatefulWidget {
  final String token;

  AssignCaregiverScreen({required this.token});

  @override
  _AssignCaregiverScreenState createState() => _AssignCaregiverScreenState();
}

class _AssignCaregiverScreenState extends State<AssignCaregiverScreen> {
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

  // Fetch caregivers and users from the backend
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
  Future<void> assignCaregiverToUser() async {
    final url = Uri.parse('http://192.168.1.2:3000/api/simple-caregivers/assign-caregiver');

    if (selectedCaregiverId == null || selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both caregiver and user')),
      );
      return;
    }

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
          'caregiverId': selectedCaregiverId,
          'userId': selectedUserId,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Caregiver assigned successfully!')),
        );
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to assign caregiver';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  // Build dropdown UI for caregiver and user assignment
  Widget _buildDropdownForAssignCaregiver() {
    return Column(
      children: [
        // Caregiver Dropdown
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButtonFormField<String>(
            value: selectedCaregiverId ?? "", // Default to empty string if null
            items: [
              DropdownMenuItem<String>(
                value: "", // Default empty option
                child: Text("Select Caregiver", style: TextStyle(color: Colors.grey)),
              ),
              ...caregivers.map((caregiver) {
                return DropdownMenuItem<String>(
                  value: caregiver['_id'] ?? "", // Ensure it’s not null
                  child: Text(caregiver['caregiverName'] ?? 'Unknown Caregiver'),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                selectedCaregiverId = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Select Caregiver',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            ),
          ),
        ),
        SizedBox(height: 16),

        // User Dropdown
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButtonFormField<String>(
            value: selectedUserId ?? "", // Default to empty string if null
            items: [
              DropdownMenuItem<String>(
                value: "", // Default empty option
                child: Text("Select User", style: TextStyle(color: Colors.grey)),
              ),
              ...users.map((user) {
                return DropdownMenuItem<String>(
                  value: user['_id'] ?? "", // Ensure it’s not null
                  child: Text(user['name'] ?? 'Unknown User'),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                selectedUserId = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Select User',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            ),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (selectedCaregiverId != null && selectedUserId != null && selectedCaregiverId != "" && selectedUserId != "") {
              assignCaregiverToUser();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please select both caregiver and user.')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
          ),
          child: Text('Assign Caregiver', style: TextStyle(fontSize: 16.0, color: Colors.white)),
        ),
      ],
    );
  }

  // Build the UI with loading indicator or grid of options
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Caregiver'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildDropdownForAssignCaregiver(),
      ),
    );
  }
}
