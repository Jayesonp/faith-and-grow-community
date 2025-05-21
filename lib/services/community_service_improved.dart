// This is an improved version of the community_service.dart file with better error handling

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:dreamflow/models/community_model.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dreamflow/services/firebase_service.dart';
import 'package:dreamflow/services/dev_mode_service.dart';
import 'package:dreamflow/services/dev_mode_service_fix.dart';

class CommunityService {
  static const String _communitiesKey = 'communities_data';
  static const String _membershipsKey = 'community_memberships_data';
  
  /// Verify if a user can create a community based on their subscription
  static Future<Map<String, dynamic>> verifyCreationEligibility(String userId) async {
    final result = <String, dynamic>{
      'canCreate': false,
      'message': '',
      'communityLimit': 0,
      'currentCount': 0,
    };
    
    try {
      // First check if dev mode is enabled
      final isDevMode = await DevModeServiceFix.isDevModeEnabled();
      final bypassPayment = await DevModeServiceFix.shouldBypassPayment();
      
      if (isDevMode && bypassPayment) {
        result['canCreate'] = true;
        result['message'] = 'Developer mode enabled';
        result['communityLimit'] = -1; // Unlimited in dev mode
        return result;
      }
      
      // Get user from Firestore
      final userDoc = await FirebaseService.firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        result['message'] = 'User not found';
        return result;
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final canCreateCommunity = userData['canCreateCommunity'] as bool? ?? false;
      final communityLimit = userData['communityLimit'] as int? ?? 0;
      final subscriptionTier = userData['subscriptionTier'] as String? ?? 'free';
      
      // Check if user is in dev mode in Firestore
      if (subscriptionTier == 'dev_mode') {
        result['canCreate'] = true;
        result['message'] = 'Developer mode enabled (server)';
        result['communityLimit'] = -1; // Unlimited in dev mode
        return result;
      }
      
      // Check if user has explicit permission
      if (!canCreateCommunity) {
        result['message'] = 'Your subscription tier does not allow community creation';
        return result;
      }
      
      // Check community limit
      if (communityLimit == 0) {
        result['message'] = 'You have reached your community creation limit';
        return result;
      }
      
      // Count existing communities
      int communityCount = 0;
      if (userData.containsKey('ownedCommunityIds')) {
        final ownedCommunityIds = List<String>.from(userData['ownedCommunityIds'] ?? []);
        communityCount = ownedCommunityIds.length;
      } else {
        // Query communities collection to count them
        final communitiesQuery = await FirebaseService.firestore
            .collection('communities')
            .where('creatorId', isEqualTo: userId)
            .get();
        communityCount = communitiesQuery.docs.length;
      }
      
      result['currentCount'] = communityCount;
      
      // Check if limit reached (if limit is -1, means unlimited)
      if (communityLimit != -1 && communityCount >= communityLimit) {
        result['message'] = 'You have reached your community creation limit of $communityLimit';
        return result;
      }
      
      // User can create a community
      result['canCreate'] = true;
      result['communityLimit'] = communityLimit;
      return result;
    } catch (e) {
      result['message'] = 'Error checking eligibility: $e';
      return result;
    }
  }

  /// Create a new community
  static Future<Map<String, dynamic>> createCommunity({
    String? id,
    required String creatorId,
    required String name,
    required String shortDescription,
    required String fullDescription,
    String? coverImageUrl,
    String? iconImageUrl,
    required String category,
    required List<CommunityTier> tiers,
    bool isPublished = false, // Default to unpublished until explicitly launched
  }) async {
    // Return object with detailed information about what happened
    final result = <String, dynamic>{
      'success': false,
      'community': null,
      'error': null,
      'errorCode': null,
      'technicalDetails': null,
    };
    
    try {
      // Check developer mode first to potentially bypass other checks
      bool isDevMode = await DevModeServiceFix.isDevModeEnabled();
      bool bypassPayment = await DevModeServiceFix.shouldBypassPayment();
      
      // Log debugging info
      print('Creating community with developer mode: $isDevMode, bypass payment: $bypassPayment');
      
      // Only check eligibility if not in dev mode with bypass enabled
      if (!(isDevMode && bypassPayment)) {
        // Check if user can create community (subscription tier check)
        final eligibility = await verifyCreationEligibility(creatorId);
        
        if (!eligibility['canCreate']) {
          result['error'] = eligibility['message'] ?? 'You cannot create a community with your current subscription';
          result['errorCode'] = 'insufficient_permissions';
          result['technicalDetails'] = 'User does not have canCreateCommunity permission';
          return result;
        }
      } else {
        print('Developer mode active: bypassing eligibility checks');
      }
      
      // Generate ID if not provided
      final communityId = id ?? const Uuid().v4();
      
      // Create community object
      final community = Community(
        id: communityId,
        creatorId: creatorId,
        name: name,
        shortDescription: shortDescription,
        fullDescription: fullDescription,
        coverImageUrl: coverImageUrl,
        iconImageUrl: iconImageUrl,
        category: category,
        tiers: tiers,
        createdAt: DateTime.now(),
        isPublished: isPublished,
      );
      
      // Save to Firestore
      try {
        print('Attempting to save community to Firestore...');
        await FirebaseService.firestore
            .collection('communities')
            .doc(communityId)
            .set(community.toJson());
            
        print('Community saved to Firestore successfully');
        
        // Update user's owned communities list
        try {
          await FirebaseService.firestore.collection('users').doc(creatorId).update({
            'ownedCommunityIds': FieldValue.arrayUnion([communityId]),
          });
          print('Updated user\'s owned communities list');
        } catch (e) {
          print('Warning: Could not update user\'s owned communities list: $e');
          // Non-fatal error, continue
        }
        
        // Also save locally for offline capability
        try {
          final prefs = await SharedPreferences.getInstance();
          List<String> communityJsonList = prefs.getStringList(_communitiesKey) ?? [];
          communityJsonList.add(jsonEncode(community.toJson()));
          await prefs.setStringList(_communitiesKey, communityJsonList);
          print('Community also saved to local storage');
        } catch (e) {
          print('Warning: Could not save community to local storage: $e');
          // Non-fatal error, continue
        }
        
        // Success!
        result['success'] = true;
        result['community'] = community;
        return result;
      } catch (e) {
        // Handle Firestore errors
        print('Error saving community to Firestore: $e');
        
        String errorMessage = 'Failed to create community';
        String errorCode = 'unknown_error';
        
        if (e is FirebaseException) {
          if (e.code == 'permission-denied') {
            errorMessage = 'You don\'t have permission to create communities. Try enabling Developer Mode';
            errorCode = 'permission-denied';
          } else if (e.code == 'unavailable') {
            errorMessage = 'Service unavailable. Check your internet connection and try again';
            errorCode = 'network_error';
          } else {
            errorMessage = 'Firebase error: ${e.message}';
            errorCode = e.code;
          }
        }
        
        result['error'] = errorMessage;
        result['errorCode'] = errorCode;
        result['technicalDetails'] = e.toString();
        return result;
      }
    } catch (e) {
      // Handle unexpected errors
      print('Unexpected error creating community: $e');
      result['error'] = 'An unexpected error occurred';
      result['technicalDetails'] = e.toString();
      return result;
    }
  }
  
  /// Publish a community (Make it visible to others)
  static Future<Community?> publishCommunity(String communityId) async {
    try {
      // Get the community
      final communityRef = FirebaseService.firestore.collection('communities').doc(communityId);
      final communityDoc = await communityRef.get();
      
      if (!communityDoc.exists) {
        throw Exception('Community not found');
      }
      
      // Update isPublished flag
      await communityRef.update({'isPublished': true});
      
      // Get updated document
      final updatedDoc = await communityRef.get();
      final data = updatedDoc.data() as Map<String, dynamic>;
      
      return Community.fromJson(data);
    } catch (e) {
      print('Error publishing community: $e');
      rethrow;
    }
  }
  
  /// Check if user is a member of a community
  static Future<CommunityMembership?> getUserMembership(String userId, String communityId) async {
    try {
      // First check Firestore
      final querySnapshot = await FirebaseService.firestore
          .collection('memberships')
          .where('userId', isEqualTo: userId)
          .where('communityId', isEqualTo: communityId)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return CommunityMembership.fromJson(doc.data());
      }
      
      // If not found in Firestore, check local storage as fallback
      final prefs = await SharedPreferences.getInstance();
      final membershipsJson = prefs.getStringList(_membershipsKey) ?? [];
      
      for (final membershipJson in membershipsJson) {
        final membership = CommunityMembership.fromJson(jsonDecode(membershipJson));
        if (membership.userId == userId && membership.communityId == communityId && membership.isActive) {
          return membership;
        }
      }
      
      // Not found in either location
      return null;
    } catch (e) {
      print('Error checking membership: $e');
      return null;
    }
  }
  
  /// Join a community as the creator
  static Future<CommunityMembership?> joinAsSelfMember(String userId, String communityId) async {
    try {
      // Check if already a member
      final existingMembership = await getUserMembership(userId, communityId);
      if (existingMembership != null) {
        return existingMembership; // Already a member
      }
      
      // Get the community to check tiers
      final communityDoc = await FirebaseService.firestore
          .collection('communities')
          .doc(communityId)
          .get();
      
      if (!communityDoc.exists) {
        throw Exception('Community not found');
      }
      
      final communityData = communityDoc.data() as Map<String, dynamic>;
      final community = Community.fromJson(communityData);
      
      // If no tiers, can't join
      if (community.tiers.isEmpty) {
        throw Exception('Community has no tiers');
      }
      
      // Use highest tier for creator
      final highestTier = community.tiers.reduce((a, b) => 
          a.monthlyPrice > b.monthlyPrice ? a : b);
      
      // Create membership with special creator flag
      final membershipId = const Uuid().v4();
      final membership = CommunityMembership(
        id: membershipId,
        userId: userId,
        communityId: communityId,
        tierId: highestTier.id,
        joinedAt: DateTime.now(),
        isActive: true,
      );
      
      // Save to Firestore
      await FirebaseService.firestore
          .collection('memberships')
          .doc(membershipId)
          .set(membership.toJson());
      
      return membership;
    } catch (e) {
      print('Error joining own community: $e');
      return null;
    }
  }
}