import 'package:flutter/material.dart';
import 'package:dreamflow/theme.dart';
import 'package:dreamflow/widgets/pricing_table.dart';
import 'package:dreamflow/widgets/common_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PricingDemoScreen extends StatefulWidget {
  const PricingDemoScreen({Key? key}) : super(key: key);

  @override
  State<PricingDemoScreen> createState() => _PricingDemoScreenState();
}

class _PricingDemoScreenState extends State<PricingDemoScreen> {
  String _selectedPlan = 'growth';

  void _handlePlanSelection(String plan) {
    setState(() {
      _selectedPlan = plan;
    });
    // Show a snackbar to demonstrate the selection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected plan: ${plan.toUpperCase()}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FaithAppBar(
        title: 'Membership Plans',
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Grow Your Faith Community',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Connect, inspire, and monetize your expertise with our membership plans',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16.r,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'No credit card required to start',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Pricing table
            PricingTable(onPlanSelected: _handlePlanSelection),
            
            // FAQ section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
              child: Column(
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),
                  _buildFaqItem(
                    context,
                    'What happens after I select a plan?',
                    'After selecting a plan, you\'ll be guided through our simple payment process. Once completed, you\'ll have immediate access to all features included in your chosen membership tier.',
                  ),
                  _buildFaqItem(
                    context,
                    'Can I upgrade or downgrade my plan later?',
                    'Yes, you can change your membership tier at any time. When upgrading, you\'ll only pay the prorated difference for the remainder of your billing period.',
                  ),
                  _buildFaqItem(
                    context,
                    'How many community groups can I create?',
                    'The number of community groups you can create depends on your membership tier: Community plan allows 1 group, Growth plan allows up to 5 groups, and Mastery plan offers unlimited group creation.',
                  ),
                  _buildFaqItem(
                    context,
                    'Is there a free trial available?',
                    'We offer a 7-day free trial on all membership tiers. You can explore the features without any commitment and decide which plan best suits your needs.',
                  ),
                ],
              ),
            ),
            
            // Testimonials (simplified for this example)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  Text(
                    'Success Stories',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  _buildTestimonial(
                    context,
                    'The Growth plan transformed my ministry. The ability to create multiple community groups allowed me to segment my audience and provide more targeted guidance.',
                    'Pastor Michael R.',
                    'Community Leader',
                  ),
                ],
              ),
            ),
            
            // CTA section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Ready to start your journey?',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Join thousands of faith-driven entrepreneurs building communities that matter',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: 200.w,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Get Started Today',
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

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            question,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          childrenPadding: EdgeInsets.all(16.r),
          children: [
            Text(
              answer,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonial(BuildContext context, String quote, String name, String title) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surface.withOpacity(0.3)
            : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote,
            color: Theme.of(context).colorScheme.primary,
            size: 32.r,
          ),
          SizedBox(height: 16.h),
          Text(
            quote,
            style: TextStyle(
              fontSize: 16.sp,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                radius: 20.r,
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24.r,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}