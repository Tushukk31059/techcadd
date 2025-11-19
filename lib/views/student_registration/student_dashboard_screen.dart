// lib/views/student/student_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:techcadd/api/api_service.dart';
import 'package:techcadd/main.dart';
import 'package:techcadd/utils/snackbar_utils.dart';
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
  Map<String, dynamic>? _courseProgressData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Get student data from storage
      final prefs = await SharedPreferences.getInstance();
      final studentDataString = prefs.getString('student_data');
      if (studentDataString != null) {
        _studentData = json.decode(studentDataString);
      }

      // Load dashboard data from API
      final dashboardResponse = await ApiService.getStudentDashboard();
      
      // Load course progress data
      final courseResponse = await ApiService.getStudentCourseDetail();

      if (dashboardResponse['dashboard'] != null && courseResponse['course'] != null) {
        setState(() {
          _dashboardData = dashboardResponse['dashboard'];
          _courseProgressData = courseResponse['course'];
        });
      } else {
        throw Exception('No dashboard data received');
      }
    } catch (e) {
      print('❌ Dashboard load error: $e');
      setState(() {
        _errorMessage = e.toString();
      });
      CustomSnackBar.showError(
        context: context,
        message: 'Failed to load dashboard',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Update the course progress section to use real data
  Widget _buildCourseProgress() {
    final courseProgress = _courseProgressData?['course_progress'] ?? {};
    final totalLessons = courseProgress['total_lessons'] ?? 0;
    final completedLessons = courseProgress['completed_lessons'] ?? 0;
    final progressPercentage = courseProgress['progress_percentage'] ?? 0.0;

    final courseStatus = _dashboardData?['course_status'] ?? 'ongoing';
    final daysRemaining = _dashboardData?['days_remaining_to_complete'] ?? 0;
    final joiningDate = _dashboardData?['joining_date'] ?? '';
    final courseCompletionDate = _dashboardData?['course_completion_date'] ?? '';

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

          // Progress Bar with real data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Learning Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                ),
              ),
              Text(
                '${progressPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressPercentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          SizedBox(height: 8),
          Text(
            '$completedLessons of $totalLessons lessons completed',
            style: TextStyle(fontSize: 12, color: kTextSecondary),
          ),
          SizedBox(height: 16),

          // Course timeline
          if (joiningDate.isNotEmpty)
            _StudentProgressItem(
              label: 'Joining Date',
              value: _formatDate(joiningDate),
              color: kTextSecondary,
            ),
          SizedBox(height: 8),
          if (courseCompletionDate.isNotEmpty)
            _StudentProgressItem(
              label: 'Completion Date',
              value: _formatDate(courseCompletionDate),
              color: kTextSecondary,
            ),
          SizedBox(height: 8),
          _StudentProgressItem(
            label: 'Days Remaining',
            value: daysRemaining > 0 ? '$daysRemaining days' : 'Course Completed',
            color: daysRemaining > 0 ? kAccentBlue : kAccentGreen,
          ),
        ],
      ),
    );
  }

  // Update quick stats to use real course data
 Widget _buildQuickStats() {
  final courseProgress = _courseProgressData?['course_progress'] ?? {};
  final modules = _courseProgressData?['modules'] ?? [];
  
  final totalLessons = courseProgress['total_lessons'] ?? 0;
  final completedLessons = courseProgress['completed_lessons'] ?? 0;
  final totalModules = modules.length;
  
  // Fix: Properly calculate completed modules
  final completedModules = modules.where((module) {
    final moduleMap = module as Map<String, dynamic>;
    final moduleCompleted = moduleMap['completed_lessons'] ?? 0;
    final moduleTotal = moduleMap['total_lessons'] ?? 0;
    return moduleCompleted == moduleTotal && moduleTotal > 0;
  }).length;

  // Fix: Properly calculate pending assignments with type safety
  final pendingAssignments = modules.fold<int>(0, (int sum, dynamic module) {
    final moduleMap = module as Map<String, dynamic>;
    final lessons = moduleMap['lessons'] ?? [];
    final lessonsList = lessons as List<dynamic>;
    
    final assignmentCount = lessonsList.where((lesson) {
      final lessonMap = lesson as Map<String, dynamic>;
      return lessonMap['lesson_type'] == 'assignment' && 
             !(lessonMap['is_completed'] ?? false);
    }).length;
    
    return sum + assignmentCount;
  });

  // Calculate upcoming classes (you can enhance this with real schedule data)
  final upcomingClasses = 0; // Placeholder - integrate with your schedule API

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
            title: 'Total Modules',
            value: totalModules.toString(),
            subtitle: 'Modules',
            color: kAccentBlue,
            icon: Icons.library_books_rounded,
          ),
          _StudentStatCard(
            title: 'Completed',
            value: completedLessons.toString(),
            subtitle: 'Lessons',
            color: kAccentGreen,
            icon: Icons.check_circle_rounded,
          ),
          _StudentStatCard(
            title: 'Upcoming',
            value: upcomingClasses.toString(),
            subtitle: 'Classes',
            color: kAccentAmber,
            icon: Icons.schedule_rounded,
          ),
          _StudentStatCard(
            title: 'Pending',
            value: pendingAssignments.toString(),
            subtitle: 'Assignments',
            color: kAccentRed,
            icon: Icons.assignment_rounded,
          ),
        ],
      ),
    ],
  );
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
            icon: Icon(Icons.refresh, size: 24),
            onPressed: _loadDashboardData,
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
          : _errorMessage.isNotEmpty
          ? _buildErrorState()
          : _buildDashboardContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Failed to load dashboard',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDashboardData,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
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

          // Payment Section
          _buildPaymentSection(),
          SizedBox(height: 24),

          // Course Content Section
          _buildCourseContentSection(),
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
                  'Welcome $studentName !',
                  style: TextStyle(
                    fontSize: 22,
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

  
  Widget _buildPaymentSection() {
    // Convert string values to numbers safely
    final totalFees =
        double.tryParse(
          _dashboardData?['total_course_fee']?.toString() ?? '0',
        ) ??
        0.0;
    final paidFees =
        double.tryParse(_dashboardData?['paid_fee']?.toString() ?? '0') ?? 0.0;
    final balance =
        double.tryParse(_dashboardData?['fee_balance']?.toString() ?? '0') ??
        0.0;
    final paymentPercentage =
        double.tryParse(
          _dashboardData?['payment_percentage']?.toString() ?? '0',
        ) ??
        0.0;

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
          Text(
            'Fee & Payments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
          SizedBox(height: 16),

          // Payment Progress
          if (paymentPercentage > 0)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payment Progress',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kTextSecondary,
                      ),
                    ),
                    Text(
                      '${paymentPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: paymentPercentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    paymentPercentage >= 100 ? kAccentGreen : kPrimaryColor,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                SizedBox(height: 16),
              ],
            ),

          // Fee Breakdown
          _StudentProgressItem(
            label: 'Total Course Fee',
            value: '₹${totalFees.toStringAsFixed(0)}',
            color: kTextSecondary,
          ),
          SizedBox(height: 8),

          _StudentProgressItem(
            label: 'Paid Fees',
            value: '₹${paidFees.toStringAsFixed(0)}',
            color: kAccentGreen,
          ),
          SizedBox(height: 8),

          _StudentProgressItem(
            label: 'Balance Amount',
            value: '₹${balance.toStringAsFixed(0)}',
            color: balance > 0 ? kAccentRed : kAccentGreen,
          ),
          SizedBox(height: 12),

          if (balance > 0)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kAccentAmber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kAccentAmber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: kAccentAmber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please contact administration for fee payment',
                      style: TextStyle(fontSize: 12, color: kAccentAmber),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCourseContentSection() {
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
          Text(
            'Course Content',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Access your course materials, lessons, and track your learning progress',
            style: TextStyle(color: kTextSecondary, fontSize: 14),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.library_books, color: Colors.white),
              label: Text(
                'View Course Content',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentCourseScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
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
    try {
      await ApiService.studentLogout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
      CustomSnackBar.showSuccess(
        context: context,
        message: 'Logged out successfully',
      );
    } catch (e) {
      CustomSnackBar.showError(context: context, message: 'Logout failed: $e');
    }
  }
}

// ============ STUDENT-SPECIFIC WIDGETS ============

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
