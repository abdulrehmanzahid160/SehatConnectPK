import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/app_header.dart';
import '../widgets/result_card.dart';

class CaloriePage extends StatefulWidget {
  const CaloriePage({super.key});

  @override
  State<CaloriePage> createState() => _CaloriePageState();
}

class _CaloriePageState extends State<CaloriePage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGender = 'male';
  String _selectedActivity = 'sedentary';

  bool _isSubmitting = false;
  String? _userId;

  // Results
  double? _calories;
  String? _advice;
  String? _tip;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  Future<void> _calculateCalories() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userId == null || _userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No active user registration found.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _calories = null;
    });

    try {
      final weight = double.parse(_weightController.text.trim());
      final height = double.parse(_heightController.text.trim());
      final age = int.parse(_ageController.text.trim());

      final response = await _apiService.calculateCalorie(
        weight: weight,
        height: height,
        age: age,
        gender: _selectedGender,
        activityLevel: _selectedActivity,
        userId: _userId!,
      );

      setState(() {
        _calories = double.tryParse(response['calories'].toString());
        _advice = response['advice'].toString();
        _tip = response['tip'].toString();
      });
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to calculate calories: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: const AppHeader(title: 'Calorie Calculator', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Card(
              color: Colors.white,
              elevation: 1.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(color: Colors.grey.withOpacity(0.15)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Your Daily Calorie Requirement (Total Daily Energy Expenditure) determines how much food energy you need to consume to maintain, lose, or gain weight. Please input your metrics below.',
                  style: TextStyle(
                    fontSize: 13.0,
                    height: 1.4,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Form
            Card(
              color: Colors.white,
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Calculate Daily Caloric Target',
                        style: GoogleFonts.sourceSerif4(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF01411C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Weight & Height
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'Weight (kg)',
                                prefixIcon: const Icon(Icons.scale_outlined, size: 18, color: Color(0xFF01411C)),
                                border: const OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF01411C), width: 2.0),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Enter weight';
                                final wt = double.tryParse(val.trim());
                                // Sensible weight limit validation to prevent invalid input (like 100,000kg)
                                if (wt == null || wt <= 1.0 || wt > 500.0) return 'Weight must be 1-500 kg';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _heightController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'Height (cm)',
                                prefixIcon: const Icon(Icons.height_outlined, size: 18, color: Color(0xFF01411C)),
                                border: const OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF01411C), width: 2.0),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Enter height';
                                final ht = double.tryParse(val.trim());
                                // Sensible height limit validation to prevent invalid input (like 1000cm)
                                if (ht == null || ht <= 10.0 || ht > 300.0) return 'Height must be 10-300 cm';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Age & Gender
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'Age (Years)',
                                prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF01411C)),
                                border: const OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF01411C), width: 2.0),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Enter age';
                                final age = int.tryParse(val.trim());
                                // Sensible age limit validation to prevent invalid input (like 1000yo)
                                if (age == null || age <= 0 || age > 120) return 'Age must be 1-120';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                              decoration: InputDecoration(
                                labelText: 'Gender',
                                prefixIcon: const Icon(Icons.wc_outlined, size: 18, color: Color(0xFF01411C)),
                                border: const OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF01411C), width: 2.0),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'male', child: Text('Male')),
                                DropdownMenuItem(value: 'female', child: Text('Female')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedGender = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Activity Level Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedActivity,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                        decoration: InputDecoration(
                          labelText: 'Activity Level',
                          prefixIcon: const Icon(Icons.directions_run_outlined, size: 20, color: Color(0xFF01411C)),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF01411C), width: 2.0),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'sedentary', child: Text('Sedentary (Little/No Exercise)')),
                          DropdownMenuItem(value: 'light', child: Text('Light (Exercise 1-3 times/week)')),
                          DropdownMenuItem(value: 'moderate', child: Text('Moderate (Exercise 3-5 times/week)')),
                          DropdownMenuItem(value: 'active', child: Text('Active (Exercise 6-7 times/week)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedActivity = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // Calculate Button
                      _isSubmitting
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF01411C)),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _calculateCalories,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF01411C),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Text(
                                'CALCULATE CALORIES',
                                style: GoogleFonts.sourceSerif4(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),

            // Result Card
            if (_calories != null && _advice != null && _tip != null)
              ResultCard(
                title: 'Calorie Intake Calculation',
                value: '${_calories!.toStringAsFixed(0)} kcal/day',
                valueLabel: 'Recommended Daily Intake',
                advice: _advice!,
                tip: _tip!,
                icon: Icons.local_fire_department,
              ),
          ],
        ),
      ),
    );
  }
}
