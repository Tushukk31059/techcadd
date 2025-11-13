// lib/views/student/student_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:techcadd/api/api_service.dart';
import 'package:techcadd/main.dart';
import 'package:techcadd/views/fee_collection/payment_history_screen.dart';
import 'package:techcadd/views/student_registration/student_course_screen.dart';

// --- Color Scheme (Same as Admin) ---
const Color kPrimaryColor = Color(0xFF282C5C);
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

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  Map<String, dynamic>? _dashboardData;
  Map<String, dynamic>? _studentData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);

      // Get student data from storage
      final prefs = await SharedPreferences.getInstance();
      final studentDataString = prefs.getString('student_data');
      if (studentDataString != null) {
        _studentData = json.decode(studentDataString);
      }

      // Load dashboard data
      final dashboardResponse = await ApiService.getStudentDashboard();
      setState(() {
        _dashboardData = dashboardResponse['dashboard'];
      });
    } catch (e) {
      print('❌ Dashboard load error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load dashboard: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Student Portal',
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
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : _buildDashboardContent(),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Welcome Card
          _buildWelcomeCard(),
          SizedBox(height: 24),

          // Quick Stats
          _buildQuickStats(),
          SizedBox(height: 24),

          // Course Progress
          _buildCourseProgress(),
          SizedBox(height: 24),

          _buildPaymentSection(),

          // Upcoming/Latest Lessons
          _buildLessonsSection(),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    final totalFees = _dashboardData?['total_course_fee'] ?? 0;
    final paidFees = _dashboardData?['paid_fee'] ?? 0;
    final balance = _dashboardData?['fee_balance'] ?? 0;

    return Container(
      padding: EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fee & Payments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => PaymentHistoryScreen(),
                //     ),
                //   );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  'View History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Quick Payment Summary
          _StudentProgressItem(
            label: 'Total Fees',
            value: '₹$totalFees',
            color: kTextSecondary,
          ),
          SizedBox(height: 8),

          _StudentProgressItem(
            label: 'Paid Fees',
            value: '₹$paidFees',
            color: kAccentGreen,
          ),
          SizedBox(height: 8),

          _StudentProgressItem(
            label: 'Balance',
            value: '₹$balance',
            color: balance > 0 ? kAccentRed : kAccentGreen,
          ),
          SizedBox(height: 12),

          if (balance > 0)
            Text(
              'Please contact administration for fee payment',
              style: TextStyle(
                fontSize: 12,
                color: kAccentAmber,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final studentName = _studentData?['student_name'] ?? 'Student';
    final courseName = _studentData?['course_name'] ?? 'Course';
    final regNumber = _studentData?['registration_number'] ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
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
                  'Welcome $studentName!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  courseName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'ID: $regNumber',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
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
            child: Icon(Icons.school_rounded, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final quickStats = _dashboardData?['quick_stats'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Overview',
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
            _StudentStatCard(
              title: 'Total Courses',
              value: quickStats['total_courses']?.toString() ?? '1',
              subtitle: 'Enrolled',
              color: kAccentBlue,
              icon: Icons.library_books_rounded,
            ),
            _StudentStatCard(
              title: 'Completed',
              value: quickStats['completed_lessons']?.toString() ?? '0',
              subtitle: 'Lessons',
              color: kAccentGreen,
              icon: Icons.check_circle_rounded,
            ),
            _StudentStatCard(
              title: 'Upcoming',
              value: quickStats['upcoming_classes']?.toString() ?? '0',
              subtitle: 'Classes',
              color: kAccentAmber,
              icon: Icons.schedule_rounded,
            ),
            _StudentStatCard(
              title: 'Pending',
              value: quickStats['pending_assignments']?.toString() ?? '0',
              subtitle: 'Assignments',
              color: kAccentRed,
              icon: Icons.assignment_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCourseProgress() {
    final courseStatus = _dashboardData?['course_status'] ?? 'ongoing';
    final daysRemaining = _dashboardData?['days_remaining_to_complete'] ?? 0;
    final paymentPercentage = _dashboardData?['payment_percentage'] ?? 0.0;
    final totalFees = _dashboardData?['total_course_fee'] ?? 0;
    final paidFees = _dashboardData?['paid_fee'] ?? 0;
    final balance = _dashboardData?['fee_balance'] ?? 0;

    return Container(
      padding: EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Course Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(courseStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(courseStatus),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(courseStatus),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Days Remaining
          _StudentProgressItem(
            label: 'Days Remaining',
            value: daysRemaining.toString(),
            color: kAccentBlue,
          ),
          SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to course screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentCourseScreen(),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Course screen coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'View Course Content',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Continue Learning',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // View all lessons
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('All lessons screen coming soon!')),
                );
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
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
          child: Column(
            children: [
              _StudentLessonItem(
                title: 'Introduction to Programming',
                progress: 75,
                duration: '30 min',
                isCompleted: false,
              ),
              Divider(height: 24),
              _StudentLessonItem(
                title: 'HTML Basics',
                progress: 100,
                duration: '45 min',
                isCompleted: true,
              ),
              Divider(height: 24),
              _StudentLessonItem(
                title: 'CSS Fundamentals',
                progress: 25,
                duration: '60 min',
                isCompleted: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return kAccentGreen;
      case 'ongoing':
        return kAccentBlue;
      case 'not_started':
        return kAccentAmber;
      default:
        return kAccentBlue;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'ongoing':
        return 'In Progress';
      case 'not_started':
        return 'Not Started';
      default:
        return status;
    }
  }

  Future<void> _logout() async {
    await ApiService.studentLogout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }
}

// ============ STUDENT-SPECIFIC WIDGETS ============

// Stat Card for Student Dashboard
class _StudentStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _StudentStatCard({
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

// Progress Item Widget for Student Dashboard
class _StudentProgressItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StudentProgressItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: kTextSecondary,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// Lesson Item Widget for Student Dashboard
class _StudentLessonItem extends StatelessWidget {
  final String title;
  final int progress;
  final String duration;
  final bool isCompleted;

  const _StudentLessonItem({
    required this.title,
    required this.progress,
    required this.duration,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? kAccentGreen.withOpacity(0.1)
                : kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isCompleted ? Icons.check_rounded : Icons.play_arrow_rounded,
            color: isCompleted ? kAccentGreen : kPrimaryColor,
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                duration,
                style: TextStyle(fontSize: 12, color: kTextSecondary),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isCompleted
                ? kAccentGreen.withOpacity(0.1)
                : kAccentBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$progress%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isCompleted ? kAccentGreen : kAccentBlue,
            ),
          ),
        ),
      ],
    );
  }
}
