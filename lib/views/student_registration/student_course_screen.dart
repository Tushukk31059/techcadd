// lib/views/student_registration/student_course_screen.dart
import 'package:flutter/material.dart';
import 'package:techcadd/api/api_service.dart';
import 'package:techcadd/utils/snackbar_utils.dart';

// Reuse the same color scheme
const Color kPrimaryColor = Color(0xFF282C5C);
const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kCardColor = Colors.white;
const Color kAccentGreen = Color(0xFF10B981);
const Color kAccentBlue = Color(0xFF3B82F6);
const Color kTextPrimary = Color(0xFF1F2937);
const Color kTextSecondary = Color(0xFF6B7280);

class StudentCourseScreen extends StatefulWidget {
  const StudentCourseScreen({super.key});

  @override
  State<StudentCourseScreen> createState() => _StudentCourseScreenState();
}

class _StudentCourseScreenState extends State<StudentCourseScreen> {
  Map<String, dynamic>? _courseData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCourseData();
  }

  Future<void> _loadCourseData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await ApiService.getStudentCourseDetail();

      if (response['course'] != null) {
        setState(() {
          _courseData = response['course'];
        });
      } else {
        throw Exception('No course data received');
      }
    } catch (e) {
      print('❌ Course load error: $e');
      setState(() {
        _errorMessage = e.toString();
      });
      CustomSnackBar.showError(
        context: context,
        message: 'Failed to load course content',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadModuleDetail(int moduleId) async {
    try {
      final response = await ApiService.getModuleDetail(moduleId);
      if (response['module'] != null) {
        // Update the specific module in course data
        setState(() {
          final modules = _courseData?['modules'] ?? [];
          final moduleIndex = modules.indexWhere(
            (module) => module['id'] == moduleId,
          );
          if (moduleIndex != -1) {
            modules[moduleIndex] = response['module'];
          }
        });
      }
    } catch (e) {
      print('❌ Module detail error: $e');
    }
  }
void _showLessonDetails(Map<String, dynamic> lesson) {
  showDialog(
    context: context,
    builder: (context) => LessonDetailDialog(
      lesson: lesson,
      onMarkComplete: (lessonId) => _markLessonComplete(lessonId),
      onStartLesson: () {
        Navigator.pop(context); // Close the dialog
        _startLesson(lesson);
      },
    ),
  );
}

  Future<void> _markLessonComplete(int lessonId) async {
    try {
      await ApiService.updateLessonProgress(
        lessonId,
        completionPercentage: 100.0,
        timeSpentMinutes: 0, // You can track actual time
        status: 'completed',
      );

      // Reload course data to reflect changes
      await _loadCourseData();

      CustomSnackBar.showSuccess(
        context: context,
        message: 'Lesson marked as completed!',
      );
    } catch (e) {
      CustomSnackBar.showError(
        context: context,
        message: 'Failed to update lesson progress',
      );
    }
  }

  void _startLesson(Map<String, dynamic> lesson) {
    final lessonId = lesson['id'];
    final lessonType = lesson['lesson_type'] ?? 'video';
    final title = lesson['title'] ?? 'Untitled Lesson';

    // Update progress to in_progress when starting
    ApiService.updateLessonProgress(
          lessonId,
          completionPercentage: 0.0,
          timeSpentMinutes: 0,
          status: 'in_progress',
        )
        .then((_) {
          CustomSnackBar.showSuccess(
            context: context,
            message: 'Starting lesson: $title',
          );

          // Navigate to lesson player based on type
          _navigateToLessonPlayer(lesson);
        })
        .catchError((e) {
          CustomSnackBar.showError(
            context: context,
            message: 'Failed to start lesson',
          );
        });
  }

  void _navigateToLessonPlayer(Map<String, dynamic> lesson) {
    final lessonType = lesson['lesson_type'] ?? 'video';

    // You can create different screens for different lesson types
    switch (lessonType) {
      case 'video':
        _openVideoPlayer(lesson);
        break;
      case 'text':
        _openTextContent(lesson);
        break;
      case 'quiz':
        _openQuiz(lesson);
        break;
      case 'assignment':
        _openAssignment(lesson);
        break;
      default:
        _openGenericLesson(lesson);
    }
  }

  void _openVideoPlayer(Map<String, dynamic> lesson) {
    // Implement video player navigation
    final videoUrl = lesson['video_url'];
    if (videoUrl != null && videoUrl.isNotEmpty) {
      // Navigate to video player screen
      CustomSnackBar.showInfo(
        context: context,
        message: 'Opening video player for: ${lesson['title']}',
      );
    } else {
      CustomSnackBar.showError(
        context: context,
        message: 'Video URL not available',
      );
    }
  }

  void _openTextContent(Map<String, dynamic> lesson) {
    // Implement text content viewer
    final textContent = lesson['text_content'];
    if (textContent != null && textContent.isNotEmpty) {
      // Navigate to text content screen
      CustomSnackBar.showInfo(
        context: context,
        message: 'Opening text content for: ${lesson['title']}',
      );
    } else {
      CustomSnackBar.showError(
        context: context,
        message: 'Text content not available',
      );
    }
  }

  void _openQuiz(Map<String, dynamic> lesson) {
    // Implement quiz screen
    CustomSnackBar.showInfo(
      context: context,
      message: 'Opening quiz: ${lesson['title']}',
    );
  }

  void _openAssignment(Map<String, dynamic> lesson) {
    // Implement assignment screen
    CustomSnackBar.showInfo(
      context: context,
      message: 'Opening assignment: ${lesson['title']}',
    );
  }

  void _openGenericLesson(Map<String, dynamic> lesson) {
    // Generic lesson viewer
    CustomSnackBar.showInfo(
      context: context,
      message: 'Opening: ${lesson['title']}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Course Content',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadCourseData),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : _errorMessage.isNotEmpty
          ? _buildErrorState()
          : _buildCourseContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Failed to load course',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCourseData,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseContent() {
    final modules = _courseData?['modules'] ?? [];
    final courseProgress = _courseData?['course_progress'] ?? {};
    final courseName = _courseData?['name'] ?? 'My Course';

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Header
          _buildCourseHeader(courseName, courseProgress),
          SizedBox(height: 24),

          // Modules List
          Text(
            'Course Modules',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
          SizedBox(height: 16),

          if (modules.isEmpty)
            Column(
              children: [
                SizedBox(height: 140),
                Center(child: _buildEmptyState()),
              ],
            )
          else
            _buildModulesList(modules),
        ],
      ),
    );
  }

  Widget _buildCourseHeader(String courseName, Map<String, dynamic> progress) {
    final totalLessons = progress['total_lessons'] ?? 0;
    final completedLessons = progress['completed_lessons'] ?? 0;
    final progressPercentage = progress['progress_percentage'] ?? 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            courseName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
          SizedBox(height: 16),

          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Course Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                ),
              ),
              Text(
                '${progressPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressPercentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          SizedBox(height: 8),
          Text(
            '$completedLessons of $totalLessons lessons completed',
            style: TextStyle(fontSize: 12, color: kTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesList(List<dynamic> modules) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return _ModuleCard(
          module: module,
          onTap: () => _showModuleDetails(module),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No course content available',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Course materials will be added soon',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showModuleDetails(Map<String, dynamic> module) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ModuleDetailSheet(
      module: module,
      onLessonTap: (lesson) => _startLesson(lesson),
      onMarkComplete: (lessonId) => _markLessonComplete(lessonId),
    ),
  );
}
}

class _ModuleCard extends StatelessWidget {
  final Map<String, dynamic> module;
  final VoidCallback onTap;

  const _ModuleCard({required this.module, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = module['title'] ?? 'Untitled Module';
    final description = module['description'] ?? '';
    final totalLessons = module['total_lessons'] ?? 0;
    final completedLessons = module['completed_lessons'] ?? 0;
    final totalDuration = module['total_duration_minutes'] ?? 0;
    final progress = totalLessons > 0
        ? (completedLessons / totalLessons) * 100
        : 0;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.folder_open_rounded, color: kPrimaryColor),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            if (description.isNotEmpty)
              Text(
                description,
                style: TextStyle(color: kTextSecondary, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.library_books, size: 12, color: kTextSecondary),
                SizedBox(width: 4),
                Text(
                  '$totalLessons lessons',
                  style: TextStyle(fontSize: 12, color: kTextSecondary),
                ),
                SizedBox(width: 12),
                Icon(Icons.schedule, size: 12, color: kTextSecondary),
                SizedBox(width: 4),
                Text(
                  '${totalDuration}m',
                  style: TextStyle(fontSize: 12, color: kTextSecondary),
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(kAccentGreen),
              minHeight: 4,
            ),
            SizedBox(height: 4),
            Text(
              '${progress.toStringAsFixed(0)}% completed',
              style: TextStyle(fontSize: 10, color: kTextSecondary),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: kTextSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}

class ModuleDetailSheet extends StatelessWidget {
  final Map<String, dynamic> module;
  final Function(Map<String, dynamic>)? onLessonTap;
  final Function(int)? onMarkComplete;

  const ModuleDetailSheet({
    super.key,
    required this.module,
    this.onLessonTap,
    this.onMarkComplete,
  });

  @override
  Widget build(BuildContext context) {
    final title = module['title'] ?? 'Untitled Module';
    final description = module['description'] ?? '';
    final lessons = module['lessons'] ?? [];
    final totalLessons = module['total_lessons'] ?? 0;
    final completedLessons = module['completed_lessons'] ?? 0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
          SizedBox(height: 8),
          if (description.isNotEmpty)
            Text(
              description,
              style: TextStyle(color: kTextSecondary, fontSize: 14),
            ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.library_books, size: 16, color: kTextSecondary),
              SizedBox(width: 4),
              Text(
                '$completedLessons/$totalLessons lessons completed',
                style: TextStyle(color: kTextSecondary, fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Lessons',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: lessons.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.playlist_play,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No lessons available',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: lessons.length,
                    itemBuilder: (context, index) {
                      final lesson = lessons[index];
                      return _LessonItem(
                        lesson: lesson,
                        onTap: onLessonTap != null 
                            ? () => onLessonTap!(lesson)
                            : null,
                        onMarkComplete: onMarkComplete,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _LessonItem extends StatelessWidget {
  final Map<String, dynamic> lesson;
  final VoidCallback? onTap;
  final Function(int)? onMarkComplete;

  const _LessonItem({required this.lesson,this.onTap,
    this.onMarkComplete,});

  @override
  Widget build(BuildContext context) {
    final title = lesson['title'] ?? 'Untitled Lesson';
    final duration = lesson['duration_minutes'] ?? 0;
    final isCompleted = lesson['is_completed'] ?? false;
    final progress = lesson['progress_percentage'] ?? 0.0;
    final lessonType = lesson['lesson_type'] ?? 'video';

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? kAccentGreen.withOpacity(0.1)
                : kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getLessonIcon(lessonType),
            color: isCompleted ? kAccentGreen : kPrimaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule, size: 12, color: kTextSecondary),
                SizedBox(width: 4),
                Text(
                  '${duration}m',
                  style: TextStyle(fontSize: 12, color: kTextSecondary),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getLessonTypeColor(lessonType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getLessonTypeText(lessonType),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getLessonTypeColor(lessonType),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (!isCompleted && progress > 0) ...[
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(kAccentBlue),
                minHeight: 4,
              ),
              SizedBox(height: 4),
              Text(
                '${progress.toStringAsFixed(0)}% completed',
                style: TextStyle(fontSize: 10, color: kTextSecondary),
              ),
            ],
          ],
        ),
        trailing: isCompleted
            ? IconButton(
                icon: Icon(Icons.check_circle, color: kAccentGreen, size: 24),
                onPressed: null, // Already completed
              )
            : IconButton(
                icon: Icon(
                  Icons.play_circle_fill_rounded,
                  color: kPrimaryColor,
                  size: 24,
                ),
                onPressed: onTap,
              ),
        onTap: onTap,
      ),
    );
  }

  IconData _getLessonIcon(String lessonType) {
    switch (lessonType) {
      case 'video':
        return Icons.play_circle_fill_rounded;
      case 'text':
        return Icons.article_rounded;
      case 'quiz':
        return Icons.quiz_rounded;
      case 'assignment':
        return Icons.assignment_rounded;
      default:
        return Icons.play_circle_fill_rounded;
    }
  }

  Color _getLessonTypeColor(String lessonType) {
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
        return kPrimaryColor;
    }
  }

  String _getLessonTypeText(String lessonType) {
    switch (lessonType) {
      case 'video':
        return 'VIDEO';
      case 'text':
        return 'TEXT';
      case 'quiz':
        return 'QUIZ';
      case 'assignment':
        return 'ASSIGNMENT';
      default:
        return lessonType.toUpperCase();
    }
  }
}

class LessonDetailDialog extends StatelessWidget {
  final Map<String, dynamic> lesson;
  final Function(int)? onMarkComplete;
  final VoidCallback? onStartLesson;

  const LessonDetailDialog({
    super.key,
    required this.lesson,
    this.onMarkComplete,
    this.onStartLesson
  });
  // Add these helper methods to _StudentCourseScreenState class

  IconData _getLessonIcon(String lessonType) {
    switch (lessonType) {
      case 'video':
        return Icons.play_circle_fill_rounded;
      case 'text':
        return Icons.article_rounded;
      case 'quiz':
        return Icons.quiz_rounded;
      case 'assignment':
        return Icons.assignment_rounded;
      case 'live_class':
        return Icons.video_camera_front_rounded;
      case 'document':
        return Icons.description_rounded;
      default:
        return Icons.play_circle_fill_rounded;
    }
  }

  Color _getLessonTypeColor(String lessonType) {
    switch (lessonType) {
      case 'video':
        return Colors.red;
      case 'text':
        return Colors.blue;
      case 'quiz':
        return Colors.orange;
      case 'assignment':
        return Colors.green;
      case 'live_class':
        return Colors.purple;
      case 'document':
        return Colors.brown;
      default:
        return kPrimaryColor;
    }
  }

  String _getLessonTypeText(String lessonType) {
    switch (lessonType) {
      case 'video':
        return 'VIDEO';
      case 'text':
        return 'TEXT';
      case 'quiz':
        return 'QUIZ';
      case 'assignment':
        return 'ASSIGNMENT';
      case 'live_class':
        return 'LIVE CLASS';
      case 'document':
        return 'DOCUMENT';
      default:
        return lessonType.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = lesson['title'] ?? 'Untitled Lesson';
    final description = lesson['description'] ?? '';
    final duration = lesson['duration_minutes'] ?? 0;
    final lessonType = lesson['lesson_type'] ?? 'video';
    final isCompleted = lesson['is_completed'] ?? false;
    final lessonId = lesson['id'];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getLessonTypeColor(lessonType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getLessonIcon(lessonType),
                    color: _getLessonTypeColor(lessonType),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (description.isNotEmpty)
              Text(
                description,
                style: TextStyle(color: kTextSecondary, fontSize: 14),
              ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: kTextSecondary),
                SizedBox(width: 4),
                Text(
                  'Duration: ${duration} minutes',
                  style: TextStyle(color: kTextSecondary),
                ),
                SizedBox(width: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getLessonTypeColor(lessonType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getLessonTypeText(lessonType),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getLessonTypeColor(lessonType),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close'),
                  ),
                ),
                SizedBox(width: 12),
                if (!isCompleted)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onMarkComplete?.call(lessonId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Mark Complete'),
                    ),
                  ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onStartLesson,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Start Lesson'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
