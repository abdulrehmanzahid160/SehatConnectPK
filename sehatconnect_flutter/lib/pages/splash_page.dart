import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _googleSignInInitialized = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _selectedGender = 'Male';

  String? _googleId;
  bool _isGoogleSignedIn = false;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkRegistration();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _checkRegistration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isRegistered = prefs.getBool('isRegistered') ?? false;
      final userId = prefs.getString('userId');

      if (isRegistered && userId != null) {
        // Already registered, redirect to Dashboard
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _isLoading = true);
      
      if (!_googleSignInInitialized) {
        try {
          // On Web, Google Sign-In requires a Web Client ID.
          // You can create a Web Client ID in the Google Cloud Console (Credentials page)
          // and paste it here:
          const String? webClientId = null; // e.g. "YOUR_CLIENT_ID.apps.googleusercontent.com"

          if (identical(0, 0.0)) { // This is a standard dart-web check (kIsWeb)
            if (webClientId == null || webClientId.isEmpty) {
              throw Exception(
                'Google Client ID is not set for Web. To test Google Sign-in on Chrome, '
                'please configure your Web Client ID in splash_page.dart or web/index.html.'
              );
            }
            await GoogleSignIn.instance.initialize(clientId: webClientId);
          } else {
            await GoogleSignIn.instance.initialize();
          }
        } catch (e) {
          // Swallow error if already initialized (common on hot-restart)
          if (!e.toString().contains('already been called')) {
            rethrow;
          }
        }
        _googleSignInInitialized = true;
      }

      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      // Check if user exists on backend without modifying backend
      try {
        await _apiService.getUser(googleUser.id);
        
        // If no exception, user exists! Save to preferences and login.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', googleUser.id);
        await prefs.setBool('isRegistered', true);
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      } catch (e) {
        // If we get an ApiException, user doesn't exist yet, proceed to registration form
        setState(() {
          _isLoading = false;
          _googleId = googleUser.id;
          _nameController.text = googleUser.displayName ?? '';
          _isGoogleSignedIn = true;
        });
      }
    } catch (error) {
      if (mounted) {
        // Only show error if the user didn't cancel the flow
        final errorStr = error.toString();
        if (!errorStr.contains('canceled')) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Google Sign-In Info'),
              content: Text(error.toString().replaceAll('Exception: ', '')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (_googleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please Sign In with Google first')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 1. Use Google ID instead of UUID to prevent backend changes
      final userId = _googleId!;

      // 2. Prepare payload
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

      // 3. Save to backend
      await _apiService.saveUser(
        userData: userData,
        userId: userId,
      );

      // 4. Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
      await prefs.setBool('isRegistered', true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile registered successfully on SehatConnect'),
            backgroundColor: Color(0xFF01411C),
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
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
            content: Text('Failed to save profile: $e'),
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F0),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF01411C)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0), // Off-white
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Government Portal Header Block
              Center(
                child: Column(
                  children: [
                    // Official Star & Crescent Emblem
                    Image.asset(
                      'assets/logo.png',
                      width: 160,
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SEHATCONNECT',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF01411C),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Government Health & Wellness Portal',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 60,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFF01411C),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Title Card
              Card(
                color: Colors.white,
                elevation: 2.0,
                shadowColor: Colors.black.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isGoogleSignedIn ? 'Complete Your Profile' : 'Sign in to SehatConnect',
                        style: GoogleFonts.sourceSerif4(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      if (!_isGoogleSignedIn)
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          icon: Image.network(
                            'https://developers.google.com/static/identity/images/g-logo.png',
                            height: 24,
                          ),
                          label: Text(
                            'Sign in with Google',
                            style: GoogleFonts.sourceSerif4(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 2.0,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                            ),
                          ),
                        )
                      else
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                            // Name field
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
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter your name';
                                }
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
                                      if (age == null || age <= 0 || age > 120) return 'Invalid age';
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
                                      if (wt == null || wt <= 0) return 'Invalid wt';
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
                                      if (ht == null || ht <= 0) return 'Invalid ht';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // Submit Button
                            _isSubmitting
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF01411C)),
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: _registerUser,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF01411C),
                                      foregroundColor: Colors.white,
                                      elevation: 2.0,
                                      minimumSize: const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    child: Text(
                                      'REGISTER & ENTER',
                                      style: GoogleFonts.sourceSerif4(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
