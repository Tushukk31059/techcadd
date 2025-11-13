// lib/techcadd/screens/staff_dashboard.dart
import 'package:flutter/material.dart';

import 'package:techcadd/api/api_service.dart';
import 'package:techcadd/models/dropdown_models.dart';
import 'package:techcadd/models/staff_model.dart';
import 'package:techcadd/views/certificate_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:techcadd/views/enquiry/create_enquiry_screen.dart';
import 'package:techcadd/views/enquiry/enquiry_screen.dart';
import 'package:techcadd/views/fee_collection/fee_collection_screen.dart';
import 'package:techcadd/views/student_registration/registration_screen.dart';

class StaffDashboardScreen extends StatefulWidget {
  final StaffProfile staff;

  const StaffDashboardScreen({super.key, required this.staff});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  late StaffProfile _staff;
  bool _isLoading = false;
  int _selectedIndex = 0;

  late List<Widget> _screens;
  final GlobalKey<_StaffHomeScreenState> _homeScreenKey =
      GlobalKey<_StaffHomeScreenState>();

  @override
  void initState() {
    super.initState();
    _staff = widget.staff;

    // Initialize screens based on role
    _screens = _getScreensForRole();

    ApiService.setStaffAutoLogout(true);
  }

  List<Widget> _getScreensForRole() {
    final role = _staff.role.toLowerCase();

    if (role.contains('counselor')) {
      return [
        StaffHomeScreen(onRefresh: _refreshDashboard),
        const EnquiryScreen(),
        const CertificatesScreen(),
      ];
    } else {
      return [
        StaffHomeScreen(onRefresh: _refreshDashboard),
        _buildComingSoonScreen('My Classes'),
        const CertificatesScreen(),
        _buildComingSoonScreen('Assignments'),
      ];
    }
  }

  // Add this method:
  void _refreshDashboard() {
    // This will be called from child screens
    setState(() {});
  }

  // Helper method to show a placeholder screen
  Widget _buildComingSoonScreen(String featureName) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build_circle_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '$featureName\nComing Soon!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performAutoLogoutOnDispose() async {
    try {
      // Only clear local data, no API call needed for auto logout
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('staff_data');
      await prefs.remove('staff_access_token');
      await prefs.remove('staff_refresh_token');
      print('✅ Staff auto-logout on screen dispose');
    } catch (e) {
      print('❌ Auto logout error: $e');
    }
  }

  @override
  void dispose() {
    _performAutoLogoutOnDispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    // Refresh dashboard data when switching back to dashboard (index 0)
    if (index == 0 && _selectedIndex != 0) {
      _homeScreenKey.currentState?._loadDashboardData();
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          '${_staff.role[0].toUpperCase() + _staff.role.substring(1).toLowerCase()} Dashboard', // Shows role in title
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF282C5C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: StaffDrawer(
        staff: _staff,
        currentIndex: _selectedIndex,
        onSelectScreen: _onItemTapped,
        // Removed onLogout parameter
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _screens[_selectedIndex],
    );
  }
}
// Staff Drawer - Updated with complete counselor options
// Staff Drawer - Updated without logout button
class StaffDrawer extends StatelessWidget {
  final StaffProfile staff;
  final int currentIndex;
  final Function(int) onSelectScreen;

  const StaffDrawer({
    super.key,
    required this.staff,
    required this.currentIndex,
    required this.onSelectScreen,
  });

  @override
  Widget build(BuildContext context) {
    final isCounselor = staff.role.toLowerCase().contains('counselor');

    return Drawer(
      child: Container(
        color: const Color(0xFFF8F9FA),
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
              decoration: const BoxDecoration(
                color: Color(0xFF282C5C),
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
                      _getRoleIcon(staff.role),
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    staff.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${staff.role[0].toUpperCase() + staff.role.substring(1).toLowerCase()} • ${staff.department[0].toUpperCase() + staff.department.substring(1).toLowerCase()}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Items - Role Specific
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: _getDrawerItems(isCounselor, context),
                ),
              ),
            ),

            // Removed Logout Button Section
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    final roleLower = role.toLowerCase();
    if (roleLower.contains('counselor')) {
      return Icons.school_rounded;
    } else if (roleLower.contains('trainer')) {
      return Icons.person_rounded;
    } else if (roleLower.contains('manager')) {
      return Icons.manage_accounts_rounded;
    } else {
      return Icons.person_rounded;
    }
  }

  List<Widget> _getDrawerItems(bool isCounselor, BuildContext context) {
    if (isCounselor) {
      return [
        _buildDrawerItem(context, Icons.dashboard_rounded, 'Dashboard', 0),

        _buildDrawerItem(
          context,
          Icons.help_center_outlined,
          'Enquiries',
          -1,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EnquiryScreen()),
          ),
        ),
        _buildDrawerItem(
          context,
          Icons.people_outlined,
          'Manage Students',
          -1,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegistrationScreen()),
          ),
        ),

        _buildDrawerItem(
          context,
          Icons.payment_rounded,
          'Fee Collection',
          -1,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FeeCollectionScreen(),
            ),
          ),
        ),
        _buildDrawerItem(
          context,
          Icons.account_balance_wallet,
          'Fee Reports',
          -1,
        ),

        _buildDrawerItem(
          context,
          Icons.workspace_premium_outlined,
          'Certificates',
          2,
        ),
        _buildDrawerItem(context, Icons.analytics_rounded, 'Reports', -1),
      ];
    } else {
      // Default items for other roles (Trainer, Manager)
      return [
        _buildDrawerItem(context, Icons.dashboard_rounded, 'Dashboard', 0),

        _buildDrawerItem(context, Icons.school_rounded, 'My Classes', -1),
        _buildDrawerItem(context, Icons.assignment_rounded, 'Assignments', -1),
      ];
    }
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    int screenIndex, {
    Color? overrideColor,
    VoidCallback? onTap,
  }) {
    final isActive = screenIndex != -1 && currentIndex == screenIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF282C5C) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              overrideColor ??
              (isActive ? Colors.white : const Color(0xFF6B7280)),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color:
                overrideColor ??
                (isActive ? Colors.white : const Color(0xFF374151)),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        onTap:
            onTap ??
            () {
              if (screenIndex >= 0) {
                onSelectScreen(screenIndex);
              } else {
                // Show coming soon message for non-implemented features
                _showComingSoon(context, title);
              }
              Navigator.pop(context);
            },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}// Staff Home Screen
class StaffHomeScreen extends StatefulWidget {
  final VoidCallback? onRefresh;
  const StaffHomeScreen({super.key, required this.onRefresh});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> with WidgetsBindingObserver {
  Map<String, dynamic> _dashboardStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This gets called when the app returns from background or when widget becomes visible
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadDashboardData();
    }
  }

  // Make this method public so parent can call it
  Future<void> _loadDashboardData() async {
    try {
      if (mounted) {
        setState(() => _isLoading = true);
      }

      // Load dashboard statistics
      final stats = await ApiService.getStaffDashboardStats();

      if (mounted) {
        setState(() {
          _dashboardStats = stats;
          _isLoading = false;
        });
      }

      print('✅ Dashboard stats loaded: $_dashboardStats');
    } catch (e) {
      print('❌ Error loading dashboard data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Add pull-to-refresh functionality
  Future<void> _handleRefresh() async {
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Quick Stats
            _buildQuickStats(),
            const SizedBox(height: 24),

            // Quick Actions Grid
            _buildQuickActions(context),
            const SizedBox(height: 24),

            // Recent Activities
            _buildRecentActivities(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: [
        _StatCard(
          title: 'Total Enquiries',
          value: _dashboardStats['total_enquiries']?.toString() ?? '0',
          subtitle: 'All Time',
          color: Colors.blue,
          icon: Icons.help_center_rounded,
        ),
        _StatCard(
          title: 'New Registrations',
          value: _dashboardStats['new_registrations']?.toString() ?? '0',
          subtitle: 'This Month',
          color: Colors.green,
          icon: Icons.person_add_rounded,
        ),
        _StatCard(
          title: 'Pending Fees',
          value: '₹${_dashboardStats['pending_fees']?.toString() ?? '0'}',
          subtitle: 'Total Due',
          color: Colors.orange,
          icon: Icons.currency_rupee_rounded,
        ),
        _StatCard(
          title: 'Certificates',
          value: _dashboardStats['certificates_generated']?.toString() ?? '0',
          subtitle: 'Generated',
          color: Colors.purple,
          icon: Icons.verified_user_rounded,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF282C5C),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.9,
          children: [
            _QuickActionCard(
              icon: Icons.add_circle_outline_rounded,
              title: 'Create\nEnquiry',
              color: Colors.blue,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FutureBuilder<DropdownChoices>(
                      future: ApiService.getEnquiryDropdownChoices(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Scaffold(
                            appBar: AppBar(
                              title: const Text('Create Enquiry'),
                              backgroundColor: const Color(0xFF282C5C),
                            ),
                            body: const Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasError) {
                          return Scaffold(
                            appBar: AppBar(
                              title: const Text('Create Enquiry'),
                              backgroundColor: const Color(0xFF282C5C),
                            ),
                            body: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error, size: 64, color: Colors.red),
                                  const SizedBox(height: 16),
                                  Text('Error: ${snapshot.error}'),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Go Back'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return CreateEnquiryScreen(
                          dropdownChoices: snapshot.data!,
                          onEnquiryCreated: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Enquiry created successfully!')),
                            );
                            _loadDashboardData();
                          },
                        );
                      },
                    ),
                  ),
                );
                _loadDashboardData();
              },
            ),
            _QuickActionCard(
              icon: Icons.person_add_alt_1_rounded,
              title: 'Student\nRegistration',
              color: Colors.green,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistrationScreen(),
                  ),
                );
                _loadDashboardData();
              },
            ),
            _QuickActionCard(
              icon: Icons.payment_rounded,
              title: 'Add\nPayment',
              color: Colors.orange,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FeeCollectionScreen(),
                  ),
                );
                _loadDashboardData();
              },
            ),
            _QuickActionCard(
              icon: Icons.verified_user_rounded,
              title: 'Generate\nCertificate',
              color: Colors.purple,
              onTap: () => _showComingSoon(context, 'Generate Certificate'),
            ),
            _QuickActionCard(
              icon: Icons.list_alt_rounded,
              title: 'Enquiry\nList',
              color: Colors.red,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EnquiryScreen()),
                );
                _loadDashboardData();
              },
            ),
            _QuickActionCard(
              icon: Icons.calendar_today_rounded,
              title: 'Take\nAttendance',
              color: Colors.teal,
              onTap: () => _showComingSoon(context, 'Take Attendance'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF282C5C),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Column(
            children: [
              _ActivityItem(
                icon: Icons.person_add_rounded,
                title: 'New Student Registered',
                subtitle: 'Rahul Sharma - Web Development',
                time: '2 hours ago',
                color: Colors.green,
              ),
              _ActivityItem(
                icon: Icons.payment_rounded,
                title: 'Fee Payment Received',
                subtitle: '₹15,000 - Priya Singh',
                time: '4 hours ago',
                color: Colors.blue,
              ),
              _ActivityItem(
                icon: Icons.help_center_rounded,
                title: 'New Enquiry Created',
                subtitle: 'Graphic Designing Course',
                time: '6 hours ago',
                color: Colors.orange,
              ),
              _ActivityItem(
                icon: Icons.verified_user_rounded,
                title: 'Certificate Generated',
                subtitle: 'Amit Kumar - Python Programming',
                time: '1 day ago',
                color: Colors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature - Coming Soon!')),
    );
  }
}// Stat Card Widget
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
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
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Quick Action Card Widget
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Activity Item Widget
class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
      ),
      trailing: Text(
        time,
        style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
      ),
    );
  }
}
