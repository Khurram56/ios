import 'package:http/http.dart' as http;
import 'dart:convert';

class LogService {
  static Future<void> logMedicationStatus(
      String medicationId, String status) async {
    final url = Uri.parse('http://192.168.1.1:3000/api/medication/log');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'medicationId': medicationId,
          'status': status, // "taken", "snoozed", or "missed"
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print('Medication status logged successfully');
      } else {
        print('Failed to log medication status');
      }
    } catch (error) {
      print('Error logging medication status: $error');
    }
  }
}
