// lib/views/student/student_course_screen.dart
import 'package:flutter/material.dart';
import 'package:techcadd/views/admin_dashboard.dart';

class StudentCourseScreen extends StatelessWidget {
  const StudentCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text('My Course'),
        backgroundColor: kPrimaryColor,
      ),
      body: Center(
        child: Text(
          'Course content will be displayed here',
          style: TextStyle(fontSize: 16, color: kTextSecondary),
        ),
      ),
    );
  }
}