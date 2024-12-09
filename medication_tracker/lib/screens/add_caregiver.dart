import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'adminDashboardScreen.dart';

class AddCaregiverScreen extends StatefulWidget {
  final String token; // Admin token for authentication
  final bool isAssignMode; // Flag to determine mode (Add or Assign)

  AddCaregiverScreen({required this.token, required this.isAssignMode});

  @override
  _AddCaregiverScreenState createState() => _AddCaregiverScreenState();
}

class _AddCaregiverScreenState extends State<AddCaregiverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caregiverNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationshipController = TextEditingController();

  bool _isLoading = false;

  // Add Caregiver Functionality
  Future<void> _addCaregiver() async {
    final url = Uri.parse('http://192.168.1.2:3000/api/simple-caregivers/add-caregiver');

    if (!_formKey.currentState!.validate()) return;

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
          'caregiverName': _caregiverNameController.text,
          'email': _emailController.text,
          'phoneNumber': _phoneController.text,
          'password': _passwordController.text,
          'relationshipToUser': _relationshipController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Caregiver added successfully!')),
        );

        // Navigate to Admin Dashboard Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboardScreen(token: widget.token)),
        );
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to add caregiver';
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

  // Build the Add Caregiver Form UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isAssignMode ? 'Assign Caregiver' : 'Add Caregiver',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Caregiver Details',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _caregiverNameController,
                label: 'Caregiver Name',
                icon: Icons.person,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.password,
                obscureText: true,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _relationshipController,
                label: 'Relationship to User',
                icon: Icons.account_circle_outlined,
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _addCaregiver,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Add Caregiver',
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable TextFormField widget for adding caregiver info
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false, // Added to handle obscureText functionality
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white70,
      ),
      obscureText: obscureText,
      validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }
}
