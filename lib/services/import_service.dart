import 'dart:convert';
import 'package:dreamflow/models/community_model.dart';
import 'package:dreamflow/services/community_service.dart';
import 'package:dreamflow/models/user_model.dart';

class ImportService {
  // Import memberships from JSON string
  static Future<List<CommunityMembership>> importMemberships(String jsonString) async {
    try {
      // Parse the JSON string - handle both string format and already-parsed format
      List<dynamic> membershipsJson;
      
      try {
        // First attempt to parse the JSON normally
        var decoded = json.decode(jsonString);
        
        // Check if we got a string (which might be another encoded JSON)
        if (decoded is String) {
          // It's a string-encoded JSON, try to parse it again
          try {
            decoded = json.decode(decoded);
          } catch (e) {
            print('Error decoding inner JSON string: $e');
          }
        }
        
        // Now check if we have a list
        if (decoded is List) {
          membershipsJson = decoded;
        } else {
          // If it's not a list, it might be a single object that needs to be wrapped in a list
          if (decoded is Map<String, dynamic>) {
            membershipsJson = [decoded];
          } else {
            throw Exception('Parsed JSON is not a list or object: ${decoded.runtimeType}');
          }
        }
      } catch (e) {
        print('JSON parsing error: $e');
        print('Problematic JSON string: $jsonString');
        throw Exception('Failed to parse membership data: $e');
      }
      
      // Convert to CommunityMembership objects
      final List<CommunityMembership> importedMemberships = membershipsJson
          .map((membershipJson) => CommunityMembership.fromJson(membershipJson))
          .toList();
      
      // Get existing memberships
      final List<CommunityMembership> existingMemberships = await CommunityService.getMemberships();
      
      // Add new memberships (skip if ID already exists)
      final List<CommunityMembership> newMemberships = [];
      
      for (final membership in importedMemberships) {
        // Check if membership already exists
        final existingIndex = existingMemberships.indexWhere((m) => m.id == membership.id);
        
        if (existingIndex == -1) {
          // Add to new memberships list
          newMemberships.add(membership);
          existingMemberships.add(membership);
          
          // Update user's membership IDs
          final user = await UserService.getCurrentUser();
          if (user != null && !user.membershipIds.contains(membership.id)) {
            final updatedUser = user.copyWith(
              membershipIds: [...user.membershipIds, membership.id],
            );
            await UserService.saveUser(updatedUser);
          }
          
          // Update community member count
          final community = await CommunityService.getCommunityById(membership.communityId);
          if (community != null) {
            final updatedCommunity = community.copyWith(
              memberCount: community.memberCount + 1,
            );
            
            // Get all communities and update the specific one
            final communities = await CommunityService.getCommunities(publishedOnly: false);
            final communityIndex = communities.indexWhere((c) => c.id == community.id);
            
            if (communityIndex != -1) {
              communities[communityIndex] = updatedCommunity;
              await CommunityService.saveCommunities(communities);
            }
          }
        }
      }
      
      // Save all memberships
      await CommunityService.saveMemberships(existingMemberships);
      
      return newMemberships;
    } catch (e) {
      throw Exception('Error importing memberships: $e');
    }
  }
}