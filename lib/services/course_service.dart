import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dreamflow/models/content_model.dart';
import 'package:dreamflow/models/course_progress_model.dart';

class CourseService {
  static final _firestore = FirebaseFirestore.instance;

  // Get courses for a community
  static Future<List<Course>> getCommunityCourses(String communityId) async {
    try {
      final snapshot = await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('courses')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final modules = (data['modules'] as List).map((moduleData) {
          return Module(
            id: moduleData['id'],
            title: moduleData['title'],
            lessons: (moduleData['lessons'] as List).map((lessonData) {
              return Lesson(
                id: lessonData['id'],
                title: lessonData['title'],
                content: lessonData['content'],
                videoUrl: lessonData['videoUrl'],
                duration: Duration(minutes: lessonData['duration']),
                isCompleted: lessonData['isCompleted'] ?? false,
              );
            }).toList(),
          );
        }).toList();

        return Course(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          imageUrl: data['imageUrl'],
          authorName: data['authorName'],
          modules: modules,
          totalLessons: data['totalLessons'],
          estimatedDuration: Duration(minutes: data['estimatedDuration']),
        );
      }).toList();
    } catch (e) {
      print('Error getting community courses: $e');
      rethrow;
    }
  }

  // Get course progress for a user
  static Future<CourseProgress?> getCourseProgress(String userId, String courseId) async {
    try {
      final doc = await _firestore
          .collection('user_progress')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .get();

      if (!doc.exists) return null;

      return CourseProgress.fromJson({
        ...doc.data()!,
        'courseId': courseId,
        'userId': userId,
      });
    } catch (e) {
      print('Error getting course progress: $e');
      return null;
    }
  }

  // Update course progress
  static Future<void> updateCourseProgress(CourseProgress progress) async {
    try {
      await _firestore
          .collection('user_progress')
          .doc(progress.userId)
          .collection('courses')
          .doc(progress.courseId)
          .set(progress.toJson());
    } catch (e) {
      print('Error updating course progress: $e');
      rethrow;
    }
  }

  // Delete a course
  static Future<void> deleteCourse(String communityId, String courseId) async {
    try {
      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('courses')
          .doc(courseId)
          .delete();
    } catch (e) {
      print('Error deleting course: $e');
      rethrow;
    }
  }

  // Check if a user has access to a course based on their membership tier
  static Future<bool> userHasAccessToCourse(
    String userId,
    String communityId,
    String courseId,
  ) async {
    try {
      // Get the user's membership tier
      final membershipDoc = await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('memberships')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (membershipDoc.docs.isEmpty) return false;

      final membership = membershipDoc.docs.first.data();
      final userTierId = membership['tierId'];

      // Get the course's minimum required tier
      final courseDoc = await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('courses')
          .doc(courseId)
          .get();

      if (!courseDoc.exists) return false;

      final courseData = courseDoc.data()!;
      final requiredTierId = courseData['minimumTierId'];

      // Get all tiers to check levels
      final communityDoc = await _firestore
          .collection('communities')
          .doc(communityId)
          .get();

      if (!communityDoc.exists) return false;

      final communityData = communityDoc.data()!;
      final tiers = List<Map<String, dynamic>>.from(communityData['tiers'] ?? []);

      // Sort tiers by price to determine hierarchy
      tiers.sort((a, b) => (a['monthlyPrice'] as num).compareTo(b['monthlyPrice'] as num));

      // Find indices of user's tier and required tier
      final userTierIndex = tiers.indexWhere((tier) => tier['id'] == userTierId);
      final requiredTierIndex = tiers.indexWhere((tier) => tier['id'] == requiredTierId);

      // User has access if their tier index is greater than or equal to required tier index
      return userTierIndex >= requiredTierIndex;
    } catch (e) {
      print('Error checking course access: $e');
      return false;
    }
  }
}
