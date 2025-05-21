import 'package:flutter/material.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/services/community_service.dart';
import 'package:dreamflow/screens/community_discovery_screen.dart';
import 'package:dreamflow/screens/community_creation_screen.dart';
import 'package:dreamflow/screens/community_detail_screen.dart';
import 'package:dreamflow/screens/community_dashboard_screen.dart';
import 'package:dreamflow/models/community_model.dart';
import 'package:dreamflow/screens/community_payment_screen.dart';
import 'package:dreamflow/screens/pricing_screen.dart';
import 'package:dreamflow/screens/pricing_example_screen.dart';
import 'package:dreamflow/screens/donation_screen.dart';
import 'package:dreamflow/services/dev_mode_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:animations/animations.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  User? _user;
  List<Community> _userCommunities = [];
  List<Community> _recommendedCommunities = [];
  List<CommunityMembership> _memberships = [];
  Map<String, dynamic>? _creationEligibility;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isDevModeActive = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
    _loadData();
    _checkDevMode();
  }
  
  // Check if developer mode is active
  Future<void> _checkDevMode() async {
    final isDevMode = await DevModeService.isDevModeEnabled();
    final bypassPayment = await DevModeService.shouldBypassPayment();
    
    if (mounted && (isDevMode && bypassPayment)) {
      setState(() {
        _isDevModeActive = true;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get current user
      final user = await UserService.getCurrentUser();
      
      if (user != null) {
        // Get user's communities
        final userCommunities = await CommunityService.getCommunitiesByCreator(user.id);
        
        // Get user's memberships
        final memberships = await CommunityService.getUserMemberships(user.id);
        
        // Get recommended communities
        final recommendedCommunities = await CommunityService.getCommunities();
        
        // Check if user can create a community
        final creationEligibility = await CommunityService.verifyCreationEligibility(user.id);
        
        if (mounted) {
          setState(() {
            _user = user;
            _userCommunities = userCommunities;
            _memberships = memberships;
            _recommendedCommunities = recommendedCommunities
                .where((c) => !userCommunities.any((uc) => uc.id == c.id))
                .where((c) => !memberships.any((m) => m.communityId == c.id))
                .take(5)
                .toList();
            _creationEligibility = creationEligibility;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_user == null) {
      return const Center(
        child: Text('Please login to access your dashboard'),
      );
    }
    
    _animationController.forward();
    
    // Determine responsive spacing based on screen size
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1200;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1200;
    
    // Adjust horizontal padding based on device size
    final horizontalPadding = isDesktop ? 24.0 : (isTablet ? 20.0 : 16.0);
    final sectionSpacing = isDesktop ? 32.0 : 24.0;
    
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding, 
              vertical: isDesktop ? 24.0 : 16.0
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - (kToolbarHeight + 32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(),
                  SizedBox(height: sectionSpacing),
                  _buildQuickActions(),
                  SizedBox(height: sectionSpacing),
                  _buildMyCommunities(),
                  SizedBox(height: sectionSpacing),
                  _buildMyCreatedCommunities(),
                  SizedBox(height: sectionSpacing),
                  _buildRecommendedCommunities(),
                  SizedBox(height: sectionSpacing),
                  _buildTestimonialsSection(),
                  const SizedBox(height: 120), // Extra space for FAB
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _getTimeBasedGreeting(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              if (_isDevModeActive)
                Tooltip(
                  message: 'Developer Mode Active: Payment Verification Bypassed',
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.code,
                          color: Colors.white,
                          size: 14.r,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'DEV MODE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            _user?.name ?? 'User',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  Widget _buildQuickActions() {
    // Determine if we're on web and get screen properties for responsive layout
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768; // Tablet+ breakpoint
    
    // Actions to display
    final actions = [
      {
        'widget': _buildCreateCommunityButton(),
      },
      {
        'widget': _buildQuickActionButton(
          context, 
          icon: Icons.search,
          label: 'Discover',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommunityDiscoveryScreen(userId: _user!.id),
              ),
            );
          },
        ),
      },
      {
        'widget': _buildQuickActionButton(
          context, 
          icon: Icons.volunteer_activism,
          label: 'Donate',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DonationScreen(userId: _user!.id),
              ),
            );
          },
        ),
      },
      {
        'widget': _buildPricingButton(),
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        // Use LayoutBuilder to adjust based on available width
        LayoutBuilder(
          builder: (context, constraints) {
            // For web desktop, adjust column count based on width
            final buttonWidth = 120.0; // Target width per button
            
            // Determine number of columns that would fit
            final availableWidth = constraints.maxWidth;
            final possibleColumns = (availableWidth / buttonWidth).floor();
            
            // Cap columns based on platform and screen size
            int columnCount;
            if (isWeb) {
              // Web responsive columns
              if (screenWidth >= 1200) {
                columnCount = 4; // Large desktop: 4 columns
              } else if (screenWidth >= 768) {
                columnCount = 4; // Tablet/small desktop: 4 columns
              } else {
                columnCount = 2; // Mobile web: 2 columns
              }
            } else {
              // Native app columns
              if (availableWidth >= 600) {
                columnCount = 4; // Wide enough for 4 columns
              } else if (availableWidth >= 400) {
                columnCount = 2; // Wide enough for 2 columns
              } else {
                columnCount = 2; // Default to 2 columns for small screens
              }
            }
            
            // Organize buttons into rows for optimal layout
            final rows = <Widget>[];
            
            for (var i = 0; i < actions.length; i += columnCount) {
              final rowChildren = <Widget>[];
              
              for (var j = 0; j < columnCount && i + j < actions.length; j++) {
                rowChildren.add(Expanded(child: actions[i + j]['widget'] as Widget));
              }
              
              // Add empty Expanded widgets if the row isn't full (to maintain equal widths)
              if (rowChildren.length < columnCount && rowChildren.isNotEmpty) {
                final emptyColumns = columnCount - rowChildren.length;
                for (var k = 0; k < emptyColumns; k++) {
                  rowChildren.add(Expanded(child: Container()));
                }
              }
              
              rows.add(
                Padding(
                  padding: EdgeInsets.only(bottom: rowChildren.isNotEmpty ? 16.0 : 0),
                  child: Row(children: rowChildren),
                ),
              );
            }
            
            return Column(children: rows);
          },
        ),
      ],
    );
  }
  
  Widget _buildPricingButton() {
    return _buildQuickActionButton(
      context,
      icon: Icons.card_membership,
      label: 'Upgrade',
      onTap: () {
        // Show our new pricing example screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PricingExampleScreen()),
        ).then((_) => _loadData());
      },
    );
  }
  
  void _showSubscriptionRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Subscription Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'A subscription is required to create community groups. Would you like to view our subscription plans?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Community plan (\$47/mo): Create 1 community group',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Growth plan (\$97/mo): Create up to 5 community groups',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Mastermind plan (\$297/mo): Create unlimited community groups',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PricingScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text('View Plans'),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateCommunityButton() {
    final bool canCreate = _creationEligibility?['canCreate'] ?? false;
    final String? reason = _creationEligibility?['reason'];
    final String? subscriptionTier = _creationEligibility?['subscriptionTier'];
    final String? limitMessage = _creationEligibility?['limitMessage'];
    final dynamic remainingGroups = _creationEligibility?['remainingGroups'];
    final int? communityCount = _creationEligibility?['communityCount'];
    final int? communityLimit = _creationEligibility?['communityLimit'];

    String label = 'Create';
    if (remainingGroups != null && subscriptionTier != null) {
      if (remainingGroups == 'unlimited') {
        label = 'Create';
      } else if (int.tryParse(remainingGroups.toString()) == 0) {
        label = 'Upgrade';
      } else {
        label = 'Create ($remainingGroups left)';
      }
    }

    return _buildQuickActionButton(
      context,
      icon: Icons.add_circle,
      label: label,
      onTap: () {
        if (canCreate) {
          // If user has a subscription that allows creation, show info dialog first
          if (subscriptionTier != null && limitMessage != null) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Community Creation', style: Theme.of(context).textTheme.titleLarge),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      limitMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (communityCount != null && communityLimit != null && communityLimit != -1) ...[  
                      const SizedBox(height: 16),
                      Text(
                        'You have created $communityCount of $communityLimit allowed groups.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (communityLimit == -1 && communityCount != null) ...[  
                      const SizedBox(height: 16),
                      Text(
                        'You have created $communityCount community groups.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommunityCreationScreen(userId: _user!.id),
                        ),
                      ).then((_) => _loadData());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: Text('Continue'),
                  ),
                ],
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommunityCreationScreen(userId: _user!.id),
              ),
            ).then((_) => _loadData());
          }
        } else {
          // Show dialog explaining why they can't create and offering upgrade
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Upgrade Needed', style: Theme.of(context).textTheme.titleLarge),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    reason ?? 'You need to upgrade your subscription to create a community.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Would you like to view our subscription plans?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Not Now'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommunityPaymentScreen(userId: _user!.id, selectedPlan: 'growth'),
                      ),
                    ).then((_) => _loadData());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Text('View Plans'),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildMyCommunities() {
    // Filter to only show memberships, not communities created by the user
    final joinedCommunities = _memberships
        .where((membership) => !_userCommunities.any((c) => c.id == membership.communityId))
        .toList();
    
    if (joinedCommunities.isEmpty) {
      return Container();
    }
    
    // Check for web and screen size for responsive layout
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768; // Use tablet+ breakpoint for grid layout
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Communities',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        // Use grid layout for desktop/tablet and horizontal list for mobile
        if (isWeb && isDesktop)
          // Grid layout for desktop/tablet web views
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: screenWidth >= 1200 ? 3 : 2, // 3 columns for large desktop, 2 for tablet
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: joinedCommunities.length,
            itemBuilder: (context, index) {
              return _buildCommunityCard(
                _recommendedCommunities.firstWhere(
                  (c) => c.id == joinedCommunities[index].communityId,
                  orElse: () => Community(
                    id: 'unknown',
                    creatorId: 'unknown',
                    name: 'Unknown Community',
                    shortDescription: 'This community could not be found',
                    fullDescription: 'This community could not be found',
                    category: 'Other',
                    tiers: [],
                    createdAt: DateTime.now(),
                  ),
                ),
                joinedCommunities[index],
              );
            },
          )
        else
          // Horizontal list for mobile and non-web views
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: joinedCommunities.length,
              itemBuilder: (context, index) {
                return _buildCommunityCard(
                  _recommendedCommunities.firstWhere(
                    (c) => c.id == joinedCommunities[index].communityId,
                    orElse: () => Community(
                      id: 'unknown',
                      creatorId: 'unknown',
                      name: 'Unknown Community',
                      shortDescription: 'This community could not be found',
                      fullDescription: 'This community could not be found',
                      category: 'Other',
                      tiers: [],
                      createdAt: DateTime.now(),
                    ),
                  ),
                  joinedCommunities[index],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMyCreatedCommunities() {
    if (_userCommunities.isEmpty) {
      return Container();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Created Communities',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (_creationEligibility?['communityLimit'] != null && 
                _creationEligibility?['communityCount'] != null &&
                _creationEligibility?['communityLimit'] != -1)
              Text(
                '${_creationEligibility?["communityCount"]}/${_creationEligibility?["communityLimit"]}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            if (_creationEligibility?['communityLimit'] == -1)
              Text(
                'Unlimited',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _userCommunities.length,
            itemBuilder: (context, index) {
              return _buildCreatorCommunityCard(_userCommunities[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedCommunities() {
    if (_recommendedCommunities.isEmpty) {
      return Container();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discover Communities',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recommendedCommunities.length,
            itemBuilder: (context, index) {
              return _buildDiscoveryCommunityCard(_recommendedCommunities[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityCard(Community community, CommunityMembership membership) {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => CommunityDashboardScreen(
                community: community,
                userId: _user!.id,
                membership: membership,
              ),
            ),
          ).then((_) => _loadData());
        },
        child: SizedBox(
          width: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Community image
              Container(
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(community.coverImageUrl ?? 
                      'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800&q=80'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // Gradient overlay for better text visibility
                    Container(
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
                    // Category chip
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          community.category,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    // Community name
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        community.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Community description
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community.shortDescription,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatorCommunityCard(Community community) {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Get the current user's membership to their own community
          CommunityService.getUserMembership(_user!.id, community.id).then((membership) {
            if (membership != null) {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => CommunityDashboardScreen(
                    community: community,
                    userId: _user!.id,
                    membership: membership,
                  ),
                ),
              ).then((_) => _loadData());
            } else {
              // If no membership found, create one (should not happen normally)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error accessing your community')),
              );
            }
          });
        },
        child: SizedBox(
          width: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Community image
              Container(
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(community.coverImageUrl ?? 
                      'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800&q=80'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // Gradient overlay for better text visibility
                    Container(
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
                    // Owner badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
                              color: Theme.of(context).colorScheme.onTertiary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Creator',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onTertiary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Community name
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        community.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Community info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${community.memberCount} members',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Icon(
                          community.isPublished ? Icons.public : Icons.lock,
                          size: 16,
                          color: community.isPublished
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          community.isPublished ? 'Public' : 'Private',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoveryCommunityCard(Community community) {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => CommunityDetailScreen(
                community: community,
                userId: _user!.id,
              ),
            ),
          ).then((_) => _loadData());
        },
        child: SizedBox(
          width: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Community image
              Container(
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(community.coverImageUrl ?? 
                      'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800&q=80'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // Gradient overlay for better text visibility
                    Container(
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
                    // Category chip
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          community.category,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ),
                    // Community name
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        community.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Community description and pricing
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community.shortDescription,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'From ${community.lowestTier.formattedPrice}/month',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
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
  }

  Widget _buildTestimonialsSection() {
    // Check for web and screen size for responsive layout
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768; // Use tablet+ breakpoint for grid layout
    
    // Success stories testimonials data
    final testimonials = [
      {
        'name': 'Sarah Miller',
        'title': 'Ministry Consultant',
        'image': 'https://randomuser.me/api/portraits/women/4.jpg',
        'quote': '"Creating my own community through Faith & Grow has been a game-changer for my ministry. I\'ve been able to build a thriving community of like-minded entrepreneurs and generate consistent income."',
      },
      {
        'name': 'John Roberts',
        'title': 'Christian Business Coach',
        'image': 'https://randomuser.me/api/portraits/men/32.jpg',
        'quote': '"The platform helped me scale my coaching practice by connecting me with entrepreneurs who share my values. The community features are exceptional."',
      },
      {
        'name': 'Rebecca Thompson',
        'title': 'Faith-Based Author',
        'image': 'https://randomuser.me/api/portraits/women/22.jpg',
        'quote': '"I\'ve been able to build a membership around my books and teachings. Faith & Grow makes it easy to manage content and engage with my readers."',
      },
    ];
    
    // Build a single testimonial card
    Widget buildTestimonialCard(Map<String, String> testimonial, VoidCallback onTap) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isWeb && isDesktop)
                  Text(
                    'Success Story',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (isWeb && isDesktop) const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(testimonial['image']!),
                      radius: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            testimonial['name']!,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            testimonial['title']!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            testimonial['quote']!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: isWeb && isDesktop ? 4 : 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Christian Entrepreneurs Say...',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        // Use grid layout for desktop/tablet web views
        if (isWeb && isDesktop)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: screenWidth >= 1200 ? 3 : 2, // 3 columns for large desktop, 2 for tablet
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: testimonials.length,
            itemBuilder: (context, index) {
              return OpenContainer(
                transitionType: ContainerTransitionType.fadeThrough,
                openBuilder: (context, _) => _buildTestimonialDetailScreen(),
                closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                closedBuilder: (context, openContainer) {
                  return buildTestimonialCard(testimonials[index], openContainer);
                },
              );
            },
          )
        else
          // Single card for mobile view
          OpenContainer(
            transitionType: ContainerTransitionType.fadeThrough,
            openBuilder: (context, _) => _buildTestimonialDetailScreen(),
            closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            closedBuilder: (context, openContainer) => InkWell(
              onTap: openContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Success Stories',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(testimonials[0]['image']!),
                          radius: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                testimonials[0]['name']!,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                testimonials[0]['title']!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                testimonials[0]['quote']!,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: openContainer,
                        child: Text('Read More Stories'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
        // Add a "View All" button for mobile view
        if (!isWeb || !isDesktop)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => _buildTestimonialDetailScreen(),
                    ),
                  );
                },
                child: Text('View All Success Stories'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTestimonialDetailScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Success Stories'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How Faith & Grow Helps Christian Entrepreneurs',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage('https://randomuser.me/api/portraits/women/4.jpg'),
                            radius: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sarah Miller',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  'Ministry Consultant',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '"Creating my own community through Faith & Grow has been a game-changer for my ministry. I\'ve been able to build a thriving community of like-minded entrepreneurs and generate consistent income. The platform is so easy to use, and the support has been incredible. I started with just a few members, and now I have over 50 paying subscribers!"',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Key Benefits:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _buildBulletPoint('Created a community of 50+ members'),
                      _buildBulletPoint('Generates \$2,500/month in membership fees'),
                      _buildBulletPoint('Launched 3 courses within her community')
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/43.jpg'),
                            radius: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Michael Johnson',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  'Christian Business Coach',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '"The unlimited communities feature on the Mastermind plan has been instrumental in scaling my business. I\'ve created different communities for various aspects of Christian entrepreneurship, allowing me to serve specific niches while maintaining a cohesive brand. The ROI has been incredible!"',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Key Benefits:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _buildBulletPoint('Created 7 distinct community groups'),
                      _buildBulletPoint('Serves over 200 Christian entrepreneurs'),
                      _buildBulletPoint('10x return on his subscription investment'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}