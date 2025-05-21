import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/models/community_model.dart';
import 'package:dreamflow/services/firebase_service.dart';
import 'package:dreamflow/services/firestore_service.dart';
import 'package:intl/intl.dart';

/// Service for handling admin-specific operations
class AdminService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;
  
  // Collection names
  static const String _usersCollection = 'users';
  static const String _communitiesCollection = 'communities';
  static const String _membershipsCollection = 'memberships';
  static const String _postsCollection = 'posts';
  static const String _subscriptionsCollection = 'subscriptions';
  static const String _adminActionsCollection = 'admin_actions';
  
  // USER MANAGEMENT
  
  /// Get all users in the system
  static Future<List<User>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection(_usersCollection).get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        // Check if user has admin flag
        if (data['isAdmin'] == true) {
          return AdminUser.fromJson({...data, 'id': doc.id});
        } else {
          return User.fromJson({...data, 'id': doc.id});
        }
      }).toList();
    } catch (e) {
      print('Error getting all users: $e');
      throw Exception('Failed to load users: $e');
    }
  }
  
  /// Update user details
  static Future<void> updateUser({
    required String userId,
    String? name,
    String? email,
    String? businessName,
    String? businessDescription,
  }) async {
    try {
      // Create a map with only the fields that need to be updated
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (businessName != null) updateData['businessName'] = businessName;
      if (businessDescription != null) updateData['businessDescription'] = businessDescription;
      
      if (updateData.isNotEmpty) {
        await _firestore.collection(_usersCollection).doc(userId).update(updateData);
        
        // Log admin action
        await _logAdminAction(
          actionType: 'update_user',
          targetId: userId,
          details: {'fields_updated': updateData.keys.toList()},
        );
      }
    } catch (e) {
      print('Error updating user: $e');
      throw Exception('Failed to update user: $e');
    }
  }
  
  /// Set a user's admin status
  static Future<void> setUserAdminStatus({
    required String userId,
    required bool isAdmin,
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'isAdmin': isAdmin,
      });
      
      // Log admin action
      await _logAdminAction(
        actionType: isAdmin ? 'grant_admin' : 'revoke_admin',
        targetId: userId,
        details: {'isAdmin': isAdmin},
      );
    } catch (e) {
      print('Error setting user admin status: $e');
      throw Exception('Failed to update admin status: $e');
    }
  }
  
  /// Delete a user and their associated data
  static Future<void> deleteUser(String userId) async {
    try {
      // Start a batch write to perform multiple operations atomically
      final batch = _firestore.batch();
      
      // Delete user document
      final userRef = _firestore.collection(_usersCollection).doc(userId);
      batch.delete(userRef);
      
      // Delete user's memberships
      final membershipsSnapshot = await _firestore
          .collection(_membershipsCollection)
          .where('userId', isEqualTo: userId)
          .get();
          
      for (final doc in membershipsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete user's communities (or transfer ownership in a real app)
      final communitiesSnapshot = await _firestore
          .collection(_communitiesCollection)
          .where('creatorId', isEqualTo: userId)
          .get();
          
      for (final doc in communitiesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Commit all the changes
      await batch.commit();
      
      // Log admin action
      await _logAdminAction(
        actionType: 'delete_user',
        targetId: userId,
        details: {
          'memberships_deleted': membershipsSnapshot.docs.length,
          'communities_deleted': communitiesSnapshot.docs.length,
        },
      );
    } catch (e) {
      print('Error deleting user: $e');
      throw Exception('Failed to delete user: $e');
    }
  }
  
  // COMMUNITY MANAGEMENT
  
  /// Get all communities in the system
  static Future<List<Community>> getAllCommunities() async {
    try {
      final snapshot = await _firestore.collection(_communitiesCollection).get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        // Convert Firestore Timestamps to DateTime
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        
        // Parse tier data
        List<CommunityTier> tiers = [];
        if (data['tiers'] is List) {
          final tiersList = data['tiers'] as List;
          tiers = tiersList.map((tierData) => CommunityTier.fromJson(tierData)).toList();
        }
        
        return Community(
          id: doc.id,
          creatorId: data['creatorId'],
          name: data['name'],
          shortDescription: data['shortDescription'],
          fullDescription: data['fullDescription'],
          coverImageUrl: data['coverImageUrl'],
          iconImageUrl: data['iconImageUrl'],
          category: data['category'],
          tiers: tiers,
          createdAt: createdAt,
          memberCount: data['memberCount'] ?? 0,
          isPublished: data['isPublished'] ?? false,
        );
      }).toList();
    } catch (e) {
      print('Error getting all communities: $e');
      throw Exception('Failed to load communities: $e');
    }
  }
  
  /// Update community details
  static Future<void> updateCommunity({
    required String communityId,
    String? name,
    String? shortDescription,
    String? fullDescription,
    String? category,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (shortDescription != null) updates['shortDescription'] = shortDescription;
      if (fullDescription != null) updates['fullDescription'] = fullDescription;
      if (category != null) updates['category'] = category;

      await FirebaseService.firestore
          .collection('communities')
          .doc(communityId)
          .update(updates);
    } catch (e) {
      print('Error updating community: $e');
      throw e;
    }
  }

  /// Set a community's publish status
  static Future<void> setCommunityPublishStatus({
    required String communityId,
    required bool isPublished,
  }) async {
    try {
      await FirebaseService.firestore
          .collection('communities')
          .doc(communityId)
          .update({'isPublished': isPublished});
    } catch (e) {
      print('Error setting community publish status: $e');
      throw e;
    }
  }

  /// Delete a community and its associated data
  static Future<void> deleteCommunity(String communityId) async {
    try {
      // First, delete all memberships for this community
      final membershipQuery = await FirebaseService.firestore
          .collection('community_memberships')
          .where('communityId', isEqualTo: communityId)
          .get();

      final batch = FirebaseService.firestore.batch();

      // Add membership deletions to batch
      for (var doc in membershipQuery.docs) {
        batch.delete(doc.reference);
      }

      // Add community deletion to batch
      batch.delete(
        FirebaseService.firestore.collection('communities').doc(communityId)
      );

      // Execute all deletions in a single batch
      await batch.commit();
    } catch (e) {
      print('Error deleting community: $e');
      throw e;
    }
  }
  
  /// Get all unique community categories
  static Future<List<String>> getCommunityCategories() async {
    try {
      final snapshot = await _firestore.collection(_communitiesCollection).get();
      final categories = snapshot.docs
          .map((doc) => doc.data()['category'] as String)
          .toSet() // Get unique categories
          .toList();
      
      categories.sort(); // Sort alphabetically
      return categories;
    } catch (e) {
      print('Error getting community categories: $e');
      throw Exception('Failed to load categories: $e');
    }
  }
  
  // DASHBOARD STATISTICS
  
  /// Get statistics for the admin dashboard
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get user count
      final usersCount = await _firestore.collection(_usersCollection).count().get();
      final totalUsers = usersCount.count;
      
      // Get communities count
      final communitiesCount = await _firestore.collection(_communitiesCollection).count().get();
      final totalCommunities = communitiesCount.count;
      
      // Get posts count
      final postsCount = await _firestore.collection(_postsCollection).count().get();
      final totalPosts = postsCount.count;
      
      // Calculate monthly revenue (from subscriptions)
      double monthlyRevenue = 0;
      final now = DateTime.now();
      final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
      
      final subscriptionsSnapshot = await _firestore
          .collection(_subscriptionsCollection)
          .where('status', isEqualTo: 'active')
          .get();
          
      for (final doc in subscriptionsSnapshot.docs) {
        final data = doc.data();
        final price = (data['price'] ?? 0.0).toDouble();
        monthlyRevenue += price;
      }
      
      // Generate user growth data for chart
      final userGrowthData = await _getUserGrowthData();
      
      return {
        'totalUsers': totalUsers,
        'totalCommunities': totalCommunities,
        'totalPosts': totalPosts,
        'monthlyRevenue': monthlyRevenue,
        'userGrowth': userGrowthData,
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      throw Exception('Failed to load dashboard statistics: $e');
    }
  }
  
  /// Generate user growth data for the last 6 months
  static Future<List<Map<String, dynamic>>> _getUserGrowthData() async {
    final now = DateTime.now();
    final growthData = <Map<String, dynamic>>[];
    
    // Mock data for chart - in a real app, you would query Firestore with timestamp filters
    for (int i = 5; i >= 0; i--) {
      final month = now.month - i > 0 ? now.month - i : now.month - i + 12;
      final year = now.month - i > 0 ? now.year : now.year - 1;
      final date = DateTime(year, month);
      final monthName = DateFormat('MMM').format(date);
      
      // Mock user count with some randomization
      final baseCount = 100;
      final monthValue = baseCount + (5 - i) * 20 + (10 - DateTime.now().day % 10);
      
      growthData.add({
        'label': monthName,
        'value': monthValue,
      });
    }
    
    return growthData;
  }
  
  /// Get recent admin and user activities for the dashboard
  static Future<List<Map<String, dynamic>>> getRecentActivities({int limit = 10}) async {
    try {
      // Get recent admin actions
      final adminActionsSnapshot = await _firestore
          .collection(_adminActionsCollection)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      
      final activities = await Future.wait(adminActionsSnapshot.docs.map((doc) async {
        final data = doc.data();
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        final adminId = data['adminId'];
        final actionType = data['actionType'];
        final targetId = data['targetId'];
        
        // Get admin name
        String adminName = 'Unknown';
        try {
          final adminDoc = await _firestore.collection(_usersCollection).doc(adminId).get();
          if (adminDoc.exists) {
            adminName = adminDoc.data()!['name'] ?? 'Unknown';
          }
        } catch (e) {
          print('Error getting admin name: $e');
        }
        
        // Format the description based on action type
        String description = _formatActionDescription(actionType, targetId, data['details']);
        
        return {
          'type': actionType,
          'description': description,
          'userName': adminName,
          'userId': adminId,
          'timeAgo': _getTimeAgo(timestamp),
          'timestamp': timestamp,
          'actionable': true,
        };
      }));
      
      // Mock some user activities with randomization
      final mockUserActivities = _generateMockUserActivities(5);
      
      // Combine and sort all activities by timestamp
      final allActivities = [...activities, ...mockUserActivities];
      allActivities.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
      
      // Return limited number of activities
      return allActivities.take(limit).toList();
    } catch (e) {
      print('Error getting recent activities: $e');
      throw Exception('Failed to load recent activities: $e');
    }
  }
  
  /// Format the description of an admin action
  static String _formatActionDescription(String actionType, String targetId, Map<String, dynamic>? details) {
    switch (actionType) {
      case 'update_user':
        final fieldsUpdated = details?['fields_updated'] ?? [];
        return 'Updated user (fields: ${fieldsUpdated.join(', ')})';
      case 'grant_admin':
        return 'Granted admin privileges to user';
      case 'revoke_admin':
        return 'Revoked admin privileges from user';
      case 'delete_user':
        return 'Deleted user and all associated data';
      case 'update_community':
        final fieldsUpdated = details?['fields_updated'] ?? [];
        return 'Updated community (fields: ${fieldsUpdated.join(', ')})';
      case 'publish_community':
        return 'Published community to public view';
      case 'unpublish_community':
        return 'Unpublished community from public view';
      case 'delete_community':
        return 'Deleted community and all associated data';
      default:
        return 'Performed admin action: $actionType';
    }
  }
  
  /// Generate mock user activities for the dashboard
  static List<Map<String, dynamic>> _generateMockUserActivities(int count) {
    final activities = <Map<String, dynamic>>[];
    final now = DateTime.now();
    final activityTypes = ['user_created', 'community_created', 'post_created', 'payment', 'login'];
    final names = ['John Smith', 'Sarah Parker', 'Michael Johnson', 'Emily Williams', 'David Brown'];
    
    for (int i = 0; i < count; i++) {
      final minutesAgo = 5 + i * 15 + (DateTime.now().second % 10);
      final timestamp = now.subtract(Duration(minutes: minutesAgo));
      final type = activityTypes[i % activityTypes.length];
      final name = names[i % names.length];
      
      String description;
      switch (type) {
        case 'user_created':
          description = 'New user registered: $name';
          break;
        case 'community_created':
          description = 'Created new community "Faith Business Network"';
          break;
        case 'post_created':
          description = 'Posted new content in "Christian Entrepreneurs"';
          break;
        case 'payment':
          description = 'Made payment for Growth subscription';
          break;
        case 'login':
          description = 'Signed in from new device';
          break;
        default:
          description = 'User activity: $type';
      }
      
      activities.add({
        'type': type,
        'description': description,
        'userName': name,
        'userId': 'user$i',
        'timeAgo': _getTimeAgo(timestamp),
        'timestamp': timestamp,
        'actionable': type != 'login',
      });
    }
    
    return activities;
  }
  
  /// Format a timestamp as a human-readable "time ago" string
  static String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
  
  // ADMIN ACTIONS LOGGING
  
  /// Log an admin action for auditing purposes
  static Future<void> _logAdminAction({
    required String actionType,
    required String targetId,
    Map<String, dynamic>? details,
  }) async {
    try {
      final currentUser = FirebaseService.currentUserId;
      if (currentUser == null) {
        throw Exception('No authenticated admin user found');
      }
      
      await _firestore.collection(_adminActionsCollection).add({
        'adminId': currentUser,
        'actionType': actionType,
        'targetId': targetId,
        'details': details ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging admin action: $e');
      // Don't throw - we don't want to fail the main operation if logging fails
    }
  }
}