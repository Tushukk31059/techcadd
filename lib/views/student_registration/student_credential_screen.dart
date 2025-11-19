// // lib/screens/student_credentials_screen.dart
// import 'package:flutter/material.dart';
// import 'package:techcadd/api/api_service.dart';
// import 'package:techcadd/utils/snackbar_utils.dart';

// class StudentCredentialsScreen extends StatefulWidget {
//   const StudentCredentialsScreen({super.key});

//   @override
//   State<StudentCredentialsScreen> createState() => _StudentCredentialsScreenState();
// }

// class _StudentCredentialsScreenState extends State<StudentCredentialsScreen> {
//   List<dynamic> _students = [];
//   bool _isLoading = true;
//   String _errorMessage = '';
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadStudentCredentials();
//   }

//   Future<void> _loadStudentCredentials() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = '';
//       });

//       // This endpoint needs to be created in your backend
//       final response = await ApiService.getStudentCredentials();
//       setState(() {
//         _students = response['students'] ?? [];
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//       CustomSnackBar.showError(context: context, message: 'Failed to load student credentials');
//     }
//   }

//   List<dynamic> get _filteredStudents {
//     if (_searchQuery.isEmpty) return _students;
    
//     return _students.where((student) {
//       final name = student['student_name']?.toString().toLowerCase() ?? '';
//       final username = student['username']?.toString().toLowerCase() ?? '';
//       final regId = student['registration_id']?.toString().toLowerCase() ?? '';
//       final course = student['course_name']?.toString().toLowerCase() ?? '';
      
//       final query = _searchQuery.toLowerCase();
//       return name.contains(query) || 
//              username.contains(query) || 
//              regId.contains(query) ||
//              course.contains(query);
//     }).toList();
//   }

//   void _showStudentCredentials(Map<String, dynamic> student) {
//     showDialog(
//       context: context,
//       builder: (context) => StudentCredentialsDialog(student: student),
//     );
//   }

//   void _copyCredentials(Map<String, dynamic> student) {
//     final username = student['username'] ?? '';
//     final password = student['password'] ?? 'Not available';
//     final credentials = 'Username: $username\nPassword: $password';
    
//     Clipboard.setData(ClipboardData(text: credentials));
//     CustomSnackBar.showSuccess(context: context, message: 'Credentials copied to clipboard');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student Credentials'),
//         backgroundColor: const Color(0xFF282C5C),
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadStudentCredentials,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               onChanged: (value) => setState(() => _searchQuery = value),
//               decoration: InputDecoration(
//                 hintText: 'Search by name, username, or course...',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ),

//           // Student Count
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Total Students: ${_students.length}',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF282C5C),
//                   ),
//                 ),
//                 if (_searchQuery.isNotEmpty)
//                   Text(
//                     'Found: ${_filteredStudents.length}',
//                     style: const TextStyle(
//                       color: Colors.grey,
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 8),

//           // Student List
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _errorMessage.isNotEmpty
//                     ? _buildErrorState()
//                     : _filteredStudents.isEmpty
//                         ? _buildEmptyState()
//                         : _buildStudentList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             'Failed to load credentials',
//             style: TextStyle(color: Colors.grey[600]),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _errorMessage,
//             style: TextStyle(color: Colors.grey[500], fontSize: 12),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: _loadStudentCredentials,
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             _searchQuery.isEmpty ? 'No students found' : 'No students match your search',
//             style: TextStyle(color: Colors.grey[600]),
//           ),
//           if (_searchQuery.isEmpty) ...[
//             const SizedBox(height: 8),
//             Text(
//               'Student credentials will appear here after registration',
//               style: TextStyle(color: Colors.grey[500], fontSize: 12),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildStudentList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: _filteredStudents.length,
//       itemBuilder: (context, index) {
//         final student = _filteredStudents[index];
//         return _StudentCard(
//           student: student,
//           onTap: () => _showStudentCredentials(student),
//           onCopy: () => _copyCredentials(student),
//         );
//       },
//     );
//   }
// }

// class _StudentCard extends StatelessWidget {
//   final Map<String, dynamic> student;
//   final VoidCallback onTap;
//   final VoidCallback onCopy;

//   const _StudentCard({
//     required this.student,
//     required this.onTap,
//     required this.onCopy,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(16),
//         leading: Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: const Color(0xFF282C5C).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Icon(
//             Icons.person,
//             color: Color(0xFF282C5C),
//           ),
//         ),
//         title: Text(
//           student['student_name'] ?? 'Unknown',
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 4),
//             Text('Username: ${student['username'] ?? 'N/A'}'),
//             const SizedBox(height: 2),
//             Text('Course: ${student['course_name'] ?? 'N/A'}'),
//             const SizedBox(height: 2),
//             Text('Branch: ${student['branch'] ?? 'N/A'}'),
//           ],
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.content_copy, size: 20),
//               onPressed: onCopy,
//               tooltip: 'Copy credentials',
//             ),
//             const SizedBox(width: 4),
//             IconButton(
//               icon: const Icon(Icons.visibility, size: 20),
//               onPressed: onTap,
//               tooltip: 'View details',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class StudentCredentialsDialog extends StatelessWidget {
//   final Map<String, dynamic> student;

//   const StudentCredentialsDialog({super.key, required this.student});

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF282C5C).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Icon(
//                     Icons.person,
//                     size: 30,
//                     color: Color(0xFF282C5C),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         student['student_name'] ?? 'Unknown',
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         student['course_name'] ?? 'No course',
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             _DetailItem(
//               icon: Icons.badge,
//               label: 'Registration ID',
//               value: student['registration_id'] ?? 'N/A',
//             ),
//             _DetailItem(
//               icon: Icons.person,
//               label: 'Username',
//               value: student['username'] ?? 'N/A',
//             ),
//             _DetailItem(
//               icon: Icons.business,
//               label: 'Branch',
//               value: student['branch'] ?? 'N/A',
//             ),
//             _DetailItem(
//               icon: Icons.calendar_today,
//               label: 'Joining Date',
//               value: student['joining_date'] ?? 'N/A',
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Note: Passwords are securely stored and cannot be retrieved after initial creation.',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey,
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   final username = student['username'] ?? '';
//                   Clipboard.setData(ClipboardData(text: username));
//                   CustomSnackBar.showSuccess(context: context, message: 'Username copied to clipboard');
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF282C5C),
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text('Copy Username'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DetailItem extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;

//   const _DetailItem({
//     required this.icon,
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 20, color: Colors.grey[600]),
//           const SizedBox(width: 12),
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey[700],
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: SelectableText(
//               value,
//               style: const TextStyle(color: Colors.black87),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }