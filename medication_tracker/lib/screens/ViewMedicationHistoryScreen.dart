import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewMedicationHistoryScreen extends StatefulWidget {
  final String token;

  ViewMedicationHistoryScreen({required this.token});

  @override
  _ViewMedicationHistoryScreenState createState() =>
      _ViewMedicationHistoryScreenState();
}

class _ViewMedicationHistoryScreenState
    extends State<ViewMedicationHistoryScreen> {
  List<dynamic> _medicationHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMedicationHistory();
  }

  Future<void> _fetchMedicationHistory() async {
    final url = Uri.parse('http://192.168.1.2:3000/api/medicationHistory');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _medicationHistory = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch medication history')),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication History'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _medicationHistory.isEmpty
          ? Center(
        child: Text(
          'No medication history available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: _medicationHistory.length,
        itemBuilder: (context, index) {
          final history = _medicationHistory[index];
          return Card(
            elevation: 4.0,
            margin: EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: Text(
                history['medication']['name'],
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dosage: ${history['medication']['dosage']}',
                    style: TextStyle(fontSize: 14.0, color: Colors.black),
                  ),
                  Text(
                    'Frequency: ${history['medication']['frequency']}',
                    style: TextStyle(fontSize: 14.0, color: Colors.black),
                  ),
                  if (history['medication']['specificTimes'] != null)
                    Text(
                      'Specific Times: ${history['medication']['specificTimes']
                          .join(", ")}',
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                    ),
                  SizedBox(height: 8.0),
                  Text(
                    'Action: ${history['action']}',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: _getActionColor(history['action']),
                    ),
                  ),
                ],
              ),
              trailing: Text(
                _formatTimestamp(history['timestamp']),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }

// Helper function to format timestamp
  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime
        .hour}:${dateTime.minute}';
  }

// Helper function to get action color
  Color _getActionColor(String action) {
    switch (action.toLowerCase()) {
      case 'acknowledged':
        return Colors.green;
      case 'missed':
        return Colors.red;
      case 'snoozed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
