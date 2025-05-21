import 'package:flutter/material.dart';
import 'package:dreamflow/models/content_model.dart';
import 'package:dreamflow/models/community_model.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseCreationScreen extends StatefulWidget {
  final String communityId;
  final String creatorId;
  final CommunityTier minimumTier;

  const CourseCreationScreen({
    Key? key,
    required this.communityId,
    required this.creatorId,
    required this.minimumTier,
  }) : super(key: key);

  @override
  State<CourseCreationScreen> createState() => _CourseCreationScreenState();
}

class _CourseCreationScreenState extends State<CourseCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<Module> _modules = [];
  bool _isLoading = false;
  String? _imageUrl;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final course = Course(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        imageUrl: _imageUrl ?? 'https://source.unsplash.com/random/400x300/?course,education',
        authorName: 'Creator Name', // TODO: Get actual creator name
        modules: _modules,
        totalLessons: _modules.fold(0, (sum, module) => sum + module.lessons.length),
        estimatedDuration: Duration(minutes: _calculateTotalDuration()),
      );

      // Save course to Firestore
      await FirebaseFirestore.instance.collection('communities')
          .doc(widget.communityId)
          .collection('courses')
          .doc(course.id)
          .set({
        'id': course.id,
        'title': course.title,
        'description': course.description,
        'imageUrl': course.imageUrl,
        'authorName': course.authorName,
        'modules': _modules.map((module) => {
          'id': module.id,
          'title': module.title,
          'lessons': module.lessons.map((lesson) => {
            'id': lesson.id,
            'title': lesson.title,
            'content': lesson.content,
            'videoUrl': lesson.videoUrl,
            'duration': lesson.duration.inMinutes,
            'isCompleted': lesson.isCompleted,
          }).toList(),
        }).toList(),
        'totalLessons': course.totalLessons,
        'estimatedDuration': course.estimatedDuration.inMinutes,
        'createdAt': DateTime.now().toIso8601String(),
        'minimumTierId': widget.minimumTier.id,
      });

      if (mounted) {
        Navigator.pop(context, course);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating course: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int _calculateTotalDuration() {
    return _modules.fold(0, (sum, module) => 
      sum + module.lessons.fold(0, (lessonSum, lesson) => 
        lessonSum + lesson.duration.inMinutes
      )
    );
  }

  void _addModule() {
    final moduleId = const Uuid().v4();
    setState(() {
      _modules.add(Module(
        id: moduleId,
        title: 'New Module ${_modules.length + 1}',
        lessons: [],
      ));
    });
  }

  void _editModule(int index) {
    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController(text: _modules[index].title);
        return AlertDialog(
          title: const Text('Edit Module'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Module Title'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _modules[index] = Module(
                    id: _modules[index].id,
                    title: titleController.text,
                    lessons: _modules[index].lessons,
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _addLesson(int moduleIndex) {
    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController();
        final contentController = TextEditingController();
        final videoUrlController = TextEditingController();
        final durationController = TextEditingController(text: '30');

        return AlertDialog(
          title: const Text('Add Lesson'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Lesson Title'),
                  autofocus: true,
                ),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 3,
                ),
                TextField(
                  controller: videoUrlController,
                  decoration: const InputDecoration(labelText: 'Video URL (optional)'),
                ),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final duration = int.tryParse(durationController.text) ?? 30;
                final lessons = List<Lesson>.from(_modules[moduleIndex].lessons);
                lessons.add(Lesson(
                  id: const Uuid().v4(),
                  title: titleController.text,
                  content: contentController.text,
                  videoUrl: videoUrlController.text.isEmpty ? null : videoUrlController.text,
                  duration: Duration(minutes: duration),
                ));

                setState(() {
                  _modules[moduleIndex] = Module(
                    id: _modules[moduleIndex].id,
                    title: _modules[moduleIndex].title,
                    lessons: lessons,
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Course'),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Course Title',
                        hintText: 'Enter a title for your course',
                      ),
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Please enter a course title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Course Description',
                        hintText: 'Describe what students will learn',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Please enter a course description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),
                    const Text(
                      'Modules',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _modules.length,
                      itemBuilder: (context, moduleIndex) {
                        final module = _modules[moduleIndex];
                        return Card(
                          margin: EdgeInsets.only(bottom: 16.h),
                          child: ExpansionTile(
                            title: Text(module.title),
                            subtitle: Text('${module.lessons.length} lessons'),
                            children: [
                              ...module.lessons.map((lesson) => ListTile(
                                    title: Text(lesson.title),
                                    subtitle: Text(lesson.formattedDuration),
                                    leading: const Icon(Icons.school),
                                  )),
                              ListTile(
                                leading: const Icon(Icons.add),
                                title: const Text('Add Lesson'),
                                onTap: () => _addLesson(moduleIndex),
                              ),
                            ],
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editModule(moduleIndex),
                            ),
                          ),
                        );
                      },
                    ),
                    ElevatedButton.icon(
                      onPressed: _addModule,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Module'),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createCourse,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Create Course'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
