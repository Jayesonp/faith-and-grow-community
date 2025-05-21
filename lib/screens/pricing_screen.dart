import 'package:flutter/material.dart';
import 'package:dreamflow/screens/community_payment_screen_updated.dart' as updated;
import 'package:dreamflow/services/firebase_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:dreamflow/widgets/responsive_layout.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({Key? key}) : super(key: key);

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Selected plan
  String _selectedPlan = 'growth';

  // Payment plans with their details
  final Map<String, Map<String, dynamic>> _plans = {
    'community': {
      'name': 'Community',
      'price': 47,
      'description': 'For entrepreneurs just starting their faith & business journey',
      'canCreateCommunity': true,
      'communityLimit': 1,
      'buttonText': 'Get Started',
      'color': Color(0xFF4CAF50),
      'features': [
        'Access to Community Feed',
        'Daily Theme Participation',
        'Limited Course Access',
        'Basic Profile',
        'Direct Messaging',
        'Create 1 Community Group',
        'Monthly Live Events',
        'Full Curriculum Access',
      ],
      'icon': Icons.people_outline,
    },
    'growth': {
      'name': 'Growth',
      'price': 97,
      'description': 'For entrepreneurs ready to accelerate with full access',
      'isPopular': true,
      'canCreateCommunity': true,
      'communityLimit': 5,
      'buttonText': 'Get Started',
      'color': Color(0xFFD4AF37),
      'features': [
        'Everything in Community',
        'Full Course Access',
        'Monthly Live Events',
        'Enhanced Profile',
        'Accountability Groups',
        'Create up to 5 Community Groups',
        'Weekly Group Coaching',
        'Resource Library',
        '1-on-1 Coaching',
      ],
      'icon': Icons.trending_up,
    },
    'mastermind': {
      'name': 'Mastermind',
      'price': 297,
      'description': 'For entrepreneurs seeking elite mentorship & community',
      'canCreateCommunity': true,
      'communityLimit': -1,
      'buttonText': 'Apply Now',
      'color': Color(0xFF000000),
      'features': [
        'Everything in Growth',
        'Quarterly 1-on-1 Coaching',
        'Mastermind Groups',
        'Business Review Sessions',
        'VIP Community Status',
        'Create Unlimited Community Groups',
        'Early Access to New Content',
        'Monthly Strategy Call',
        'MSME CRM Sales & Marketing',
        'Private Slack Channel',
      ],
      'icon': Icons.workspace_premium,
    },
  };

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
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut)
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectPlan(String plan) {
    setState(() {
      _selectedPlan = plan;
    });
    print('Selected plan: $plan'); // Debug print to verify plan selection
  }

  void _navigateToSubscription(String plan) {
    // Navigate to the updated payment screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => updated.CommunityPaymentScreen(
          userId: FirebaseService.currentUserId ?? '',
          selectedPlan: plan,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Plans'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: ResponsiveLayout(
        mobilePortraitBody: _buildMobilePortraitLayout(),
        mobileLandscapeBody: _buildMobileLandscapeLayout(),
        tabletPortraitBody: _buildTabletPortraitLayout(),
        tabletLandscapeBody: _buildTabletLandscapeLayout(),
        desktopBody: _buildDesktopLayout(),
      ),
    );
  }

  // Mobile portrait layout - stacked vertically
  Widget _buildMobilePortraitLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeroSection(),
          _buildPricingSection(),
          _buildBenefitsSection(),
        ],
      ),
    );
  }

  // Mobile landscape layout - compact with sideways scrolling for plans
  Widget _buildMobileLandscapeLayout() {
    // Ensure all plans are shown
    final allPlans = ['community', 'growth', 'mastermind'];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // More compact hero section for landscape
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Your Plan',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Select the plan that best fits your needs and goals',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          // Horizontal scrolling for pricing cards
          SizedBox(
            height: 300,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              children: allPlans.map((plan) => Container(
                width: 280,
                margin: EdgeInsets.only(right: 16),
                child: _buildPlanCard(plan),
              )).toList(),
            ),
          ),
          // Smaller benefits section
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Membership Benefits',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildBenefitCard(
                        icon: Icons.people,
                        title: 'Community',
                        description: 'Connect with like-minded entrepreneurs',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildBenefitCard(
                        icon: Icons.trending_up,
                        title: 'Growth',
                        description: 'Access resources to scale your business',
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tablet portrait layout - more space between elements
  Widget _buildTabletPortraitLayout() {
    // Ensure all plans are shown
    final allPlans = ['community', 'growth', 'mastermind'];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Enhanced hero section with more padding
          _buildHeroSection(),
          // Centered pricing cards with 3 in a row
          ResponsiveConstraints(
            tabletMaxWidth: 700,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      'Choose Your Membership',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Row(
                    children: allPlans.map((plan) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildPlanCard(plan),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 48),
          // Enhanced benefits section with more visual appeal
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: EdgeInsets.symmetric(vertical: 48.0),
            child: ResponsiveConstraints(
              tabletMaxWidth: 700,
              child: _buildBenefitsSection(),
            ),
          ),
        ],
      ),
    );
  }

  // Tablet landscape layout - side by side hero and pricing
  Widget _buildTabletLandscapeLayout() {
    final allPlans = ['community', 'growth', 'mastermind'];
    return SingleChildScrollView(
      child: Column(
        children: [
          // Two column layout for top section
          Container(
            height: 400,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left side - hero content
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: EdgeInsets.all(32.0),
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grow Your Business with Faith',
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Our membership plans are designed to help Christian entrepreneurs build thriving businesses while staying true to their faith.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _navigateToSubscription(_selectedPlan),
                          icon: Icon(Icons.arrow_forward),
                          label: Text('Get Started Today'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right side - featured plan
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: EdgeInsets.all(24.0),
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    child: _buildPlanCard('growth'),
                  ),
                ),
              ],
            ),
          ),
          // All plans in a row
          Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'All Available Plans',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  children: allPlans.map((plan) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: _buildPlanCard(plan),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          // Benefits in a grid
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: EdgeInsets.all(32.0),
            child: Column(
              children: [
                Text(
                  'Membership Benefits',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildBenefitCard(
                        icon: Icons.people,
                        title: 'Community',
                        description: 'Connect with like-minded entrepreneurs',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildBenefitCard(
                        icon: Icons.school,
                        title: 'Learning',
                        description: 'Access courses and resources',
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildBenefitCard(
                        icon: Icons.monetization_on,
                        title: 'Business',
                        description: 'Grow your business with expert guidance',
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Desktop layout - multi-column, full-width sections
  Widget _buildDesktopLayout() {
    final allPlans = ['community', 'growth', 'mastermind'];
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero section with animated background
          Container(
            height: 500,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: ResponsiveConstraints(
              desktopMaxWidth: 1200,
              child: Row(
                children: [
                  // Left column - text content
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: EdgeInsets.all(48.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Faith & Business United',
                            style: Theme.of(context).textTheme.displaySmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Join our community of Christian entrepreneurs dedicated to growing businesses that honor God and serve others.',
                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.normal,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(height: 48),
                          ElevatedButton.icon(
                            onPressed: () => _navigateToSubscription(_selectedPlan),
                            icon: Icon(Icons.arrow_forward),
                            label: Text('Start Your Journey'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Right column - illustration or image
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: Icon(
                        Icons.church,
                        size: 250,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Pricing section
          Container(
            padding: EdgeInsets.symmetric(vertical: 64.0),
            child: ResponsiveConstraints(
              desktopMaxWidth: 1200,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 48.0),
                    child: Column(
                      children: [
                        Text(
                          'Membership Plans',
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: 600,
                          child: Text(
                            'Choose the plan that aligns with your business goals and faith journey',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: allPlans.map((plan) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: _buildPlanCard(plan),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
          // Benefits section with grid layout
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: EdgeInsets.symmetric(vertical: 64.0),
            child: ResponsiveConstraints(
              desktopMaxWidth: 1200,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 48.0),
                    child: Column(
                      children: [
                        Text(
                          'Why Join Our Community?',
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: 600,
                          child: Text(
                            'Experience these transformative benefits for your faith and business',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBenefitCard(
                          icon: Icons.people,
                          title: 'Community',
                          description: 'Connect with like-minded entrepreneurs',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: _buildBenefitCard(
                          icon: Icons.school,
                          title: 'Learning',
                          description: 'Access courses and resources',
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: _buildBenefitCard(
                          icon: Icons.monetization_on,
                          title: 'Business',
                          description: 'Grow your business with expert guidance',
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBenefitCard(
                          icon: Icons.groups,
                          title: 'Accountability',
                          description: 'Stay on track with accountability groups',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: _buildBenefitCard(
                          icon: Icons.lightbulb,
                          title: 'Inspiration',
                          description: 'Find inspiration in faith-based business principles',
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: _buildBenefitCard(
                          icon: Icons.star,
                          title: 'Excellence',
                          description: 'Pursue excellence in all aspects of business',
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.church,
            size: 60,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 16),
          Text(
            'Faith & Business United',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Join our community of Christian entrepreneurs dedicated to growing businesses that honor God',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    // Get all available plan keys to ensure we're displaying everything
    final allPlans = ['community', 'growth', 'mastermind'];
    
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Choose Your Membership',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Force display of all plans with debug info
          ...allPlans.map((plan) => Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: _buildPlanCard(plan),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String plan) {
    final data = _plans[plan]!;
    final isPopular = data['isPopular'] == true;
    final planColor = data['color'] as Color;
    
    // Use screen size to determine appropriate spacing and sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    
    // Standardized sizes across all device types
    final double iconSize = isSmallScreen ? 24 : (isDesktop ? 32 : 28);
    final double headerFontSize = isSmallScreen ? 16 : (isDesktop ? 22 : 18);
    final double priceFontSize = isSmallScreen ? 22 : (isDesktop ? 30 : 26);
    final double priceSuffixFontSize = isSmallScreen ? 14 : (isDesktop ? 18 : 16);
    final double descriptionFontSize = isSmallScreen ? 12 : (isDesktop ? 16 : 14);
    final double featureFontSize = isSmallScreen ? 12 : (isDesktop ? 15 : 14);
    final double buttonHeight = isSmallScreen ? 40 : (isDesktop ? 52 : 46);
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: isDesktop ? 580 : (isTablet ? 540 : 520),
      decoration: BoxDecoration(
        color: _selectedPlan == plan ? planColor.withOpacity(0.08) : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedPlan == plan ? planColor : Theme.of(context).colorScheme.outline,
          width: _selectedPlan == plan ? 2.0 : 1.0,
        ),
        boxShadow: _selectedPlan == plan
          ? [BoxShadow(color: planColor.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))]
          : [],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan header with icon and name
                Row(
                  children: [
                    Icon(
                      data['icon'] as IconData,
                      color: planColor,
                      size: iconSize,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        data['name'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: planColor,
                          fontSize: headerFontSize,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Price display with consistent sizing
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '\$${data['price']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: priceFontSize,
                        ),
                      ),
                      TextSpan(
                        text: '/month',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: priceSuffixFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  data['description'] as String,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: descriptionFontSize,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 8),
                // Feature list with standardized UI
                Expanded(
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: (data['features'] as List).length,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: planColor,
                            size: isSmallScreen ? 16 : 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              (data['features'] as List)[index],
                              style: TextStyle(
                                fontSize: featureFontSize,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Responsive action button with consistent size
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      _selectPlan(plan);
                      _navigateToSubscription(plan);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: planColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      data['buttonText'] as String,
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                    ),
                  ),
                ),
                if (plan == 'community')
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 12.0),
                      child: Text(
                        'No credit card required',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Most Popular badge with standardized size
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12, 
                  vertical: 6
                ),
                decoration: BoxDecoration(
                  color: planColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Text(
                  'Most Popular',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        // Determine layout based on device type
        final isDesktop = sizingInformation.deviceScreenType == DeviceScreenType.desktop;
        final isTablet = sizingInformation.deviceScreenType == DeviceScreenType.tablet;
        final isMobile = sizingInformation.deviceScreenType == DeviceScreenType.mobile;
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
        
        // Adjust spacing based on screen size
        final verticalPadding = isDesktop ? 48.0 : (isTablet ? 36.0 : 24.0);
        final horizontalPadding = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);
        final itemSpacing = isDesktop ? 24.0 : (isTablet ? 16.0 : 12.0);
        final titleBottomSpacing = isDesktop ? 48.0 : (isTablet ? 32.0 : 24.0);
        
        // Determine layout style (row or column)
        final useRowLayout = isDesktop || (isTablet && isLandscape);
        
        // Create benefits widgets
        final benefits = [
          _buildBenefitCard(
            icon: Icons.groups,
            title: 'Faith-Centered Community',
            description: 'Connect with like-minded Christian entrepreneurs who share your values and mission.',
            color: Theme.of(context).colorScheme.secondary,
          ),
          _buildBenefitCard(
            icon: Icons.school,
            title: 'Biblical Business Training',
            description: 'Access courses that integrate faith principles with sound business strategies.',
            color: Theme.of(context).colorScheme.primary,
          ),
          _buildBenefitCard(
            icon: Icons.monetization_on,
            title: 'Monetize Your Expertise',
            description: 'Create your own communities and generate recurring revenue through memberships.',
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ];
        
        return Container(
          padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Why Join Faith & Grow?',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                  fontSize: isDesktop ? 32.sp : (isTablet ? 28.sp : 24.sp),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: titleBottomSpacing),
              
              // Use different layouts based on screen size
              if (useRowLayout)
                // Desktop and Landscape Tablet - Row Layout
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < benefits.length; i++) ...[  
                      Expanded(child: benefits[i]),
                      if (i < benefits.length - 1) SizedBox(width: itemSpacing),
                    ],
                  ],
                )
              else
                // Mobile and Portrait Tablet - Column Layout
                Column(
                  children: [
                    for (int i = 0; i < benefits.length; i++) ...[  
                      benefits[i],
                      if (i < benefits.length - 1) SizedBox(height: itemSpacing * 1.5),
                    ],
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
  
  int min(int a, int b) => a < b ? a : b;
}