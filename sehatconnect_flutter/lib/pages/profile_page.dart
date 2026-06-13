import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import '../widgets/app_header.dart';
import 'splash_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  // Form controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _selectedGender = 'Male';

  String? _userId;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId');

      if (_userId != null && _userId!.isNotEmpty) {
        final userData = await _apiService.getUser(_userId!);
        
        setState(() {
          _nameController.text = userData['name']?.toString() ?? '';
          _ageController.text = userData['age']?.toString() ?? '';
          _weightController.text = userData['weight']?.toString() ?? '';
          _heightController.text = userData['height']?.toString() ?? '';
          
          final genderRaw = userData['gender']?.toString() ?? 'Male';
          // Support both lowercase/uppercase variations returned from the backend
          if (genderRaw.toLowerCase() == 'female') {
            _selectedGender = 'Female';
          } else {
            _selectedGender = 'Male';
          }
          
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile details: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userId == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final name = _nameController.text.trim();
      final age = int.parse(_ageController.text.trim());
      final weight = double.parse(_weightController.text.trim());
      final height = double.parse(_heightController.text.trim());

      final userData = {
        'name': name,
        'age': age,
        'gender': _selectedGender,
        'weight': weight,
        'height': height,
      };

      await _apiService.saveUser(
        userData: userData,
        userId: _userId!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile information updated successfully!'),
            backgroundColor: Color(0xFF01411C),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save updates: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout', style: GoogleFonts.sourceSerif4(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out from SehatConnect?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        try {
          await GoogleSignIn.instance.signOut();
        } catch (_) {}

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SplashPage()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to logout: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppHeader(
        title: 'Official Profile Details',
        showBackButton: canPop,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF01411C)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Government Badge
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF01411C).withOpacity(0.08),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF01411C).withOpacity(0.2), width: 1.0),
                          ),
                          child: const Icon(
                            Icons.account_box_outlined,
                            size: 48,
                            color: Color(0xFF01411C),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'REGISTERED CITIZEN PROFILE',
                          style: GoogleFonts.sourceSerif4(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF01411C),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Keep your biological variables accurate to ensure precise health calculations.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Form Card
                  Card(
                    color: Colors.white,
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Name
                            TextFormField(
                              controller: _nameController,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: const Icon(Icons.person_outline, size: 20, color: Color(0xFF01411C)),
                                border: const OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF01411C), width: 2.0),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Please enter your name';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Age and Gender
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Expanded(
                                    flex: 5,
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
                                        // Sensible upper limit validation to prevent invalid input (like 1000yo)
                                        if (age == null || age <= 0 || age > 120) return 'Age must be 1-120';
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 6,
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
                                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                                        DropdownMenuItem(value: 'Female', child: Text('Female')),
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
  
                              // Weight and Height
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
                                        // Sensible upper limit validation to prevent invalid input (like 100,000kg)
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
                                        // Sensible upper limit validation to prevent invalid input (like 1000cm)
                                        if (ht == null || ht <= 10.0 || ht > 300.0) return 'Height must be 10-300 cm';
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 28),

                            // Submit button
                            _isSaving
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF01411C)),
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: _saveProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF01411C),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    child: Text(
                                      'SAVE PROFILE UPDATES',
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
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: Text(
                      'LOG OUT',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
