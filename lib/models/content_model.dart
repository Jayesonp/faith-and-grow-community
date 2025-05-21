import 'package:intl/intl.dart';

// Post model for community content
class Post {
  final String id;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final List<Comment> comments;
  final List<String> likes;
  final String category;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    this.comments = const [],
    this.likes = const [],
    this.category = 'General',
  });

  String get formattedDate => DateFormat.yMMMd().format(createdAt);
  int get likeCount => likes.length;
  int get commentCount => comments.length;

  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userImageUrl,
    String? content,
    String? imageUrl,
    DateTime? createdAt,
    List<Comment>? comments,
    List<String>? likes,
    String? category,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      comments: comments ?? this.comments,
      likes: likes ?? this.likes,
      category: category ?? this.category,
    );
  }
}

// Comment model for post comments
class Comment {
  final String id;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.content,
    required this.createdAt,
  });

  String get formattedDate => DateFormat.yMMMd().add_jm().format(createdAt);
}

// Course model for learning modules
class Course {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String authorName;
  final List<Module> modules;
  final int totalLessons;
  final Duration estimatedDuration;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.authorName,
    this.modules = const [],
    required this.totalLessons,
    required this.estimatedDuration,
  });

  String get formattedDuration {
    final hours = estimatedDuration.inHours;
    final minutes = estimatedDuration.inMinutes % 60;
    return hours > 0 ? '$hours hr ${minutes > 0 ? " $minutes min" : ""}' : '$minutes min';
  }
}

// Module model for course sections
class Module {
  final String id;
  final String title;
  final List<Lesson> lessons;

  Module({
    required this.id,
    required this.title,
    this.lessons = const [],
  });
}

// Lesson model for individual learning units
class Lesson {
  final String id;
  final String title;
  final String content;
  final String? videoUrl;
  final Duration duration;
  final bool isCompleted;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    this.videoUrl,
    required this.duration,
    this.isCompleted = false,
  });

  String get formattedDuration {
    final minutes = duration.inMinutes;
    return '$minutes min';
  }

  Lesson copyWith({
    String? id,
    String? title,
    String? content,
    String? videoUrl,
    Duration? duration,
    bool? isCompleted,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      videoUrl: videoUrl ?? this.videoUrl,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// Business model for directory listings
class Business {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String? logoUrl;
  final String category;
  final List<String> tags;
  final String? website;
  final String? phoneNumber;
  final String? email;

  Business({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    this.logoUrl,
    required this.category,
    this.tags = const [],
    this.website,
    this.phoneNumber,
    this.email,
  });
}