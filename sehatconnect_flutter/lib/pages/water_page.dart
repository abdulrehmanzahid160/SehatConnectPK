import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/app_header.dart';
import '../widgets/result_card.dart';

class WaterPage extends StatefulWidget {
  const WaterPage({super.key});

  @override
  State<StatefulWidget> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  final _weightController = TextEditingController();
  String _selectedActivity = 'sedentary';

  bool _isSubmitting = false;
  String? _userId;

  // Results
  double? _waterLitres;
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
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  Future<void> _calculateWater() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userId == null || _userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No active user registration found.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _waterLitres = null;
    });

    try {
      final weight = double.parse(_weightController.text.trim());

      final response = await _apiService.calculateWater(
        weight: weight,
        activityLevel: _selectedActivity,
        userId: _userId!,
      );

      setState(() {
        _waterLitres = double.tryParse(response['waterLitres'].toString());
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
            content: Text('Failed to calculate water intake: $e'),
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
      appBar: const AppHeader(title: 'Water Intake Estimator', showBackButton: true),
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
                  'Hydration is essential for maintaining physical functions and mental clarity. Calculate your daily recommended water volume in liters based on your body weight and daily activity levels.',
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
                        'Estimate Daily Hydration Goal',
                        style: GoogleFonts.sourceSerif4(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF01411C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Weight
                      TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Weight (kg)',
                          prefixIcon: const Icon(Icons.scale_outlined, size: 20, color: Color(0xFF01411C)),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF01411C), width: 2.0),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter your weight';
                          final wt = double.tryParse(val.trim());
                          // Sensible biological limits check to prevent extreme values (like 100,000 kg)
                          if (wt == null || wt <= 1.0 || wt > 500.0) return 'Enter a weight between 1.0 and 500.0 kg';
                          return null;
                        },
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
                          DropdownMenuItem(value: 'sedentary', child: Text('Sedentary (No Exercise)')),
                          DropdownMenuItem(value: 'active', child: Text('Active (Light/Moderate Exercise)')),
                          DropdownMenuItem(value: 'very_active', child: Text('Very Active (Heavy Daily Exercise)')),
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
                              onPressed: _calculateWater,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF01411C),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Text(
                                'ESTIMATE WATER GOAL',
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

            // Result
            if (_waterLitres != null && _advice != null && _tip != null)
              ResultCard(
                title: 'Water Intake Estimation',
                value: '${_waterLitres!.toStringAsFixed(2)} Litres',
                valueLabel: 'Recommended Daily Intake',
                advice: _advice!,
                tip: _tip!,
                icon: Icons.local_drink,
              ),
          ],
        ),
      ),
    );
  }
}
