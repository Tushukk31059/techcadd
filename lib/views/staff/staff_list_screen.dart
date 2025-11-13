// lib/screens/staff_list_screen.dart
import 'package:flutter/material.dart';
import 'package:techcadd/api/api_service.dart';
import 'package:techcadd/models/staff_model.dart';
import 'package:techcadd/views/staff/create_staff_screen.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  List<StaffProfile> _staffList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadStaffList();
  }

  Future<void> _loadStaffList() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await ApiService.getStaffList();

      setState(() {
        _staffList = response.staffList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showStaffDetails(StaffProfile staff) {
    showDialog(
      context: context,
      builder: (context) =>
          StaffDetailDialog(staff: staff, onUpdate: _loadStaffList),
    );
  }

  void _confirmDeleteStaff(StaffProfile staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Staff Account'),
        content: Text(
          'Are you sure you want to delete ${staff.fullName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteStaff(staff.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStaff(int staffId) async {
    try {
      await ApiService.deleteStaffAccount(staffId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Staff account deleted successfully')),
      );
      _loadStaffList();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete staff: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Staff Management'),
      //   backgroundColor: const Color(0xFF282C5C),
      //   foregroundColor: Colors.white,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.refresh),
      //       onPressed: _loadStaffList,
      //     ),
      //   ],
      // ),
      // In StaffListScreen's build method
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateStaffScreen()),
          ).then((_) => _loadStaffList()); // Refresh list after returning
        },
        backgroundColor: const Color(0xFF282C5C),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? _buildErrorState()
          : _buildStaffList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Failed to load staff list',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadStaffList, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildStaffList() {
    return Column(
      children: [
        // Summary Card
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(
                  count: _staffList.length,
                  label: 'Total Staff',
                  icon: Icons.people,
                ),
                _SummaryItem(
                  count: _staffList.where((s) => s.isActive).length,
                  label: 'Active',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                _SummaryItem(
                  count: _staffList.where((s) => !s.isActive).length,
                  label: 'Inactive',
                  icon: Icons.cancel,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),

        // Staff List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _staffList.length,
            itemBuilder: (context, index) {
              final staff = _staffList[index];
              return _StaffCard(
                staff: staff,
                onTap: () => _showStaffDetails(staff),
                onDelete: () => _confirmDeleteStaff(staff),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.count,
    required this.label,
    required this.icon,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF282C5C),
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

class _StaffCard extends StatelessWidget {
  final StaffProfile staff;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _StaffCard({
    required this.staff,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF282C5C).withOpacity(0.1),
          child: Text(
            staff.firstName[0] + staff.lastName[0],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF282C5C),
            ),
          ),
        ),
        title: Text(
          staff.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(staff.role),
            Text(
              staff.department,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: staff.statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                staff.status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: staff.statusColor,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete Account'),
                ),
              ],
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

// Add this class to the same file
class StaffDetailDialog extends StatefulWidget {
  final StaffProfile staff;
  final VoidCallback onUpdate;

  const StaffDetailDialog({
    super.key,
    required this.staff,
    required this.onUpdate,
  });

  @override
  State<StaffDetailDialog> createState() => _StaffDetailDialogState();
}

class _StaffDetailDialogState extends State<StaffDetailDialog> {
  bool _isLoading = false;

  Future<void> _toggleStaffStatus() async {
    try {
      setState(() => _isLoading = true);

      await ApiService.updateStaffStatus(
        widget.staff.id,
        !widget.staff.isActive,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Staff status updated successfully')),
      );

      widget.onUpdate();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final staff = widget.staff;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF282C5C).withOpacity(0.1),
                  child: Text(
                    staff.firstName[0] + staff.lastName[0],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF282C5C),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        staff.role,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: staff.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          staff.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: staff.statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _DetailRow(icon: Icons.email, label: 'Email', value: staff.email),
            _DetailRow(icon: Icons.phone, label: 'Phone', value: staff.phone),
            _DetailRow(
              icon: Icons.business,
              label: 'Department',
              value: staff.department,
            ),
            _DetailRow(
              icon: Icons.location_on,
              label: 'Address',
              value: staff.address,
            ),

            if (staff.dateJoined != null)
              _DetailRow(
                icon: Icons.calendar_today,
                label: 'Date Joined',
                value:
                    '${staff.dateJoined!.day}/${staff.dateJoined!.month}/${staff.dateJoined!.year}',
              ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _toggleStaffStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: staff.isActive
                            ? Colors.orange
                            : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        staff.isActive
                            ? 'Deactivate Account'
                            : 'Activate Account',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
