// lib/views/registration_screen.dart
import 'package:flutter/material.dart';
import 'package:techcadd/api/api_service.dart';
import 'package:techcadd/utils/snackbar_utils.dart';
import 'package:techcadd/views/student_registration/create_registration_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late Future<Map<String, dynamic>> _optionsFuture;
  List<dynamic> _registrations = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _optionsFuture = ApiService.getRegistrationOptions();
    _loadRegistrationData();
  }

  Future<void> _loadRegistrationData() async {
    try {
      setState(() => _isLoading = true);
      print('🔍 Loading registration data from API...');

      final registrations = await ApiService.getStudentRegistrations();

      print('✅ Registrations loaded: ${registrations.length} items');

      setState(() {
        _registrations = registrations;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading registration data: $e');
      setState(() {
        _registrations = [];
        _isLoading = false;
      });

      CustomSnackBar.showError(context: context, message: 'Failed to load Data');
     
    }
  }

  Future<void> _refreshData() async {
    await _loadRegistrationData();
  }

  List<dynamic> get _searchedRegistrations {
    final searchTerm = _searchController.text.toLowerCase();
    if (searchTerm.isEmpty) {
      return _registrations;
    }

    return _registrations.where((registration) {
      final registrationMap = registration as Map<String, dynamic>;
      final name =
          registrationMap['student_name']?.toString().toLowerCase() ?? '';
      final regNumber =
          registrationMap['registration_number']?.toString().toLowerCase() ??
          '';
      final phone = registrationMap['phone_no']?.toString() ?? '';

      return name.contains(searchTerm) ||
          regNumber.contains(searchTerm) ||
          phone.contains(searchTerm);
    }).toList();
  }

  void _showCreateRegistrationDialog(Map<String, dynamic> options) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRegistrationScreen(
          registrationOptions: options,
          onRegistrationCreated: () {
            print('🔄 Refreshing registration list after creation...');
            _loadRegistrationData();
          },
        ),
      ),
    ).then((value) {
      print('🔄 Create screen closed, refreshing data...');
      _loadRegistrationData();
    });
  }

  Color _getCourseStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'not_started':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getCourseStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return 'Ongoing';
      case 'completed':
        return 'Completed';
      case 'not_started':
        return 'Not Started';
      default:
        return status;
    }
  }

  void _showRegistrationDetails(dynamic registration) {
    final registrationMap = registration as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF282C5C),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Student Photo/Icon
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.school,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Name and Registration Number
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getValue(registrationMap, 'student_name'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.badge,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getValue(
                                    registrationMap,
                                    'registration_number',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getValue(registrationMap, 'phone_no'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course and Branch
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailRow(
                              'Course',
                              _getValue(registrationMap, 'course_name'),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildDetailRow(
                              'Branch',
                              _getValue(registrationMap, 'branch_display'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Course Type and Duration
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailRow(
                              'Course Type',
                              _getValue(registrationMap, 'course_type_name'),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildDetailRow(
                              'Duration',
                              _getValue(
                                registrationMap,
                                'duration_months_display',
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Fees Information
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailRow(
                              'Total Fees',
                              '₹${_getValue(registrationMap, 'total_course_fee')}',
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildDetailRow(
                              'Paid Fees',
                              '₹${_getValue(registrationMap, 'paid_fee')}',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Balance and Days Remaining
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailRow(
                              'Balance',
                              '₹${_getValue(registrationMap, 'fee_balance')}',
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildDetailRow(
                              'Days Remaining',
                              '${_getValue(registrationMap, 'days_remaining_to_complete')} days',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Course Status
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _getCourseStatusColor(
                            _getValue(registrationMap, 'course_status'),
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getCourseStatusColor(
                              _getValue(registrationMap, 'course_status'),
                            ).withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 12,
                              color: _getCourseStatusColor(
                                _getValue(registrationMap, 'course_status'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Status: ${_getCourseStatusLabel(_getValue(registrationMap, 'course_status'))}',
                              style: TextStyle(
                                color: _getCourseStatusColor(
                                  _getValue(registrationMap, 'course_status'),
                                ),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Certificate Status
                      if (_getValue(registrationMap, 'certificate_issued') ==
                          'true')
                        Column(
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.verified,
                                    size: 20,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Certificate Issued',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Certificate No: ${_getValue(registrationMap, 'certificate_number')}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                      // Dates
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailRow(
                              'Joining Date',
                              _getValue(registrationMap, 'joining_date'),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildDetailRow(
                              'Completion Date',
                              _getValue(
                                    registrationMap,
                                    'course_completion_date',
                                  ) ??
                                  'Not Set',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF282C5C),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getValue(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return '-';
    return value.toString();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _optionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Student Registrations'),
              backgroundColor: const Color(0xFF282C5C),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Student Registrations'),
              backgroundColor: const Color(0xFF282C5C),
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final options = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Student Registrations',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            backgroundColor: const Color(0xFF282C5C),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          resizeToAvoidBottomInset: false,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreateRegistrationDialog(options),
            backgroundColor: const Color(0xFF282C5C),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          SizedBox(height: 80),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search Name/Reg No/Phone...',
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Color(0xFF282C5C),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              onChanged: (value) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Results Count
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Showing ${_searchedRegistrations.length} registrations',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // Registration List
                  if (_isLoading)
                    const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_searchedRegistrations.isEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            Icon(
                              Icons.school_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'No registrations found'
                                  : 'No registrations match your search',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final registration = _searchedRegistrations[index];
                        final registrationMap =
                            registration as Map<String, dynamic>;

                        final status =
                            registrationMap['course_status']?.toString() ??
                            'ongoing';

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _RegistrationListItem(
                            registration: registration,
                            statusColor: _getCourseStatusColor(status),
                            statusLabel: _getCourseStatusLabel(status),
                            onTap: () => _showRegistrationDetails(registration),
                          ),
                        );
                      }, childCount: _searchedRegistrations.length),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ), // Space for FAB
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Registration List Item Widget
class _RegistrationListItem extends StatelessWidget {
  final dynamic registration;
  final Color statusColor;
  final String statusLabel;
  final VoidCallback? onTap;

  const _RegistrationListItem({
    required this.registration,
    required this.statusColor,
    required this.statusLabel,
    this.onTap,
  });

  String _getValue(String key) {
    if (registration is! Map) return 'N/A';
    final map = registration as Map;
    final value = map[key];
    return value?.toString() ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final name = _getValue('student_name');
    final regNumber = _getValue('registration_number');
    final course = _getValue('course_name');
    final phone = _getValue('phone_no');
    final totalFees = _getValue('total_course_fee');
    final paidFees = _getValue('paid_fee');
    final balance = _getValue('fee_balance');
    final joiningDate = _getValue('joining_date');

    final avatarText = name != 'N/A' && name.isNotEmpty ? name[0] : '?';

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Leading
              CircleAvatar(
                backgroundColor: const Color(0xFF282C5C),
                child: Text(
                  avatarText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF282C5C),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('🎓 $course', style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      '📞 $phone | Reg: $regNumber',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '💰 Fees: ₹$paidFees/₹$totalFees (Balance: ₹$balance)',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '📅 Joined: $joiningDate',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Container(
                width: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
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
    );
  }
}
