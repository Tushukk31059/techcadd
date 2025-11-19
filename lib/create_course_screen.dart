// // lib/screens/create_course_screen.dart
// import 'package:flutter/material.dart';
// import 'package:techcadd/api/api_service.dart';

// import 'package:techcadd/models/registration_model.dart';
// import 'package:techcadd/utils/snackbar_utils.dart';

// class CreateCourseScreen extends StatefulWidget {
//   const CreateCourseScreen({super.key});

//   @override
//   State<CreateCourseScreen> createState() => _CreateCourseScreenState();
// }

// class _CreateCourseScreenState extends State<CreateCourseScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _durationHoursController = TextEditingController();
//   final _courseFeeController = TextEditingController();
//   final _softwareController = TextEditingController();

//   List<CourseType> _courseTypes = [];
//   int? _selectedCourseTypeId;
//   String? _selectedDuration;
//   bool _isLoading = false;
//   String _errorMessage = '';

//   final Map<String, String> _durationOptions = {
//     '2_months': '2 Months',
//     '3_months': '3 Months',
//     '4_months': '4 Months',
//     '6_months': '6 Months',
//     '9_months': '9 Months',
//     '1_year': '1 Year',
//   };

//   @override
//   void initState() {
//     super.initState();
//     _loadCourseTypes();
//   }

//   Future<void> _loadCourseTypes() async {
//     try {
//       final courseTypes = await ApiService.getCourseTypes();
//       setState(() {
//         _courseTypes = courseTypes;
//       });
//     } catch (e) {
//       CustomSnackBar.showError(context: context, message: 'Failed to load course types');
//     }
//   }

//   Future<void> _createCourse() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedCourseTypeId == null) {
//       CustomSnackBar.showError(context: context, message: 'Please select course type');
//       return;
//     }
//     if (_selectedDuration == null) {
//       CustomSnackBar.showError(context: context, message: 'Please select duration');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       final courseData = CreateCourseRequest(
//         name: _nameController.text.trim(),
//         courseType: _selectedCourseTypeId!,
//         description: _descriptionController.text.trim(),
//         durationMonths: _selectedDuration!,
//         durationHours: int.parse(_durationHoursController.text),
//         courseFee: double.parse(_courseFeeController.text),
//         softwareCovered: _softwareController.text.trim(),
//       );

//       await ApiService.createCourse(courseData);
      
//       CustomSnackBar.showSuccess(
//         context: context,
//         message: 'Course created successfully',
//       );
      
//       Navigator.pop(context);
      
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//       });
//       CustomSnackBar.showError(
//         context: context,
//         message: 'Failed to create course: $e',
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create New Course'),
//         backgroundColor: const Color(0xFF282C5C),
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Error Message
//               if (_errorMessage.isNotEmpty)
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(12),
//                   margin: const EdgeInsets.only(bottom: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.red[50],
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.red),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.error_outline, color: Colors.red[400]),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           _errorMessage,
//                           style: TextStyle(color: Colors.red[700]),
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.close, color: Colors.red[400]),
//                         onPressed: () => setState(() => _errorMessage = ''),
//                         padding: EdgeInsets.zero,
//                       ),
//                     ],
//                   ),
//                 ),

//               _buildTextField(
//                 controller: _nameController,
//                 label: 'Course Name',
//                 hintText: 'Enter course name',
//                 icon: Icons.school,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter course name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Course Type Dropdown
//               _buildDropdown(
//                 value: _selectedCourseTypeId?.toString(),
//                 label: 'Course Type',
//                 hint: 'Select course type',
//                 items: _courseTypes.map((type) => DropdownMenuItem(
//                   value: type.id.toString(),
//                   child: Text(type.name),
//                 )).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedCourseTypeId = int.parse(value!);
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Duration Dropdown
//               _buildDropdown(
//                 value: _selectedDuration,
//                 label: 'Duration',
//                 hint: 'Select duration',
//                 items: _durationOptions.entries.map((entry) => DropdownMenuItem(
//                   value: entry.key,
//                   child: Text(entry.value),
//                 )).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedDuration = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),

//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildTextField(
//                       controller: _durationHoursController,
//                       label: 'Duration Hours',
//                       hintText: 'e.g., 120',
//                       icon: Icons.access_time,
//                       keyboardType: TextInputType.number,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter duration hours';
//                         }
//                         if (int.tryParse(value) == null) {
//                           return 'Please enter valid number';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _buildTextField(
//                       controller: _courseFeeController,
//                       label: 'Course Fee (₹)',
//                       hintText: 'e.g., 15000',
//                       icon: Icons.currency_rupee,
//                       keyboardType: TextInputType.number,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter course fee';
//                         }
//                         if (double.tryParse(value) == null) {
//                           return 'Please enter valid amount';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               _buildTextField(
//                 controller: _descriptionController,
//                 label: 'Description',
//                 hintText: 'Enter course description',
//                 icon: Icons.description,
//                 maxLines: 3,
//               ),
//               const SizedBox(height: 16),

//               _buildTextField(
//                 controller: _softwareController,
//                 label: 'Software Covered',
//                 hintText: 'List software/tools covered in this course',
//                 icon: Icons.computer,
//                 maxLines: 2,
//               ),
//               const SizedBox(height: 32),

//               // Create Button
//               _isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         onPressed: _createCourse,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF282C5C),
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text(
//                           'Create Course',
//                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hintText,
//     required IconData icon,
//     bool isPassword = false,
//     TextInputType keyboardType = TextInputType.text,
//     int maxLines = 1,
//     String? Function(String?)? validator,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey[700],
//           ),
//         ),
//         const SizedBox(height: 6),
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey[300]!, width: 1.5),
//           ),
//           child: TextFormField(
//             controller: controller,
//             obscureText: isPassword,
//             keyboardType: keyboardType,
//             maxLines: maxLines,
//             validator: validator,
//             decoration: InputDecoration(
//               hintText: hintText,
//               hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
//               border: InputBorder.none,
//               prefixIcon: Icon(icon, color: const Color(0xFF282C5C)),
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 16,
//               ),
//             ),
//             style: const TextStyle(fontSize: 16),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdown({
//     required String? value,
//     required String label,
//     required String hint,
//     required List<DropdownMenuItem<String>> items,
//     required Function(String?) onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey[700],
//           ),
//         ),
//         const SizedBox(height: 6),
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey[300]!, width: 1.5),
//           ),
//           child: DropdownButtonFormField<String>(
//             value: value,
//             decoration: InputDecoration(
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               prefixIcon: Icon(
//                 Icons.category,
//                 color: const Color(0xFF282C5C),
//               ),
//             ),
//             items: [
//               DropdownMenuItem(
//                 value: null,
//                 child: Text(
//                   hint,
//                   style: TextStyle(color: Colors.grey[500]),
//                 ),
//               ),
//               ...items,
//             ],
//             onChanged: onChanged,
//             validator: (value) {
//               if (value == null) {
//                 return 'Please select $label';
//               }
//               return null;
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }