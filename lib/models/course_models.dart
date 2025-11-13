// lib/models/course_models.dart
import 'dart:ui';

import 'package:flutter/material.dart';

class Course {
  final int id;
  final String name;
  final String description;
  final String duration;
  final double fees;
  final List<CourseModule> modules;
  final int totalModules;
  final int totalLessons;
  final int completedLessons;
  final int overallProgress;

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.fees,
    required this.modules,
    required this.totalModules,
    required this.totalLessons,
    required this.completedLessons,
    required this.overallProgress,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      fees: (json['fees'] as num?)?.toDouble() ?? 0.0,
      modules: (json['modules'] as List<dynamic>?)
          ?.map((module) => CourseModule.fromJson(module))
          .toList() ?? [],
      totalModules: json['total_modules'] ?? 0,
      totalLessons: json['total_lessons'] ?? 0,
      completedLessons: json['completed_lessons'] ?? 0,
      overallProgress: json['overall_progress'] ?? 0,
    );
  }
}

class CourseModule {
  final int id;
  final String title;
  final String description;
  final int order;
  final List<Lesson> lessons;
  final int completedLessons;
  final int totalLessons;
  final int progressPercentage;

  CourseModule({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.lessons,
    required this.completedLessons,
    required this.totalLessons,
    required this.progressPercentage,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      order: json['order'] ?? 0,
      lessons: (json['lessons'] as List<dynamic>?)
          ?.map((lesson) => Lesson.fromJson(lesson))
          .toList() ?? [],
      completedLessons: json['completed_lessons'] ?? 0,
      totalLessons: json['total_lessons'] ?? 0,
      progressPercentage: json['progress_percentage'] ?? 0,
    );
  }
}

class Lesson {
  final int id;
  final String title;
  final String description;
  final String lessonType; // 'video', 'text', 'quiz', 'assignment'
  final int order;
  final String? videoUrl;
  final String? textContent;
  final int durationMinutes;
  final bool isCompleted;
  final int progressPercentage;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.lessonType,
    required this.order,
    this.videoUrl,
    this.textContent,
    required this.durationMinutes,
    required this.isCompleted,
    required this.progressPercentage,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      lessonType: json['lesson_type'] ?? 'video',
      order: json['order'] ?? 0,
      videoUrl: json['video_url'],
      textContent: json['text_content'],
      durationMinutes: json['duration_minutes'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      progressPercentage: json['progress_percentage'] ?? 0,
    );
  }

  String get durationFormatted {
    if (durationMinutes < 60) {
      return '${durationMinutes}m';
    } else {
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }

  IconData get icon {
    switch (lessonType) {
      case 'video':
        return Icons.play_circle_filled;
      case 'text':
        return Icons.article;
      case 'quiz':
        return Icons.quiz;
      case 'assignment':
        return Icons.assignment;
      default:
        return Icons.play_circle_filled;
    }
  }

  Color get iconColor {
    switch (lessonType) {
      case 'video':
        return Colors.red;
      case 'text':
        return Colors.blue;
      case 'quiz':
        return Colors.orange;
      case 'assignment':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

