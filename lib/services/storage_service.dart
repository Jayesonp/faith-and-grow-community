import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dreamflow/services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseService.storage;
  static const Uuid _uuid = Uuid();
  
  // Storage paths
  static const String _profileImagesPath = 'profile_images';
  static const String _communityImagesPath = 'community_images';
  static const String _postImagesPath = 'post_images';
  
  // Upload a profile image
  static Future<String> uploadProfileImage(String userId, Uint8List imageBytes) async {
    try {
      final imageName = '$userId.jpg';
      final storageRef = _storage.ref().child('$_profileImagesPath/$imageName');
      
      // Upload the file
      final uploadTask = storageRef.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Wait for the upload to complete
      final snapshot = await uploadTask.whenComplete(() => null);
      
      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      if (downloadUrl.isEmpty) {
        throw Exception('Failed to get download URL for profile image');
      }
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception('Failed to upload profile image: ${e.toString()}');
    }
  }
  
  // Upload a community cover image
  static Future<String> uploadCommunityCoverImage(String communityId, Uint8List imageBytes) async {
    try {
      // Handle empty image data
      if (imageBytes.isEmpty) {
        throw Exception('Cover image data is empty or corrupted');
      }
      
      final imageName = '$communityId-cover.jpg';
      final storageRef = _storage.ref().child('$_communityImagesPath/$imageName');
      
      // Upload the file with explicit content type
      final uploadTask = storageRef.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Add error handling for the upload task
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.state == TaskState.error) {
          print('Cover image upload error: ${snapshot.toString()}');
        }
      });
      
      // Wait for the upload to complete and handle any errors
      final snapshot = await uploadTask.whenComplete(() => null);
      
      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      if (downloadUrl.isEmpty) {
        throw Exception('Failed to get download URL for community cover image');
      }
      
      print('Cover image successfully uploaded: $imageName');
      return downloadUrl;
    } catch (e) {
      print('Error uploading community cover image: $e');
      throw Exception('Failed to upload community cover image: ${e.toString()}');
    }
  }
  
  // Upload a community icon image
  static Future<String> uploadCommunityIconImage(String communityId, Uint8List imageBytes) async {
    try {
      // Handle empty image data
      if (imageBytes.isEmpty) {
        throw Exception('Icon image data is empty or corrupted');
      }
      
      final imageName = '$communityId-icon.jpg';
      final storageRef = _storage.ref().child('$_communityImagesPath/$imageName');
      
      // Upload the file with explicit content type
      final uploadTask = storageRef.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Add error handling for the upload task
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.state == TaskState.error) {
          print('Icon image upload error: ${snapshot.toString()}');
        }
      });
      
      // Wait for the upload to complete
      final snapshot = await uploadTask.whenComplete(() => null);
      
      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      if (downloadUrl.isEmpty) {
        throw Exception('Failed to get download URL for community icon image');
      }
      
      print('Icon image successfully uploaded: $imageName');
      return downloadUrl;
    } catch (e) {
      print('Error uploading community icon image: $e');
      throw Exception('Failed to upload community icon image: ${e.toString()}');
    }
  }
  
  // Upload a post image
  static Future<String> uploadPostImage(Uint8List imageBytes) async {
    try {
      final imageName = '${_uuid.v4()}.jpg';
      final storageRef = _storage.ref().child('$_postImagesPath/$imageName');
      
      // Upload the file
      final uploadTask = storageRef.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Wait for the upload to complete
      final snapshot = await uploadTask.whenComplete(() => null);
      
      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      if (downloadUrl.isEmpty) {
        throw Exception('Failed to get download URL for post image');
      }
      return downloadUrl;
    } catch (e) {
      print('Error uploading post image: $e');
      throw Exception('Failed to upload post image: ${e.toString()}');
    }
  }
  
  // Delete an image by URL
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      // Convert URL to storage reference
      Reference ref = _storage.refFromURL(imageUrl);
      
      // Delete the file
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
}