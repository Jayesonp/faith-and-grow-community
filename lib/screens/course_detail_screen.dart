import 'package:flutter/material.dart';
import 'package:dreamflow/models/content_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  final String userId;
  final double initialProgress;
  final Function(String, double) onProgressUpdated;

  const CourseDetailScreen({
    Key? key,
    required this.course,
    required this.userId,
    required this.initialProgress,
    required this.onProgressUpdated,
  }) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final _completedLessons = <String>{};
  double _progress = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _progress = widget.initialProgress;
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_progress')
          .doc(widget.userId)
          .collection('courses')
          .doc(widget.course.id)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['completedLessons'] != null) {
          setState(() {
            _completedLessons.addAll(
              List<String>.from(data['completedLessons']),
            );
            _progress = data['progress']?.toDouble() ?? 0.0;
          });
        }
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleLessonCompletion(String lessonId) async {
    final isCompleted = _completedLessons.contains(lessonId);
    
    try {
      if (isCompleted) {
        _completedLessons.remove(lessonId);
      } else {
        _completedLessons.add(lessonId);
      }

      // Calculate new progress
      final totalLessons = widget.course.modules.fold<int>(
        0,
        (sum, module) => sum + module.lessons.length,
      );
      
      final newProgress = _completedLessons.length / totalLessons;

      // Update progress in Firestore
      await FirebaseFirestore.instance
          .collection('user_progress')
          .doc(widget.userId)
          .collection('courses')
          .doc(widget.course.id)
          .set({
        'completedLessons': _completedLessons.toList(),
        'progress': newProgress,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      setState(() {
        _progress = newProgress;
      });

      widget.onProgressUpdated(widget.course.id, newProgress);
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      widget.course.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                        Container(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.school,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.course.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          widget.course.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        SizedBox(height: 16.h),
                        LinearProgressIndicator(value: _progress),
                        SizedBox(height: 8.h),
                        Text(
                          '${(_progress * 100).toInt()}% Complete',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'Course Content',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 16.h),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.course.modules.length,
                          itemBuilder: (context, moduleIndex) {
                            final module = widget.course.modules[moduleIndex];
                            return Card(
                              margin: EdgeInsets.only(bottom: 16.h),
                              child: ExpansionTile(
                                title: Text(module.title),
                                subtitle: Text('${module.lessons.length} lessons'),
                                children: module.lessons.map((lesson) {
                                  final isCompleted = _completedLessons.contains(lesson.id);
                                  return ListTile(
                                    title: Text(lesson.title),
                                    subtitle: Text(lesson.formattedDuration),
                                    leading: Icon(
                                      isCompleted
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color: isCompleted
                                          ? Theme.of(context).colorScheme.primary
                                          : null,
                                    ),
                                    trailing: const Icon(Icons.play_circle_outline),
                                    onTap: () {
                                      // Open lesson content
                                      showDialog(
                                        context: context,
                                        builder: (context) => LessonContentDialog(
                                          lesson: lesson,
                                          isCompleted: isCompleted,
                                          onComplete: () => _toggleLessonCompletion(lesson.id),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class LessonContentDialog extends StatelessWidget {
  final Lesson lesson;
  final bool isCompleted;
  final VoidCallback onComplete;

  const LessonContentDialog({
    Key? key,
    required this.lesson,
    required this.isCompleted,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lesson.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            if (lesson.videoUrl != null) ...[
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Flexible(
              child: SingleChildScrollView(
                child: Text(lesson.content),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                onComplete();
                Navigator.pop(context);
              },
              child: Text(isCompleted ? 'Mark as Incomplete' : 'Mark as Complete'),
            ),
          ],
        ),
      ),
    );
  }
}
