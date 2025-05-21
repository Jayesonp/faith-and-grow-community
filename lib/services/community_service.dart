import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:dreamflow/models/community_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dreamflow/services/firebase_service.dart';
import 'package:dreamflow/services/dev_mode_service.dart';

class CommunityService {
  static const String _communitiesKey = 'communities_data';
  static const String _membershipsKey = 'community_memberships_data';

  // Get all communities from Firestore or local storage
  static Future<List<Community>> getCommunities({String? category, bool publishedOnly = true}) async {
    try {
      if (FirebaseService.mockMode) {
        // Fallback to local storage in mock mode
        final prefs = await SharedPreferences.getInstance();
        final String? communitiesJson = prefs.getString(_communitiesKey);

        if (communitiesJson == null) {
          final mockCommunities = _generateMockCommunities();
          await saveCommunities(mockCommunities);
          return mockCommunities;
        }

        List<dynamic> decoded = jsonDecode(communitiesJson);
        List<Community> communities = decoded.map((json) => Community.fromJson(json)).toList();

        if (publishedOnly) {
          communities = communities.where((community) => community.isPublished).toList();
        }

        if (category != null && category != 'All') {
          communities = communities.where((community) => community.category == category).toList();
        }

        return communities;
      } else {
        // Use Firestore in normal mode
        Query query = FirebaseService.firestore.collection('communities');

        if (publishedOnly) {
          query = query.where('isPublished', isEqualTo: true);
        }

        if (category != null && category != 'All') {
          query = query.where('category', isEqualTo: category);
        }

        final querySnapshot = await query.get();
        return querySnapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Community.fromJson({...data, 'id': doc.id});
            })
            .toList();
      }
    } catch (e) {
      print('Error fetching communities: $e');
      return [];
    }
  }

  // Get a specific community by ID
  static Future<Community?> getCommunityById(String communityId) async {
    try {
      if (communityId.isEmpty) {
        print('Error: Empty community ID provided to getCommunityById');
        return null;
      }

      print('Looking up community with ID: $communityId');

      int retryCount = 0;
      const maxRetries = 3;
      Exception? lastException;

      while (retryCount < maxRetries) {
        try {
          final docSnapshot = await FirebaseService.firestore
              .collection('communities')
              .doc(communityId)
              .get();

          if (docSnapshot.exists) {
            final data = docSnapshot.data() as Map<String, dynamic>;
            return Community.fromJson({...data, 'id': docSnapshot.id});
          }
          break;
        } catch (e) {
          print('Attempt ${retryCount + 1} failed: $e');
          lastException = Exception('Firebase error: ${e.toString()}');
          retryCount++;

          if (retryCount < maxRetries) {
            await Future.delayed(Duration(milliseconds: 500 * retryCount));
          }
        }
      }

      if (retryCount == maxRetries && lastException != null) {
        print('All ${maxRetries} attempts failed to fetch community');
      }

      print('Community with ID $communityId not found in Firestore or reached max retries');
      
      try {
        final localCommunities = await getCommunities(publishedOnly: false);
        final localCommunity = localCommunities.firstWhere(
          (c) => c.id == communityId,
          orElse: () => Community(
            id: '',
            creatorId: '',
            name: '',
            shortDescription: '',
            fullDescription: '',
            category: '',
            tiers: [],
            createdAt: DateTime.now(),
          ),
        );

        return localCommunity.id.isNotEmpty ? localCommunity : null;
      } catch (e) {
        print('Error accessing local communities: $e');
        return null;
      }
    } catch (e) {
      print('Error fetching community by ID: $e');
      return null;
    }
  }

  // Get communities created by a specific user
  static Future<List<Community>> getCommunitiesByCreator(String userId) async {
    try {
      final querySnapshot = await FirebaseService.firestore
          .collection('communities')
          .where('creatorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Community.fromJson({...data, 'id': doc.id});
            })
            .toList();
    } catch (e) {
      print('Error fetching communities by creator: $e');
      return [];
    }
  }

  // Save communities to local storage
  static Future<void> saveCommunities(List<Community> communities) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(communities.map((community) => community.toJson()).toList());
    await prefs.setString(_communitiesKey, encoded);
  }

  // Process payment for community creation
  static Future<bool> processCommunityPayment({
    required String userId,
    required String plan,
    required double amount,
    required String cardLast4,
  }) async {
    try {
      // In a real app, this would integrate with a payment processor like Stripe
      // For this demo, we'll simulate a successful payment

      // Record the payment in Firestore
      await FirebaseService.firestore.collection('payments').add({
        'userId': userId,
        'plan': plan,
        'amount': amount,
        'cardLast4': cardLast4,
        'status': 'completed',
        'type': 'community_creation',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error processing payment: $e');
      return false;
    }
  }

  // Verify if a user can create a community based on their subscription
  static Future<Map<String, dynamic>> verifyCreationEligibility(String userId) async {
    try {
      // Check if developer mode is enabled with payment bypass
      final bypassPayment = await DevModeService.shouldBypassPayment();

      // Print debug info
      print('DEV MODE CHECK: BypassPayment=$bypassPayment, UserId=$userId');

      if (bypassPayment) {
        // In dev mode with payment bypass, allow unlimited community creation
        // Also update the user document to have dev_mode privileges
        try {
          await FirebaseService.firestore
              .collection('users')
              .doc(userId)
              .update({
                'subscriptionTier': 'dev_mode',
                'canCreateCommunity': true,
                'communityLimit': -1, // Unlimited
              });
          print('DEV MODE: Updated user document with dev_mode privileges');
        } catch (e) {
          print('DEV MODE WARNING: Failed to update user document: $e');
          // Continue anyway since we're in dev mode
        }

        return {
          'canCreate': true,
          'subscriptionTier': 'dev_mode',
          'communityCount': 0,
          'communityLimit': -1, // Unlimited in dev mode
          'limitMessage': 'Developer Mode: Payment verification bypassed',
          'remainingGroups': 'unlimited',
          'isDevMode': true
        };
      }

      // Normal flow - check the user's subscription in Firestore
      final userDoc = await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return {
          'canCreate': false,
          'reason': 'User not found',
        };
      }

      final userData = userDoc.data();
      if (userData == null) {
        return {
          'canCreate': false,
          'reason': 'User data not found',
        };
      }

      final String? subscriptionTier = userData['subscriptionTier'] as String?;
      final bool canCreateCommunity = userData['canCreateCommunity'] as bool? ?? false;
      final int communityLimit = userData['communityLimit'] as int? ?? 0;

      // If user can't create communities based on their subscription
      if (!canCreateCommunity) {
        return {
          'canCreate': false,
          'reason': 'Your current plan does not include community creation. Please upgrade to unlock this feature.',
          'subscriptionTier': subscriptionTier,
        };
      }

      // Check if the user has reached their community limit
      final ownedCommunitiesQuery = await FirebaseService.firestore
          .collection('communities')
          .where('creatorId', isEqualTo: userId)
          .get();

      final int ownedCommunitiesCount = ownedCommunitiesQuery.docs.length;

      // Community plan allows 1 group, Growth allows 5 groups, Mastermind has unlimited
      String limitMessage = '';
      if (subscriptionTier == 'community') {
        limitMessage = 'Your Community plan (\$47/month) allows 1 community group.';
      } else if (subscriptionTier == 'growth') {
        limitMessage = 'Your Growth plan (\$97/month) allows up to 5 community groups.';
      } else if (subscriptionTier == 'mastermind') {
        limitMessage = 'Your Mastermind plan (\$297/month) allows unlimited community groups.';
      }

      // If communityLimit is -1, it means unlimited
      if (communityLimit != -1 && ownedCommunitiesCount >= communityLimit) {
        return {
          'canCreate': false,
          'reason': 'You have reached your limit of $communityLimit ${communityLimit == 1 ? "community group" : "community groups"}. Please upgrade your plan to create more community groups.',
          'subscriptionTier': subscriptionTier,
          'communityCount': ownedCommunitiesCount,
          'communityLimit': communityLimit,
          'limitMessage': limitMessage,
        };
      }

      return {
        'canCreate': true,
        'subscriptionTier': subscriptionTier,
        'communityCount': ownedCommunitiesCount,
        'communityLimit': communityLimit,
        'limitMessage': limitMessage,
        'remainingGroups': communityLimit == -1 ? 'unlimited' : (communityLimit - ownedCommunitiesCount).toString()
      };
    } catch (e) {
      print('Error verifying creation eligibility: $e');
      return {
        'canCreate': false,
        'reason': 'An error occurred. Please try again later.',
      };
    }
  }

  // Create a new community
  static Future<Community> createCommunity({
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
    // Check if demo mode is active - if so, we'll use a special approach
    final isDevMode = await DevModeService.shouldBypassPayment();
    // Validate required fields
    if (name.trim().isEmpty) {
      throw Exception('Community name cannot be empty');
    }
    if (shortDescription.trim().isEmpty) {
      throw Exception('Short description cannot be empty');
    }
    if (fullDescription.trim().isEmpty) {
      throw Exception('Full description cannot be empty');
    }
    if (tiers.isEmpty) {
      throw Exception('Community must have at least one membership tier');
    }

    final communityId = id ?? const Uuid().v4();

    final community = Community(
      id: communityId,
      creatorId: creatorId,
      name: name.trim(),
      shortDescription: shortDescription.trim(),
      fullDescription: fullDescription.trim(),
      coverImageUrl: coverImageUrl,
      iconImageUrl: iconImageUrl,
      category: category,
      tiers: tiers,
      createdAt: DateTime.now(),
      isPublished: isPublished,
    );

    try {
      // Create the community document in Firestore
      await FirebaseService.firestore
        .collection('communities')
        .doc(community.id)
        .set(community.toJson());

      // In dev mode, first check if the user document exists
      if (isDevMode) {
        // Check if user document exists
        final userDoc = await FirebaseService.firestore
          .collection('users')
          .doc(creatorId)
          .get();

        if (!userDoc.exists) {
          // Create a new user document for dev mode
          await FirebaseService.firestore
            .collection('users')
            .doc(creatorId)
            .set({
              'id': creatorId,
              'name': 'Demo User',
              'email': 'demo@example.com',
              'subscriptionTier': 'dev_mode',
              'canCreateCommunity': true,
              'communityLimit': -1,
              'ownedCommunityIds': [community.id],
              'createdAt': FieldValue.serverTimestamp(),
            });
        } else {
          // Update existing user document
          await FirebaseService.firestore
            .collection('users')
            .doc(creatorId)
            .update({
              'subscriptionTier': 'dev_mode', // Ensure it's set to dev_mode
              'canCreateCommunity': true,     // Ensure they can create communities
              'communityLimit': -1,           // Ensure unlimited communities
              'ownedCommunityIds': FieldValue.arrayUnion([community.id]),
            });
        }
      } else {
        // Normal update for non-dev mode users
        await FirebaseService.firestore
          .collection('users')
          .doc(creatorId)
          .update({
            'ownedCommunityIds': FieldValue.arrayUnion([community.id]),
          });
      }

      // Assume success for both operations

      // Both operations completed successfully

      // Only verify database write in non-dev mode to avoid unnecessary errors
      if (!isDevMode) {
        // Verify the community was properly saved by retrieving it
        final verificationCheck = await getCommunityById(community.id);
        if (verificationCheck == null) {
          throw Exception('Community created but could not be verified in database');
        }
      }

      return community;
    } catch (e) {
      print('Error creating community: $e');
      // Don't silently fall back to local storage - we need to know if there's a Firebase error
      throw Exception('Failed to create community: ${e.toString()}');
    }
  }

  // Update an existing community
  static Future<Community?> updateCommunity(Community updatedCommunity) async {
    try {
      await FirebaseService.firestore
          .collection('communities')
          .doc(updatedCommunity.id)
          .update(updatedCommunity.toJson());

      return updatedCommunity;
    } catch (e) {
      print('Error updating community: $e');
      return null;
    }
  }

  // Publish a community
  static Future<Community?> publishCommunity(String communityId) async {
    try {
      // First check if the document exists
      final docExists = await FirebaseService.documentExists('communities', communityId);
      if (!docExists) {
        throw Exception('Community not found. It may have been deleted.');
      }

      await FirebaseService.firestore
          .collection('communities')
          .doc(communityId)
          .update({'isPublished': true});

      final communityDoc = await FirebaseService.firestore
          .collection('communities')
          .doc(communityId)
          .get();

      if (!communityDoc.exists) {
        throw Exception('Failed to retrieve community after publishing.');
      }

      final data = communityDoc.data() as Map<String, dynamic>;
      return Community.fromJson({...data, 'id': communityId});
    } catch (e) {
      print('Error publishing community: $e');
      // Rethrow to allow better error handling in the UI
      throw Exception('Failed to publish community: ${e.toString()}');
    }
  }

  // Delete a community
  static Future<bool> deleteCommunity(String communityId) async {
    try {
      // Get the community to find the creator
      final communityDoc = await FirebaseService.firestore
          .collection('communities')
          .doc(communityId)
          .get();

      if (!communityDoc.exists) {
        return false;
      }

      final communityData = communityDoc.data() as Map<String, dynamic>;
      final String creatorId = communityData['creatorId'] as String;

      // Delete the community document
      await FirebaseService.firestore
          .collection('communities')
          .doc(communityId)
          .delete();

      // Update the user's ownedCommunityIds
      await FirebaseService.firestore.collection('users').doc(creatorId).update({
        'ownedCommunityIds': FieldValue.arrayRemove([communityId]),
      });

      return true;
    } catch (e) {
      print('Error deleting community: $e');
      return false;
    }
  }

  // Get all community memberships
  static Future<List<CommunityMembership>> getMemberships() async {
    try {
      final querySnapshot = await FirebaseService.firestore
          .collection('memberships')
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return CommunityMembership.fromJson({...data, 'id': doc.id});
          })
          .toList();
    } catch (e) {
      print('Error fetching memberships: $e');

      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      final String? membershipsJson = prefs.getString(_membershipsKey);

      if (membershipsJson == null) {
        return [];
      }

      List<dynamic> decoded = jsonDecode(membershipsJson);
      return decoded.map((json) => CommunityMembership.fromJson(json)).toList();
    }
  }

  // Get memberships for a specific user
  static Future<List<CommunityMembership>> getUserMemberships(String userId) async {
    try {
      final querySnapshot = await FirebaseService.firestore
          .collection('memberships')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return CommunityMembership.fromJson({...data, 'id': doc.id});
          })
          .toList();
    } catch (e) {
      print('Error fetching user memberships: $e');
      return [];
    }
  }

  // Get memberships for a specific community
  static Future<List<CommunityMembership>> getCommunityMemberships(String communityId) async {
    try {
      final querySnapshot = await FirebaseService.firestore
          .collection('memberships')
          .where('communityId', isEqualTo: communityId)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return CommunityMembership.fromJson({...data, 'id': doc.id});
          })
          .toList();
    } catch (e) {
      print('Error fetching community memberships: $e');
      return [];
    }
  }

  // Check if user is a member of a community
  static Future<CommunityMembership?> getUserMembership(String userId, String communityId) async {
    try {
      final querySnapshot = await FirebaseService.firestore
          .collection('memberships')
          .where('userId', isEqualTo: userId)
          .where('communityId', isEqualTo: communityId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      return CommunityMembership.fromJson({...data, 'id': doc.id});
    } catch (e) {
      print('Error checking membership: $e');
      return null;
    }
  }

  // Save memberships to local storage with improved error handling
  static Future<void> saveMemberships(List<CommunityMembership> memberships) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(memberships.map((membership) => membership.toJson()).toList());
      await prefs.setString(_membershipsKey, encoded);
    } catch (e) {
      print('Error saving memberships: $e');
    }
  }

  // Join a community (create membership)
  static Future<CommunityMembership?> joinCommunity({
    required String userId,
    required String communityId,
    required String tierId,
  }) async {
    try {
      // Check if the user is already a member
      final existingMembership = await getUserMembership(userId, communityId);

      if (existingMembership != null) {
        // If they're already a member, return the existing membership
        return existingMembership;
      }

      // Get the community to verify it exists
      final community = await getCommunityById(communityId);
      if (community == null) {
        return null;
      }

      // Ensure the tier exists in this community
      final tier = community.tiers.firstWhere(
        (t) => t.id == tierId,
        orElse: () => community.tiers.first, // Default to first tier if not found
      );

      // Create a new membership
      final membership = CommunityMembership(
        id: const Uuid().v4(),
        userId: userId,
        communityId: communityId,
        tierId: tier.id,
        joinedAt: DateTime.now(),
        // Set expiry to one month from now
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
      );

      // Save to Firestore
      await FirebaseService.firestore
          .collection('memberships')
          .doc(membership.id)
          .set(membership.toJson());

      // Update user's membershipIds
      await FirebaseService.firestore.collection('users').doc(userId).update({
        'membershipIds': FieldValue.arrayUnion([membership.id]),
      });

      // Update community member count
      await FirebaseService.firestore.collection('communities').doc(communityId).update({
        'memberCount': FieldValue.increment(1),
      });

      return membership;
    } catch (e) {
      print('Error joining community: $e');
      return null;
    }
  }

  // Leave a community (deactivate membership)
  static Future<bool> leaveCommunity(String userId, String communityId) async {
    try {
      // Find the membership
      final querySnapshot = await FirebaseService.firestore
          .collection('memberships')
          .where('userId', isEqualTo: userId)
          .where('communityId', isEqualTo: communityId)
          .where('isActive', isEqualTo: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return false;
      }

      final docId = querySnapshot.docs.first.id;

      // Update the membership to inactive
      await FirebaseService.firestore
          .collection('memberships')
          .doc(docId)
          .update({'isActive': false});

      // Update community member count
      await FirebaseService.firestore.collection('communities').doc(communityId).update({
        'memberCount': FieldValue.increment(-1),
      });

      return true;
    } catch (e) {
      print('Error leaving community: $e');
      return false;
    }
  }

  // Upgrade membership tier
  static Future<CommunityMembership?> upgradeMembership({
    required String userId,
    required String communityId,
    required String newTierId,
  }) async {
    try {
      // Find the current membership
      final querySnapshot = await FirebaseService.firestore
          .collection('memberships')
          .where('userId', isEqualTo: userId)
          .where('communityId', isEqualTo: communityId)
          .where('isActive', isEqualTo: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final currentMembership = CommunityMembership.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});

      // If already on this tier, just return the current membership
      if (currentMembership.tierId == newTierId) {
        return currentMembership;
      }

      // Create an updated membership
      final updatedMembership = currentMembership.copyWith(
        tierId: newTierId,
        // Reset the expiry date to one month from now
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );

      // Update in Firestore
      await FirebaseService.firestore
          .collection('memberships')
          .doc(updatedMembership.id)
          .update(updatedMembership.toJson());

      return updatedMembership;
    } catch (e) {
      print('Error upgrading membership: $e');
      return null;
    }
  }

  // Remove a member from a community
  static Future<bool> removeMember(String userId, String communityId) async {
    try {
      if (FirebaseService.mockMode) {
        // Handle removal in mock mode using local storage
        final prefs = await SharedPreferences.getInstance();
        final String? membershipsJson = prefs.getString(_membershipsKey);
        if (membershipsJson != null) {
          List<dynamic> decoded = jsonDecode(membershipsJson);
          List<CommunityMembership> memberships = decoded
              .map((json) => CommunityMembership.fromJson(json))
              .toList();

          // Remove the specific membership
          memberships.removeWhere(
            (membership) =>
                membership.userId == userId &&
                membership.communityId == communityId,
          );

          // Save updated memberships
          await saveMemberships(memberships);

          // Update community member count
          final community = await getCommunityById(communityId);
          if (community != null) {
            final updatedCommunity = community.copyWith(
              memberCount: community.memberCount - 1,
            );
            await _updateCommunityInStorage(updatedCommunity);
          }
        }
      } else {
        // Use Firestore in normal mode
        final membershipQuery = await FirebaseService.firestore
            .collection('community_memberships')
            .where('userId', isEqualTo: userId)
            .where('communityId', isEqualTo: communityId)
            .get();

        if (membershipQuery.docs.isNotEmpty) {
          // Delete the membership
          final batch = FirebaseService.firestore.batch();
          membershipQuery.docs.forEach((doc) {
            batch.delete(doc.reference);
          });

          // Update community member count
          final communityRef = FirebaseService.firestore
              .collection('communities')
              .doc(communityId);

          batch.update(communityRef, {
            'memberCount': FieldValue.increment(-1),
          });

          await batch.commit();
        }
      }

      return true;
    } catch (e) {
      print('Error removing member: $e');
      return false;
    }
  }

  // Get community categories
  static Future<List<String>> getCommunityCategories() async {
    return ['All', 'Ministry', 'Business', 'Arts & Media', 'Education', 'Health & Wellness', 'Technology', 'Family', 'Other'];
  }

  // Mock data generation
  static List<Community> _generateMockCommunities() {
    final List<Community> communities = [];
    final uuid = Uuid();

    // Faith Leaders Community
    communities.add(Community(
      id: uuid.v4(),
      creatorId: 'admin',
      name: 'Faith Leaders Network',
      shortDescription: 'A community for pastors and ministry leaders to connect and grow',
      fullDescription: 'Join fellow pastors, ministers, and faith leaders in a supportive environment where you can share resources, discuss challenges, and grow together in your calling. This community offers exclusive resources, prayer support, and professional development opportunities.',
      coverImageUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30',
      category: 'Ministry',
      tiers: [
        CommunityTier(
          id: uuid.v4(),
          name: 'Basic',
          monthlyPrice: 0,
          features: ['Access to community feed', 'Weekly devotionals', 'Ministry resources library'],
        ),
        CommunityTier(
          id: uuid.v4(),
          name: 'Premium',
          monthlyPrice: 9.99,
          features: ['All Basic features', 'Monthly leadership webinars', 'Private networking groups', 'Sermon preparation tools'],
        ),
        CommunityTier(
          id: uuid.v4(),
          name: 'Executive',
          monthlyPrice: 29.99,
          features: ['All Premium features', 'One-on-one ministry consulting', 'Access to exclusive conferences', 'Leadership development resources'],
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      memberCount: 275,
      isPublished: true,
    ));

    // Christian Entrepreneurs
    communities.add(Community(
      id: uuid.v4(),
      creatorId: 'admin',
      name: 'Kingdom Entrepreneurs',
      shortDescription: 'Business builders with a biblical worldview',
      fullDescription: 'A community dedicated to helping Christian entrepreneurs build successful businesses while honoring God. Connect with like-minded business owners, access faith-based business resources, and grow your business with integrity and purpose.',
      coverImageUrl: 'https://images.unsplash.com/photo-1600880292089-90a7e086ee0c',
      category: 'Business',
      tiers: [
        CommunityTier(
          id: uuid.v4(),
          name: 'Starter',
          monthlyPrice: 0,
          features: ['Community access', 'Business devotionals', 'Basic templates'],
        ),
        CommunityTier(
          id: uuid.v4(),
          name: 'Growth',
          monthlyPrice: 19.99,
          features: ['All Starter features', 'Weekly masterminds', 'Business planning tools', 'Monthly expert Q&As'],
        ),
        CommunityTier(
          id: uuid.v4(),
          name: 'Excellence',
          monthlyPrice: 49.99,
          features: ['All Growth features', 'One-on-one business coaching', 'Exclusive investor network', 'Annual business retreat'],
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      memberCount: 432,
      isPublished: true,
    ));

    // Christian Artists Community
    communities.add(Community(
      id: uuid.v4(),
      creatorId: 'admin',
      name: 'Creative Faith Collective',
      shortDescription: 'Artists using their gifts for God\'s glory',
      fullDescription: 'A supportive community for Christian artists, musicians, writers, and creatives. Share your work, receive feedback, find collaboration opportunities, and learn how to use your creative gifts to honor God and impact culture.',
      coverImageUrl: 'https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b',
      category: 'Arts & Media',
      tiers: [
        CommunityTier(
          id: uuid.v4(),
          name: 'Creator',
          monthlyPrice: 0,
          features: ['Community access', 'Weekly inspiration', 'Creative showcase'],
        ),
        CommunityTier(
          id: uuid.v4(),
          name: 'Artisan',
          monthlyPrice: 12.99,
          features: ['All Creator features', 'Monthly workshops', 'Portfolio reviews', 'Collaboration tools'],
        ),
        CommunityTier(
          id: uuid.v4(),
          name: 'Master',
          monthlyPrice: 34.99,
          features: ['All Artisan features', 'Mentorship program', 'Industry connections', 'Exhibition opportunities'],
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      memberCount: 189,
      isPublished: true,
    ));

    return communities;
  }

  static Future<void> _updateCommunityInStorage(Community community) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? communitiesJson = prefs.getString(_communitiesKey);
      
      if (communitiesJson != null) {
        List<dynamic> decoded = jsonDecode(communitiesJson);
        List<Community> communities = decoded.map((json) => Community.fromJson(json)).toList();
        
        final index = communities.indexWhere((c) => c.id == community.id);
        if (index >= 0) {
          communities[index] = community;
          await saveCommunities(communities);
        }
      }
    } catch (e) {
      print('Error updating community in storage: $e');
    }
  }
}