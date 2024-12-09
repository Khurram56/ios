import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CaregiverDashboardScreen extends StatefulWidget {
  final String token;

  CaregiverDashboardScreen({required this.token});

  @override
  _CaregiverDashboardScreenState createState() => _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  bool _isLoading = false;
  Map<String, dynamic> caregiverData = {};

  @override
  void initState() {
    super.initState();
    fetchCaregiverDashboardData();
  }

  // Fetch caregiver's assigned user's data and medication history
  Future<void> fetchCaregiverDashboardData() async {
    final url = Uri.parse('http://192.168.1.2:3000/api/caregivers/dashboard'); // Your endpoint

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
        final data = jsonDecode(response.body);
        setState(() {
          caregiverData = data; // Store the data fetched from the backend
        });
      } else {
        throw Exception('Failed to fetch caregiver data');
      }
    } catch (error) {
      print('Error fetching caregiver data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load caregiver data')),
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
        title: Text('Caregiver Dashboard'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Caregiver: ${caregiverData['caregiverName'] ?? 'N/A'}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('User Info:', style: TextStyle(fontSize: 16)),
            ListTile(
              title: Text('Name: ${caregiverData['user']['name'] ?? 'N/A'}'),
              subtitle: Text('Email: ${caregiverData['user']['email'] ?? 'N/A'}'),
            ),
            Divider(),
            Text('Medication History:', style: TextStyle(fontSize: 16)),
            Expanded(
              child: ListView.builder(
                itemCount: caregiverData['medicationHistory']?.length ?? 0,
                itemBuilder: (context, index) {
                  final medication = caregiverData['medicationHistory'][index];
                  return ListTile(
                    title: Text(medication['medication']['name']),
                    subtitle: Text(
                      'Dosage: ${medication['medication']['dosage']} - Frequency: ${medication['medication']['frequency']}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
