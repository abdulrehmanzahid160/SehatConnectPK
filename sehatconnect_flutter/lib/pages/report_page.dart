import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/app_header.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _apiService = ApiService();
  String? _userId;
  String _userName = '';
  List<dynamic> _results = [];
  bool _isLoading = true;
  bool _isTextLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId');

      if (_userId != null && _userId!.isNotEmpty) {
        final response = await _apiService.getReport(_userId!);
        setState(() {
          _userName = response['userName']?.toString() ?? 'Citizen';
          _results = response['results'] as List<dynamic>? ?? [];
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
          SnackBar(content: Text('Failed to load health report: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _viewTextReport() async {
    if (_userId == null) return;

    setState(() {
      _isTextLoading = true;
    });

    try {
      final textReport = await _apiService.getReportText(_userId!);

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Official Text Report',
                    style: GoogleFonts.sourceSerif4(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Text(
                      textReport,
                      style: GoogleFonts.robotoMono(
                        fontSize: 12.0,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('DISMISS', style: TextStyle(color: Color(0xFF01411C), fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            );
          },
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
          SnackBar(content: Text('Failed to fetch plain text report: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isTextLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppHeader(
        title: 'Official Health Report',
        showBackButton: canPop,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF01411C)),
              ),
            )
          : _results.isEmpty
              ? _buildEmptyState()
              : _buildReportState(),
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
                Icons.assignment_late_outlined,
                size: 64,
                color: Color(0xFF01411C),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Health Calculations Yet',
              style: GoogleFonts.sourceSerif4(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF01411C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Perform health calculations (BMI, Water, Calories, Sleep) to generate official health assessment reports.',
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

  Widget _buildReportState() {
    return RefreshIndicator(
      onRefresh: _loadReport,
      color: const Color(0xFF01411C),
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // User profile header
          Card(
            color: Colors.white,
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: const Color(0xFF01411C).withOpacity(0.15)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF01411C).withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.badge_outlined, color: Color(0xFF01411C)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HEALTH STATEMENT RECORD',
                              style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              _userName,
                              style: GoogleFonts.sourceSerif4(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF01411C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isTextLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF01411C)),
                          ),
                        )
                      : ElevatedButton.icon(
                          icon: const Icon(Icons.article_outlined, size: 18),
                          label: Text(
                            'VIEW TEXT REPORT',
                            style: GoogleFonts.sourceSerif4(fontWeight: FontWeight.bold, fontSize: 14.0),
                          ),
                          onPressed: _viewTextReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF01411C),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                          ),
                        ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Calculation History Timeline',
            style: GoogleFonts.sourceSerif4(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),

          // Timeline items
          ..._results.map((res) {
            final typeStr = res['type']?.toString() ?? 'bmi';
            final valueNum = double.tryParse(res['value']?.toString() ?? '0.0') ?? 0.0;
            final adviceStr = res['advice']?.toString() ?? '';
            final dateStr = res['date']?.toString() ?? '';

            // Map standard titles & icons
            IconData resIcon = Icons.help_outline;
            String cleanTitle = 'Calculation';
            String valueUnit = '';

            if (typeStr.toLowerCase().contains('bmi')) {
              resIcon = Icons.monitor_weight_outlined;
              cleanTitle = 'Body Mass Index (BMI)';
              valueUnit = ' kg/m²';
            } else if (typeStr.toLowerCase().contains('water')) {
              resIcon = Icons.local_drink_outlined;
              cleanTitle = 'Water Intake Estimate';
              valueUnit = ' Litres';
            } else if (typeStr.toLowerCase().contains('calorie')) {
              resIcon = Icons.local_fire_department_outlined;
              cleanTitle = 'Calorie Intake Target';
              valueUnit = ' kcal';
            } else if (typeStr.toLowerCase().contains('sleep')) {
              resIcon = Icons.bedtime_outlined;
              cleanTitle = 'Sleep Debt Tracker';
              valueUnit = ' Hours';
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline Node Graphic
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF01411C),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF01411C).withOpacity(0.2),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: Icon(resIcon, color: Colors.white, size: 18),
                      ),
                      Container(
                        width: 2.0,
                        height: 110.0, // Fixed height spacer representing timeline line
                        color: const Color(0xFF01411C).withOpacity(0.15),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14.0),

                  // Timeline Card Contents
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 1.5,
                      shadowColor: Colors.black.withOpacity(0.04),
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        side: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    cleanTitle,
                                    style: GoogleFonts.sourceSerif4(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                      color: const Color(0xFF01411C),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${valueNum.toStringAsFixed(1)}$valueUnit',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6.0),
                            Text(
                              adviceStr,
                              style: const TextStyle(fontSize: 12.0, color: Color(0xFF1A1A1A), height: 1.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Divider(height: 14.0, thickness: 0.5),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 12.0, color: Colors.grey),
                                const SizedBox(width: 4.0),
                                Expanded(
                                  child: Text(
                                    dateStr.length > 25 ? dateStr.substring(0, 20) : dateStr,
                                    style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
