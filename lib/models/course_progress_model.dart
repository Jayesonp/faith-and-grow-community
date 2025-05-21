class CourseProgress {
  final String courseId;
  final String userId;
  final List<String> completedLessons;
  final double progress;
  final DateTime lastUpdated;

  CourseProgress({
    required this.courseId,
    required this.userId,
    required this.completedLessons,
    required this.progress,
    required this.lastUpdated,
  });

  factory CourseProgress.fromJson(Map<String, dynamic> json) {
    return CourseProgress(
      courseId: json['courseId'],
      userId: json['userId'],
      completedLessons: List<String>.from(json['completedLessons'] ?? []),
      progress: json['progress']?.toDouble() ?? 0.0,
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'userId': userId,
      'completedLessons': completedLessons,
      'progress': progress,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  CourseProgress copyWith({
    String? courseId,
    String? userId,
    List<String>? completedLessons,
    double? progress,
    DateTime? lastUpdated,
  }) {
    return CourseProgress(
      courseId: courseId ?? this.courseId,
      userId: userId ?? this.userId,
      completedLessons: completedLessons ?? this.completedLessons,
      progress: progress ?? this.progress,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
