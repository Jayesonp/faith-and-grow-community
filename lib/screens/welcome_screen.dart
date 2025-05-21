import 'package:flutter/material.dart';
import 'package:dreamflow/theme.dart';
import 'package:dreamflow/screens/auth_screen.dart';
import 'package:dreamflow/screens/pricing_screen.dart';
import 'package:dreamflow/widgets/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _currentPage = 0;
  final PageController _pageController = PageController();
  final List<Map<String, dynamic>> _welcomePages = [
    {
      'title': 'Welcome to Faith & Grow',
      'subtitle': 'Where Faith Meets Business Growth',
      'description': 'Join a community of Christian entrepreneurs dedicated to growing their businesses with faith-based principles.',
      'icon': Icons.church,
      'color': Color(0xFF4CAF50),
    },
    {
      'title': 'Create & Monetize Communities',
      'subtitle': 'Share Your Expertise',
      'description': 'Start your own community, share valuable content, and generate recurring revenue through memberships.',
      'icon': Icons.monetization_on,
      'color': Color(0xFFD4AF37),
    },
    {
      'title': 'Choose Your Plan',
      'subtitle': 'Grow at Your Own Pace',
      'description': 'Select from our tiered membership plans designed to support your business journey.',
      'icon': Icons.star,
      'color': Color(0xFF000000),
    },
  ];
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn)
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut)
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if device is in landscape mode
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ],
            ),
          ),
          child: isLandscape && !isDesktop
              // Landscape layout for phones/tablets: side-by-side
              ? Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _welcomePages.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return _buildWelcomePage(_welcomePages[index]);
                        },
                      ),
                    ),
                    Expanded(
                      flex: isTablet ? 2 : 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildPageIndicator(),
                          SizedBox(height: 16.0),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            child: _buildBottomButtons(),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              // Portrait layout or desktop: stacked
              : Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _welcomePages.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return _buildWelcomePage(_welcomePages[index]);
                        },
                      ),
                    ),
                    _buildPageIndicator(),
                    _buildBottomButtons(),
                  ],
                ),
        ),
      ),
    );
  }
  
  Widget _buildWelcomePage(Map<String, dynamic> pageData) {
    // Determine if device is in landscape mode or tablet
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    
    // Adjust padding based on screen size and orientation
    final horizontalPadding = isDesktop ? 48.0 : (isTablet ? 36.0 : 24.0);
    final verticalPadding = isLandscape && !isDesktop ? 16.0 : 24.0;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaithGrowLogo(size: 120),
                const SizedBox(height: 32),
                Text(
                  pageData['title'],
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  pageData['subtitle'],
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: pageData['color'],
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  pageData['description'],
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                if (_currentPage == 2)
                  FaithButton(
                  label: 'Get Started',
                  icon: Icons.login,
                  onPressed: () async {
                    // Mark welcome screen as seen when user completes onboarding
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('has_seen_welcome', true);
                    
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthScreen(),
                      ),
                    );
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _welcomePages.length,
          (index) => Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index
                  ? _welcomePages[index]['color']
                  : Colors.grey.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildBottomButtons() {
    // Determine if device is in landscape mode or tablet
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    
    // Adjust padding based on screen size and orientation
    final padding = isLandscape && !isDesktop ? 16.0 : 24.0;
    
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () async {
              // Mark welcome screen as seen when user skips
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('has_seen_welcome', true);
              
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthScreen(),
                ),
              );
            },
            child: Text('Skip'),
          ),
          _currentPage < _welcomePages.length - 1
              ? ElevatedButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _welcomePages[_currentPage]['color'],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Row(
                    children: [
                      Text('Next'),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                )
              : ElevatedButton(
                  onPressed: () async {
                    // Mark welcome screen as seen when user completes onboarding
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('has_seen_welcome', true);
                    
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _welcomePages[_currentPage]['color'],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Row(
                    children: [
                      Text('Get Started'),
                      const SizedBox(width: 8),
                      Icon(Icons.login),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}