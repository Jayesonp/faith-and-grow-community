import 'package:flutter/material.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/models/community_model.dart';
import 'package:dreamflow/services/community_service.dart';
import 'package:dreamflow/services/donation_service.dart';
import 'package:dreamflow/widgets/common_widgets.dart';
import 'package:dreamflow/widgets/community_widgets.dart';
import 'package:dreamflow/screens/community_discovery_screen.dart';
import 'package:dreamflow/screens/community_dashboard_screen.dart';
import 'package:dreamflow/screens/auth_screen.dart';
import 'package:dreamflow/screens/membership_import_screen.dart';
import 'package:dreamflow/screens/donation_screen.dart';
import 'package:dreamflow/theme.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  
  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  User? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  List<Community> _ownedCommunities = [];
  List<Map<String, dynamic>> _memberships = [];
  List<Donation> _donations = [];
  double _totalDonations = 0.0;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _businessDescriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get user data
      final user = await UserService.getCurrentUser();
      
      if (user != null) {
        // Load user's owned communities
        final ownedCommunities = await CommunityService.getCommunitiesByCreator(user.id);
        
        // Load user's memberships with error handling
        List<CommunityMembership> memberships = [];
        try {
          memberships = await CommunityService.getUserMemberships(user.id);
        } catch (e) {
          print('Error loading user memberships: $e');
          // Continue with empty memberships list rather than failing entirely
        }
        
        // Prepare membership data with community and tier info
        final membershipData = <Map<String, dynamic>>[];
        for (final membership in memberships) {
          final community = await CommunityService.getCommunityById(membership.communityId);
          if (community != null) {
            // Find the tier
            CommunityTier? tier;
            try {
              tier = community.tiers.firstWhere((t) => t.id == membership.tierId);
            } catch (e) {
              tier = community.lowestTier;
            }
            
            membershipData.add({
              'membership': membership,
              'community': community,
              'tier': tier,
            });
          }
        }
        
        if (mounted) {
          setState(() {
            _user = user;
            _ownedCommunities = ownedCommunities;
            _memberships = membershipData;
            
            // Set controller values
            _nameController.text = user.name;
            _businessNameController.text = user.businessName ?? '';
            _businessDescriptionController.text = user.businessDescription ?? '';
          });
          
          // Load donation history
          try {
            final donations = await DonationService.getUserDonations(user.id);
            final totalDonations = await DonationService.getUserTotalDonation(user.id);
            
            if (mounted) {
              setState(() {
                _donations = donations;
                _totalDonations = totalDonations;
              });
            }
          } catch (e) {
            print('Error loading donation history: $e');
            // Continue without failing entirely
          }
        }
      }
    } catch (e) {
      print('Detailed profile loading error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
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
  
  void _toggleEditMode() {
    if (_user == null) return;
    
    setState(() {
      _isEditing = !_isEditing;
      
      if (_isEditing) {
        // Set current values
        _nameController.text = _user!.name;
        _businessNameController.text = _user!.businessName ?? '';
        _businessDescriptionController.text = _user!.businessDescription ?? '';
      }
    });
  }
  
  Future<void> _saveChanges() async {
    if (_user == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final name = _nameController.text.trim();
      final businessName = _businessNameController.text.trim().isNotEmpty ? _businessNameController.text.trim() : null;
      final businessDescription = _businessDescriptionController.text.trim().isNotEmpty ? _businessDescriptionController.text.trim() : null;
      
      // Update user with new values
      final updatedUser = _user!.copyWith(
        name: name,
        businessName: businessName,
        businessDescription: businessDescription,
      );
      
      // Save updated user
      await UserService.saveUser(updatedUser);
      
      setState(() {
        _user = updatedUser;
        _isEditing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    ) ?? false;
    
    if (!confirmed) return;
    
    await UserService.logout();
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: _isLoading
          ? const Center(child: FaithLoadingIndicator(message: 'Loading profile...'))
          : _user == null
              ? EmptyStateWidget(
                  message: 'Profile Not Available',
                  description: 'Please log in to view your profile',
                  icon: Icons.account_circle_outlined,
                  actionLabel: 'Login',
                  onActionPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthScreen()),
                    );
                  },
                )
              : RefreshIndicator(
                  onRefresh: _loadUserData,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Profile header with app bar
                      SliverAppBar(
                        expandedHeight: 200.0,
                        floating: false,
                        pinned: true,
                        stretch: true,
                        backgroundColor: theme.colorScheme.primary,
                        flexibleSpace: FlexibleSpaceBar(
                          title: Text(
                            'My Profile',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          background: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withOpacity(0.7),
                                  theme.colorScheme.secondary.withOpacity(0.5),
                                ],
                              ),
                            ),
                            child: Center(
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: theme.colorScheme.secondary,
                                child: CircleAvatar(
                                  radius: 55,
                                  backgroundColor: theme.colorScheme.surface,
                                  child: Text(
                                    _user!.name[0].toUpperCase(),
                                    style: theme.textTheme.displaySmall!.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          IconButton(
                            icon: Icon(
                              _isEditing ? Icons.save : Icons.edit,
                              color: theme.colorScheme.onPrimary,
                            ),
                            onPressed: _isEditing ? _saveChanges : _toggleEditMode,
                            tooltip: _isEditing ? 'Save changes' : 'Edit profile',
                          ),
                        ],
                      ),
                      // Profile content
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User info card
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: _isEditing 
                                    ? _buildEditProfileForm() 
                                    : _buildProfileInfo(),
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Stats card
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.insights, color: theme.colorScheme.primary),
                                          const SizedBox(width: 8),
                                          Text('Activity Stats', style: theme.textTheme.titleMedium),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(Icons.groups, color: theme.colorScheme.primary),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${_ownedCommunities.length + _memberships.length}',
                                                style: theme.textTheme.titleLarge!.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.colorScheme.primary,
                                                ),
                                              ),
                                              Text(
                                                'Communities',
                                                style: theme.textTheme.bodySmall!.copyWith(
                                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(Icons.create_outlined, color: theme.colorScheme.primary),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${_ownedCommunities.length}',
                                                style: theme.textTheme.titleLarge!.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.colorScheme.primary,
                                                ),
                                              ),
                                              Text(
                                                'Created',
                                                style: theme.textTheme.bodySmall!.copyWith(
                                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(Icons.person_add_outlined, color: theme.colorScheme.primary),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${_memberships.length}',
                                                style: theme.textTheme.titleLarge!.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.colorScheme.primary,
                                                ),
                                              ),
                                              Text(
                                                'Joined',
                                                style: theme.textTheme.bodySmall!.copyWith(
                                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // My Communities section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.groups, color: theme.colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Text('My Communities', style: theme.textTheme.titleLarge),
                                    ],
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Join More'),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CommunityDiscoveryScreen(
                                            userId: _user!.id,
                                          ),
                                        ),
                                      ).then((_) => _loadUserData());
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              
                              // Display communities
                              _ownedCommunities.isEmpty && _memberships.isEmpty
                                  ? Center(
                                      child: EmptyStateWidget(
                                        message: 'No Communities Joined',
                                        description: 'You haven\'t joined any communities yet. Discover communities to join!',
                                        icon: Icons.explore,
                                        actionLabel: 'Discover Communities',
                                        onActionPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CommunityDiscoveryScreen(
                                                userId: _user!.id,
                                              ),
                                            ),
                                          ).then((_) => _loadUserData());
                                        },
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Created communities section
                                        if (_ownedCommunities.isNotEmpty) ...[  
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.create,
                                                  size: 16,
                                                  color: theme.colorScheme.secondary,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Communities I Created',
                                                  style: theme.textTheme.titleMedium!.copyWith(
                                                    color: theme.colorScheme.secondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ..._ownedCommunities.map((community) {
                                            return Card(
                                              margin: const EdgeInsets.only(bottom: 8),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              elevation: 1,
                                              child: InkWell(
                                                onTap: () async {
                                                  // Check if user has a membership for their own community
                                                  final membership = await CommunityService.getUserMembership(
                                                    _user!.id,
                                                    community.id,
                                                  );
                                                  
                                                  if (mounted) {
                                                    // Navigate to community dashboard
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => CommunityDashboardScreen(
                                                          community: community,
                                                          userId: _user!.id,
                                                          membership: membership ?? 
                                                              CommunityMembership(
                                                                id: const Uuid().v4(),
                                                                userId: _user!.id,
                                                                communityId: community.id,
                                                                tierId: community.tiers.first.id,
                                                                joinedAt: DateTime.now(),
                                                              ),
                                                        ),
                                                      ),
                                                    ).then((_) => _loadUserData());
                                                  }
                                                },
                                                borderRadius: BorderRadius.circular(12),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(12.0),
                                                  child: Row(
                                                    children: [
                                                      // Community avatar
                                                      Container(
                                                        width: 50,
                                                        height: 50,
                                                        decoration: BoxDecoration(
                                                          color: theme.colorScheme.secondary,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            community.name[0].toUpperCase(),
                                                            style: theme.textTheme.titleLarge!.copyWith(
                                                              color: theme.colorScheme.onSecondary,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      // Community info
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              community.name,
                                                              style: theme.textTheme.titleMedium!.copyWith(
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 4),
                                                            Text(
                                                              community.shortDescription,
                                                              style: theme.textTheme.bodySmall!.copyWith(
                                                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      // Creator badge
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: theme.colorScheme.secondary.withOpacity(0.2),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons.star,
                                                              size: 16,
                                                              color: theme.colorScheme.secondary,
                                                            ),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              'Creator',
                                                              style: theme.textTheme.labelSmall!.copyWith(
                                                                color: theme.colorScheme.secondary,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Icon(
                                                        Icons.arrow_forward_ios,
                                                        size: 16,
                                                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          const SizedBox(height: 16),
                                        ],
                                        
                                        // Joined communities section
                                        if (_memberships.isNotEmpty) ...[  
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.person_add,
                                                  size: 16,
                                                  color: theme.colorScheme.primary,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Communities I Joined',
                                                  style: theme.textTheme.titleMedium!.copyWith(
                                                    color: theme.colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ..._memberships.map((membershipData) {
                                            final community = membershipData['community'] as Community;
                                            final tier = membershipData['tier'] as CommunityTier;
                                            final membership = membershipData['membership'] as CommunityMembership;
                                            
                                            return Card(
                                              margin: const EdgeInsets.only(bottom: 8),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              elevation: 1,
                                              child: InkWell(
                                                onTap: () {
                                                  // Navigate to community dashboard
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => CommunityDashboardScreen(
                                                        community: community,
                                                        userId: _user!.id,
                                                        membership: membership,
                                                      ),
                                                    ),
                                                  ).then((_) => _loadUserData());
                                                },
                                                borderRadius: BorderRadius.circular(12),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(12.0),
                                                  child: Row(
                                                    children: [
                                                      // Community avatar
                                                      Container(
                                                        width: 50,
                                                        height: 50,
                                                        decoration: BoxDecoration(
                                                          color: theme.colorScheme.primary,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            community.name[0].toUpperCase(),
                                                            style: theme.textTheme.titleLarge!.copyWith(
                                                              color: theme.colorScheme.onPrimary,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      // Community info
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              community.name,
                                                              style: theme.textTheme.titleMedium!.copyWith(
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 4),
                                                            Text(
                                                              community.shortDescription,
                                                              style: theme.textTheme.bodySmall!.copyWith(
                                                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            Row(
                                                              children: [
                                                                CommunityMembershipBadge(
                                                                  tierName: tier.name,
                                                                  size: 18,
                                                                ),
                                                                const SizedBox(width: 4),
                                                                if (tier.monthlyPrice > 0)
                                                                  Text(
                                                                    tier.formattedPrice,
                                                                    style: theme.textTheme.bodySmall!.copyWith(
                                                                      color: theme.colorScheme.primary,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Icon(
                                                        Icons.arrow_forward_ios,
                                                        size: 16,
                                                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ],
                                    ),
                              
                              const SizedBox(height: 24),
                              
                              // Import Memberships button (for admin/testing)
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const MembershipImportScreen(),
                                      ),
                                    ).then((_) => _loadUserData());
                                  },
                                  icon: Icon(
                                    Icons.upload_file,
                                    color: theme.colorScheme.secondary,
                                  ),
                                  label: Text(
                                    'Import Memberships',
                                    style: TextStyle(color: theme.colorScheme.secondary),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: BorderSide(color: theme.colorScheme.secondary),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Donation History Section
                              if (_donations.isNotEmpty) Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.volunteer_activism, color: theme.colorScheme.secondary),
                                      const SizedBox(width: 8),
                                      Text('Donation History', style: theme.textTheme.titleMedium),
                                      const Spacer(),
                                      Text(
                                        'Total: \$${_totalDonations.toStringAsFixed(2)}',
                                        style: theme.textTheme.titleSmall!.copyWith(
                                          color: theme.colorScheme.secondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  ...List.generate(_donations.length > 3 ? 3 : _donations.length, (index) {
                                    final donation = _donations[index];
                                    final dateFormatted = DateFormat.yMMMd().format(donation.createdAt);
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                                        child: Icon(Icons.volunteer_activism, color: theme.colorScheme.secondary),
                                      ),
                                      title: Text('\$${donation.amount.toStringAsFixed(2)}'),
                                      subtitle: Text('Date: $dateFormatted'),
                                      trailing: donation.cardLast4 != null
                                        ? Text('•••• ${donation.cardLast4}')
                                        : null,
                                    );
                                  }),
                                  if (_donations.length > 3)
                                    Align(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        onPressed: () {
                                          // Implement a donation history detail screen here if needed
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Viewing full donation history will be available in a future update')),
                                          );
                                        },
                                        child: Text('View All Donations'),
                                      ),
                                    ),
                                  SizedBox(height: 8),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => DonationScreen(userId: _user!.id)),
                                      ).then((_) => _loadUserData());
                                    },
                                    icon: Icon(Icons.add, color: theme.colorScheme.secondary),
                                    label: Text('Make a Donation', style: TextStyle(color: theme.colorScheme.secondary)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      side: BorderSide(color: theme.colorScheme.secondary),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Logout button
                              SizedBox(
                                width: double.infinity,
                                child: FaithButton(
                                  label: 'Logout',
                                  onPressed: _logout,
                                  isOutlined: true,
                                  icon: Icons.logout,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildProfileInfo() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('Personal Information', style: theme.textTheme.titleMedium),
          ],
        ),
        const Divider(),
        _buildProfileInfoItem(
          icon: Icons.account_circle_outlined,
          title: 'Full Name',
          value: _user!.name,
        ),
        _buildProfileInfoItem(
          icon: Icons.email_outlined,
          title: 'Email',
          value: _user!.email,
        ),
        if (_user!.businessName?.isNotEmpty ?? false)
          _buildProfileInfoItem(
            icon: Icons.business_outlined,
            title: 'Business Name',
            value: _user!.businessName!,
          ),
        if (_user!.businessDescription?.isNotEmpty ?? false)
          _buildProfileInfoItem(
            icon: Icons.description_outlined,
            title: 'Business Description',
            value: _user!.businessDescription!,
          ),
      ],
    );
  }
  
  Widget _buildProfileInfoItem({required IconData icon, required String title, required String value, Color? valueColor}) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium!.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: valueColor ?? theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEditProfileForm() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.edit, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('Edit Profile', style: theme.textTheme.titleMedium),
          ],
        ),
        const Divider(),
        const SizedBox(height: 16),
        
        // Name field
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Name',
            prefixIcon: Icon(Icons.person, color: theme.colorScheme.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Business Name field
        TextFormField(
          controller: _businessNameController,
          decoration: InputDecoration(
            labelText: 'Business Name (Optional)',
            prefixIcon: Icon(Icons.business, color: theme.colorScheme.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Business Description field
        TextFormField(
          controller: _businessDescriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Business Description (Optional)',
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 45),
              child: Icon(Icons.description, color: theme.colorScheme.primary),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),
        
        // Save/Cancel buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: _toggleEditMode,
              icon: const Icon(Icons.cancel, size: 16),
              label: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save, size: 16),
              label: const Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}