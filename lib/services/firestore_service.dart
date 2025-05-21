import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/models/community_model.dart';
import 'package:dreamflow/models/content_model.dart';
import 'package:dreamflow/services/firebase_service.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;
  
  // Collection names
  static const String _usersCollection = 'users';
  static const String _communitiesCollection = 'communities';
  static const String _membershipsCollection = 'memberships';
  static const String _postsCollection = 'posts';
  static const String _commentsCollection = 'comments';
  static const String _coursesCollection = 'courses';
  static const String _businessesCollection = 'businesses';
  
  // USER OPERATIONS
  
  // Create a new user document in Firestore
  static Future<void> createUser(User user) async {
    try {
      await _firestore.collection(_usersCollection).doc(user.id).set(user.toJson());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }
  
  // Get a user document from Firestore
  static Future<User?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      rethrow;
    }
  }
  
  // Update a user document in Firestore
  static Future<void> updateUser(User user) async {
    try {
      await _firestore.collection(_usersCollection).doc(user.id).update(user.toJson());
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }
  
  // Update user learning progress
  static Future<void> updateLearningProgress(String userId, String courseId, double progress) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'learningProgress.$courseId': progress,
      });
    } catch (e) {
      print('Error updating learning progress: $e');
      rethrow;
    }
  }
  
  // COMMUNITY OPERATIONS
  
  // Get all communities
  static Future<List<Community>> getCommunities({String? category, bool publishedOnly = true}) async {
    try {
      Query query = _firestore.collection(_communitiesCollection);
      
      if (publishedOnly) {
        query = query.where('isPublished', isEqualTo: true);
      }
      
      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Community.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting communities: $e');
      return [];
    }
  }
  
  // Get a specific community by ID
  static Future<Community?> getCommunityById(String communityId) async {
    try {
      final doc = await _firestore.collection(_communitiesCollection).doc(communityId).get();
      if (doc.exists && doc.data() != null) {
        return Community.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting community: $e');
      return null;
    }
  }
  
  // Get communities created by a specific user
  static Future<List<Community>> getCommunitiesByCreator(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_communitiesCollection)
          .where('creatorId', isEqualTo: userId)
          .get();
          
      return snapshot.docs
          .map((doc) => Community.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting communities by creator: $e');
      return [];
    }
  }
  
  // Create a new community
  static Future<Community> createCommunity(Community community) async {
    try {
      await _firestore.collection(_communitiesCollection).doc(community.id).set(community.toJson());
      return community;
    } catch (e) {
      print('Error creating community: $e');
      rethrow;
    }
  }
  
  // Update an existing community
  static Future<Community?> updateCommunity(Community community) async {
    try {
      await _firestore.collection(_communitiesCollection).doc(community.id).update(community.toJson());
      return community;
    } catch (e) {
      print('Error updating community: $e');
      rethrow;
    }
  }
  
  // Publish a community
  static Future<Community?> publishCommunity(String communityId) async {
    try {
      await _firestore.collection(_communitiesCollection).doc(communityId).update({
        'isPublished': true,
      });
      return await getCommunityById(communityId);
    } catch (e) {
      print('Error publishing community: $e');
      rethrow;
    }
  }
  
  // Delete a community
  static Future<bool> deleteCommunity(String communityId) async {
    try {
      await _firestore.collection(_communitiesCollection).doc(communityId).delete();
      return true;
    } catch (e) {
      print('Error deleting community: $e');
      return false;
    }
  }
  
  // MEMBERSHIP OPERATIONS
  
  // Get all memberships
  static Future<List<CommunityMembership>> getMemberships() async {
    try {
      final snapshot = await _firestore.collection(_membershipsCollection).get();
      return snapshot.docs
          .map((doc) => CommunityMembership.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting memberships: $e');
      return [];
    }
  }
  
  // Get memberships for a specific user
  static Future<List<CommunityMembership>> getUserMemberships(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_membershipsCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();
          
      return snapshot.docs
          .map((doc) => CommunityMembership.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting user memberships: $e');
      return [];
    }
  }
  
  // Get memberships for a specific community
  static Future<List<CommunityMembership>> getCommunityMemberships(String communityId) async {
    try {
      final snapshot = await _firestore
          .collection(_membershipsCollection)
          .where('communityId', isEqualTo: communityId)
          .where('isActive', isEqualTo: true)
          .get();
          
      return snapshot.docs
          .map((doc) => CommunityMembership.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting community memberships: $e');
      return [];
    }
  }
  
  // Check if user is a member of a community
  static Future<CommunityMembership?> getUserMembership(String userId, String communityId) async {
    try {
      final snapshot = await _firestore
          .collection(_membershipsCollection)
          .where('userId', isEqualTo: userId)
          .where('communityId', isEqualTo: communityId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
          
      if (snapshot.docs.isNotEmpty) {
        return CommunityMembership.fromJson(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Error checking membership: $e');
      return null;
    }
  }
  
  // Create a new membership
  static Future<CommunityMembership?> createMembership(CommunityMembership membership) async {
    try {
      await _firestore.collection(_membershipsCollection).doc(membership.id).set(membership.toJson());
      
      // Update user's membership IDs
      await _firestore.collection(_usersCollection).doc(membership.userId).update({
        'membershipIds': FieldValue.arrayUnion([membership.id]),
      });
      
      // Update community member count
      await _firestore.collection(_communitiesCollection).doc(membership.communityId).update({
        'memberCount': FieldValue.increment(1),
      });
      
      return membership;
    } catch (e) {
      print('Error creating membership: $e');
      rethrow;
    }
  }
  
  // Update a membership
  static Future<CommunityMembership?> updateMembership(CommunityMembership membership) async {
    try {
      await _firestore.collection(_membershipsCollection).doc(membership.id).update(membership.toJson());
      return membership;
    } catch (e) {
      print('Error updating membership: $e');
      rethrow;
    }
  }
  
  // POST OPERATIONS
  
  // Get posts with optional category filter
  static Future<List<Post>> getPosts({String? category}) async {
    try {
      Query query = _firestore.collection(_postsCollection).orderBy('createdAt', descending: true);
      
      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }
      
      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Post(
          id: doc.id,
          userId: data['userId'] ?? '',
          userName: data['userName'] ?? '',
          userImageUrl: data['userImageUrl'],
          content: data['content'] ?? '',
          imageUrl: data['imageUrl'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          category: data['category'] ?? 'General',
          // You would handle comments and likes separately for better performance
          comments: [],
          likes: List<String>.from(data['likes'] ?? []),
        );
      }).toList();
    } catch (e) {
      print('Error getting posts: $e');
      return [];
    }
  }
  
  // Create a new post
  static Future<Post?> createPost(Post post) async {
    try {
      final docRef = await _firestore.collection(_postsCollection).add({
        'userId': post.userId,
        'userName': post.userName,
        'userImageUrl': post.userImageUrl,
        'content': post.content,
        'imageUrl': post.imageUrl,
        'createdAt': Timestamp.fromDate(post.createdAt),
        'category': post.category,
        'likes': post.likes,
      });
      
      return post.copyWith(id: docRef.id);
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }
  
  // Toggle like on a post
  static Future<void> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection(_postsCollection).doc(postId);
      final post = await postRef.get();
      
      if (post.exists) {
        final likes = List<String>.from(post.data()?['likes'] ?? []);
        
        if (likes.contains(userId)) {
          // Unlike
          await postRef.update({
            'likes': FieldValue.arrayRemove([userId]),
          });
        } else {
          // Like
          await postRef.update({
            'likes': FieldValue.arrayUnion([userId]),
          });
        }
      }
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }
  
  // Add a comment to a post
  static Future<Comment?> addComment(String postId, Comment comment) async {
    try {
      final commentRef = _firestore
          .collection(_postsCollection)
          .doc(postId)
          .collection(_commentsCollection)
          .doc(comment.id);
          
      await commentRef.set({
        'id': comment.id,
        'userId': comment.userId,
        'userName': comment.userName,
        'userImageUrl': comment.userImageUrl,
        'content': comment.content,
        'createdAt': Timestamp.fromDate(comment.createdAt),
      });
      
      return comment;
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }
  
  // Get comments for a post
  static Future<List<Comment>> getComments(String postId) async {
    try {
      final snapshot = await _firestore
          .collection(_postsCollection)
          .doc(postId)
          .collection(_commentsCollection)
          .orderBy('createdAt', descending: false)
          .get();
          
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Comment(
          id: doc.id,
          userId: data['userId'] ?? '',
          userName: data['userName'] ?? '',
          userImageUrl: data['userImageUrl'],
          content: data['content'] ?? '',
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      print('Error getting comments: $e');
      return [];
    }
  }
}