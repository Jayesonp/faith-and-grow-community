import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/services/firebase_service.dart';
import 'package:dreamflow/services/firestore_service.dart';

class AuthService {
  static final firebase_auth.FirebaseAuth _auth = FirebaseService.auth;

  // Get the current user
  static User? _userFromFirebaseUser(firebase_auth.User? firebaseUser) {
    if (firebaseUser == null) return null;
    
    // Create basic user from Firebase Auth data
    // We'll fetch the full user profile from Firestore separately
    return User(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      profileImageUrl: firebaseUser.photoURL,
    );
  }
  
  // Get current user from Firebase Auth
  static User? get currentUser {
    return _userFromFirebaseUser(_auth.currentUser);
  }
  
  // Auth state changes stream
  static Stream<User?> get userChanges {
    return _auth.userChanges().map(_userFromFirebaseUser);
  }
  
  // Sign in with email and password
  static Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('Attempting to sign in with email: $email');
      
      // Validate email and password before attempting to sign in
      if (email.isEmpty || !email.contains('@')) {
        print('Invalid email format');
        throw firebase_auth.FirebaseAuthException(
          code: 'invalid-email',
          message: 'The email address is not valid.',
        );
      }
      
      if (password.isEmpty || password.length < 6) {
        print('Password too short');
        throw firebase_auth.FirebaseAuthException(
          code: 'weak-password',
          message: 'The password is too weak.',
        );
      }
      
      // First check if Firebase is properly initialized
      if (Firebase.apps.isEmpty) {
        print('ERROR: Firebase not initialized');
        throw Exception('Firebase not initialized. Please restart the app.');
      }
      
      // Check if we're in mock mode
      if (FirebaseService.mockMode) {
        print('WARNING: Firebase is in mock mode, authentication might not work');
      }
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = userCredential.user;
      print('Firebase sign-in result: ${firebaseUser != null ? 'success' : 'null user'}');
      
      if (firebaseUser != null) {
        // Get or create user document in Firestore
        try {
          print('Fetching user document from Firestore for uid: ${firebaseUser.uid}');
          final userDoc = await FirebaseService.firestore.collection('users').doc(firebaseUser.uid).get();
          
          if (userDoc.exists) {
            print('User document exists in Firestore');
            // Create user from Firestore document
            final userData = {'id': firebaseUser.uid, ...userDoc.data()!};
            print('User data fetched: ${userData.toString()}');
            
            final user = User.fromJson(userData);
            
            // Cache user locally
            await UserService.saveUser(user);
            await UserService.setLoggedIn(true);
            
            print('User successfully logged in and cached: ${user.email}');
            return user;
          } else {
            print('User exists in Auth but not in Firestore - creating new document');
            // User exists in Auth but not in Firestore - create a basic profile
            final newUser = User(
              id: firebaseUser.uid,
              name: firebaseUser.displayName ?? email.split('@')[0],
              email: email,
            );
            
            // Save to Firestore
            await FirestoreService.createUser(newUser);
            
            // Cache user locally
            await UserService.saveUser(newUser);
            await UserService.setLoggedIn(true);
            
            print('New user created in Firestore and cached locally');
            return newUser;
          }
        } catch (firestoreError) {
          print('Error accessing Firestore: $firestoreError');
          // If Firestore access fails, still return a basic user from Auth
          final fallbackUser = User(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? email.split('@')[0],
            email: email,
          );
          
          // Still try to cache locally
          try {
            await UserService.saveUser(fallbackUser);
            await UserService.setLoggedIn(true);
          } catch (cacheError) {
            print('Error caching user: $cacheError');
          }
          
          print('Returning fallback user from Auth only');
          return fallbackUser;
        }
      }
      print('ERROR: Firebase returned null user after successful authentication');
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Firebase Auth Exception during sign in: ${e.code} - ${e.message}');
      // Add more detailed logging for common authentication errors
      switch (e.code) {
        case 'user-not-found':
          print('No user found with email: $email');
          break;
        case 'wrong-password':
          print('Incorrect password for email: $email');
          break;
        case 'invalid-email':
          print('Invalid email format: $email');
          break;
        case 'user-disabled':
          print('Account has been disabled: $email');
          break;
        case 'too-many-requests':
          print('Too many sign-in attempts. Account temporarily locked.');
          break;
        case 'network-request-failed':
          print('Network error during authentication. Check internet connection.');
          break;
      }
      throw e;
    } catch (e) {
      print('Unexpected error during sign in: $e');
      throw Exception('Failed to sign in: $e');
    }
  }
  
  // Register with email and password
  static Future<User?> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    String? businessName,
    String? businessDescription,
  }) async {
    try {
      print('Attempting to register user with email: $email');
      
      // Create the user in Firebase Auth
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        print('User created in Firebase Auth with UID: ${result.user!.uid}');
        
        // Update display name
        try {
          await result.user!.updateDisplayName(name);
          print('Display name updated successfully');
        } catch (displayNameError) {
          print('Error updating display name: $displayNameError');
          // Continue anyway as this is not critical
        }
        
        // Create user profile in Firestore
        final newUser = User(
          id: result.user!.uid,
          name: name,
          email: email,
          businessName: businessName,
          businessDescription: businessDescription,
          // Initialize with basic subscription tier
          canCreateCommunity: false,
          communityLimit: 0,
        );
        
        // Save to Firestore
        try {
          await FirestoreService.createUser(newUser);
          print('User profile created in Firestore');
        } catch (firestoreError) {
          print('Error creating user profile in Firestore: $firestoreError');
          // We'll return the user anyway as the Auth account was created
        }
        
        // Cache locally
        try {
          await UserService.saveUser(newUser);
          await UserService.setLoggedIn(true);
          print('User cached locally');
        } catch (cacheError) {
          print('Error caching user: $cacheError');
        }
        
        return newUser;
      }
      
      print('Registration failed - null user returned from Firebase');
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Firebase Auth Exception during registration: ${e.code} - ${e.message}');
      throw e;
    } catch (e) {
      print('Registration error: $e');
      throw Exception('Failed to register: $e');
    }
  }
  
  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }
  
  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Password reset error: $e');
      rethrow;
    }
  }
  
  // Get error message from Firebase Auth exception
  static String getErrorMessage(firebase_auth.FirebaseAuthException exception) {
    switch (exception.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}