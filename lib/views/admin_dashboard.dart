import 'package:flutter/material.dart';


import 'package:techcadd/views/staff/staff_list_screen.dart';
import 'certificate_screen.dart';
import 'enquiry/enquiry_screen.dart';

// --- 1. Enhanced Color Scheme with Primary Color ---
const Color kPrimaryColor = Color(0xFF282C5C); // Your primary color
const Color kPrimaryLight = Color(0xFF3A3F7A);
const Color kPrimaryDark = Color(0xFF1A1D40);
const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kCardColor = Colors.white;
const Color kAccentGreen = Color(0xFF10B981);
const Color kAccentRed = Color(0xFFEF4444);
const Color kAccentAmber = Color(0xFFF59E0B);
const Color kAccentBlue = Color(0xFF3B82F6);
const Color kAccentPurple = Color(0xFF8B5CF6);
const Color kAccentPink = Color(0xFFEC4899);
const Color kTextPrimary = Color(0xFF1F2937);
const Color kTextSecondary = Color(0xFF6B7280);
const Color kTextLight = Color(0xFF9CA3AF);

class AdminMobileConsole extends StatefulWidget {
  const AdminMobileConsole({super.key});

  @override
  State<AdminMobileConsole> createState() => _AdminMobileConsoleState();
}

class _AdminMobileConsoleState extends State<AdminMobileConsole> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const EnquiryScreen(),
    const StaffListScreen(),
    // const CourseListScreen(),
    const CertificatesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          'TechCADD Admin',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, size: 24),
            onPressed: () {},
          ),
          SizedBox(width: 8),
        ],
      ),
      drawer: AdminDrawer(
        onSelectScreen: _onItemTapped,
        currentIndex: _selectedIndex,
      ),
      body: _screens[_selectedIndex],
      // bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -2),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.dashboard_rounded, 'Dashboard', 0),
              _buildNavItem(Icons.help_center_outlined, 'Enquiry', 1),
              _buildNavItem(
                Icons.workspace_premium_outlined,
                'Certificates',
                2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // decoration: BoxDecoration(
        //   color: isSelected
        //       ? kPrimaryColor.withOpacity(0.1)
        //       : Colors.transparent,
        //   borderRadius: BorderRadius.circular(16),
        // ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? kPrimaryColor : kTextLight,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? kPrimaryColor : kTextLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. Enhanced Drawer ---
class AdminDrawer extends StatelessWidget {
  final Function(int) onSelectScreen;
  final int currentIndex;

  const AdminDrawer({
    super.key,
    required this.onSelectScreen,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: kBackgroundColor,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 60,
                bottom: 24,
                left: 24,
                right: 24,
              ),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'TechCADD Management',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Items
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDrawerItem(
                      Icons.dashboard_rounded,
                      'Dashboard',
                      0,
                      context: context,
                    ),
                    _buildDrawerItem(
                      Icons.help_center_outlined,
                      'Enquiry',
                      1,
                      context: context,
                    ),
                   
                    _buildDrawerItem(
                      Icons.people_outline,
                      'Staff Management',
                      2, 
                      context: context,
                    ),
                    _buildDrawerItem(
                      Icons.person_add_alt_1_rounded,
                      'Student Registration',
                      -1,
                      context: context,
                    ),
                    _buildDrawerItem(
                      Icons.calendar_today_rounded,
                      'Student Attendance',
                      -1,
                      context: context,
                    ),
                  
                    _buildDrawerItem(
                      Icons.person_remove_rounded,
                      'Discontinue Student',
                      -1,
                      context: context,
                    ),
                    _buildDrawerItem(
                      Icons.receipt_long_rounded,
                      'Fee Receipt',
                      -1,
                      context: context,
                    ),
                    _buildDrawerItem(
                      Icons.verified_user_rounded,
                      'Certificate',
                      3,
                      context: context,
                    ),
                  ],
                ),
              ),
            ),

            // Logout
            Container(
              padding: const EdgeInsets.all(16),
              child: _buildDrawerItem(
                Icons.logout_rounded,
                'Logout',
                -1,
                overrideColor: kAccentRed,
                context: context,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    int screenIndex, {
    Color? overrideColor,
    required BuildContext context,
  }) {
    final isActive = screenIndex != -1 && currentIndex == screenIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? kPrimaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: overrideColor ?? (isActive ? Colors.white : kTextSecondary),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: overrideColor ?? (isActive ? Colors.white : kTextSecondary),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: () {
          if (screenIndex >= 0 && screenIndex < 4) {
            onSelectScreen(screenIndex);
          }
          Navigator.pop(context);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// --- 3. Enhanced Dashboard Screen ---
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Welcome Card
          _buildWelcomeCard(),
          SizedBox(height: 24),

          // Quick Stats Grid
          _buildStatsGrid(),
          SizedBox(height: 24),

          // Enquiry Overview
          _buildEnquirySection(),
          SizedBox(height: 24),

          // Course Breakdown
          _buildCourseSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Admin!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Here\'s your daily performance overview',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.analytics_rounded, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kTextPrimary,
          ),
        ),
        SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          children: [
            _StatCard(
              title: 'Daily Registration',
              value: '2',
              subtitle: 'Today',
              color: kAccentGreen,
              icon: Icons.person_add_alt_1_rounded,
            ),
            _StatCard(
              title: 'Daily Collection',
              value: '₹8,170',
              subtitle: 'Today',
              color: kAccentAmber,
              icon: Icons.currency_rupee_rounded,
            ),
            _StatCard(
              title: 'Daily Attendance',
              value: '92%',
              subtitle: 'Avg Rate',
              color: kAccentBlue,
              icon: Icons.calendar_month_rounded,
            ),
            _StatCard(
              title: 'Daily Expense',
              value: '₹0',
              subtitle: 'Today',
              color: kAccentRed,
              icon: Icons.money_off_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnquirySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Enquiry Record',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Today',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _EnquiryChip(count: 5, label: 'Random Calls', color: kAccentRed),
            _EnquiryChip(count: 6, label: 'Visited', color: kAccentBlue),
            _EnquiryChip(count: 10, label: 'Register', color: kAccentGreen),
            _EnquiryChip(
              count: 2,
              label: 'Daily Enquiries',
              color: kAccentPurple,
            ),
            _EnquiryChip(
              count: 2,
              label: 'Daily Registration',
              color: kAccentAmber,
            ),
            _EnquiryChip(count: 0, label: 'Daily Expense', color: kAccentPink),
          ],
        ),
      ],
    );
  }

  Widget _buildCourseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Enquiries',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kTextPrimary,
          ),
        ),
        SizedBox(height: 16),
        Column(
          children: [
            _CourseItem(label: 'Computer/IT', count: 5, color: kAccentRed),
            _CourseItem(label: 'CSE/IT', count: 0, color: kAccentBlue),
            _CourseItem(
              label: 'Graphic Designing',
              count: 2,
              color: kAccentGreen,
            ),
            _CourseItem(
              label: 'Digital Marketing',
              count: 0,
              color: kAccentAmber,
            ),
          ],
        ),
      ],
    );
  }
}

// Enhanced Stat Card
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Enquiry Chip
class _EnquiryChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _EnquiryChip({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Course Item
class _CourseItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _CourseItem({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
