import 'package:flutter/material.dart';
import 'package:dreamflow/models/community_model.dart';
import 'package:dreamflow/models/content_model.dart';
import 'package:dreamflow/services/community_service.dart';
import 'package:dreamflow/services/admin_service.dart';
import 'package:dreamflow/services/data_service.dart';
import 'package:dreamflow/services/course_service.dart';
import 'package:dreamflow/widgets/common_widgets.dart';
import 'package:dreamflow/screens/course_detail_screen.dart';
import 'package:dreamflow/screens/course_creation_screen.dart';

class CommunityDashboardScreen extends StatefulWidget {
  final Community community;
  final String userId;
  final CommunityMembership membership;
  
  const CommunityDashboardScreen({
    Key? key,
    required this.community,
    required this.userId,
    required this.membership,
  }) : super(key: key);

  @override
  State<CommunityDashboardScreen> createState() => _CommunityDashboardScreenState();
}

class _CommunityDashboardScreenState extends State<CommunityDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Post> _posts = [];
  List<Course> _courses = [];
  List<CommunityMembership> _memberships = [];
  List<dynamic> _members = []; // This would be populated in a real app
  bool _isCreator = false;
  CommunityTier? _currentTier;
  final _postContentController = TextEditingController();
  bool _isSubmittingPost = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _postContentController.dispose();
    super.dispose();
  }
  
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Check if user is the creator
      _isCreator = widget.community.creatorId == widget.userId;
      
      // Get current tier information
      try {
        _currentTier = widget.community.tiers.firstWhere(
          (tier) => tier.id == widget.membership.tierId,
        );
      } catch (e) {
        // If tier not found, default to the lowest tier
        _currentTier = widget.community.lowestTier;
      }
      
      // Load community-specific content
      final posts = await DataService.getPosts();
      final courses = await CourseService.getCommunityCourses(widget.community.id);
      final memberships = await CommunityService.getCommunityMemberships(widget.community.id);
      
      // In a real app, you'd fetch actual user data for members
      // For now, just create placeholder member data
      final mockMembers = List.generate(
        memberships.length,
        (index) => {
          'id': 'user_$index',
          'name': 'Member ${index + 1}',
          'email': 'member${index + 1}@example.com',
          'profileImageUrl': index % 3 == 0 ? 
              "https://pixabay.com/get/g839b483bc1d6d6276872af95e7223882ad37b85898870d0cbeef80f59f5fa1647bf68461ed55cecfea07f445cefec6ae2e71080f173d427fb0ebdec7fae94565_1280.jpg" : null,
        },
      );
      
      setState(() {
        _posts = posts;
        _courses = courses;
        _memberships = memberships;
        _members = mockMembers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }
  
  void _createPost() {
    final content = _postContentController.text.trim();
    if (content.isEmpty) return;
    
    setState(() {
      _isSubmittingPost = true;
    });
    
    DataService.addPost(
      widget.userId,
      'You', // In a real app, you'd use the actual username
      content,
      category: widget.community.category,
    ).then((post) {
      setState(() {
        _posts.insert(0, post);
        _postContentController.clear();
        _isSubmittingPost = false;
      });
    }).catchError((error) {
      setState(() {
        _isSubmittingPost = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating post: $error')),
      );
    });
  }
  
  Widget _buildCreatePostForm() {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Post',
            style: theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primary,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _postContentController,
                  decoration: InputDecoration(
                    hintText: 'Share something with the community...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  maxLines: 4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.photo, color: theme.colorScheme.primary),
                    onPressed: () {
                      // Add photo attachment functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Photo attachment coming soon')),
                      );
                    },
                    tooltip: 'Add photo',
                  ),
                  IconButton(
                    icon: Icon(Icons.videocam, color: theme.colorScheme.secondary),
                    onPressed: () {
                      // Add video attachment functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Video attachment coming soon')),
                      );
                    },
                    tooltip: 'Add video',
                  ),
                  IconButton(
                    icon: Icon(Icons.link, color: theme.colorScheme.tertiary),
                    onPressed: () {
                      // Add link attachment functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link attachment coming soon')),
                      );
                    },
                    tooltip: 'Add link',
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _isSubmittingPost ? null : _createPost,
                icon: _isSubmittingPost
                    ? Container(
                        width: 20,
                        height: 20,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: const Text('Post'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showUpgradeDialog() {
    final theme = Theme.of(context);
    
    // Find tiers that are higher than the current one
    final availableUpgrades = widget.community.tiers
        .where((tier) => tier.monthlyPrice > (_currentTier?.monthlyPrice ?? 0))
        .toList();
    
    if (availableUpgrades.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You already have the highest membership tier!')),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AnimatedPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          duration: const Duration(milliseconds: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upgrade Membership',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Get more out of ${widget.community.name} with a premium membership tier.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              for (final tier in availableUpgrades) ...[            
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.star,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(tier.name),
                  subtitle: Text('${tier.features.length} features'),
                  trailing: Text(
                    tier.formattedPrice,
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, tier),
                ),
                const Divider(),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ).then((selectedTier) {
      if (selectedTier != null) {
        _upgradeMembership(selectedTier);
      }
    });
  }
  
  Future<void> _upgradeMembership(CommunityTier newTier) async {
    Navigator.pop(context); // Close dialog
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final updatedMembership = await CommunityService.upgradeMembership(
        userId: widget.userId,
        communityId: widget.community.id,
        newTierId: newTier.id,
      );
      
      if (updatedMembership != null) {
        // Show success animation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text('Upgraded to ${newTier.name} tier successfully!')),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Refresh the page with updated membership
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CommunityDashboardScreen(
                community: widget.community,
                userId: widget.userId,
                membership: updatedMembership,
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error upgrading membership: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _leaveCommunity() async {
    // Ask for confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Community?'),
        content: Text(
          'Are you sure you want to leave ${widget.community.name}? You will lose access to all content and conversations.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Leave'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    
    if (confirm != true) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await CommunityService.leaveCommunity(
        widget.userId,
        widget.community.id,
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have left ${widget.community.name}')),
        );
        
        // Navigate back to the discovery screen
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error leaving community: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showManageCommunityOptions() {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Community',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your community settings and content',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.edit,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Edit Community Details'),
              onTap: () {
                Navigator.pop(context);
                _showEditCommunityDialog();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.people,
                color: theme.colorScheme.secondary,
              ),
              title: const Text('Manage Members'),
              trailing: Text(
                '${_memberships.length}',
                style: theme.textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                _showMemberManagement();
              },
            ),
            ListTile(
              leading: Icon(
                widget.community.isPublished ? Icons.visibility_off : Icons.visibility,
                color: widget.community.isPublished ? Colors.orange : Colors.green,
              ),
              title: Text(widget.community.isPublished ? 'Unpublish Community' : 'Publish Community'),
              subtitle: Text(
                widget.community.isPublished 
                  ? 'Hide from discovery' 
                  : 'Make visible in discovery'
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleCommunityPublishStatus();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_forever,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Delete Community',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              subtitle: Text(
                'This action cannot be undone',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error.withOpacity(0.7),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteCommunityDialog();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEditCommunityDialog() {
    final nameController = TextEditingController(text: widget.community.name);
    final shortDescController = TextEditingController(text: widget.community.shortDescription);
    final fullDescController = TextEditingController(text: widget.community.fullDescription);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Community'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Community Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: shortDescController,
                decoration: const InputDecoration(
                  labelText: 'Short Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: fullDescController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Full Description',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateCommunity(
                nameController.text,
                shortDescController.text,
                fullDescController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCommunity(String name, String shortDesc, String fullDesc) async {
    try {
      await AdminService.updateCommunity(
        communityId: widget.community.id,
        name: name,
        shortDescription: shortDesc,
        fullDescription: fullDesc,
        category: widget.community.category, // Keep existing category
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Community updated successfully')),
      );

      // Refresh the page with updated community data
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CommunityDashboardScreen(
              community: widget.community.copyWith(
                name: name,
                shortDescription: shortDesc,
                fullDescription: fullDesc,
              ),
              userId: widget.userId,
              membership: widget.membership,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating community: $e')),
      );
    }
  }

  void _showMemberManagement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Manage Members',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _memberships.length,
                itemBuilder: (context, index) {
                  final membership = _memberships[index];
                  final member = index < _members.length ? _members[index] : null;
                  final tierName = widget.community.tiers
                    .firstWhere(
                      (tier) => tier.id == membership.tierId,
                      orElse: () => widget.community.lowestTier,
                    ).name;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        member?['name']?[0].toUpperCase() ?? '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(member?['name'] ?? 'Unknown Member'),
                    subtitle: Text('$tierName tier'),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showMemberOptions(membership, member),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMemberOptions(CommunityMembership membership, Map<String, dynamic>? member) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(member?['name'] ?? 'Unknown Member'),
            subtitle: Text(member?['email'] ?? ''),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.remove_circle_outline, color: theme.colorScheme.error),
            title: const Text('Remove from Community'),
            onTap: () {
              Navigator.pop(context);
              _showRemoveMemberDialog(membership, member);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showRemoveMemberDialog(CommunityMembership membership, Map<String, dynamic>? member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member?'),
        content: Text(
          'Are you sure you want to remove ${member?['name'] ?? 'this member'} from the community? They will lose access to all content and conversations.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await CommunityService.removeMember(
          membership.userId,
          widget.community.id,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${member?['name'] ?? 'Member'} has been removed')),
          );
          _loadData(); // Refresh member list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error removing member: $e')),
          );
        }
      }
    }
  }

  Future<void> _toggleCommunityPublishStatus() async {
    final newStatus = !widget.community.isPublished;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(newStatus ? 'Publish Community' : 'Unpublish Community'),
        content: Text(
          newStatus
            ? 'Are you sure you want to publish "${widget.community.name}"? This will make it visible to all users.'
            : 'Are you sure you want to unpublish "${widget.community.name}"? This will hide it from public view.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? Colors.green : Colors.orange,
            ),
            child: Text(newStatus ? 'Publish' : 'Unpublish'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AdminService.setCommunityPublishStatus(
          communityId: widget.community.id,
          isPublished: newStatus,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(
              newStatus 
                ? 'Community published successfully' 
                : 'Community unpublished successfully'
            )),
          );

          // Refresh the page with updated community data
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CommunityDashboardScreen(
                community: widget.community.copyWith(isPublished: newStatus),
                userId: widget.userId,
                membership: widget.membership,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating community: $e')),
          );
        }
      }
    }
  }

  void _showDeleteCommunityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Community?'),
        content: Text(
          'Are you sure you want to delete "${widget.community.name}"? This will permanently remove the community and all its content. This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _deleteCommunity,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCommunity() async {
    try {
      await AdminService.deleteCommunity(widget.community.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Community deleted successfully')),
        );

        // Navigate back to the discovery screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting community: $e')),
        );
      }
    }
  }

  Future<void> _createCourse() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseCreationScreen(
          communityId: widget.community.id,
          creatorId: widget.userId,
          minimumTier: widget.community.lowestTier,
        ),
      ),
    );

    if (result != null) {
      // Refresh courses list
      setState(() {
        _courses.add(result);
      });
    }
  }

  void _navigateToCourseDetail(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(
          course: course,
          userId: widget.userId,
          initialProgress: 0.0,
          onProgressUpdated: (courseId, progress) {
            // Handle progress update
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: _isLoading
          ? const Center(child: FaithLoadingIndicator())
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 200,
                    floating: true,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        widget.community.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: innerBoxIsScrolled ? [] : [
                            Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 3, offset: const Offset(0, 1)),
                          ],
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Community cover image
                          Image.network(
                            widget.community.coverImageUrl ?? 
                              "https://pixabay.com/get/gc283668bb4e7eb04cf479da7879616907595b6a1b584b7509b0aeb55e760a361b8f01992597e0eb8d091ee23dbe33fca976bbb7328fd6489e439e1d1aa7a9a5e_1280.jpg",
                            fit: BoxFit.cover,
                          ),
                          // Gradient overlay for better text visibility
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                                stops: const [0.6, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      if (_isCreator)
                        IconButton(
                          icon: const Icon(Icons.settings),
                          tooltip: 'Manage community',
                          onPressed: _isCreator ? () => _showManageCommunityOptions() : null,
                        ),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(kToolbarHeight),
                      child: Container(
                        decoration: BoxDecoration(
                          // Using a gradient for better contrast against any background
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: theme.colorScheme.primary,
                          indicatorWeight: 3,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white.withOpacity(0.7),
                          labelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                              Shadow(
                                color: Colors.black,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          indicator: UnderlineTabIndicator(
                            borderSide: BorderSide(
                              width: 3,
                              color: theme.colorScheme.primary,
                            ),
                            insets: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          tabs: const [
                            Tab(text: 'Feed'),
                            Tab(text: 'Courses'),
                            Tab(text: 'Members'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildFeedTab(),
                  _buildCoursesTab(),
                  _buildMembersTab(),
                ],
              ),
            ),
      floatingActionButton: _tabController.index == 0 // Only show on Feed tab
          ? FloatingActionButton(
              onPressed: () {
                // Show bottom sheet to create post
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                      left: 16,
                      right: 16,
                      top: 16,
                    ),
                    child: _buildCreatePostForm(),
                  ),
                );
              },
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Current tier badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _currentTier?.name ?? 'Basic',
                      style: theme.textTheme.labelMedium!.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Upgrade button
              if (_currentTier != widget.community.tiers.reduce(
                    (a, b) => a.monthlyPrice > b.monthlyPrice ? a : b))
                TextButton.icon(
                  onPressed: _showUpgradeDialog,
                  icon: Icon(
                    Icons.upgrade,
                    size: 16,
                    color: theme.colorScheme.secondary,
                  ),
                  label: Text(
                    'Upgrade',
                    style: TextStyle(color: theme.colorScheme.secondary),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              const Spacer(),
              // Leave community button
              if (!_isCreator) // Creator can't leave their own community
                TextButton.icon(
                  onPressed: _leaveCommunity,
                  icon: Icon(
                    Icons.exit_to_app,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                  label: Text(
                    'Leave',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeedTab() {
    final theme = Theme.of(context);
    
    if (_posts.isEmpty) {
      // Using theme variable to style the empty state widget
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: EmptyStateWidget(
            message: 'No Posts Yet',
            description: 'Be the first to create a post in this community!',
            icon: Icons.post_add_rounded,
            actionLabel: 'Create Post',
            onActionPressed: _createPost,
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.separated(
          itemCount: _posts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final post = _posts[index];
            // TODO: Implement PostCard widget
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(post.userName),
                subtitle: Text(post.content),
                onTap: () {}, // No action for now
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildCoursesTab() {
    final theme = Theme.of(context);
    final minTier = _currentTier;
    
    if (minTier == null) {
      return const Center(child: Text('Error: Could not determine your membership tier'));
    }
    
    // Determine if the user's tier allows access to courses
    bool hasAccess = true; // Simplified - in a real app you'd check tier permissions
    
    if (!hasAccess) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Premium Content',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upgrade your membership to access courses',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_courses.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          message: 'No Courses Available',
          description: 'The community owner hasn\'t added any courses yet.',
          icon: Icons.school_rounded,
          actionLabel: _isCreator ? 'Add Course' : null,
          onActionPressed: _isCreator ? _createCourse : null,
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isCreator)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton.icon(
                onPressed: _createCourse,
                icon: const Icon(Icons.add),
                label: const Text('Create Course'),
              ),
            ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: Card(
                    child: InkWell(
                      onTap: () => _navigateToCourseDetail(course),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              course.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                Container(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  child: Icon(
                                    Icons.school,
                                    size: 48,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${course.totalLessons} lessons • ${course.formattedDuration}',
                                  style: TextStyle(
                                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMembersTab() {
    final theme = Theme.of(context);
    
    if (_memberships.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: EmptyStateWidget(
            message: 'No Members Yet',
            description: 'Share your community with others to grow your membership!',
            icon: Icons.people_outline,
            actionLabel: 'Share Community',
            onActionPressed: () {
              // Share community functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing coming soon')),
              );
            },
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Members (${_memberships.length})',
            style: theme.textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _memberships.length,
              itemBuilder: (context, index) {
                // In a real app, you'd use member.userId to get the user's profile data
                final membership = _memberships[index];
                final member = index < _members.length ? _members[index] : null;
                final tierName = widget.community.tiers
                    .firstWhere(
                      (tier) => tier.id == membership.tierId,
                      orElse: () => widget.community.lowestTier,
                    ).name;
                    
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                      backgroundImage: member != null && member['profileImageUrl'] != null
                          ? NetworkImage(member['profileImageUrl'])
                          : null,
                      child: member == null || member['profileImageUrl'] == null
                          ? Text(
                              member != null && member['name'] != null ? member['name'][0] : '?',
                              style: TextStyle(color: theme.colorScheme.primary),
                            )
                          : null,
                    ),
                    title: Text(member != null && member['name'] != null ? member['name'] : 'Member ${index + 1}'),
                    subtitle: Text(
                      'Joined ${membership.joinedAt.month}/${membership.joinedAt.day}/${membership.joinedAt.year}',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tierName,
                        style: theme.textTheme.labelSmall!.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}