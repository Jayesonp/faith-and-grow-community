import 'package:flutter/material.dart';
import 'package:dreamflow/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dreamflow/widgets/responsive_layout.dart';

class PricingTable extends StatefulWidget {
  final Function(String) onPlanSelected;
  
  const PricingTable({
    Key? key,
    required this.onPlanSelected,
  }) : super(key: key);

  @override
  State<PricingTable> createState() => _PricingTableState();
}

class _PricingTableState extends State<PricingTable> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedPlan = 'growth'; // Default to most popular plan

  // Pricing plans data
  final Map<String, Map<String, dynamic>> _plans = {
    'community': {
      'name': 'Community',
      'price': 47,
      'description': 'For entrepreneurs just starting their faith & business journey',
      'isPopular': false,
      'canCreateCommunity': true,
      'communityLimit': 1,
      'buttonText': 'Get Started',
      'color': Color(0xFF4CAF50), // Green
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
      'color': Color(0xFFD4AF37), // Gold
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
      'name': 'Mastery',
      'price': 297,
      'description': 'For entrepreneurs seeking elite mentorship & community',
      'isPopular': false,
      'canCreateCommunity': true,
      'communityLimit': -1, // Unlimited
      'buttonText': 'Apply Now',
      'color': Color(0xFF000000), // Black
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
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
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
    widget.onPlanSelected(plan);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobilePortraitBody: _buildMobileLayout(context),
      mobileLandscapeBody: _buildMobileLayout(context, isLandscape: true),
      tabletPortraitBody: _buildTabletLayout(context),
      tabletLandscapeBody: _buildDesktopLayout(context),
      desktopBody: _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context, {bool isLandscape = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Choose Your Membership Plan',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          SizedBox(height: 8.h),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Unlock the full power of Faith & Grow with our membership plans',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          SizedBox(height: 24.h),
          // Mobile plans display (vertical scrolling)
          ...['growth', 'community', 'mastermind'].map((plan) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _buildPlanCard(context, plan),
              )),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Text(
                'Choose Your Membership Plan',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Text(
                'Unlock the full power of Faith & Grow with our membership plans',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 32.h),
          // Tablet plans display (in a row with slight scroll overflow on smaller tablets)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPlanCard(context, 'community', isTablet: true),
                SizedBox(width: 16.w),
                _buildPlanCard(context, 'growth', isTablet: true),
                SizedBox(width: 16.w),
                _buildPlanCard(context, 'mastermind', isTablet: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: kIsWeb ? 48 : 32.w, vertical: kIsWeb ? 48 : 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Choose Your Membership Plan',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: kIsWeb ? 16 : 12.h),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Unlock the full power of Faith & Grow with our membership plans',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: kIsWeb ? 48 : 40.h),
          // Desktop plans display (3 cards in a row)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildPlanCard(context, 'community', isDesktop: true),
              ),
              SizedBox(width: kIsWeb ? 24 : 20.w),
              Expanded(
                flex: 115, // Slightly larger for emphasis
                child: _buildPlanCard(context, 'growth', isDesktop: true),
              ),
              SizedBox(width: kIsWeb ? 24 : 20.w),
              Expanded(
                child: _buildPlanCard(context, 'mastermind', isDesktop: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, String plan, {bool isTablet = false, bool isDesktop = false}) {
    final planData = _plans[plan]!;
    final Color planColor = planData['color'] as Color;
    final bool isPopular = planData['isPopular'] as bool;
    final bool isSelected = _selectedPlan == plan;
    
    // Width adjustments for different screen sizes
    double cardWidth = isDesktop
        ? double.infinity
        : isTablet
            ? 300.w
            : double.infinity;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: cardWidth,
        constraints: BoxConstraints(
          minHeight: isDesktop || isTablet ? 600.h : 400.h,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.surface
              : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected || isPopular 
                ? planColor 
                : Theme.of(context).colorScheme.outline.withOpacity(0.5),
            width: isSelected || isPopular ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isPopular
                  ? planColor.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Popular badge
            if (isPopular)
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: planColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.r),
                    topRight: Radius.circular(10.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 16.r,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'MOST POPULAR',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                    ),
                  ],
                ),
              ),
            // Plan content
            Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan icon and name
                  Row(
                    children: [
                      Icon(
                        planData['icon'] as IconData,
                        color: planColor,
                        size: 28.r,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        planData['name'] as String,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: planColor,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${planData['price']}',
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                      ),
                      SizedBox(width: 4.w),
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Text(
                          '/month',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Description
                  Text(
                    planData['description'] as String,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                  ),
                  SizedBox(height: 24.h),
                  // Divider
                  Divider(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                  SizedBox(height: 16.h),
                  // Features
                  ...List.generate(
                    (planData['features'] as List).length,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: planColor,
                            size: 20.r,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              planData['features'][index] as String,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Spacer
                  const Spacer(),
                  SizedBox(height: 24.h),
                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () => _selectPlan(plan),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: planColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        planData['buttonText'] as String,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
  }
}