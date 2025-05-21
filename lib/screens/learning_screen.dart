import 'package:flutter/material.dart';
import 'package:dreamflow/models/content_model.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/services/data_service.dart';
import 'package:dreamflow/widgets/common_widgets.dart';
import 'package:dreamflow/theme.dart';

import 'package:url_launcher/url_launcher.dart';

class LearningScreen extends StatefulWidget {
  final String userId;
  
  const LearningScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> with AutomaticKeepAliveClientMixin {
  List<Course> _courses = [];
  bool _isLoading = true;
  Map<String, double> _userProgress = {};
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final courses = await DataService.getCourses();
      final user = await UserService.getCurrentUser();
      
      setState(() {
        _courses = courses;
        _userProgress = Map<String, double>.from(user?.learningProgress ?? {});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading courses: $e')),
      );
    }
  }
  
  void _navigateToCourseDetail(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(
          course: course,
          userId: widget.userId,
          initialProgress: _userProgress[course.id] ?? 0.0,
          onProgressUpdated: (courseId, progress) {
            setState(() {
              _userProgress[courseId] = progress;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Faith Learning',
          style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const FaithLoadingIndicator(message: 'Loading courses...')
            : _courses.isEmpty
                ? const EmptyStateWidget(
                    message: 'No Courses Yet',
                    description: 'Check back soon for new courses and learning resources.',
                    icon: Icons.school_rounded,
                  )
                : ListView(
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    children: [
                      // User progress section
                      if (_userProgress.isNotEmpty) ...[  
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Learning Journey',
                                    style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  ...(_userProgress.entries.map((entry) {
                                    final courseId = entry.key;
                                    final progress = entry.value;
                                    final course = _courses.firstWhere(
                                      (c) => c.id == courseId,
                                      orElse: () => Course(
                                        id: courseId,
                                        title: 'Unknown Course',
                                        description: '',
                                        imageUrl: "https://pixabay.com/get/g3420d2a76113b0e9f1fe1db43db50a14e172a4c98ca30cc45b56558a0ff95ee0abaf934a4cd9f11e599a25d60b0ad8f3a599ed94d8968aeca8421351e676af24_1280.jpg",
                                        authorName: '',
                                        totalLessons: 0,
                                        estimatedDuration: const Duration(minutes: 0),
                                      ),
                                    );
                                    
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            course.title,
                                            style: theme.textTheme.titleSmall,
                                          ),
                                          const SizedBox(height: 4),
                                          LinearProgressIndicator(
                                            value: progress,
                                            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                                            color: theme.colorScheme.primary,
                                            borderRadius: BorderRadius.circular(10),
                                            minHeight: 8,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${(progress * 100).toInt()}% complete',
                                            style: theme.textTheme.bodySmall!.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList()),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Scripture inspiration
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.format_quote,
                                  size: 30,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '"The fear of the LORD is the beginning of wisdom, and knowledge of the Holy One is understanding."',
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Proverbs 9:10',
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Available courses section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Available Courses',
                          style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Course list
                      ..._courses.map((course) => Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(course.title),
                          subtitle: Text(course.description),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _navigateToCourseDetail(course),
                        ),
                      )).toList(),
                    ],
                  ),
      ),
    );
  }
}

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  final String userId;
  final double initialProgress;
  final Function(String, double) onProgressUpdated;
  
  const CourseDetailScreen({
    Key? key,
    required this.course,
    required this.userId,
    this.initialProgress = 0.0,
    required this.onProgressUpdated,
  }) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  double _progress = 0.0;
  int _completedLessons = 0;
  
  @override
  void initState() {
    super.initState();
    _progress = widget.initialProgress;
    _calculateCompletedLessons();
  }
  
  void _calculateCompletedLessons() {
    int totalLessons = 0;
    int completed = 0;
    
    for (final module in widget.course.modules) {
      for (final lesson in module.lessons) {
        totalLessons++;
        if (lesson.isCompleted) completed++;
      }
    }
    
    setState(() {
      _completedLessons = completed;
    });
  }
  
  void _updateProgress(double newProgress) {
    setState(() {
      _progress = newProgress;
    });
    widget.onProgressUpdated(widget.course.id, newProgress);
    UserService.updateLearningProgress(widget.course.id, newProgress);
  }
  
  void _markLessonComplete(Lesson lesson) {
    // In a real app, this would update the lesson's completion status in the database
    // For this MVP, we'll just update the progress
    final totalLessons = widget.course.totalLessons;
    final newProgress = (_completedLessons + 1) / totalLessons;
    
    setState(() {
      _completedLessons++;
    });
    
    _updateProgress(newProgress.clamp(0.0, 1.0));
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lesson marked as complete!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
  
  void _navigateToLesson(Module module, Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(
          course: widget.course,
          module: module,
          lesson: lesson,
          onComplete: () => _markLessonComplete(lesson),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Course header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Course image
                  Image.network(
                    widget.course.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Course title
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      widget.course.title,
                      style: theme.textTheme.headlineSmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: theme.colorScheme.surface,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () {
                  // Share functionality would be implemented in a full version
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share functionality would be implemented in a full version')),
                  );
                },
              ),
            ],
          ),
          
          // Course info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course description
                  Text(
                    widget.course.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  // Course metadata
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.course.authorName,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.course.formattedDuration,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.course.totalLessons} lessons',
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_completedLessons/${widget.course.totalLessons} completed',
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress bar
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(_progress * 100).toInt()}% complete',
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Module list header
                  Text(
                    'Course Content',
                    style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          
          // Module list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final module = widget.course.modules[index];
                return _buildModuleCard(module);
              },
              childCount: widget.course.modules.length,
            ),
          ),
          
          // Empty space at bottom
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
  
  Widget _buildModuleCard(Module module) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Module title
              Text(
                module.title,
                style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              // Lesson list
              ...module.lessons.map((lesson) => _buildLessonItem(module, lesson)).toList(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLessonItem(Module module, Lesson lesson) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToLesson(module, lesson),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: lesson.isCompleted
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.surface,
            border: Border.all(
              color: lesson.isCompleted
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Lesson completion icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: lesson.isCompleted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  border: Border.all(
                    color: lesson.isCompleted
                        ? Colors.transparent
                        : theme.colorScheme.primary,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    lesson.isCompleted ? Icons.check : Icons.play_arrow,
                    size: 18,
                    color: lesson.isCompleted
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Lesson title and duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: theme.textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: lesson.isCompleted
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lesson.formattedDuration,
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        if (lesson.videoUrl != null) ...[  
                          const SizedBox(width: 8),
                          Icon(
                            Icons.videocam,
                            size: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Video',
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Start/Continue button
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LessonScreen extends StatefulWidget {
  final Course course;
  final Module module;
  final Lesson lesson;
  final VoidCallback onComplete;
  
  const LessonScreen({
    Key? key,
    required this.course,
    required this.module,
    required this.lesson,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  bool _isVideoExpanded = false;
  
  Future<void> _openVideo() async {
    if (widget.lesson.videoUrl != null) {
      final url = Uri.parse(widget.lesson.videoUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open video link')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: FaithAppBar(
        title: widget.lesson.title,
        actions: [
          if (widget.lesson.videoUrl != null)
            IconButton(
              icon: Icon(Icons.videocam, color: theme.colorScheme.primary),
              onPressed: _openVideo,
              tooltip: 'Watch Video',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course and module info
            Text(
              widget.course.title,
              style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              widget.module.title,
              style: theme.textTheme.titleSmall!.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            
            // Video section if available
            if (widget.lesson.videoUrl != null) ...[  
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isVideoExpanded = !_isVideoExpanded;
                  });
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              "https://pixabay.com/get/g06340b20c8f116089fc9761f79159aa75b2ab8c11fbe61da19bd7a63196d28e7ca558916d70be03e33092170ac9ccd5455d9ac46a0f9ccaa1c890a713335ea9f_1280.png",
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary.withOpacity(0.8),
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: theme.colorScheme.onPrimary,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lesson Video',
                              style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to ${_isVideoExpanded ? 'collapse' : 'expand'} video information',
                              style: theme.textTheme.bodySmall,
                            ),
                            if (_isVideoExpanded) ...[  
                              const SizedBox(height: 12),
                              Text(
                                'This video will provide a visual explanation of the lesson content. Tap the play button to watch on YouTube.',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              FaithButton(
                                label: 'Watch Video',
                                onPressed: _openVideo,
                                icon: Icons.open_in_new,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Lesson content
            Text(
              'Lesson Content',
              style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              widget.lesson.content,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            
            // Scripture reference
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: theme.colorScheme.primary.withOpacity(0.1),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.format_quote,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"But the wisdom that comes from heaven is first of all pure; then peace-loving, considerate, submissive, full of mercy and good fruit, impartial and sincere."',
                      style: theme.textTheme.bodyMedium!.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'James 3:17',
                      style: theme.textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Mark as complete button
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                child: FaithButton(
                  label: 'Mark as Complete',
                  onPressed: () {
                    widget.onComplete();
                    Navigator.pop(context);
                  },
                  width: double.infinity,
                  icon: Icons.check_circle,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}