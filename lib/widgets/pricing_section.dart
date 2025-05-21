import 'package:flutter/material.dart';
import 'package:dreamflow/widgets/pricing_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PricingSection extends StatelessWidget {
  final Function(String plan)? onPlanSelected;

  const PricingSection({
    Key? key,
    this.onPlanSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Determine if we should use column or row layout based on width
      final useColumnLayout = constraints.maxWidth < 768;
      
      // Build the layout
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: useColumnLayout
            ? _buildColumnLayout(context)
            : _buildRowLayout(context),
      );
    });
  }

  Widget _buildColumnLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStarterCard(),
        SizedBox(height: 24.h),
        _buildProCard(),
        SizedBox(height: 24.h),
        _buildEliteCard(),
      ],
    );
  }

  Widget _buildRowLayout(BuildContext context) {
    // For web, we want to center the cards and have some maximum width
    if (kIsWeb) {
      return Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: _buildStarterCard()),
              SizedBox(width: 24.w),
              Expanded(child: _buildProCard()),
              SizedBox(width: 24.w),
              Expanded(child: _buildEliteCard()),
            ],
          ),
        ),
      );
    }
    
    // For mobile devices, we want to use a ListView to allow scrolling if needed
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _buildStarterCard(),
          SizedBox(width: 24.w),
          _buildProCard(),
          SizedBox(width: 24.w),
          _buildEliteCard(),
        ],
      ),
    );
  }

  Widget _buildStarterCard() {
    return PricingCard(
      title: 'Starter',
      price: '\$47',
      features: [
        'Community Access',
        'Daily Themes',
        'Limited Courses',
        'Basic Profile',
        'Direct Messaging',
      ],
      buttonLabel: 'Get Started',
      onPressed: () => onPlanSelected?.call('starter'),
    );
  }

  Widget _buildProCard() {
    return PricingCard(
      title: 'Pro',
      price: '\$97',
      isPopular: true,
      features: [
        'All Starter Features',
        'Full Course Access',
        'Live Events',
        'Enhanced Profile',
        'Accountability Groups',
      ],
      buttonLabel: 'Get Started',
      onPressed: () => onPlanSelected?.call('pro'),
    );
  }

  Widget _buildEliteCard() {
    return PricingCard(
      title: 'Elite',
      price: '\$297',
      features: [
        'All Pro Features',
        '1-on-1 Coaching',
        'Mastermind Groups',
        'Business Reviews',
        'VIP Community Status',
      ],
      buttonLabel: 'Apply Now',
      onPressed: () => onPlanSelected?.call('elite'),
    );
  }
}