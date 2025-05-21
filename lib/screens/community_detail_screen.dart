import 'package:flutter/material.dart';
import 'package:dreamflow/models/community_model.dart';
import 'package:dreamflow/services/community_service.dart';
import 'package:dreamflow/widgets/community_widgets.dart';
import 'package:dreamflow/screens/community_dashboard_screen.dart';
import 'package:dreamflow/widgets/common_widgets.dart';
import 'package:dreamflow/theme.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommunityDetailScreen extends StatefulWidget {
  final Community community;
  final String userId;
  
  const CommunityDetailScreen({
    Key? key,
    required this.community,
    required this.userId,
  }) : super(key: key);

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isMember = false;
  CommunityTier? _selectedTier;
  CommunityMembership? _membership;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _checkMembershipStatus();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _checkMembershipStatus() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Check if the user is already a member
      final membership = await CommunityService.getUserMembership(
        widget.userId, 
        widget.community.id
      );
      
      if (membership != null) {
        // If they are a member, check which tier they belong to
        CommunityTier? userTier;
        
        for (var tier in widget.community.tiers) {
          if (tier.id == membership.tierId) {
            userTier = tier;
            break;
          }
        }
        
        setState(() {
          _isMember = true;
          _membership = membership;
          if (userTier != null) {
            _selectedTier = userTier;
          } else {
            // Fallback to the first tier if the user's tier can't be found
            _selectedTier = widget.community.tiers.first;
          }
        });
      } else {
        // If they are not a member, pre-select the lowest tier by default
        setState(() {
          _isMember = false;
          _membership = null;
          
          // Pre-select the lowest priced tier
          if (widget.community.tiers.isNotEmpty) {
            CommunityTier lowestTier = widget.community.tiers.first;
            
            for (var tier in widget.community.tiers) {
              if (tier.monthlyPrice < lowestTier.monthlyPrice) {
                lowestTier = tier;
              }
            }
            
            _selectedTier = lowestTier;
          }
        });
      }
      
      // Start the animation after setting the state
      _animationController.forward();
    } catch (e) {
      print('Error checking membership status: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading membership data: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      
      // Set default state
      setState(() {
        _isMember = false;
        _membership = null;
        if (widget.community.tiers.isNotEmpty) {
          _selectedTier = widget.community.tiers.first;
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _selectTier(CommunityTier tier) {
    setState(() {
      _selectedTier = tier;
    });
  }
  
  Future<void> _joinCommunity() async {
    if (_selectedTier == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Clear any existing corrupted membership data first
      await CommunityService.getMemberships();
      
      final membership = await CommunityService.joinCommunity(
        userId: widget.userId,
        communityId: widget.community.id,
        tierId: _selectedTier!.id,
      );
      
      if (membership != null) {
        setState(() {
          _isMember = true;
          _membership = membership;
        });
        
        // Show success animation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text('Successfully joined ${widget.community.name}!')),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Short delay to allow user to see the success message
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _navigateToCommunityDashboard();
          }
        });
      }
    } catch (e) {
      // Show a more user-friendly error message
      String errorMessage = 'Unable to join community';
      
      if (e.toString().contains('type \'String\' is not a subtype of type \'List<dynamic>?\'')) {
        errorMessage = 'There was a problem with membership data. Please try again.';
        // Fix the data format by resetting memberships
        await CommunityService.saveMemberships([]);
      } else {
        errorMessage = 'Error: ${e.toString().split(':').last.trim()}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _navigateToCommunityDashboard([CommunityMembership? customMembership]) {
    final membershipToUse = customMembership ?? _membership;
    
    if (membershipToUse != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommunityDashboardScreen(
            community: widget.community,
            userId: widget.userId,
            membership: membershipToUse,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: _isLoading
        ? const Center(child: FaithLoadingIndicator(message: "Loading community details..."))
        : CustomScrollView(
            slivers: [
              // Flexible app bar with community cover image
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).orientation == Orientation.landscape ? 150 : 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.community.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width < 360 ? 16.0 : 18.0,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 1),
                          blurRadius: 3.0,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Community cover image
                      if (widget.community.coverImageUrl != null)
                        Image.network(
                          widget.community.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: theme.colorScheme.primary,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          color: theme.colorScheme.primary,
                          child: Center(
                            child: Icon(
                              Icons.groups,
                              size: 50,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
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
                    ],
                  ),
                ),
                actions: [
                  if (_isMember)
                    IconButton(
                      icon: const Icon(Icons.dashboard, color: Colors.white),
                      onPressed: () => _navigateToCommunityDashboard(),
                      tooltip: 'Go to dashboard',
                    ),
                ],
              ),
              
              // Community content
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width < 360 ? 12.0 : 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Community meta info
                        Row(
                          children: [
                            _buildCategoryChip(context),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.community.memberCount} members',
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Community description
                        Text(
                          widget.community.shortDescription,
                          style: theme.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.community.fullDescription,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        
                        // Membership options
                        _isMember
                          ? ElevatedButton.icon(
                              onPressed: () => _navigateToCommunityDashboard(),
                              icon: const Icon(Icons.dashboard),
                              label: const Text('Go to Community Dashboard'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              ),
                            )
                          : _buildMembershipCard(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }
  
  Widget _buildCategoryChip(BuildContext context) {
    final theme = Theme.of(context);
    final Color chipColor = theme.colorScheme.secondary;
    final IconData categoryIcon = _getCategoryIcon(widget.community.category);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: chipColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoryIcon,
            size: 16,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            widget.community.category,
            style: theme.textTheme.labelMedium!.copyWith(
              color: chipColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'business':
        return Icons.business;
      case 'ministry':
        return Icons.church;
      case 'arts & media':
        return Icons.brush;
      case 'education':
        return Icons.school;
      case 'health & wellness':
        return Icons.health_and_safety;
      case 'technology':
        return Icons.computer;
      case 'family':
        return Icons.family_restroom;
      default:
        return Icons.category;
    }
  }
  
  Widget _buildMembershipCard(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Join this Community',
              style: theme.textTheme.titleLarge!.copyWith(
                fontSize: isSmallScreen ? 18 : 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select a membership tier to access content',
              style: theme.textTheme.bodyMedium!.copyWith(
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            // Tier selection
            ...widget.community.tiers.map((tier) {
              final isSelected = _selectedTier?.id == tier.id;
              return InkWell(
                onTap: () => _selectTier(tier),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Selection indicator
                      Radio<String>(
                        value: tier.id,
                        groupValue: _selectedTier?.id,
                        onChanged: (_) => _selectTier(tier),
                        activeColor: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      // Tier info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tier.name,
                                  style: theme.textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : null,
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                                Text(
                                  tier.formattedPrice,
                                  style: theme.textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.secondary,
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? 6 : 8),
                            // Features - limit to 3 on small screens
                            ...tier.features.take(isSmallScreen ? 3 : tier.features.length).map((feature) => Padding(
                              padding: EdgeInsets.only(bottom: isSmallScreen ? 2 : 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: isSmallScreen ? 14 : 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  SizedBox(width: isSmallScreen ? 6 : 8),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: theme.textTheme.bodyMedium!.copyWith(
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                            // Show "more features" indicator if we limited the display
                            if (isSmallScreen && tier.features.length > 3)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  '+${tier.features.length - 3} more features',
                                  style: theme.textTheme.bodySmall!.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: isSmallScreen ? 16 : 20),
            // Join button
            SizedBox(
              width: double.infinity,
              height: isSmallScreen ? 44 : 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _joinCommunity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 12 : 16,
                    horizontal: isSmallScreen ? 16 : 24
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: isSmallScreen ? 16 : 20,
                        width: isSmallScreen ? 16 : 20,
                        child: CircularProgressIndicator(
                          strokeWidth: isSmallScreen ? 1.5 : 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_add, size: isSmallScreen ? 18 : 20),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Text(
                            _selectedTier != null && _selectedTier!.monthlyPrice > 0
                                ? 'Join Now (${_selectedTier!.formattedPrice})'
                                : 'Join Now (Free)',
                            style: theme.textTheme.labelLarge!.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            if (_selectedTier != null && _selectedTier!.monthlyPrice > 0)
              Padding(
                padding: EdgeInsets.only(top: isSmallScreen ? 6 : 8),
                child: Text(
                  'You can cancel your membership at any time.',
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}