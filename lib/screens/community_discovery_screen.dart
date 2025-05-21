import 'package:flutter/material.dart';
import 'package:dreamflow/models/community_model.dart';
import 'package:dreamflow/services/community_service.dart';
import 'package:dreamflow/widgets/community_widgets.dart';
import 'package:dreamflow/screens/community_detail_screen.dart';
import 'package:dreamflow/screens/community_creation_screen.dart';
import 'package:dreamflow/widgets/common_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CommunityDiscoveryScreen extends StatefulWidget {
  final String userId;
  
  const CommunityDiscoveryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<CommunityDiscoveryScreen> createState() => _CommunityDiscoveryScreenState();
}

class _CommunityDiscoveryScreenState extends State<CommunityDiscoveryScreen> with SingleTickerProviderStateMixin {
  List<Community> _communities = [];
  List<Community> _filteredCommunities = [];
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
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
    ).animate(_animationController);
    
    _loadData();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
      _filterCommunities();
    });
  }
  
  Future<void> _loadData() async {
    try {
      final communities = await CommunityService.getCommunities(publishedOnly: true);
      
      // Extract unique categories from communities
      final Set<String> categories = {'All'};
      for (var community in communities) {
        categories.add(community.category);
      }
      
      // Make sure 'All' is the first category
      if (!categories.contains('All')) {
        categories.add('All');
      }
      
      // Convert to list for sorting
      final categoriesList = categories.toList();
      // Sort alphabetically but keep 'All' at the beginning
      categoriesList.sort((a, b) => 
        a == 'All' ? -1 : (b == 'All' ? 1 : a.compareTo(b)));
      
      if (mounted) {
        setState(() {
          _communities = communities;
          _filteredCommunities = communities;
          _categories = categoriesList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading communities: $e')),
        );
      }
    }
    
    // Start the animation after data is loaded
    _animationController.forward();
  }
  
  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _filterCommunities();
    });
  }
  
  void _filterCommunities() {
    setState(() {
      if (_selectedCategory == 'All' && _searchQuery.isEmpty) {
        _filteredCommunities = _communities;
      } else {
        _filteredCommunities = _communities.where((community) {
          final matchesCategory = _selectedCategory == 'All' || 
                                 community.category == _selectedCategory;
          
          final matchesSearch = _searchQuery.isEmpty ||
                              community.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                              community.shortDescription.toLowerCase().contains(_searchQuery.toLowerCase());
          
          return matchesCategory && matchesSearch;
        }).toList();
      }
    });
  }
  
  void _navigateToCommunityDetail(Community community) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityDetailScreen(
          community: community,
          userId: widget.userId,
        ),
      ),
    ).then((_) {
      // Refresh data when returning from detail screen
      _loadData();
    });
  }
  
  void _navigateToCreateCommunity() {
    // First check if the user is eligible to create a community
    CommunityService.verifyCreationEligibility(widget.userId).then((eligibility) {
      if (eligibility['canCreate'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommunityCreationScreen(userId: widget.userId),
          ),
        );
      } else {
        // Show dialog explaining why they can't create a community
        _showSubscriptionRequired();
      }
    });
  }
  
  // Helper method to get an icon for a category
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

  // Show dialog when user needs to upgrade subscription
  void _showSubscriptionRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Subscription Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium,
              size: 48,
              color: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(height: 16),
            Text(
              'Creating a community requires a Growth or Mastermind subscription.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Upgrade your subscription to unlock community creation.',
              style: TextStyle(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/pricing');
            },
            child: Text('View Plans'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isWeb = kIsWeb;
    
    return Scaffold(
      appBar: const FaithAppBar(
        title: 'Communities',
      ),
      body: _isLoading
          ? const Center(child: FaithLoadingIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search and filter section
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Responsive search field
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search communities...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 10 : 12,
                                horizontal: isSmallScreen ? 16 : 20
                              ),
                            ),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14.sp : 16.sp,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.trim();
                                _filterCommunities();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    // Category filter - responsive for different screen sizes
                    Container(
                      height: isSmallScreen ? 45 : 50,
                      margin: EdgeInsets.only(top: isSmallScreen ? 12 : 16),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16
                        ),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final bool isSelected = category == _selectedCategory;
                          return Padding(
                            padding: EdgeInsets.only(
                              right: isSmallScreen ? 6 : 8
                            ),
                            child: FilterChip(
                              label: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: isSmallScreen ? 12.sp : 14.sp,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) => _selectCategory(category),
                              backgroundColor: theme.colorScheme.surface,
                              selectedColor: theme.colorScheme.primary,
                              padding: EdgeInsets.symmetric(horizontal: 
                                isSmallScreen ? 2 : 4
                              ),
                              visualDensity: isSmallScreen 
                                ? VisualDensity.compact 
                                : VisualDensity.standard,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          );
                        },
                      ),
                    ),
                    // Community grid - responsive layout based on screen size
                    Expanded(
                      child: _isLoading
                          ? const Center(child: FaithLoadingIndicator())
                          : _filteredCommunities.isEmpty
                              ? Center(
                                  child: EmptyStateWidget(
                                    message: 'No Communities Found',
                                    description: 'Try searching with different keywords or categories.',
                                    icon: Icons.search_off,
                                  ),
                                )
                              : LayoutBuilder(
                              builder: (context, constraints) {
                                // Get the current screen info for responsive layout
                                final isWeb = kIsWeb;
                                final screenWidth = MediaQuery.of(context).size.width;
                                
                                // Determine number of columns based on available width and platform
                                int crossAxisCount;
                                double childAspectRatio;
                                
                                if (isWeb) {
                                  // Web-specific responsive grid adjustments
                                  if (screenWidth >= 1200) {
                                    // Large desktop
                                    crossAxisCount = 3;
                                    childAspectRatio = 1.5;
                                  } else if (screenWidth >= 768) {
                                    // Small desktop/tablet
                                    crossAxisCount = 2;
                                    childAspectRatio = 1.4;
                                  } else if (screenWidth >= 480) {
                                    // Large mobile web
                                    crossAxisCount = 1;
                                    childAspectRatio = 1.3;
                                  } else {
                                    // Small mobile web
                                    crossAxisCount = 1;
                                    childAspectRatio = 1.2;
                                  }
                                } else {
                                  // Native app - use the existing logic but enhance it
                                  crossAxisCount = isLandscape && !isSmallScreen ? 2 : 1;
                                  childAspectRatio = isLandscape
                                    ? (isSmallScreen ? 1.8 : 2.0)
                                    : (isSmallScreen ? 1.0 : 1.2);
                                }
                                
                                // Use padding that scales with screen size
                                final padding = isWeb 
                                  ? (screenWidth >= 768 ? 24.0 : 16.0)
                                  : (isSmallScreen ? 12.0 : 16.0);
                                
                                // Use spacing that scales with screen size
                                final spacing = isWeb
                                  ? (screenWidth >= 768 ? 24.0 : 16.0)
                                  : (isSmallScreen ? 12.0 : 16.0);
                                  
                                return Padding(
                                  padding: EdgeInsets.all(padding),
                                  child: GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      childAspectRatio: childAspectRatio,
                                      crossAxisSpacing: spacing,
                                      mainAxisSpacing: spacing,
                                    ),
                                    itemCount: _filteredCommunities.length,
                                    itemBuilder: (context, index) {
                                      final community = _filteredCommunities[index];
                                      return CommunityCard(
                                        community: community,
                                        onTap: () => _navigateToCommunityDetail(community),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),                    ),
                    // Add padding at the bottom for better spacing with FAB
                    SizedBox(height: isSmallScreen ? 70 : 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateCommunity,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
        tooltip: 'Create Community',
      ),
    );
  }
}