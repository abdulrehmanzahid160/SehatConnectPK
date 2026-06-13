import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/app_header.dart';
import '../widgets/result_card.dart';

class BmiPage extends StatefulWidget {
  const BmiPage({super.key});

  @override
  State<BmiPage> createState() => _BmiPageState();
}

class _BmiPageState extends State<BmiPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  bool _isSubmitting = false;
  String? _userId;

  // Results from API
  double? _bmi;
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
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  Future<void> _calculateBmi() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userId == null || _userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No active user registration found.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _bmi = null; // Reset old results
    });

    try {
      final weight = double.parse(_weightController.text.trim());
      final height = double.parse(_heightController.text.trim());

      final response = await _apiService.calculateBmi(
        weight: weight,
        height: height,
        userId: _userId!,
      );

      setState(() {
        _bmi = double.tryParse(response['bmi'].toString());
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
            content: Text('Failed to calculate: $e'),
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
      backgroundColor: const Color(0xFFF5F5F0), // Off-white
      appBar: const AppHeader(title: 'BMI Calculator', showBackButton: true),
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
                  'Body Mass Index (BMI) is a measure of body fat based on weight and height that applies to adult men and women. Please enter your weight in Kilograms (kg) and height in Meters (m).',
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
                        'Calculate Your Body Mass Index',
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
                          if (wt == null || wt <= 1.0 || wt > 500.0) return 'Enter a valid weight';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Height
                      TextFormField(
                        controller: _heightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Height (meters, e.g. 1.75)',
                          prefixIcon: const Icon(Icons.height_outlined, size: 20, color: Color(0xFF01411C)),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF01411C), width: 2.0),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter your height';
                          final ht = double.tryParse(val.trim());
                          if (ht == null || ht <= 0.2 || ht > 3.0) return 'Enter a valid height in meters';
                          return null;
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
                              onPressed: _calculateBmi,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF01411C),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Text(
                                'CALCULATE BMI',
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

            // Result Display
            if (_bmi != null && _advice != null && _tip != null)
              ResultCard(
                title: 'BMI Calculation Result',
                value: _bmi!.toStringAsFixed(2),
                valueLabel: 'Body Mass Index Value',
                advice: _advice!,
                tip: _tip!,
                icon: Icons.monitor_weight,
              ),
          ],
        ),
      ),
    );
  }
}
