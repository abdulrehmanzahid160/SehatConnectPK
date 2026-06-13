import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_header.dart';

// Import all pages
import 'bmi_page.dart';
import 'water_page.dart';
import 'calorie_page.dart';
import 'sleep_page.dart';
import 'medicine_page.dart';
import 'report_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final int initialTab;
  const HomePage({super.key, this.initialTab = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  // Helper list of screens to show in Bottom Navigation
  List<Widget> _getPages() {
    return [
      _buildDashboardBody(),      // Tab 0: Home Dashboard
      _buildCalculatorsBody(),    // Tab 1: Calculators List
      const MedicinePage(),       // Tab 2: Medicines Reminder Page
      const ReportPage(),         // Tab 3: My Report Page
      const ProfilePage(),        // Tab 4: Profile Page
    ];
  }

  // Tapping a grid item in Tab 0 can open pages directly or switch tabs
  void _navigateToPage(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    ).then((_) {
      // Re-trigger load if necessary when coming back
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0), // Off-white background
      appBar: _currentIndex == 0
          ? const AppHeader(title: 'SehatConnect')
          : null, // Sub-pages will define their own app bars or utilize headers
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: const Color(0xFF01411C).withOpacity(0.15),
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF01411C), // Pakistan Green
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate_outlined),
              activeIcon: Icon(Icons.calculate),
              label: 'Calculators',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medication_outlined),
              activeIcon: Icon(Icons.medication),
              label: 'Medicines',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Report',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // ─── Tab 0: Main Dashboard Body ────────────────────────────
  Widget _buildDashboardBody() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 720 ? 3 : 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Institutional Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            decoration: BoxDecoration(
              color: const Color(0xFF01411C),
              borderRadius: BorderRadius.circular(6.0),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF01411C).withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WELCOME TO SEHATCONNECT',
                  style: GoogleFonts.sourceSerif4(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Official Health Assistance & Analytics Portal of Pakistan. Calculate your metrics, manage daily medicine plans, and compile local reports.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Official Healthcare Services',
            style: GoogleFonts.sourceSerif4(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),

          // Grid View of Cards
          GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: screenWidth > 720 ? 1.4 : 1.15,
            children: [
              _buildServiceCard(
                label: 'BMI Calculator',
                icon: Icons.monitor_weight_outlined,
                color: const Color(0xFF01411C),
                onTap: () => _navigateToPage(const BmiPage()),
              ),
              _buildServiceCard(
                label: 'Water Intake',
                icon: Icons.local_drink_outlined,
                color: const Color(0xFF01411C),
                onTap: () => _navigateToPage(const WaterPage()),
              ),
              _buildServiceCard(
                label: 'Calorie Calculator',
                icon: Icons.local_fire_department_outlined,
                color: const Color(0xFF01411C),
                onTap: () => _navigateToPage(const CaloriePage()),
              ),
              _buildServiceCard(
                label: 'Sleep Tracker',
                icon: Icons.bedtime_outlined,
                color: const Color(0xFF01411C),
                onTap: () => _navigateToPage(const SleepPage()),
              ),
              _buildServiceCard(
                label: 'Medicine Reminders',
                icon: Icons.notification_important_outlined,
                color: const Color(0xFF01411C),
                onTap: () {
                  setState(() {
                    _currentIndex = 2; // Route to Tab index 2
                  });
                },
              ),
              _buildServiceCard(
                label: 'My Health Report',
                icon: Icons.assignment_outlined,
                color: const Color(0xFF01411C),
                onTap: () {
                  setState(() {
                    _currentIndex = 3; // Route to Tab index 3
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Tab 1: Calculators List Body ──────────────────────────
  Widget _buildCalculatorsBody() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: const AppHeader(title: 'Health Calculators'),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildCalculatorListItem(
            title: 'Body Mass Index (BMI)',
            subtitle: 'Calculate your body fat based on weight and height.',
            icon: Icons.monitor_weight_outlined,
            onTap: () => _navigateToPage(const BmiPage()),
          ),
          const SizedBox(height: 12),
          _buildCalculatorListItem(
            title: 'Water Intake Estimator',
            subtitle: 'Determine daily hydration needs based on activity levels.',
            icon: Icons.local_drink_outlined,
            onTap: () => _navigateToPage(const WaterPage()),
          ),
          const SizedBox(height: 12),
          _buildCalculatorListItem(
            title: 'Calorie Requirement Calculator',
            subtitle: 'Estimate total daily calorie requirements for weight targets.',
            icon: Icons.local_fire_department_outlined,
            onTap: () => _navigateToPage(const CaloriePage()),
          ),
          const SizedBox(height: 12),
          _buildCalculatorListItem(
            title: 'Sleep Debt & Health Tracker',
            subtitle: 'Check if you have an active sleep debt and view sleeping suggestions.',
            icon: Icons.bedtime_outlined,
            onTap: () => _navigateToPage(const SleepPage()),
          ),
        ],
      ),
    );
  }

  // ─── Grid Card builder ─────────────────────────────────────
  Widget _buildServiceCard({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2.0,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: color.withOpacity(0.12),
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.sourceSerif4(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Calculator List Item builder ──────────────────────────
  Widget _buildCalculatorListItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
        side: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: const Color(0xFF01411C).withOpacity(0.08),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: const Icon(
            Icons.calculate_outlined,
            color: Color(0xFF01411C),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.sourceSerif4(
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF01411C),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14.0, color: Color(0xFF01411C)),
        onTap: onTap,
      ),
    );
  }
}
