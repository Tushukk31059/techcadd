// // lib/screens/course_detail_screen.dart
// import 'package:flutter/material.dart';

// import 'package:techcadd/api/api_service.dart';

// import '../models/course_models.dart';


// class CourseDetailScreen extends StatefulWidget {
//   final int courseId;

//   const CourseDetailScreen({super.key, required this.courseId});

//   @override
//   State<CourseDetailScreen> createState() => _CourseDetailScreenState();
// }

// class _CourseDetailScreenState extends State<CourseDetailScreen> {
//   Course? _course;
//   bool _isLoading = true;
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadCourseDetail();
//   }

//   Future<void> _loadCourseDetail() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = '';
//       });

//       final course = await ApiService.getCourseDetail(widget.courseId);
      
//       setState(() {
//         _course = course;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_course?.name ?? 'Course Details'),
//         backgroundColor: const Color(0xFF282C5C),
//         foregroundColor: Colors.white,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _errorMessage.isNotEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Failed to load course',
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         _errorMessage,
//                         style: TextStyle(color: Colors.grey[500], fontSize: 12),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: _loadCourseDetail,
//                         child: const Text('Retry'),
//                       ),
//                     ],
//                   ),
//                 )
//               : _course == null
//                   ? const Center(child: Text('Course not found'))
//                   : _buildCourseContent(),
//     );
//   }

//   Widget _buildCourseContent() {
//     final course = _course!;
    
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Course Header
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Color(0xFF282C5C), Color(0xFF3A3F7A)],
//               ),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   course.name,
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   course.description,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.white.withOpacity(0.9),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     _CourseStat(
//                       icon: Icons.layers,
//                       value: '${course.totalModules}',
//                       label: 'Modules',
//                     ),
//                     const SizedBox(width: 20),
//                     _CourseStat(
//                       icon: Icons.play_lesson,
//                       value: '${course.totalLessons}',
//                       label: 'Lessons',
//                     ),
//                     const SizedBox(width: 20),
//                     _CourseStat(
//                       icon: Icons.schedule,
//                       value: course.duration,
//                       label: 'Duration',
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
          
//           const SizedBox(height: 24),
          
//           // Progress Section
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.grey[50],
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey[200]!),
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Course Progress',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       '${course.overallProgress}%',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF282C5C),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 LinearProgressIndicator(
//                   value: course.overallProgress / 100,
//                   backgroundColor: Colors.grey[300],
//                   color: const Color(0xFF282C5C),
//                   minHeight: 8,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '${course.completedLessons} of ${course.totalLessons} lessons completed',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     Text(
//                       '${((course.completedLessons / course.totalLessons) * 100).toStringAsFixed(0)}%',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
          
//           const SizedBox(height: 24),
          
//           // Modules List
//           Text(
//             'Course Modules',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[800],
//             ),
//           ),
//           const SizedBox(height: 16),
          
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: course.modules.length,
//             itemBuilder: (context, index) {
//               final module = course.modules[index];
//               return _ModuleCard(module: module);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _CourseStat extends StatelessWidget {
//   final IconData icon;
//   final String value;
//   final String label;

//   const _CourseStat({
//     required this.icon,
//     required this.value,
//     required this.label,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Icon(icon, size: 24, color: Colors.white),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.white.withOpacity(0.8),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _ModuleCard extends StatelessWidget {
//   final CourseModule module;

//   const _ModuleCard({required this.module});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF282C5C).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     '${module.order}',
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF282C5C),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         module.title,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF282C5C),
//                         ),
//                       ),
//                       if (module.description.isNotEmpty) ...[
//                         const SizedBox(height: 4),
//                         Text(
//                           module.description,
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ],
//             ),
            
//             const SizedBox(height: 16),
            
//             // Progress bar
//             LinearProgressIndicator(
//               value: module.progressPercentage / 100,
//               backgroundColor: Colors.grey[200],
//               color: const Color(0xFF282C5C),
//               minHeight: 6,
//               borderRadius: BorderRadius.circular(3),
//             ),
            
//             const SizedBox(height: 8),
            
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   '${module.progressPercentage}% Complete',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF282C5C),
//                   ),
//                 ),
//                 Text(
//                   '${module.completedLessons}/${module.totalLessons} lessons',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
            
//             const SizedBox(height: 16),
            
//             // Lessons list
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: module.lessons.length,
//               itemBuilder: (context, index) {
//                 final lesson = module.lessons[index];
//                 return _LessonItem(lesson: lesson);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _LessonItem extends StatelessWidget {
//   final Lesson lesson;

//   const _LessonItem({required this.lesson});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: lesson.iconColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Icon(lesson.icon, size: 16, color: lesson.iconColor),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   lesson.title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   lesson.description,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 lesson.durationFormatted,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               const SizedBox(height: 4),
//               if (lesson.isCompleted)
//                 Icon(Icons.check_circle, size: 16, color: Colors.green)
//               else
//                 Icon(Icons.circle_outlined, size: 16, color: Colors.grey),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }