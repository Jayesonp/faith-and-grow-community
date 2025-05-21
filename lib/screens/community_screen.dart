import 'package:flutter/material.dart';
import 'package:dreamflow/models/content_model.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/services/data_service.dart';
import 'package:dreamflow/widgets/common_widgets.dart';
import 'package:dreamflow/theme.dart';


class CommunityScreen extends StatefulWidget {
  final String userId;
  
  const CommunityScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with AutomaticKeepAliveClientMixin {
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  List<Post> _posts = [];
  bool _isLoading = true;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final categories = await DataService.getPostCategories();
      final posts = await DataService.getPosts(category: _selectedCategory != 'All' ? _selectedCategory : null);
      
      setState(() {
        _categories = categories;
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }
  
  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadData();
  }
  
  Future<void> _handleLike(Post post) async {
    try {
      await DataService.toggleLike(post.id, widget.userId.isEmpty ? 'current_user_id' : widget.userId);
      await _loadData(); // Refresh posts to show updated like status
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  void _showPostDetail(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPostDetailSheet(post),
    );
  }
  
  Widget _buildPostDetailSheet(Post post) {
    final theme = Theme.of(context);
    final commentController = TextEditingController();
    
    return StatefulBuilder(
      builder: (context, setState) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Post content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        // TODO: Implement PostCard widget
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${post.userName}', style: Theme.of(context).textTheme.titleMedium),
                                SizedBox(height: 8),
                                Text(post.content),
                              ],
                            ),
                          ),
                          
                        ),
                        const SizedBox(height: 16),
                        // Add comment form
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add a Comment',
                                  style: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: theme.colorScheme.primary,
                                      radius: 20,
                                      child: const Icon(Icons.person, color: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: commentController,
                                        decoration: InputDecoration(
                                          hintText: 'Share your thoughts...',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        maxLines: 3,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FaithButton(
                                    label: 'Post Comment',
                                    onPressed: () async {
                                      if (commentController.text.isNotEmpty) {
                                        try {
                                          await DataService.addComment(
                                            post.id, 
                                            widget.userId.isEmpty ? 'current_user_id' : widget.userId,
                                            'You', // In a real app, this would be the current user's name
                                            commentController.text,
                                          );
                                          // Clear the text field
                                          commentController.clear();
                                          // Refresh the post to show the new comment
                                          _loadData();
                                          Navigator.pop(context);
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error: $e')),
                                          );
                                        }
                                      }
                                    },
                                    icon: Icons.send_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Faith Community',
          style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            // Category filter
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _categories.length > 1 ? 50 : 0,
              child: _categories.length > 1
                  ? FilterChips(
                      categories: _categories,
                      selectedCategory: _selectedCategory,
                      onCategorySelected: _selectCategory,
                    )
                  : null,
            ),
            
            // Posts list
            Expanded(
              child: _isLoading
                  ? const FaithLoadingIndicator(message: 'Loading community posts...')
                  : _posts.isEmpty
                      ? EmptyStateWidget(
                          message: 'No Posts Yet',
                          description: _selectedCategory != 'All'
                              ? 'There are no posts in the "$_selectedCategory" category yet.'
                              : 'Be the first to create a post in the community!',
                          icon: Icons.post_add_rounded,
                          actionLabel: 'Create Post',
                          onActionPressed: () {
                            // Show create post dialog
                            _showCreatePostDialog();
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            final post = _posts[index];
                            // TODO: Implement PostCard widget
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text(post.userName),
                                subtitle: Text(post.content),
                                onTap: () => _showPostDetail(post),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _showCreatePostDialog() async {
    final theme = Theme.of(context);
    final contentController = TextEditingController();
    String selectedCategory = 'General';
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Create a Post',
              style: theme.textTheme.titleLarge,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category dropdown
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: [
                      'General',
                      'Testimonials',
                      'Business Tips',
                      'Prayer Requests',
                    ].map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Content text field
                  TextField(
                    controller: contentController,
                    decoration: InputDecoration(
                      labelText: 'What\'s on your mind?',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLines: 5,
                  ),
                  // Image upload option would go here in a full implementation
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (contentController.text.isNotEmpty) {
                    await DataService.addPost(
                      widget.userId.isEmpty ? 'current_user_id' : widget.userId,
                      'You', // In a real app, this would be the current user's name
                      contentController.text,
                      category: selectedCategory,
                    );
                    Navigator.pop(context, true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text('Post'),
              ),
            ],
          );
        },
      ),
    );
    
    if (result == true) {
      // Reload posts with the new one
      _loadData();
    }
  }
}