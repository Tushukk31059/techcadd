import 'package:flutter/material.dart';

import 'package:techcadd/api/api_service.dart';
import 'package:techcadd/models/dropdown_models.dart';
import 'package:techcadd/utils/snackbar_utils.dart';
import 'package:techcadd/views/enquiry/create_enquiry_screen.dart';
import 'package:techcadd/views/enquiry/edit_enquiry_dialog.dart';

class EnquiryScreen extends StatefulWidget {
  const EnquiryScreen({super.key});

  @override
  State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  late Future<DropdownChoices> _dropdownFuture;
  List<dynamic> _enquiries = [];
  Map<String, dynamic> _enquiryStats = {};
  bool _isLoading = true;
  String _currentFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  String _formatText(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').replaceAll('_', ' ').trim();
  }
  // Add this method to _EnquiryScreenState class

  Color _getStatusColorForFilter(String status) {
    // For 'all' filter, use a default color
    if (status == 'all') {
      return const Color(0xFF282C5C); // Your primary color
    }

    // Use the same logic as _getStatusColor but for filter names
    final statusLower = status.toLowerCase().trim();

    if (statusLower == 'registration_done' ||
        statusLower.contains('registration')) {
      return const Color(0xFF282C5C);
    } else if (statusLower == 'visited' || statusLower.contains('visited')) {
      return const Color(0xFF3B82F6);
    } else if (statusLower == 'in_process' || statusLower.contains('process')) {
      return Colors.orange;
    } else if (statusLower == 'positive' || statusLower.contains('positive')) {
      return Colors.green;
    } else if (statusLower == 'negative' || statusLower.contains('negative')) {
      return Colors.grey;
    } else if (statusLower == 'follow_up_required' ||
        statusLower.contains('follow')) {
      return Colors.purple;
    } else if (statusLower == 'admission_done' ||
        statusLower.contains('admission')) {
      return Colors.teal;
    } else if (statusLower == 'course_completed' ||
        statusLower.contains('course')) {
      return Colors.blue;
    } else if (statusLower == 'dropped' || statusLower.contains('dropped')) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _dropdownFuture = ApiService.getEnquiryDropdownChoices();
    _loadEnquiryData();
  }

  Future<void> _loadEnquiryData() async {
    try {
      setState(() => _isLoading = true);

      print('🔍 Loading enquiry data from API...');

      // Load stats and enquiries from API
      final stats = await ApiService.getEnquiryStats();
      final enquiries = await ApiService.getEnquiries();

      print(
        '✅ Data loaded - Stats: ${stats.length}, Enquiries: ${enquiries.length}',
      );

      // Ensure we have proper data structure even if APIs fail
      setState(() {
        _enquiryStats = stats.isNotEmpty ? stats : <String, dynamic>{};
        _enquiries = enquiries;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading enquiry data: $e');
      setState(() {
        _enquiryStats = <String, dynamic>{};
        _enquiries = [];
        _isLoading = false;
      });

      if (!e.toString().contains('404')) {
        CustomSnackBar.showError(
          context: context,
          message: "Failed to load Data",
        );
      }
    }
  }

  String _getFilterCount(String filter) {
    // If stats is empty, return '0'
    if (_enquiryStats.isEmpty) return '0';

    // For 'all' filter, return total count from API
    if (filter == 'all') {
      final totalCount = _enquiryStats['total_students'] ?? _enquiries.length;
      return totalCount.toString();
    }

    // For specific status filters, count from the complete list
    final count = _enquiries.where((enquiry) {
      final enquiryMap = enquiry as Map<String, dynamic>;
      return enquiryMap['enquiry_status'] == filter;
    }).length;

    return count.toString();
  }

  Future<void> _refreshData() async {
    await _loadEnquiryData();
  }

  List<dynamic> get _filteredEnquiries {
    if (_currentFilter == 'all') {
      return _enquiries;
    }

    return _enquiries.where((enquiry) {
      final enquiryMap = enquiry as Map<String, dynamic>;
      return enquiryMap['enquiry_status'] == _currentFilter;
    }).toList();
  }

  List<dynamic> get _searchedEnquiries {
    final searchTerm = _searchController.text.toLowerCase();
    if (searchTerm.isEmpty) {
      return _filteredEnquiries;
    }

    return _filteredEnquiries.where((enquiry) {
      final enquiryMap = enquiry as Map<String, dynamic>;
      final name = enquiryMap['student_name']?.toString().toLowerCase() ?? '';
      final phone = enquiryMap['mobile']?.toString() ?? '';

      return name.contains(searchTerm) || phone.contains(searchTerm);
    }).toList();
  }

  void _showCreateEnquiryDialog(DropdownChoices dropdowns) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEnquiryScreen(
          dropdownChoices: dropdowns,
          onEnquiryCreated: () {
            // Force refresh when returning from create screen
            print('🔄 Refreshing enquiry list after creation...');
            _loadEnquiryData();
          },
        ),
      ),
    ).then((value) {
      // This runs when the create screen is popped
      print('🔄 Create screen closed, refreshing data...');
      _loadEnquiryData();
    });
  }

  Color _getStatusColor(String status) {
    // Convert to lowercase for consistent comparison
    final statusLower = status.toLowerCase().trim();

    print('🔍 _getStatusColor called with: "$status" -> "$statusLower"');

    // Direct string comparison - no complex logic
    if (statusLower == 'registration_done' ||
        statusLower.contains('registration')) {
      print('✅ Matched: registration_done -> Color(0xFF282C5C)');
      return const Color(0xFF282C5C);
    } else if (statusLower == 'visited' || statusLower.contains('visited')) {
      print('✅ Matched: visited -> Color(0xFF3B82F6)');
      return const Color(0xFF3B82F6);
    } else if (statusLower == 'in_process' || statusLower.contains('process')) {
      print('✅ Matched: in_process -> Colors.orange');
      return Colors.orange;
    } else if (statusLower == 'positive' || statusLower.contains('positive')) {
      print('✅ Matched: positive -> Colors.green');
      return Colors.green;
    } else if (statusLower == 'negative' || statusLower.contains('negative')) {
      print('✅ Matched: negative -> Colors.grey');
      return Colors.grey;
    } else if (statusLower == 'follow_up_required' ||
        statusLower.contains('follow')) {
      print('✅ Matched: follow_up_required -> Colors.purple');
      return Colors.purple;
    } else if (statusLower == 'admission_done' ||
        statusLower.contains('admission')) {
      print('✅ Matched: admission_done -> Colors.teal');
      return Colors.teal;
    } else if (statusLower == 'course_completed' ||
        statusLower.contains('course')) {
      print('✅ Matched: course_completed -> Colors.blue');
      return Colors.blue;
    } else if (statusLower == 'dropped' || statusLower.contains('dropped')) {
      print('✅ Matched: dropped -> Colors.red');
      return Colors.red;
    } else {
      print('❌ No match found, using default: Colors.grey');
      return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'in_process':
        return 'In Process';
      case 'visited':
        return 'Visited';
      case 'registration_done':
        return 'Registration Done';
      case 'positive':
        return 'Positive';
      case 'negative':
        return 'Negative';
      case 'follow_up_required':
        return 'Follow Up Required';
      case 'admission_done':
        return 'Admission Done';
      case 'course_completed':
        return 'Course Completed';
      case 'dropped':
        return 'Dropped';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DropdownChoices>(
      future: _dropdownFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Enquiries'),
              backgroundColor: const Color(0xFF282C5C),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Enquiries'),
              backgroundColor: const Color(0xFF282C5C),
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final dropdowns = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Enquiries',
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
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          resizeToAvoidBottomInset: false,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreateEnquiryDialog(dropdowns),
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
                  // Filter Buttons with Dynamic Counts
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        // Replace your filter buttons with this:
                        children: [
                          _FilterButton(
                            'All (${_getFilterCount('all')})',
                            _getStatusColorForFilter('all'),
                            isActive: _currentFilter == 'all',
                            onTap: () => setState(() => _currentFilter = 'all'),
                          ),
                          _FilterButton(
                            'Registration (${_getFilterCount('registration_done')})',
                            _getStatusColorForFilter('registration_done'),
                            isActive: _currentFilter == 'registration_done',
                            onTap: () => setState(
                              () => _currentFilter = 'registration_done',
                            ),
                          ),
                          _FilterButton(
                            'Visited (${_getFilterCount('visited')})',
                            _getStatusColorForFilter('visited'),
                            isActive: _currentFilter == 'visited',
                            onTap: () =>
                                setState(() => _currentFilter = 'visited'),
                          ),
                          _FilterButton(
                            'In Process (${_getFilterCount('in_process')})',
                            _getStatusColorForFilter('in_process'),
                            isActive: _currentFilter == 'in_process',
                            onTap: () =>
                                setState(() => _currentFilter = 'in_process'),
                          ),
                          _FilterButton(
                            'Positive (${_getFilterCount('positive')})',
                            _getStatusColorForFilter('positive'),
                            isActive: _currentFilter == 'positive',
                            onTap: () =>
                                setState(() => _currentFilter = 'positive'),
                          ),
                          _FilterButton(
                            'Negative (${_getFilterCount('negative')})',
                            _getStatusColorForFilter('negative'),
                            isActive: _currentFilter == 'negative',
                            onTap: () =>
                                setState(() => _currentFilter = 'negative'),
                          ),
                          _FilterButton(
                            'Follow Up (${_getFilterCount('follow_up_required')})',
                            _getStatusColorForFilter('follow_up_required'),
                            isActive: _currentFilter == 'follow_up_required',
                            onTap: () => setState(
                              () => _currentFilter = 'follow_up_required',
                            ),
                          ),
                          _FilterButton(
                            'Admission Done (${_getFilterCount('admission_done')})',
                            _getStatusColorForFilter('admission_done'),
                            isActive: _currentFilter == 'admission_done',
                            onTap: () => setState(
                              () => _currentFilter = 'admission_done',
                            ),
                          ),
                          _FilterButton(
                            'Dropped (${_getFilterCount('dropped')})',
                            _getStatusColorForFilter('dropped'),
                            isActive: _currentFilter == 'dropped',
                            onTap: () =>
                                setState(() => _currentFilter = 'dropped'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search and Action Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search Name/Phone...',
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
                        'Showing ${_searchedEnquiries.length} enquiries',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // Enquiry List
                  if (_isLoading)
                    const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_searchedEnquiries.isEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'No enquiries found'
                                  : 'No enquiries match your search',
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
                        final enquiry = _searchedEnquiries[index];

                        // Safe status access - works with both Map types
                        String status = 'in_process';
                        if (enquiry is Map) {
                          final statusValue = enquiry['enquiry_status'];
                          status = statusValue?.toString() ?? 'in_process';
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _EnquiryListItem(
                            enquiry: enquiry,
                            statusColor: _getStatusColor(status),
                            statusLabel: _getStatusLabel(status),
                            onEdit: () => _editEnquiry(enquiry, dropdowns),
                            onDelete: () {
                              // Safe ID extraction from dynamic map
                              dynamic id;
                              if (enquiry is Map) {
                                id = enquiry['id'];
                              }
                              if (id != null && id is int) {
                                _deleteEnquiry(id);
                              } else {
                                CustomSnackBar.showError(
                                  context: context,
                                  message: "Cannot delete. Invalid Enquiry ID!",
                                );
                              }
                            },
                            onTap: () => _showEnquiryDetails(enquiry),
                          ),
                        );
                      }, childCount: _searchedEnquiries.length),
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

  void _editEnquiry(dynamic enquiry, DropdownChoices dropdowns) {
    // Convert dynamic map to String keys map
    Map<String, dynamic> enquiryMap = {};

    if (enquiry is Map) {
      enquiry.forEach((key, value) {
        enquiryMap[key.toString()] = value;
      });
    }

    final name = enquiryMap['student_name']?.toString() ?? 'Unknown';
    final enquiryId = enquiryMap['id'];

    if (enquiryId == null) {
      CustomSnackBar.showError(
        context: context,
        message: "Cannot edit: Invalid enquiry ID",
      );

      return;
    }

    // Show edit dialog
    showDialog(
      context: context,
      builder: (context) => EditEnquiryDialog(
        enquiry: enquiryMap,
        dropdownChoices: dropdowns,
        onEnquiryUpdated: () {
          print('🔄 Enquiry updated, refreshing list...');
          _loadEnquiryData(); // Refresh the list
        },
      ),
    );
  }

  String capitalizeEachWord(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  void _showEnquiryDetails(dynamic enquiry) {
    Map<String, dynamic> enquiryMap = {};

    if (enquiry is Map) {
      enquiry.forEach((key, value) {
        enquiryMap[key.toString()] = value;
      });
    }

    print('=== ENQUIRY DATA RECEIVED ===');
    enquiryMap.forEach((key, value) {
      print('$key: $value');
    });

    // DEBUG: Detailed status check
    print('=== DETAILED STATUS DEBUG ===');
    print('Raw enquiry_status: ${enquiryMap['enquiry_status']}');
    print('Type: ${enquiryMap['enquiry_status'].runtimeType}');
    print('_getValue result: "${_getValue(enquiryMap, 'enquiry_status')}"');
    print(
      'Status label: "${_getStatusLabel(_getValue(enquiryMap, 'enquiry_status'))}"',
    );
    print(
      'Status color: ${_getStatusColor(_getValue(enquiryMap, 'enquiry_status'))}',
    );

    // Test all possible status values
    print('--- Testing all status values ---');
    final testStatuses = [
      'in_process',
      'visited',
      'registration_done',
      'positive',
      'negative',
      'follow_up_required',
      'admission_done',
      'course_completed',
      'dropped',
    ];
    for (final status in testStatuses) {
      print('$status -> ${_getStatusColor(status)}');
    }
    print('================================');
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
                      // Student Photo/Icon on LEFT
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Name and Phone Number
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getValue(enquiryMap, 'student_name'),
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
                                Icon(
                                  Icons.phone,
                                  size: 18,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getValue(enquiryMap, 'mobile'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (_getValue(enquiryMap, 'email') != '-' &&
                                _getValue(enquiryMap, 'email').isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    Icons.email,
                                    size: 16,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _getValue(enquiryMap, 'email'),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                      overflow: TextOverflow.ellipsis,
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
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailRow(
                              'Course',
                              capitalizeEachWord(
                                _getValue(enquiryMap, 'trade'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildDetailRow(
                              'Centre',
                              capitalizeEachWord(
                                _getValue(enquiryMap, 'centre'),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Status with colored badge
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            _getValue(enquiryMap, 'enquiry_status'),
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(
                              _getValue(enquiryMap, 'enquiry_status'),
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
                              color: _getStatusColor(
                                _getValue(enquiryMap, 'enquiry_status'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Status: ${_getStatusLabel(capitalizeEachWord(_getValue(enquiryMap, 'enquiry_status')))}',
                              style: TextStyle(
                                color: _getStatusColor(
                                  _getValue(enquiryMap, 'enquiry_status'),
                                ),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Enquiry Taken By
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF282C5C).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF282C5C).withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 20,
                              color: const Color(0xFF282C5C).withOpacity(0.7),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Enquiry Taken By',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF282C5C),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    capitalizeEachWord(
                                      _getValue(
                                        enquiryMap,
                                        'enquiry_taken_by_name',
                                      ),
                                    ),
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

                      // Dates
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailRow(
                              'Enquiry Date',
                              _getValue(enquiryMap, 'enquiry_date'),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildDetailRow(
                              'Next Follow Up',
                              _getValue(enquiryMap, 'next_follow_up_date'),
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

  // Updated Helper method for detail rows with better styling
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

  // FIXED: Helper method to safely get values - Now replaces "N/A" with "-"
  String _getValue(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return '-';

    final stringValue = value.toString().trim();

    // Replace "N/A", "null", or empty strings with "-"
    if (stringValue.isEmpty || stringValue == 'null' || stringValue == 'N/A') {
      return '-';
    }

    // Format specific fields for better display
    final formattedValue = _formatText(stringValue);

    // Additional formatting for specific fields
    if (key == 'student_name' ||
        key == 'qualification' ||
        key == 'work_college') {
      return _capitalizeWords(formattedValue);
    } else if (key == 'address' || key == 'remark') {
      return _capitalizeFirstLetter(formattedValue);
    }

    return formattedValue;
  }

  void _deleteEnquiry(int enquiryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Enquiry'),
        content: const Text('Are you sure you want to delete this enquiry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete enquiry API call
              CustomSnackBar.showSuccess(
                context: context,
                message: "Enquiry Deleted Successfully",
              );

              _refreshData();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Filter Button Widget with onTap
class _FilterButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterButton(
    this.label,
    this.color, {
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? color : color.withOpacity(0.3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: isActive ? 2 : 0,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.white.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}

class _EnquiryListItem extends StatelessWidget {
  final dynamic enquiry;
  final Color statusColor;
  final String statusLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const _EnquiryListItem({
    required this.enquiry,
    required this.statusColor,
    required this.statusLabel,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });
  String _formatText(String text) {
    // Remove extra spaces and fix common formatting issues
    return text
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        ) // Replace multiple spaces with single space
        .replaceAll('_', '') // Remove underscores
        .trim(); // Remove leading/trailing spaces
  }

  String _getValue(String key) {
    if (enquiry is! Map) return '-';

    final map = enquiry as Map;
    Map<String, dynamic> enquiryMap = {};

    // Convert to String keys map
    map.forEach((key, value) {
      enquiryMap[key.toString()] = value;
    });

    // First try to get display field (e.g., trade_display, centre_display)
    final displayKey = '${key}_display';
    if (enquiryMap.containsKey(displayKey)) {
      final displayValue = enquiryMap[displayKey];
      if (displayValue != null && displayValue.toString().trim().isNotEmpty) {
        return displayValue.toString().trim();
      }
    }

    // Fallback to regular field
    final value = enquiryMap[key];
    if (value == null) return '-';

    final stringValue = value.toString().trim();

    // Replace "N/A", "null", or empty strings with "-"
    if (stringValue.isEmpty || stringValue == 'null' || stringValue == 'N/A') {
      return '-';
    }

    return _formatText(stringValue);
  }

  String capitalizeEachWord(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    // Safe property access with null checks
    final name = _getValue('student_name');
    final phone = _getValue('mobile');
    final course = _getValue('trade');
    final fees = _getValue('course_fee_offer');
    final source = _getValue('enquiry_source');

    final createdAt = _getValue('created_at');
    final takenBy = _getValue('enquiry_taken_by_name');
    final email = _getValue('email');

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
                      capitalizeEachWord(name),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF282C5C),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📞 $phone | Course: $course',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),

                    if (email != 'N/A')
                      Text(
                        'Email: $email',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    if (takenBy != 'N/A')
                      Text(
                        'Taken by: ${capitalizeEachWord(takenBy)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 60, // Minimum width
                  maxWidth: 120, // Maximum width (so it doesn't get too big)
                ),
                child: Container(
                  width: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
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
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              color: const Color(0xFF3B82F6),
                              onPressed: onEdit,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: IconButton(
                              icon: const Icon(Icons.delete, size: 18),
                              color: Colors.red,
                              onPressed: onDelete,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateEnquiryDialog extends StatefulWidget {
  final DropdownChoices dropdownChoices;
  final VoidCallback onEnquiryCreated;

  const CreateEnquiryDialog({
    super.key,
    required this.dropdownChoices,
    required this.onEnquiryCreated,
  });

  @override
  State<CreateEnquiryDialog> createState() => _CreateEnquiryDialogState();
}

class _CreateEnquiryDialogState extends State<CreateEnquiryDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _qualificationController =
      TextEditingController();
  final TextEditingController _workCollegeController = TextEditingController();
  final TextEditingController _takenByController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _batchTimeController = TextEditingController();
  final TextEditingController _courseFeeController = TextEditingController();
  final TextEditingController _courseInterestedController =
      TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _nextFollowUpController = TextEditingController();

  String? _selectedCentre;
  String? _selectedTrade;
  String? _selectedSource;
  String? _selectedStatus;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Enquiry',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF282C5C),
                ),
              ),
              const SizedBox(height: 16),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter name' : null,
              ),
              const SizedBox(height: 12),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter mobile number' : null,
              ),
              const SizedBox(height: 12),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter email' : null,
              ),
              const SizedBox(height: 12),

              // Date of Birth Field
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth (YYYY-MM-DD) *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter date of birth' : null,
              ),
              const SizedBox(height: 12),

              // Qualification Field
              TextFormField(
                controller: _qualificationController,
                decoration: const InputDecoration(
                  labelText: 'Qualification *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter qualification' : null,
              ),
              const SizedBox(height: 12),

              // Work/College Field
              TextFormField(
                controller: _workCollegeController,
                decoration: const InputDecoration(
                  labelText: 'Work/College',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Address Field
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter address' : null,
              ),
              const SizedBox(height: 12),

              // Centre Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCentre,
                decoration: const InputDecoration(
                  labelText: 'Centre *',
                  border: OutlineInputBorder(),
                ),
                items: widget.dropdownChoices.centreChoices.map((choice) {
                  return DropdownMenuItem(
                    value: choice.value,
                    child: Text(choice.label),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCentre = value),
                validator: (value) =>
                    value == null ? 'Please select centre' : null,
              ),
              const SizedBox(height: 12),

              // Trade Dropdown
              DropdownButtonFormField<String>(
                value: _selectedTrade,
                decoration: const InputDecoration(
                  labelText: 'Course/Trade *',
                  border: OutlineInputBorder(),
                ),
                items: widget.dropdownChoices.tradeChoices.map((choice) {
                  return DropdownMenuItem(
                    value: choice.value,
                    child: Text(choice.label),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedTrade = value),
                validator: (value) =>
                    value == null ? 'Please select course' : null,
              ),
              const SizedBox(height: 12),

              // Source Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSource,
                decoration: const InputDecoration(
                  labelText: 'Enquiry Source *',
                  border: OutlineInputBorder(),
                ),
                items: widget.dropdownChoices.enquirySourceChoices.map((
                  choice,
                ) {
                  return DropdownMenuItem(
                    value: choice.value,
                    child: Text(choice.label),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedSource = value),
                validator: (value) =>
                    value == null ? 'Please select source' : null,
              ),
              const SizedBox(height: 12),

              // Status Dropdown
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status *',
                  border: OutlineInputBorder(),
                ),
                items: widget.dropdownChoices.enquiryStatusChoices.map((
                  choice,
                ) {
                  return DropdownMenuItem(
                    value: choice.value,
                    child: Text(choice.label),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedStatus = value),
                validator: (value) =>
                    value == null ? 'Please select status' : null,
              ),
              const SizedBox(height: 12),

              // Batch Time Field
              TextFormField(
                controller: _batchTimeController,
                decoration: const InputDecoration(
                  labelText: 'Batch Time',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Course Fee Offer Field
              TextFormField(
                controller: _courseFeeController,
                decoration: const InputDecoration(
                  labelText: 'Course Fee Offer',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Course Interested Field
              TextFormField(
                controller: _courseInterestedController,
                decoration: const InputDecoration(
                  labelText: 'Course Interested',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Remark Field
              TextFormField(
                controller: _remarkController,
                decoration: const InputDecoration(
                  labelText: 'Remark',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Next Follow Up Date Field
              TextFormField(
                controller: _nextFollowUpController,
                decoration: const InputDecoration(
                  labelText: 'Next Follow Up Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _saveEnquiry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF282C5C),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Save Enquiry'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveEnquiry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final enquiryData = {
        'student_name': _nameController.text,
        'date_of_birth': _dobController.text,
        'qualification': _qualificationController.text,
        'work_college': _workCollegeController.text.isEmpty
            ? null
            : _workCollegeController.text,
        'mobile': _phoneController.text,
        'email': _emailController.text,
        'enquiry_taken_by_name': _takenByController.text,
        'address': _addressController.text,
        'centre': _selectedCentre,
        'batch_time': _batchTimeController.text.isEmpty
            ? null
            : _batchTimeController.text,
        'course_fee_offer': _courseFeeController.text.isEmpty
            ? null
            : double.tryParse(_courseFeeController.text),
        'course_interested': _courseInterestedController.text.isEmpty
            ? null
            : _courseInterestedController.text,
        'trade': _selectedTrade,
        'enquiry_source': _selectedSource,
        'enquiry_status': _selectedStatus,
        'remark': _remarkController.text.isEmpty
            ? null
            : _remarkController.text,
        'next_follow_up_date': _nextFollowUpController.text.isEmpty
            ? null
            : _nextFollowUpController.text,
      };

      print('📤 Sending enquiry data: $enquiryData');

      await ApiService.createEnquiry(enquiryData);

      CustomSnackBar.showSuccess(
        context: context,
        message: "Enquiry Created Successfully",
      );

      widget.onEnquiryCreated();
      Navigator.pop(context);
    } catch (e) {
      CustomSnackBar.showError(
        context: context,
        message: "Failed to Create Enquiry",
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _qualificationController.dispose();
    _workCollegeController.dispose();
    _dobController.dispose();
    _batchTimeController.dispose();
    _courseFeeController.dispose();
    _courseInterestedController.dispose();
    _remarkController.dispose();
    _nextFollowUpController.dispose();
    super.dispose();
  }
}
