import 'package:firebase_core/firebase_core.dart';
import 'package:dreamflow/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;

/// Core service for Firebase initialization and management
class FirebaseService {
  // Firebase instances
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Getter methods for Firebase services
  static FirebaseFirestore get firestore => _firestore;
  static FirebaseAuth get auth => _auth;
  static FirebaseStorage get storage => _storage;
  
  /// Initialize Firebase services with optional mock mode for faster loading
  static bool _mockMode = false;
  static bool get mockMode => _mockMode;
  
  static Future<void> initializeFirebase({bool useMockMode = false}) async {
    // Set mock mode flag
    _mockMode = useMockMode;
    
    if (!Firebase.apps.isEmpty) {
      // Firebase is already initialized
      return;
    }
    
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Enable Firestore offline persistence
      await _firestore.enablePersistence(PersistenceSettings(
        synchronizeTabs: true,
      ));
      
      // Enable debug logging in non-production (comment out for production)
      if (kIsWeb) {
        // Web platform specific settings
        _firestore.enableNetwork();
      }
      
      // Print success message
      print('Firebase initialized successfully!');
      printAuthState();
    } catch (e) {
      // Handle initialization errors
      print('Error initializing Firebase: $e');
      if (e.toString().contains('already-initialized')) {
        print('Firebase was already initialized');
      } else {
        // Fallback to mock mode on error
        print('Falling back to mock mode due to Firebase initialization error');
        _mockMode = true;
      }
    }
  }
  
  /// Get the current authenticated user ID or null if not logged in
  static String? get currentUserId => _auth.currentUser?.uid;
  
  /// Check if a user is currently authenticated
  static bool get isUserLoggedIn => _auth.currentUser != null;
  
  /// Create a document reference for a specific collection and ID
  static DocumentReference documentRef(String collection, String docId) {
    return _firestore.collection(collection).doc(docId);
  }
  
  /// Create a collection reference
  static CollectionReference collectionRef(String collection) {
    return _firestore.collection(collection);
  }
  
  /// Get a storage reference for a specific path
  static Reference storageRef(String path) {
    return _storage.ref().child(path);
  }
  
  /// Check if a document exists in Firestore
  static Future<bool> documentExists(String collection, String docId) async {
    try {
      final docSnapshot = await _firestore.collection(collection).doc(docId).get();
      return docSnapshot.exists;
    } catch (e) {
      return false;
    }
  }
  
  /// Debug: Print the current auth state
  static void printAuthState() {
    final user = _auth.currentUser;
    print('Current auth state: ${user != null ? "Logged in as ${user.email}" : "Not logged in"}');
    if (user != null) {
      print('User ID: ${user.uid}');
    }
  }
}