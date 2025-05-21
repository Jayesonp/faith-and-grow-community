import 'package:flutter/material.dart';
import 'package:dreamflow/widgets/pricing_section.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:dreamflow/widgets/responsive_layout.dart';

class PricingExampleScreen extends StatefulWidget {
  const PricingExampleScreen({Key? key}) : super(key: key);

  @override
  State<PricingExampleScreen> createState() => _PricingExampleScreenState();
}

class _PricingExampleScreenState extends State<PricingExampleScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobilePortraitBody: _buildMobileLayout(context),
        tabletPortraitBody: _buildTabletLayout(context),
        desktopBody: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 180.h,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Membership Plans'),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  "https://pixabay.com/get/g22c6430f67ab8fe44ba3e076cb97800bf91616eed0137b08c6d4555c3f4bfde797e512b15900fe377d04a010d0ceda365cf8317e25ed1cf002942def718fc569_1280.jpg",
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntroSection(context),
                    SizedBox(height: 32.h),
                    const PricingSection(),
                    SizedBox(height: 32.h),
                    _buildTestimonialSection(context),
                    SizedBox(height: 32.h),
                    _buildFAQSection(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220.h,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Membership Plans'),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  "https://pixabay.com/get/g7bfcf8f5506d3fd9dc4e446980cf7ed0617f55bd5b1b2cc6652f06d5a82907c6b0e7dfd777e7c63cbb46c156fb73843afb62e7b8ae32431b6ae7fec64998cda4_1280.jpg",
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntroSection(context),
                    SizedBox(height: 40.h),
                    const PricingSection(),
                    SizedBox(height: 40.h),
                    _buildTestimonialSection(context),
                    SizedBox(height: 40.h),
                    _buildFAQSection(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Faith & Grow Membership Plans'),
            titlePadding: const EdgeInsets.only(bottom: 16),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  "https://pixabay.com/get/gc846aaabe647b3a734e0accbb520296c56b23e1fa8feb74ed6cd6b618da84bcd19afce0466abb95389b58dabdc3f2cf04220c7604b6238599db9b72ce2aab664_1280.jpg",
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIntroSection(context),
                        const SizedBox(height: 60),
                        const PricingSection(),
                        const SizedBox(height: 60),
                        _buildWebTestimonialSection(context),
                        const SizedBox(height: 60),
                        _buildWebFAQSection(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntroSection(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    
    return Column(
      crossAxisAlignment: isDesktop ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (isDesktop) ...[  
          Center(
            child: Text(
              'Grow Your Business with Faith',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 700,
              child: Text(
                'Join a community of Christian entrepreneurs dedicated to growing their businesses with faith-based principles.',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ] else ...[  
          Text(
            'Grow Your Business with Faith',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Join a community of Christian entrepreneurs dedicated to growing their businesses with faith-based principles.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
        ],
        SizedBox(height: isDesktop ? 24 : 16.h),
        if (!isDesktop) Divider(thickness: 1.h),
      ],
    );
  }

  Widget _buildTestimonialSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What Our Members Say',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote,
                    color: Theme.of(context).colorScheme.primary,
                    size: 36.r,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Faith & Grow has been a game-changer for my business. The community support and biblical principles have helped me build a thriving company that honors God.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage("https://pixabay.com/get/g648d454d9c2c4144489c725889308e8da8edefcb0e24689d9e596b6abda6fd5a95a22963a237837aab2a76c4ef0a8229a12151df940e7f363b32a384642f9177_1280.jpg"),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sarah Johnson',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Pro Member, Faith Marketing',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebTestimonialSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'What Our Members Say',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTestimonialCard(
                context,
                'Faith & Grow has been a game-changer for my business. The community support and biblical principles have helped me build a thriving company that honors God.',
                'Sarah Johnson',
                'Pro Member, Faith Marketing',
                "https://pixabay.com/get/g415d1850c74d3a8852d5c2b39b6a60a7b973ca63206420d2ff52632b03ceab0669ed647933a927ad2ee66a5276459853a7b35dd4294b467b8f964f20046bd830_1280.jpg",
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildTestimonialCard(
                context,
                'The mastermind groups and 1-on-1 coaching have taken my business to a whole new level. I\'ve found a community that shares my values while helping me grow professionally.',
                'Michael Brown',
                'Elite Member, Faithful Finance',
                "https://pixabay.com/get/g463771f80324f68111a873f6652095643ffc9f0a15ee88593a74bb1e0d02d0fa1cef0268b8f1f46ffa561901ab16aa487f6de0d0102912aa29638a190aa8b9c1_1280.jpg",
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildTestimonialCard(
                context,
                'As a faith-driven entrepreneur, finding a community like this has been invaluable. The resources, connections and guidance align perfectly with my business goals and spiritual values.',
                'Rachel Davis',
                'Mastermind Member, Grace Design Co.',
                "https://pixabay.com/get/g3d017a035a0c15ed14dcf7a18f08415a7f1a998103b2bac7a80f0a3b6ec01d33ef736414741e63f79c18b2953042d3e3ffcf6c8196b58ec431100e27cd87cc45_1280.jpg",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTestimonialCard(BuildContext context, String quote, String name, String title, String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.format_quote,
                color: Theme.of(context).colorScheme.primary,
                size: 36,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  quote,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(imageUrl),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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

  Widget _buildFAQSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        SizedBox(height: 16.h),
        _buildFAQItem(
          context,
          'What are the benefits of a paid membership?',
          'Paid memberships give you access to premium content, community features, live events, and personalized coaching depending on your chosen tier.',
        ),
        _buildFAQItem(
          context,
          'Can I upgrade my plan later?',
          'Yes! You can upgrade your membership plan at any time. Your new benefits will be immediately available and you\'ll only be charged the difference.',
        ),
        _buildFAQItem(
          context,
          'Is there a money-back guarantee?',
          'We offer a 14-day money-back guarantee if you\'re not satisfied with your membership experience.',
        ),
      ],
    );
  }

  Widget _buildWebFAQSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Frequently Asked Questions',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildFAQItemWeb(
                    context,
                    'What are the benefits of a paid membership?',
                    'Paid memberships give you access to premium content, community features, live events, and personalized coaching depending on your chosen tier.',
                    Icons.card_membership,
                  ),
                  const SizedBox(height: 24),
                  _buildFAQItemWeb(
                    context,
                    'Is there a money-back guarantee?',
                    'We offer a 14-day money-back guarantee if you\'re not satisfied with your membership experience.',
                    Icons.timer,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              child: Column(
                children: [
                  _buildFAQItemWeb(
                    context,
                    'Can I upgrade my plan later?',
                    'Yes! You can upgrade your membership plan at any time. Your new benefits will be immediately available and you\'ll only be charged the difference.',
                    Icons.upgrade,
                  ),
                  const SizedBox(height: 24),
                  _buildFAQItemWeb(
                    context,
                    'Can I create multiple communities?',
                    'Yes, but it depends on your membership tier. Growth tier allows you to create one community, while Elite tier enables you to create multiple communities.',
                    Icons.groups,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            question,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          iconColor: Theme.of(context).colorScheme.primary,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Text(
                answer,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItemWeb(BuildContext context, String question, String answer, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}