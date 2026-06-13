import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

class ApiService {
  // ── Render deployment URL ──
  // Replace YOUR_SERVICE_NAME with your actual Render service name
  static final String baseUrl =
      'http://10.4.44.232:8081/api';

  /// Helper: Generate auth headers with local UUID bearer token
  Map<String, String> _headers(String? userId) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (userId != null && userId.isNotEmpty) {
      headers['Authorization'] = 'Bearer $userId';
    }
    return headers;
  }

  /// Process response and check for non-200 status codes
  dynamic _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (e) {
        // If it's not valid JSON, return as plain text (e.g. text report)
        return response.body;
      }
    } else {
      String message = 'Server error occurred (${response.statusCode})';
      try {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        if (errorBody.containsKey('message') && errorBody['message'] != null && errorBody['message'].toString().isNotEmpty) {
          message = errorBody['message'].toString();
        } else if (errorBody.containsKey('error') && errorBody['error'] != null) {
          message = errorBody['error'].toString();
        }
      } catch (_) {
        if (response.body.isNotEmpty) {
          message = response.body;
        }
      }
      throw ApiException(message, response.statusCode);
    }
  }

  // ─── Health Calculators ────────────────────────────────────

  /// Calculate BMI
  Future<Map<String, dynamic>> calculateBmi({
    required double weight,
    required double height,
    required String userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bmi'),
      headers: _headers(userId),
      body: jsonEncode({
        'weight': weight,
        'height': height,
      }),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// Calculate Water Intake
  Future<Map<String, dynamic>> calculateWater({
    required double weight,
    required String activityLevel,
    required String userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/water'),
      headers: _headers(userId),
      body: jsonEncode({
        'weight': weight,
        'activityLevel': activityLevel,
      }),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// Calculate Calorie Needs
  Future<Map<String, dynamic>> calculateCalorie({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
    required String userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/calorie'),
      headers: _headers(userId),
      body: jsonEncode({
        'weight': weight,
        'height': height,
        'age': age,
        'gender': gender,
        'activityLevel': activityLevel,
      }),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// Calculate Sleep Debt
  Future<Map<String, dynamic>> calculateSleep({
    required double hoursSlept,
    required String ageGroup,
    required String userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sleep'),
      headers: _headers(userId),
      body: jsonEncode({
        'hoursSlept': hoursSlept,
        'ageGroup': ageGroup,
      }),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }



  // ─── Medicine ──────────────────────────────────────────────

  /// Get medicines list from backend
  Future<List<dynamic>> getMedicines(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/medicine/list/$userId'),
      headers: _headers(userId),
    );
    return _processResponse(response) as List<dynamic>;
  }

  /// Add a medicine
  Future<Map<String, dynamic>> addMedicine({
    required String userId,
    required String name,
    required String dosage,
    required String timing,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/medicine/add'),
      headers: _headers(userId),
      body: jsonEncode({
        'userId': userId,
        'name': name,
        'dosage': dosage,
        'timing': timing,
      }),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// Delete a medicine
  Future<Map<String, dynamic>> removeMedicine({
    required String userId,
    required String medicineName,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/medicine/remove/$userId/$medicineName'),
      headers: _headers(userId),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  // ─── Reports ───────────────────────────────────────────────

  /// Get health report JSON data
  Future<Map<String, dynamic>> getReport(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/report/$userId'),
      headers: _headers(userId),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// Get health report plain text
  Future<String> getReportText(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/report/$userId/text'),
      headers: _headers(userId),
    );
    return _processResponse(response) as String;
  }

  // ─── User Profile ──────────────────────────────────────────

  /// Save user profile
  Future<Map<String, dynamic>> saveUser({
    required Map<String, dynamic> userData,
    required String userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/save'),
      headers: _headers(userId),
      body: jsonEncode(userData),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// Get user profile
  Future<Map<String, dynamic>> getUser(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId'),
      headers: _headers(userId),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }
}
