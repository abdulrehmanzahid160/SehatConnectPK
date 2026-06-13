import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/app_header.dart';
import '../widgets/result_card.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  final _hoursController = TextEditingController();
  String _selectedAgeGroup = 'adult';

  bool _isSubmitting = false;
  String? _userId;

  // Results
  double? _sleepDebt;
  String? _advice;
  String? _tip;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  Future<void> _calculateSleep() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userId == null || _userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No active user registration found.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _sleepDebt = null;
    });

    try {
      final hoursSlept = double.parse(_hoursController.text.trim());

      final response = await _apiService.calculateSleep(
        hoursSlept: hoursSlept,
        ageGroup: _selectedAgeGroup,
        userId: _userId!,
      );

      setState(() {
        _sleepDebt = double.tryParse(response['sleepDebt'].toString());
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
            content: Text('Failed to calculate sleep debt: $e'),
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
      appBar: const AppHeader(title: 'Sleep Tracker', showBackButton: true),
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
                  'Sleep Debt is the cumulative effect of not getting enough sleep. A large sleep debt can lead to mental and physical fatigue. Check if your nightly sleeping hours are optimal for your age group.',
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
                        'Analyze Sleep Debt & Quality',
                        style: GoogleFonts.sourceSerif4(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF01411C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Hours Slept
                      TextFormField(
                        controller: _hoursController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Hours Slept (Last Night)',
                          prefixIcon: const Icon(Icons.bedtime_outlined, size: 20, color: Color(0xFF01411C)),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF01411C), width: 2.0),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter hours slept';
                          final hr = double.tryParse(val.trim());
                          if (hr == null || hr < 0.0 || hr > 24.0) return 'Enter valid hours between 0 and 24';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Age Group Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedAgeGroup,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                        decoration: InputDecoration(
                          labelText: 'Age Group',
                          prefixIcon: const Icon(Icons.person_search_outlined, size: 20, color: Color(0xFF01411C)),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF01411C), width: 2.0),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'child', child: Text('Child (6-12 Years)')),
                          DropdownMenuItem(value: 'teen', child: Text('Teenager (13-18 Years)')),
                          DropdownMenuItem(value: 'adult', child: Text('Adult (18+ Years)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedAgeGroup = val;
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
                              onPressed: _calculateSleep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF01411C),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Text(
                                'TRACK SLEEP DEBT',
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
            if (_sleepDebt != null && _advice != null && _tip != null)
              ResultCard(
                title: 'Sleep Tracking Report',
                value: _sleepDebt! <= 0
                    ? 'Optimal Sleep (0.00 Sleep Debt)'
                    : '${_sleepDebt!.toStringAsFixed(2)} Hours Debt',
                valueLabel: 'Sleeping Hour Shortage',
                advice: _advice!,
                tip: _tip!,
                icon: Icons.bedtime,
              ),
          ],
        ),
      ),
    );
  }
}
