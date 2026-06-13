import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/app_header.dart';

class MedicinePage extends StatefulWidget {
  const MedicinePage({super.key});

  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  String _selectedTiming = 'Morning';

  String? _userId;
  List<dynamic> _medicines = [];
  bool _isLoading = true;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserIdAndList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId');

      if (_userId != null && _userId!.isNotEmpty) {
        await _fetchMedicines();
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

  Future<void> _fetchMedicines() async {
    if (_userId == null) return;
    try {
      final list = await _apiService.getMedicines(_userId!);
      setState(() {
        _medicines = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load medicines: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _addMedicineReminder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userId == null) return;

    setState(() {
      _isAdding = true;
    });

    try {
      final name = _nameController.text.trim();
      final dosage = _dosageController.text.trim();

      await _apiService.addMedicine(
        userId: _userId!,
        name: name,
        dosage: dosage,
        timing: _selectedTiming,
      );

      // Reset form
      _nameController.clear();
      _dosageController.clear();
      _selectedTiming = 'Morning';

      // Close bottom sheet
      Navigator.of(context).pop();

      // Refresh list
      await _fetchMedicines();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicine reminder added successfully'),
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
          SnackBar(content: Text('Failed to add medicine: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isAdding = false;
      });
    }
  }

  Future<void> _deleteMedicine(String medicineName) async {
    if (_userId == null) return;
    try {
      await _apiService.removeMedicine(
        userId: _userId!,
        medicineName: medicineName,
      );

      // Refresh list
      await _fetchMedicines();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed reminder for $medicineName'),
            backgroundColor: const Color(0xFF01411C),
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
          SnackBar(content: Text('Failed to remove medicine: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddMedicineBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Medicine Reminder',
                        style: GoogleFonts.sourceSerif4(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF01411C),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(height: 1.0),
                  const SizedBox(height: 20),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Medicine Name',
                      prefixIcon: const Icon(Icons.medication, size: 20, color: Color(0xFF01411C)),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF01411C), width: 2.0),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please enter medicine name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Dosage
                  TextFormField(
                    controller: _dosageController,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Dosage (e.g. 1 Tablet, 5ml)',
                      prefixIcon: const Icon(Icons.science_outlined, size: 20, color: Color(0xFF01411C)),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF01411C), width: 2.0),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please enter dosage';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Timing Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedTiming,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                    decoration: InputDecoration(
                      labelText: 'Timing Schedule',
                      prefixIcon: const Icon(Icons.alarm, size: 20, color: Color(0xFF01411C)),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF01411C), width: 2.0),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Morning', child: Text('Morning (Subh)')),
                      DropdownMenuItem(value: 'Afternoon', child: Text('Afternoon (Dopahar)')),
                      DropdownMenuItem(value: 'Evening', child: Text('Evening (Shaam)')),
                      DropdownMenuItem(value: 'Night', child: Text('Night (Raat)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        _selectedTiming = val;
                      }
                    },
                  ),
                  const SizedBox(height: 28),

                  // Submit Button
                  _isAdding
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF01411C)),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _addMedicineReminder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF01411C),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            'SAVE REMINDER',
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine whether this page is rendered inside the Tab bar or pushed on stack
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppHeader(
        title: 'Medicine Reminders',
        showBackButton: canPop,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF01411C)),
              ),
            )
          : _medicines.isEmpty
              ? _buildEmptyState()
              : _buildListState(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMedicineBottomSheet,
        backgroundColor: const Color(0xFF01411C),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color(0xFF01411C).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication_liquid_sharp,
                size: 64,
                color: Color(0xFF01411C),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Reminders Active',
              style: GoogleFonts.sourceSerif4(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF01411C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have no configured medical reminder routines. Tap the green plus button below to register a medication routine.',
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.grey[700],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListState() {
    return ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: _medicines.length,
      itemBuilder: (context, index) {
        final med = _medicines[index];
        final name = med['name']?.toString() ?? 'Unknown';
        final dosage = med['dosage']?.toString() ?? 'Dosage not set';
        final timing = med['timing']?.toString() ?? 'Morning';

        IconData timingIcon = Icons.wb_sunny_outlined;
        Color timingColor = Colors.orange;

        if (timing.toLowerCase().contains('afternoon')) {
          timingIcon = Icons.brightness_5;
          timingColor = Colors.amber[700]!;
        } else if (timing.toLowerCase().contains('evening')) {
          timingIcon = Icons.brightness_4_outlined;
          timingColor = Colors.indigo;
        } else if (timing.toLowerCase().contains('night')) {
          timingIcon = Icons.nights_stay;
          timingColor = Colors.black87;
        }

        return Card(
          color: Colors.white,
          elevation: 2.0,
          shadowColor: Colors.black.withOpacity(0.05),
          margin: const EdgeInsets.only(bottom: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
            side: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1.0),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            leading: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0xFF01411C).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication,
                color: Color(0xFF01411C),
                size: 24,
              ),
            ),
            title: Text(
              name,
              style: GoogleFonts.sourceSerif4(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF01411C),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      dosage,
                      style: TextStyle(fontSize: 11.5, color: Colors.grey[800], fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Icon(timingIcon, size: 14, color: timingColor),
                  const SizedBox(width: 4.0),
                  Text(
                    timing,
                    style: TextStyle(fontSize: 11.5, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[700], size: 22),
              onPressed: () {
                // Show a brief deletion dialog to prevent accidental deletion
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(
                      'Confirm Deletion',
                      style: GoogleFonts.sourceSerif4(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    content: Text('Are you sure you want to delete the reminder for $name?'),
                    actions: [
                      TextButton(
                        child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                      TextButton(
                        child: Text('DELETE', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _deleteMedicine(name);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
