import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/services/data_service.dart';
import 'package:dreamflow/widgets/common_widgets.dart';
import 'package:dreamflow/widgets/responsive_layout.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:dreamflow/screens/community_screen.dart';
import 'package:dreamflow/screens/learning_screen.dart';
import 'package:dreamflow/screens/directory_screen.dart';
import 'package:dreamflow/screens/profile_screen.dart';
import 'package:dreamflow/screens/dashboard_tab.dart';
import 'package:dreamflow/screens/donation_screen.dart';
import 'package:dreamflow/screens/pricing_screen.dart';
import 'package:dreamflow/screens/settings_screen.dart';
import 'package:dreamflow/screens/help_center_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  
  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;
  late List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Initialize screens
    _screens = [
      DashboardTab(),
      CommunityScreen(userId: widget.user.id),
      LearningScreen(userId: widget.user.id),
      DirectoryScreen(),
      ProfileScreen(userId: widget.user.id),
    ];
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    // On Web, use more desktop-optimized breakpoints
    final bool useDesktopLayout = screenWidth >= 1200;
    final bool useTabletLayout = !useDesktopLayout && screenWidth >= 768;
    final bool useMobileLayout = !useDesktopLayout && !useTabletLayout;
    
    // For a consistent web experience, use a custom layout for larger screens
    if (kIsWeb && useDesktopLayout) {
      return _buildWebDesktopLayout();
    }
    
    // For responsive layouts on various devices
    return ResponsiveLayout(
      // Mobile portrait layout (standard bottom navigation)
      mobilePortraitBody: _buildMobilePortraitLayout(),
      
      // Mobile landscape layout (more compact navigation)
      mobileLandscapeBody: _buildMobileLandscapeLayout(),
      
      // Tablet portrait layout (left navigation rail with labels)
      tabletPortraitBody: _buildTabletLayout(isLandscape: false),
      
      // Tablet landscape layout (side navigation with more space)
      tabletLandscapeBody: _buildTabletLayout(isLandscape: true),
      
      // Desktop layout (permanent drawer with full labels)
      desktopBody: _buildDesktopLayout(),
    );
  }

  // Web-specific desktop layout with optimized proportions
  Widget _buildWebDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Optimized sidebar for web (fixed width with responsive content)
          Container(
            width: MediaQuery.of(context).size.width < 1600 ? 250 : 280,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  blurRadius: 6,
                  offset: Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // App logo and title with proper spacing
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      // Responsive but not overly scaled logo
                      FaithGrowLogo(size: 72),
                      const SizedBox(height: 16),
                      // Non-breaking text with proper overflow handling
                      Text(
                        'Faith & Grow',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 0.0,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Main navigation
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWebNavItem(0, 'Dashboard', Icons.dashboard),
                        _buildWebNavItem(1, 'Community', Icons.people),
                        _buildWebNavItem(2, 'Learning', Icons.school),
                        _buildWebNavItem(3, 'Directory', Icons.business),
                        _buildWebNavItem(4, 'Profile', Icons.person),
                        
                        // Section divider
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                          child: Divider(thickness: 1, color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                        ),
                        
                        // Quick actions section
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0, bottom: 8.0, top: 8.0),
                          child: Text(
                            'QUICK ACTIONS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        
                        // Settings option
                        _buildWebActionItem(
                          'Settings',
                          Icons.settings,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SettingsScreen(userId: widget.user.id)),
                          ),
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        
                        // Create community shortcut
                        _buildWebActionItem(
                          'Plans & Pricing',
                          Icons.monetization_on,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PricingScreen()),
                          ),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        
                        // Support link
                        _buildWebActionItem(
                          'Support Ministry',
                          Icons.favorite_outline,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DonationScreen(userId: widget.user.id)),
                          ),
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        
                        // Help Center link
                        _buildWebActionItem(
                          'Help Center',
                          Icons.help_outline,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
                          ),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // User info section at bottom
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                    ),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Row(
                    children: [
                      // User avatar
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: widget.user.profileImageUrl != null
                            ? NetworkImage(widget.user.profileImageUrl!)
                            : null,
                        backgroundColor: widget.user.profileImageUrl == null 
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        child: widget.user.profileImageUrl == null
                            ? Text(
                                widget.user.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      
                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.user.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.user.email.isNotEmpty)
                              Text(
                                widget.user.email,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Content area with max width constraint for better readability
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 1400,
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: _screens[_currentIndex],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // Mobile layout with bottom navigation
  Widget _buildMobilePortraitLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faith and Grow'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help Center',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen(userId: widget.user.id)),
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _tabController.animateTo(index);
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Learning'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Directory'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // Mobile landscape layout with navigation rail
  Widget _buildMobileLandscapeLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Space-efficient navigation rail
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
                _tabController.animateTo(index);
              });
            },
            minWidth: 56,
            labelType: NavigationRailLabelType.none,
            // Optimize for landscape by using just icons without labels
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                selectedIcon: Icon(Icons.people),
                label: Text('Community'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.school),
                selectedIcon: Icon(Icons.school),
                label: Text('Learning'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business),
                selectedIcon: Icon(Icons.business),
                label: Text('Directory'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
            selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
            unselectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          ),
          
          // Content area
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // Tablet layout with navigation rail and labels
  Widget _buildTabletLayout({required bool isLandscape}) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation rail with responsively sized labels
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
                _tabController.animateTo(index);
              });
            },
            extended: isLandscape,
            minWidth: 72,
            minExtendedWidth: 180,
            labelType: isLandscape ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                selectedIcon: Icon(Icons.people),
                label: Text('Community'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.school),
                selectedIcon: Icon(Icons.school),
                label: Text('Learning'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business),
                selectedIcon: Icon(Icons.business),
                label: Text('Directory'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
            selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
            selectedLabelTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
            unselectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            unselectedLabelTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14.sp,
            ),
          ),
          
          // Content area
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // Desktop layout with side drawer
  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Side drawer with optimal width for readability
          Container(
            width: (MediaQuery.of(context).size.width * 0.20).clamp(220.0, 300.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(2, 0),
                ),
              ],
              border: Border(
                right: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
              ),
            ),
            child: Column(
              children: [
                // App logo and title
                Padding(
                  padding: EdgeInsets.all(16.0.sp),
                  child: Column(
                    children: [
                      // Logo with responsive sizing
                      FaithGrowLogo(size: 64),
                      SizedBox(height: 12.h),
                      // Non-breaking title text
                      Text(
                        'Faith & Grow',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Navigation items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    children: [
                      _buildDesktopNavItem(0, 'Dashboard', Icons.dashboard),
                      _buildDesktopNavItem(1, 'Community', Icons.people),
                      _buildDesktopNavItem(2, 'Learning', Icons.school),
                      _buildDesktopNavItem(3, 'Directory', Icons.business),
                      _buildDesktopNavItem(4, 'Profile', Icons.person),
                      
                      // Divider with consistent spacing
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                        child: Divider(thickness: 1, color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                      ),
                      
                      // Action section heading
                      Padding(
                        padding: EdgeInsets.only(left: 16.w, bottom: 8.h),
                        child: Text(
                          'QUICK ACTIONS',
                          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      
                      // Settings access
                      ListTile(
                        leading: Icon(
                          Icons.settings,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        title: Text(
                          'Settings',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SettingsScreen(userId: widget.user.id)),
                          );
                        },
                      ),
                      
                      // Create community option
                      ListTile(
                        leading: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.secondary),
                        title: Text(
                          'Create Community',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PricingScreen()),
                          );
                        },
                      ),
                      
                      // Support ministry option
                      ListTile(
                        leading: Icon(Icons.favorite_outline, color: Theme.of(context).colorScheme.tertiary),
                        title: Text(
                          'Support Ministry',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DonationScreen(userId: widget.user.id)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // User information bar
                Container(
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                    ),
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  ),
                  child: Row(
                    children: [
                      // User avatar with consistent sizing
                      CircleAvatar(
                        radius: 18.r,
                        backgroundImage: widget.user.profileImageUrl != null
                            ? NetworkImage(widget.user.profileImageUrl!)
                            : null,
                        backgroundColor: widget.user.profileImageUrl == null 
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        child: widget.user.profileImageUrl == null
                            ? Text(
                                widget.user.name[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              )
                            : null,
                      ),
                      SizedBox(width: 12.w),
                      
                      // User name and email with overflow handling
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.user.name,
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.user.email.isNotEmpty)
                              Text(
                                widget.user.email,
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 12.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Main content area
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // Desktop navigation item builder
  Widget _buildDesktopNavItem(int index, String label, IconData icon) {
    final isSelected = _currentIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          size: 24,
        ),
        title: Text(
          label,
          style: isSelected
              ? Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  height: 1.2, // Consistent line height
                )
              : Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  height: 1.2, // Consistent line height
                ),
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
        tileColor: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
        onTap: () {
          setState(() {
            _currentIndex = index;
            _tabController.animateTo(index);
          });
        },
      ),
    );
  }
  
  // Web-specific navigation item builder
  Widget _buildWebNavItem(int index, String label, IconData icon) {
    final isSelected = _currentIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: MaterialButton(
        onPressed: () {
          setState(() {
            _currentIndex = index;
            _tabController.animateTo(index);
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }
  
  // Web action item builder
  Widget _buildWebActionItem(String label, IconData icon, VoidCallback onTap, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: MaterialButton(
        onPressed: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.7), size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Floating action button visibility control
  Widget? _buildFloatingActionButton() {
    if (_currentIndex == 1) { // Only on Community tab
      return FloatingActionButton(
        onPressed: () => _showCreatePostDialog(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      );
    }
    return null;
  }
  
  // Create post dialog
  void _showCreatePostDialog(BuildContext context) {
    final contentController = TextEditingController();
    final contentFocusNode = FocusNode();
    String category = 'General';
    bool isSubmitting = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Create New Post',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category selection
                  Row(
                    children: [
                      Text(
                        'Category: ',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: category,
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              category = newValue;
                            });
                          }
                        },
                        items: ['General', 'Question', 'Testimony', 'Prayer', 'Business']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Post content field
                  TextField(
                    controller: contentController,
                    focusNode: contentFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts with the community...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16),
                    ),
                    maxLines: 5,
                    minLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (contentController.text.trim().isNotEmpty) {
                          setState(() {
                            isSubmitting = true;
                          });
                          
                          final newPost = await DataService.addPost(
                            widget.user.id,
                            widget.user.name,
                            contentController.text.trim(),
                            category: category,
                            userImageUrl: widget.user.profileImageUrl,
                          );
                          
                          setState(() {
                            isSubmitting = false;
                          });
                          
                          if (context.mounted) {
                            Navigator.of(context).pop(true);
                            
                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Your post has been created!'),
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                child: isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Text('Post'),
              ),
            ],
          );
        },
      ),
    );
  }
}