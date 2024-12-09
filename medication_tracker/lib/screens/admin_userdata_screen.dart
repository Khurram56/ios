import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminUserDataScreen extends StatefulWidget {
  final String token;

  AdminUserDataScreen({required this.token});

  @override
  _AdminUserDataScreenState createState() => _AdminUserDataScreenState();
}

class _AdminUserDataScreenState extends State<AdminUserDataScreen> {
  List<dynamic> usersWithHistories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUsersWithMedicationHistory();
  }

  // Fetch all users with their medication histories
  Future<void> fetchUsersWithMedicationHistory() async {
    final url = Uri.parse('http://192.168.1.2:3000/api/admin/users-with-medications');

    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}', // Send the token for authentication
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          usersWithHistories = data['usersWithHistories'];
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (error) {
      print('Error fetching data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Build the UI for the list of users and their medication histories
  Widget _buildUserMedicationList() {
    if (usersWithHistories.isEmpty) {
      return Center(
        child: Text(
          'No users or medication history found.',
          style: TextStyle(fontSize: 18.0, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: usersWithHistories.length,
      itemBuilder: (context, index) {
        final user = usersWithHistories[index];
        final medicationHistory = user['medicationHistory'];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ExpansionTile(
            title: Text(
              user['username'] ?? 'Unknown User',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Click for More Information'),
            children: [
              if (medicationHistory.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('No medication history available.'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: medicationHistory.length,
                  itemBuilder: (context, medIndex) {
                    final med = medicationHistory[medIndex];
                    return ListTile(
                      leading: Icon(Icons.medication, color: Colors.deepPurple),
                      title: Text(med['medication']['name'] ?? 'Unknown Medication'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dosage: ${med['medication']['dosage'] ?? 'N/A'}'),
                          Text('Frequency: ${med['medication']['frequency'] ?? 'N/A'}'),
                          Text('Start Date: ${med['medication']['specificTimes']?.join(", ") ?? 'N/A'}'),
                          Text('End Date: ${med['medication']['specificTimes']?.join(", ") ?? 'Ongoing'}'),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin User Data'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildUserMedicationList(),
    );
  }
}
