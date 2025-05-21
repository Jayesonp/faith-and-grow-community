import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:dreamflow/models/community_model.dart';
import 'package:dreamflow/screens/community_review_launch_screen.dart';
import 'package:dreamflow/image_upload.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CommunityCreationScreen extends StatefulWidget {
  final String userId;

  const CommunityCreationScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<CommunityCreationScreen> createState() => _CommunityCreationScreenState();
}

class _CommunityCreationScreenState extends State<CommunityCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _fullDescController = TextEditingController();

  String _selectedCategory = 'Technology';
  final List<String> _categories = [
    'Ministry', 'Business', 'Arts & Media', 'Education',
    'Health & Wellness', 'Technology', 'Family', 'Other'
  ];

  Uint8List? _coverImage;
  Uint8List? _iconImage;
  bool _isLoading = false;

  // Image size limits and validation
  static const int _maxCoverImageSize = 5 * 1024 * 1024; // 5MB
  static const int _maxIconImageSize = 2 * 1024 * 1024; // 2MB
  String? _coverImageError;
  String? _iconImageError;

  @override
  void dispose() {
    _nameController.dispose();
    _shortDescController.dispose();
    _fullDescController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    setState(() {
      _coverImageError = null;
    });
    
    try {
      final image = await ImageUploadHelper.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (image != null) {
        final isValid = await _validateImage(image, _maxCoverImageSize, 'cover');
        if (isValid) {
          setState(() {
            _coverImage = image;
          });
        }
      }
    } catch (e) {
      setState(() {
        _coverImageError = 'Failed to load image. Please try again.';
      });
      debugPrint('Error picking cover image: $e');
    }
  }

  Future<void> _pickIconImage() async {
    setState(() {
      _iconImageError = null;
    });
    
    try {
      final image = await ImageUploadHelper.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
      );
      
      if (image != null) {
        final isValid = await _validateImage(image, _maxIconImageSize, 'icon');
        if (isValid) {
          setState(() {
            _iconImage = image;
          });
        }
      }
    } catch (e) {
      setState(() {
        _iconImageError = 'Failed to load image. Please try again.';
      });
      debugPrint('Error picking icon image: $e');
    }
  }

  Future<bool> _validateImage(Uint8List? imageData, int maxSize, String imageType) async {
    if (imageData == null) return true;

    if (imageData.length > maxSize) {
      final sizeMB = maxSize / (1024 * 1024);
      setState(() {
        if (imageType == 'cover') {
          _coverImageError = 'Cover image must be less than ${sizeMB}MB';
        } else {
          _iconImageError = 'Icon must be less than ${sizeMB}MB';
        }
      });
      return false;
    }

    setState(() {
      if (imageType == 'cover') {
        _coverImageError = null;
      } else {
        _iconImageError = null;
      }
    });
    return true;
  }

  Future<String?> _uploadImage(Uint8List imageData, String prefix) async {
    try {
      final fileName = '${prefix}_${const Uuid().v4()}';
      final ref = FirebaseStorage.instance.ref().child('community_images').child(fileName);

      await ref.putData(imageData);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<Community?> _createCommunity() async {
    try {
      // Upload images first if they exist
      final coverImageUrl = _coverImage != null ? await _uploadImage(_coverImage!, 'cover') : null;

      final iconImageUrl = _iconImage != null ? await _uploadImage(_iconImage!, 'icon') : null;

      // Create default free tier
      final defaultTier = CommunityTier(
        id: const Uuid().v4(),
        name: 'Free',
        monthlyPrice: 0,
        features: ['Access to community posts', 'Join discussions'],
      );

      // Create community
      final community = Community(
        id: const Uuid().v4(),
        creatorId: widget.userId,
        name: _nameController.text,
        shortDescription: _shortDescController.text,
        fullDescription: _fullDescController.text,
        coverImageUrl: coverImageUrl,
        iconImageUrl: iconImageUrl,
        category: _selectedCategory,
        tiers: [defaultTier],
        createdAt: DateTime.now(),
        memberCount: 1,
        isPublished: false,
      );

      // Save to Firestore
      await FirebaseFirestore.instance.collection('communities').doc(community.id).set(community.toJson());

      return community;
    } catch (e) {
      print('Error creating community: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Community'),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Cover Image
                      Text(
                        'Cover Image',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8.h),
                      _buildCoverImageContainer(),
                      SizedBox(height: 24.h),

                      // Community Icon
                      Text(
                        'Community Icon',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8.h),
                      _buildIconImageContainer(),
                      SizedBox(height: 24.h),

                      // Form Fields
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Community Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Short Description
                      TextFormField(
                        controller: _shortDescController,
                        decoration: InputDecoration(
                          labelText: 'Short Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        maxLength: 150,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter a short description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Full Description
                      TextFormField(
                        controller: _fullDescController,
                        decoration: InputDecoration(
                          labelText: 'Full Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        maxLength: 1000,
                        maxLines: 5,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter a full description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),

                      // Create Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            setState(() => _isLoading = true);

                            try {
                              final community = await _createCommunity();

                              if (community != null && mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommunityReviewLaunchScreen(
                                      community: community,
                                      userId: widget.userId,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to create community'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isLoading = false);
                              }
                            }
                          }
                        },
                        child: Text(_isLoading ? 'Creating...' : 'Create Community'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCoverImageContainer() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: _coverImageError != null
                ? Theme.of(context).colorScheme.error
                : Colors.grey[300]!,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickCoverImage,
              child: _coverImage != null
                  ? Image.memory(
                      _coverImage!,
                      fit: BoxFit.cover,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 32.sp,
                          color: Colors.grey[600],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Upload Cover Image',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        if (_coverImageError != null)
                          Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              _coverImageError!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconImageContainer() {
    return Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: _iconImageError != null
              ? Theme.of(context).colorScheme.error
              : Colors.grey[300]!,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _pickIconImage,
            child: _iconImage != null
                ? Image.memory(
                    _iconImage!,
                    fit: BoxFit.cover,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 32.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Upload Icon',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      if (_iconImageError != null)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            _iconImageError!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}