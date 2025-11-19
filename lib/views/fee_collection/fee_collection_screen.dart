// lib/views/fee_collection/fee_collection_screen.dart
import 'package:flutter/material.dart';
import 'package:techcadd/api/api_service.dart';
import 'package:techcadd/utils/snackbar_utils.dart';
import 'package:techcadd/views/fee_collection/add_fee_dialog.dart';

class FeeCollectionScreen extends StatefulWidget {
  const FeeCollectionScreen({super.key});

  @override
  State<FeeCollectionScreen> createState() => _FeeCollectionScreenState();
}

class _FeeCollectionScreenState extends State<FeeCollectionScreen> {
  List<dynamic> _pendingFeeStudents = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPendingFeeStudents();
  }

  Future<void> _loadPendingFeeStudents() async {
    try {
      setState(() => _isLoading = true);
      print('💰 Loading students with pending fees...');

      final students = await ApiService.getStudentsWithPendingFees();

      print('✅ Pending fee students loaded: ${students.length} items');

      setState(() {
        _pendingFeeStudents = students;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading pending fee students: $e');
      setState(() {
        _pendingFeeStudents = [];
        _isLoading = false;
      });

     CustomSnackBar.showError(context: context, message: "Failed to load data");
           
    }
  }

  Future<void> _refreshData() async {
    await _loadPendingFeeStudents();
  }

  List<dynamic> get _searchedStudents {
    final searchTerm = _searchController.text.toLowerCase();
    if (searchTerm.isEmpty) {
      return _pendingFeeStudents;
    }

    return _pendingFeeStudents.where((student) {
      final studentMap = student as Map<String, dynamic>;
      final name = studentMap['student_name']?.toString().toLowerCase() ?? '';
      final regNumber = studentMap['registration_number']?.toString().toLowerCase() ?? '';
      final phone = studentMap['phone_no']?.toString() ?? '';

      return name.contains(searchTerm) ||
          regNumber.contains(searchTerm) ||
          phone.contains(searchTerm);
    }).toList();
  }

  void _showAddFeeDialog(dynamic student) {
    final studentMap = student as Map<String, dynamic>;
    final registrationNumber = studentMap['registration_number']?.toString() ?? '';
    final studentName = studentMap['student_name']?.toString() ?? '';
    final totalFee = double.tryParse(studentMap['total_course_fee']?.toString() ?? '0') ?? 0;
    final paidFee = double.tryParse(studentMap['paid_fee']?.toString() ?? '0') ?? 0;
    final pendingFee = double.tryParse(studentMap['fee_balance']?.toString() ?? '0') ?? 0;

    showDialog(
      context: context,
      builder: (context) => AddFeeDialog(
        registrationNumber: registrationNumber,
        studentName: studentName,
        totalFee: totalFee,
        paidFee: paidFee,
        pendingFee: pendingFee,
        onFeeAdded: () {
          _refreshData(); // Refresh the list
          CustomSnackBar.showSuccess(context: context, message: "Fee added Successfully");
           
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fee Collection',
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
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search students with pending fees...',
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ),

              // Results Count
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '${_searchedStudents.length} students with pending fees',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Students List
              if (_isLoading)
                const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_searchedStudents.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        Icon(
                          Icons.credit_card_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No students with pending fees'
                              : 'No students match your search',
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
                    final student = _searchedStudents[index];
                    final studentMap = student as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _PendingFeeStudentItem(
                        student: student,
                        onTap: () => _showAddFeeDialog(student),
                      ),
                    );
                  }, childCount: _searchedStudents.length),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingFeeStudentItem extends StatelessWidget {
  final dynamic student;
  final VoidCallback onTap;

  const _PendingFeeStudentItem({
    required this.student,
    required this.onTap,
  });

  String _getValue(String key) {
    if (student is! Map) return 'N/A';
    final map = student as Map;
    final value = map[key];
    return value?.toString() ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final name = _getValue('student_name');
    final regNumber = _getValue('registration_number');
    final course = _getValue('course_name');
    final totalFee = double.tryParse(_getValue('total_course_fee')) ?? 0;
    final paidFee = double.tryParse(_getValue('paid_fee')) ?? 0;
    final pendingFee = double.tryParse(_getValue('fee_balance')) ?? 0;
    final paymentPercentage = totalFee > 0 ? (paidFee / totalFee * 100) : 0;

    final avatarText = name != 'N/A' && name.isNotEmpty ? name[0] : '?';

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
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
              const SizedBox(width: 16),

              // Student Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF282C5C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🎓 $course',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📋 $regNumber',
                      style: const TextStyle(fontSize: 12),
                    ),
                    
                    // Fee Progress
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Fees Paid: ₹${paidFee.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Pending: ₹${pendingFee.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: paymentPercentage / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${paymentPercentage.toStringAsFixed(1)}% Paid (Total: ₹${totalFee.toStringAsFixed(0)})',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Add Fee Button
              const SizedBox(width: 8),
              IconButton(
                onPressed: onTap,
                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.green,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}