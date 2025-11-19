// // lib/screens/course_list_screen.dart
// import 'package:flutter/material.dart';
// import 'package:techcadd/api/api_service.dart';
// import 'package:techcadd/create_course_screen.dart';

// import 'package:techcadd/models/course_models.dart';


// class CourseListScreen extends StatefulWidget {
//   const CourseListScreen({super.key});

//   @override
//   State<CourseListScreen> createState() => _CourseListScreenState();
// }

// class _CourseListScreenState extends State<CourseListScreen> {
//   List<Course> _courses = [];
//   List<CourseType> _courseTypes = [];
//   int? _selectedCourseTypeId;
//   bool _isLoading = true;
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadCourseData();
//   }

//   Future<void> _loadCourseData() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = '';
//       });

//       // Load course types and courses in parallel
//       final [courseTypesResponse, coursesResponse] = await Future.wait([
//         ApiService.getCourseTypes(),
//         ApiService.getCourses(courseTypeId: _selectedCourseTypeId),
//       ]);

//       setState(() {
//         _courseTypes = courseTypesResponse;
//         _courses = coursesResponse.courses;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   void _filterByCourseType(int? courseTypeId) {
//     setState(() {
//       _selectedCourseTypeId = courseTypeId;
//     });
//     _loadCourseData();
//   }

//   void _showCourseDetails(Course course) {
//     showDialog(
//       context: context,
//       builder: (context) => CourseDetailDialog(course: course),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const CreateCourseScreen()),
//           ).then((_) => _loadCourseData());
//         },
//         backgroundColor: const Color(0xFF282C5C),
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//       body: Column(
//         children: [
//           // Filter Chips
//           _buildFilterChips(),
          
//           // Course List
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _errorMessage.isNotEmpty
//                     ? _buildErrorState()
//                     : _buildCourseList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterChips() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Filter by Category:',
//             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//           ),
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 8,
//             children: [
//               // All courses chip
//               FilterChip(
//                 selected: _selectedCourseTypeId == null,
//                 label: const Text('All Courses'),
//                 onSelected: (_) => _filterByCourseType(null),
//               ),
//               // Course type chips
//               ..._courseTypes.map((type) => FilterChip(
//                 selected: _selectedCourseTypeId == type.id,
//                 label: Text(type.name),
//                 onSelected: (_) => _filterByCourseType(type.id),
//               )).toList(),
//             ],
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
//             'Failed to load courses',
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
//             onPressed: _loadCourseData,
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCourseList() {
//     return _courses.isEmpty
//         ? const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.school, size: 64, color: Colors.grey),
//                 SizedBox(height: 16),
//                 Text(
//                   'No courses found',
//                   style: TextStyle(color: Colors.grey, fontSize: 16),
//                 ),
//               ],
//             ),
//           )
//         : ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: _courses.length,
//             itemBuilder: (context, index) {
//               final course = _courses[index];
//               return _CourseCard(
//                 course: course,
//                 onTap: () => _showCourseDetails(course),
//               );
//             },
//           );
//   }
// }

// class _CourseCard extends StatelessWidget {
//   final Course course;
//   final VoidCallback onTap;

//   const _CourseCard({
//     required this.course,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       child: ListTile(
//         leading: Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: const Color(0xFF282C5C).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             Icons.school,
//             color: const Color(0xFF282C5C),
//           ),
//         ),
//         title: Text(
//           course.name,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(course.courseTypeName),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Icon(Icons.schedule, size: 12, color: Colors.grey[600]),
//                 const SizedBox(width: 4),
//                 Text(
//                   '${course.durationDisplay} • ${course.durationHours} hrs',
//                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         trailing: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               '₹${course.courseFee}',
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF282C5C),
//               ),
//             ),
//             const SizedBox(height: 2),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//               decoration: BoxDecoration(
//                 color: course.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 course.isActive ? 'Active' : 'Inactive',
//                 style: TextStyle(
//                   fontSize: 10,
//                   color: course.isActive ? Colors.green : Colors.red,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         onTap: onTap,
//       ),
//     );
//   }
// }

// class CourseDetailDialog extends StatelessWidget {
//   final Course course;

//   const CourseDetailDialog({super.key, required this.course});

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
//                   child: Icon(
//                     Icons.school,
//                     size: 30,
//                     color: const Color(0xFF282C5C),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         course.name,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         course.courseTypeName,
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             _DetailItem(icon: Icons.schedule, label: 'Duration', value: '${course.durationDisplay} (${course.durationHours} hours)'),
//             _DetailItem(icon: Icons.currency_rupee, label: 'Course Fee', value: '₹${course.courseFee}'),
//             if (course.description.isNotEmpty)
//               _DetailItem(icon: Icons.description, label: 'Description', value: course.description),
//             if (course.softwareCovered.isNotEmpty)
//               _DetailItem(icon: Icons.computer, label: 'Software Covered', value: course.softwareCovered),
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
//             child: Text(
//               value,
//               style: const TextStyle(color: Colors.black87),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
