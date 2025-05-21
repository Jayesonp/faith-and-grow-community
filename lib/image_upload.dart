import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

/// Helper class for handling image uploads
class ImageUploadHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from the gallery or camera
  /// Returns the image bytes if successful, null if cancelled or on error
  static Future<Uint8List?> pickImage({
    required ImageSource source,
    int maxWidth = 1920,
    int maxHeight = 1080,
    int imageQuality = 80,
  }) async {
    try {
      // Request permission first
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (image != null) {
        // Read the file bytes
        final bytes = await image.readAsBytes();
        if (bytes.isEmpty) {
          debugPrint('Error: Image bytes are empty');
          return null;
        }
        return bytes;
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Pick an image from the gallery
  static Future<Uint8List?> pickImageFromGallery() async {
    return pickImage(source: ImageSource.gallery);
  }

  /// Capture an image using the camera
  static Future<Uint8List?> captureImage() async {
    return pickImage(source: ImageSource.camera);
  }
}
