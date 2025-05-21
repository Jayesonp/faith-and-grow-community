import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dreamflow/services/firebase_service.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String? businessName;
  final String? businessDescription;
  final List<String> interests;
  final Map<String, dynamic> learningProgress;
  final List<String> ownedCommunityIds;
  final List<String> membershipIds;
  final bool canCreateCommunity;
  final int communityLimit;
  final String subscriptionTier;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.businessName,
    this.businessDescription,
    this.interests = const [],
    this.learningProgress = const {},
    this.ownedCommunityIds = const [],
    this.membershipIds = const [],
    this.canCreateCommunity = false,
    this.communityLimit = 0,
    this.subscriptionTier = 'free',
  });
  
  /// Check if this user has admin privileges
  bool get isAdmin => this is AdminUser;

  factory User.fromJson(Map<String, dynamic> json) {
    // Check if this is an admin user
    final isAdmin = json['isAdmin'] == true;
    
    if (isAdmin) {
      return AdminUser.fromJson(json);
    }
    
    // Handle potentially missing fields
    List<String> interests = [];
    try {
      interests = List<String>.from(json['interests'] ?? []);
    } catch (e) {
      print('Error parsing interests: $e');
    }
    
    Map<String, dynamic> learningProgress = {};
    try {
      learningProgress = Map<String, dynamic>.from(json['learningProgress'] ?? {});
    } catch (e) {
      print('Error parsing learningProgress: $e');
    }
    
    List<String> ownedCommunityIds = [];
    try {
      ownedCommunityIds = List<String>.from(json['ownedCommunityIds'] ?? []);
    } catch (e) {
      print('Error parsing ownedCommunityIds: $e');
    }
    
    List<String> membershipIds = [];
    try {
      membershipIds = List<String>.from(json['membershipIds'] ?? []);
    } catch (e) {
      print('Error parsing membershipIds: $e');
    }
    
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      businessName: json['businessName'],
      businessDescription: json['businessDescription'],
      interests: interests,
      learningProgress: learningProgress,
      ownedCommunityIds: ownedCommunityIds,
      membershipIds: membershipIds,
      canCreateCommunity: json['canCreateCommunity'] ?? false,
      communityLimit: json['communityLimit'] ?? 0,
      subscriptionTier: json['subscriptionTier'] ?? 'free',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'businessName': businessName,
      'businessDescription': businessDescription,
      'interests': interests,
      'learningProgress': learningProgress,
      'ownedCommunityIds': ownedCommunityIds,
      'membershipIds': membershipIds,
      'canCreateCommunity': canCreateCommunity,
      'communityLimit': communityLimit,
      'subscriptionTier': subscriptionTier,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    String? businessName,
    String? businessDescription,
    List<String>? interests,
    Map<String, dynamic>? learningProgress,
    List<String>? ownedCommunityIds,
    List<String>? membershipIds,
    bool? canCreateCommunity,
    int? communityLimit,
    String? subscriptionTier,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      businessName: businessName ?? this.businessName,
      businessDescription: businessDescription ?? this.businessDescription,
      interests: interests ?? this.interests,
      learningProgress: learningProgress ?? this.learningProgress,
      ownedCommunityIds: ownedCommunityIds ?? this.ownedCommunityIds,
      membershipIds: membershipIds ?? this.membershipIds,
      canCreateCommunity: canCreateCommunity ?? this.canCreateCommunity,
      communityLimit: communityLimit ?? this.communityLimit,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
    );
  }
}

/// Admin user class with additional admin-specific properties and capabilities
class AdminUser extends User {
  final String adminLevel; // 'super', 'standard', etc.
  final DateTime? lastAdminAction;
  
  AdminUser({
    required super.id,
    required super.name,
    required super.email,
    super.profileImageUrl,
    super.businessName,
    super.businessDescription,
    super.interests,
    super.learningProgress,
    super.ownedCommunityIds,
    super.membershipIds,
    super.canCreateCommunity = true,
    super.communityLimit = -1, // Admin users can create unlimited communities
    super.subscriptionTier = 'admin',
    this.adminLevel = 'standard',
    this.lastAdminAction,
  });
  
  factory AdminUser.fromJson(Map<String, dynamic> json) {
    List<String> interests = [];
    try {
      interests = List<String>.from(json['interests'] ?? []);
    } catch (e) {
      print('Error parsing admin interests: $e');
    }
    
    Map<String, dynamic> learningProgress = {};
    try {
      learningProgress = Map<String, dynamic>.from(json['learningProgress'] ?? {});
    } catch (e) {
      print('Error parsing admin learningProgress: $e');
    }
    
    List<String> ownedCommunityIds = [];
    try {
      ownedCommunityIds = List<String>.from(json['ownedCommunityIds'] ?? []);
    } catch (e) {
      print('Error parsing admin ownedCommunityIds: $e');
    }
    
    List<String> membershipIds = [];
    try {
      membershipIds = List<String>.from(json['membershipIds'] ?? []);
    } catch (e) {
      print('Error parsing admin membershipIds: $e');
    }
    
    return AdminUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      businessName: json['businessName'],
      businessDescription: json['businessDescription'],
      interests: interests,
      learningProgress: learningProgress,
      ownedCommunityIds: ownedCommunityIds,
      membershipIds: membershipIds,
      canCreateCommunity: json['canCreateCommunity'] ?? true,
      communityLimit: json['communityLimit'] ?? -1,
      subscriptionTier: json['subscriptionTier'] ?? 'admin',
      adminLevel: json['adminLevel'] ?? 'standard',
      lastAdminAction: json['lastAdminAction'] != null 
          ? (json['lastAdminAction'] is DateTime 
              ? json['lastAdminAction'] 
              : DateTime.parse(json['lastAdminAction']))
          : null,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'isAdmin': true,
      'adminLevel': adminLevel,
      'lastAdminAction': lastAdminAction?.toIso8601String(),
    };
  }
  
  @override
  AdminUser copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    String? businessName,
    String? businessDescription,
    List<String>? interests,
    Map<String, dynamic>? learningProgress,
    List<String>? ownedCommunityIds,
    List<String>? membershipIds,
    bool? canCreateCommunity,
    int? communityLimit,
    String? subscriptionTier,
    String? adminLevel,
    DateTime? lastAdminAction,
  }) {
    return AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      businessName: businessName ?? this.businessName,
      businessDescription: businessDescription ?? this.businessDescription,
      interests: interests ?? this.interests,
      learningProgress: learningProgress ?? this.learningProgress,
      ownedCommunityIds: ownedCommunityIds ?? this.ownedCommunityIds,
      membershipIds: membershipIds ?? this.membershipIds,
      canCreateCommunity: canCreateCommunity ?? this.canCreateCommunity,
      communityLimit: communityLimit ?? this.communityLimit,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      adminLevel: adminLevel ?? this.adminLevel,
      lastAdminAction: lastAdminAction ?? this.lastAdminAction,
    );
  }
  
  /// Check if this admin user has super admin privileges
  bool get isSuperAdmin => adminLevel == 'super';
}

class UserService {
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static User? _currentUser;
  
  // Get the current logged in user with improved performance and better error handling
  static Future<User?> getCurrentUser() async {
    try {
      print('Getting current user...');
      
      // First, check if we have a cached user
      if (_currentUser != null) {
        print('Returning cached user: ${_currentUser!.email}');
        return _currentUser;
      }
      
      // If not, try to get the current Firebase user
      final uid = FirebaseService.currentUserId;
      print('Current Firebase user ID: $uid');
      
      if (uid != null) {
        try {
          print('Attempting to fetch user data from Firestore');
          final userDoc = await FirebaseService.firestore.collection('users').doc(uid).get();
          
          if (userDoc.exists) {
            print('User document found in Firestore');
            final userData = {'id': uid, ...userDoc.data()!};
            _currentUser = User.fromJson(userData);
            print('User data loaded from Firestore: ${_currentUser!.email}');
            return _currentUser;
          } else {
            print('User document NOT found in Firestore');
            // Try to create a user document if it doesn't exist
            final firebaseUser = FirebaseService.auth.currentUser;
            if (firebaseUser != null) {
              print('Creating user document for existing Firebase Auth user');
              final newUser = User(
                id: firebaseUser.uid,
                name: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
                email: firebaseUser.email ?? '',
              );
              
              // Try to create the user document in Firestore
              try {
                await FirebaseService.firestore.collection('users').doc(uid).set(newUser.toJson());
                print('Created new user document in Firestore');
                _currentUser = newUser;
                return _currentUser;
              } catch (firestoreError) {
                print('Failed to create user document: $firestoreError');
                // Still return the user even if we failed to save to Firestore
                return newUser;
              }
            }
          }
        } catch (firestoreError) {
          print('Error accessing Firestore: $firestoreError');
          // Try to get basic user data from Firebase Auth
          final firebaseUser = FirebaseService.auth.currentUser;
          if (firebaseUser != null) {
            print('Falling back to basic user data from Firebase Auth');
            return User(
              id: firebaseUser.uid,
              name: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
              email: firebaseUser.email ?? '',
            );
          }
        }
      }
      
      // If no Firebase user, check local storage as fallback
      print('Checking local storage for user data');
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        try {
          print('User data found in local storage');
          final userData = json.decode(userJson) as Map<String, dynamic>;
          _currentUser = User.fromJson(userData);
          print('User loaded from local storage: ${_currentUser!.email}');
          return _currentUser;
        } catch (jsonError) {
          print('Error parsing user JSON from local storage: $jsonError');
        }
      } else {
        print('No user data found in local storage');
      }
      
      print('No user found in any storage location');
      return null;
    } catch (e) {
      print('Unexpected error getting current user: $e');
      return null;
    }
  }
  
  // Save user data to local storage - now just caches the user
  static Future<void> saveUser(User user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_userKey, json.encode(user.toJson()));
  }
  
  // Check if a user is logged in with faster response
  static Future<bool> isLoggedIn() async {
    // First, check if Firebase user is logged in
    if (FirebaseService.isUserLoggedIn) {
      return true;
    }
    
    // Fallback to local storage
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) == true;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }
  
  // Set login status - now just caches or clears the user
  static Future<void> setLoggedIn(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_isLoggedInKey, status);
  }
  
  // Log out the current user - now just clears the cache
  static Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_userKey);
    prefs.setBool(_isLoggedInKey, false);
  }
  
  // Update user learning progress - handled by FirestoreService
  static Future<void> updateLearningProgress(String courseId, double progress) async {
    if (_currentUser == null) return;
    
    try {
      await FirebaseService.firestore.collection('users').doc(_currentUser!.id).update({
        'learningProgress.$courseId': progress,
      });
      
      // Update local cache
      final updatedProgress = {..._currentUser!.learningProgress, courseId: progress};
      _currentUser = _currentUser!.copyWith(learningProgress: updatedProgress);
      
      // Save to local storage
      await saveUser(_currentUser!);
    } catch (e) {
      print('Error updating learning progress: $e');
    }
  }
}