import 'package:flutter/material.dart';

// --- COLOR AND CONSTANTS ---
// Custom Brand Primary Color (0xFF282C5C)
const Color primaryColor = Color(0xFF282C5C);
const Color backgroundColor = Color(0xFFF7F9FC); // Light background
const Color secondaryColor = Color(0xFF10B981); // Emerald - Success
const Color warningColor = Color(0xFFF59E0B); // Amber - Warning
const Color dangerColor = Color(0xFFEF4444); // Red - Critical/Due
const Color infoColor = Color(0xFF3B82F6); // Blue - Info
const Color codingColor = Color(0xFF06B6D4); // Cyan - Coding
const Color grayBorderColor = Color(0xFF6B7280); // Gray 500

class StudentDashboardApp extends StatelessWidget {
  final String name;
  final String course;

  const StudentDashboardApp({
    super.key,
    required this.name,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechEdu Student Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily:
            'Inter', // Assuming Inter font is available or a sensible default is used
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: const MaterialColor(0xFF282C5C, {
            50: Color(0xFFE5E6E8),
            100: Color(0xFFBFC2C7),
            200: Color(0xFF949AA1),
            300: Color(0xFF69727B),
            400: Color(0xFF495460),
            500: Color(0xFF282C5C), // Primary Color
            600: Color(0xFF232854),
            700: Color(0xFF1C2048),
            800: Color(0xFF161A3C),
            900: Color(0xFF0D102A),
          }),
        ).copyWith(secondary: infoColor),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(16),
          ),
        ),

        // CardTheme(
        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        //   elevation: 4,
        // )
      ),
      home: StudentDashboardScreen(name: name,course: course,),
    );
  }
}

class StudentDashboardScreen extends StatelessWidget {
  final String name;
  final String course;
  const StudentDashboardScreen({
    super.key,
    required this.name,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        // Hide the default drawer icon on desktop
        automaticallyImplyLeading: MediaQuery.of(context).size.width < 1024,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: MediaQuery.of(context).size.width < 1024
          ?  SidebarWidget(name: name,course: course,)
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1024) {
            // Desktop Layout (Fixed Sidebar + Main Content)
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SidebarWidget(isDesktop: true, name: name, course: course),
                Expanded(
                  child: MainContentArea(name: name, course: course),
                ),
              ],
            );
          } else {
            // Mobile/Tablet Layout (Drawer Sidebar + Main Content)
            return MainContentArea(name: name,course: course,);
          }
        },
      ),
    );
  }
}

// --- SIDEBAR WIDGET (DRAWER) ---
class SidebarWidget extends StatelessWidget {
  final bool isDesktop;
  final String name;
  final String course;

  const SidebarWidget({
    super.key,
    this.isDesktop = false,
    required this.name,
    required this.course,
  });

  Widget _buildNavLink(IconData icon, String title, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: isActive ? primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            // Handle navigation logic
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isDesktop ? 256 : 300,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: isDesktop
            ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]
            : null,
      ),
      child: Column(
        children: [
          // Logo/App Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Techcadd',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Student Portal',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.grey),

          // Student Profile Widget
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: infoColor,
                  child: const Text(
                    'AS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Course: $course',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),

          // Navigation Links
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildNavLink(
                    Icons.dashboard_rounded,
                    'Dashboard',
                    isActive: true,
                  ),
                  _buildNavLink(
                    Icons.calendar_today_rounded,
                    'Attendance Record',
                  ),
                  _buildNavLink(
                    Icons.assignment_rounded,
                    'Projects & Assignments',
                  ),
                  _buildNavLink(
                    Icons.account_balance_wallet_rounded,
                    'Fees & Payments',
                  ),
                ],
              ),
            ),
          ),

          // Logout Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey)),
            ),
            child: _buildNavLink(
              Icons.logout_rounded,
              'Logout',
              isActive: false,
            ),
          ),
        ],
      ),
    );
  }
}

// --- MAIN CONTENT AREA ---
class MainContentArea extends StatelessWidget {
  final String name;
  final String course;

  const MainContentArea({
    super.key,
    required this.name,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Welcome,$name ',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          // Text(
          //   'Quick summary of your course.',
          //   style: TextStyle(color: Colors.grey.shade500),
          // ),
          const SizedBox(height: 24),

          // Top Row: Attendance and Fee Alert
          LayoutBuilder(
            builder: (context, constraints) {
              // Adjust layout for small vs large screens
              if (constraints.maxWidth > 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(flex: 2, child: AttendanceCard()),
                    const SizedBox(width: 24),
                    Expanded(flex: 1, child: FeeAlertCard()),
                  ],
                );
              } else {
                return Column(
                  children: [
                    const AttendanceCard(),
                    const SizedBox(height: 24),
                    FeeAlertCard(),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 32),

          // Middle Row: Topics, Progress, Announcements
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 1000) {
                return const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: TodayTopicCard()),
                    SizedBox(width: 24),
                    Expanded(child: CourseProgressCard()),
                    SizedBox(width: 24),
                    Expanded(child: AnnouncementsCard()),
                  ],
                );
              } else {
                return Column(
                  children: const [
                    TodayTopicCard(),
                    SizedBox(height: 24),
                    CourseProgressCard(),
                    SizedBox(height: 24),
                    AnnouncementsCard(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// --- 1. ATTENDANCE CARD ---
class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: primaryColor, width: 4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Attendance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Text(
                    //   'Required: 75% | Safe Zone: > 80%',
                    //   style: TextStyle(
                    //     fontSize: 13,
                    //     color: Colors.grey.shade500,
                    //   ),
                    // ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'MERN Stack Course',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Progress Circle (72%)
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 60,
                        width: 60,
                        child: CircularProgressIndicator(
                          value: 0.72, // 72%
                          strokeWidth: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            warningColor,
                          ),
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: '72',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: warningColor,
                          ),
                          children: const [
                            TextSpan(text: '%', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                // Details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      secondaryColor,
                      'Classes Attended:',
                      '108/150',
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(dangerColor, 'Classes Missed:', '42'),
                    const SizedBox(height: 16),
                    Text(
                      'Status: Warning!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: warningColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: Text(
                'View Subject-wise Breakdown →',
                style: TextStyle(color: primaryColor, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(Color color, String label, String value) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// --- 2. FEE ALERT CARD ---
class FeeAlertCard extends StatelessWidget {
  FeeAlertCard({super.key});

  final TextStyle labelStyle = TextStyle(
    fontSize: 13,
    color: Colors.grey.shade500,
  );
  final TextStyle valueStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: dangerColor,
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: dangerColor, width: 4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fee and Payment Alerts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Next Installment Alert
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: dangerColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: dangerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Next Installment', style: labelStyle),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹ 15,000', style: valueStyle),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: dangerColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Due in 4 Days!',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Total Dues
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Dues', style: labelStyle),
                  const SizedBox(height: 4),
                  Text(
                    '₹ 30,000',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextButton(
              onPressed: () {},
              child: const Text(
                'Pay Now →',
                style: TextStyle(color: dangerColor, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 3. TODAY'S TOPIC CARD ---
class TodayTopicCard extends StatelessWidget {
  const TodayTopicCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: codingColor, width: 4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Focus Topic",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Next Class
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: codingColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.code_rounded, size: 16, color: codingColor),
                      const SizedBox(width: 4),
                      Text(
                        'MERN Stack | Module 4',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Express.js: Middleware and Routes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Time: 11:00 AM - 1:00 PM | Instructor: Mr. A. Singh',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Upcoming Lab Session
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.computer_rounded,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Next Session',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Hands-on Lab: REST API Design',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Time: 2:00 PM - 4:00 PM ',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 4. COURSE PROGRESS CARD ---
class CourseProgressCard extends StatelessWidget {
  const CourseProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: infoColor, width: 4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Course Module Progress",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Module Progress
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: infoColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MERN Stack Development (8 Modules)',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Module 4/8',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: infoColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.50, // 50%
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(infoColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Progress: 50% Completed',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Next Major Project
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Major Project',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'E-commerce API Backend',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Due Date: 15 Nov 2024',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextButton(
              onPressed: () {},
              child: const Text(
                'View All Projects →',
                style: TextStyle(color: infoColor, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 5. ANNOUNCEMENTS CARD ---
class AnnouncementsCard extends StatelessWidget {
  const AnnouncementsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: warningColor, width: 4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Important Announcements",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250, // Fixed height for scrolling
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildAnnouncement(
                    isUrgent: true,
                    title: 'Project Submission Portal Closing',
                    body:
                        "The 'Authentication Module' project will not be accepted after 11:59 PM tonight.",
                  ),
                  _buildAnnouncement(
                    isUrgent: false,
                    title: 'New AI Course Batch Starts',
                    body:
                        "Students who registered should report to Lab 101 tomorrow at 9 AM.",
                  ),
                  _buildAnnouncement(
                    isUrgent: false,
                    title: 'Class Timing Change',
                    body:
                        "Python evening class will be held at 2 PM today (one-time change).",
                  ),
                  _buildAnnouncement(
                    isUrgent: false,
                    title: 'Holiday Notice',
                    body:
                        "The institute will be closed next Monday for a public holiday.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All Notifications →',
                style: TextStyle(color: warningColor, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncement({
    required bool isUrgent,
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: isUrgent ? dangerColor : primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isUrgent ? dangerColor : primaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }
}
