import 'package:flutter/material.dart';
import 'package:dreamflow/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dreamflow/widgets/common_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<String> _searchResults = [];

  // FAQ data
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I create a community?',
      'answer': 'To create a community, navigate to the Dashboard tab and click on "Create Community" button. You need to have an active Growth or Mastermind subscription plan to create a community.'
    },
    {
      'question': 'How do I upgrade my subscription?',
      'answer': 'To upgrade your subscription, go to Settings > Membership > Subscription Plans. Select the plan that best fits your needs and follow the payment process.'
    },
    {
      'question': 'How can I join an existing community?',
      'answer': 'You can discover communities on the Dashboard tab under "Recommended Communities" or by using the "Discover" button. Once you find a community you like, click on it and select a membership tier to join.'
    },
    {
      'question': 'Can I create multiple communities?',
      'answer': 'Yes, but the number of communities you can create depends on your subscription tier. Growth tier allows 1 community, while Mastermind tier allows unlimited communities.'
    },
    {
      'question': 'How do I post content in a community?',
      'answer': 'After joining a community, navigate to that community\'s dashboard and use the post creation form at the top of the feed to share content.'
    },
    {
      'question': 'How do I access learning resources?',
      'answer': 'Learning resources are available in the Learning tab on the main navigation. You can browse courses, track your progress, and access lessons.'
    },
    {
      'question': 'How do I reset my password?',
      'answer': 'Go to Settings > Security > Change Password to update your password. If you\'re locked out, use the "Forgot Password" option on the login screen.'
    },
    {
      'question': 'How do I find businesses in the directory?',
      'answer': 'Use the Directory tab to browse Christian businesses. You can filter by category and use the search feature to find specific businesses.'
    },
  ];

  // Contact options
  final List<Map<String, dynamic>> _contactOptions = [
    {
      'title': 'Email Support',
      'description': 'Send us an email for assistance',
      'icon': Icons.email,
      'action': 'support@faithandgrow.com'
    },
    {
      'title': 'Live Chat',
      'description': 'Chat with our support team',
      'icon': Icons.chat,
      'action': 'chat'
    },
    {
      'title': 'Phone Support',
      'description': 'Call our customer service line',
      'icon': Icons.phone,
      'action': '+1-800-FAITH-GROW'
    },
    {
      'title': 'Schedule a Call',
      'description': 'Book a consultation with our team',
      'icon': Icons.calendar_today,
      'action': 'calendar'
    },
  ];

  // Help topics
  final List<Map<String, dynamic>> _helpTopics = [
    {
      'title': 'Getting Started',
      'icon': Icons.play_circle_outline,
      'subtopics': [
        'Creating your account',
        'Setting up your profile',
        'Navigating the app',
        'Understanding subscription plans'
      ]
    },
    {
      'title': 'Communities',
      'icon': Icons.people_outline,
      'subtopics': [
        'Joining communities',
        'Creating your community',
        'Managing community settings',
        'Monetizing your expertise'
      ]
    },
    {
      'title': 'Learning',
      'icon': Icons.school_outlined,
      'subtopics': [
        'Accessing courses',
        'Tracking your progress',
        'Completing lessons',
        'Finding new courses'
      ]
    },
    {
      'title': 'Business Directory',
      'icon': Icons.business_center_outlined,
      'subtopics': [
        'Finding businesses',
        'Contacting business owners',
        'Adding your business',
        'Using categories and filters'
      ]
    },
    {
      'title': 'Account Management',
      'icon': Icons.manage_accounts_outlined,
      'subtopics': [
        'Updating your profile',
        'Changing password',
        'Managing subscriptions',
        'Privacy settings'
      ]
    },
    {
      'title': 'Troubleshooting',
      'icon': Icons.build_outlined,
      'subtopics': [
        'Common issues',
        'App performance',
        'Login problems',
        'Payment issues'
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_handleSearch);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        // Search in FAQs
        _searchResults = _faqs
            .where((faq) =>
                faq['question']!.toLowerCase().contains(query) ||
                faq['answer']!.toLowerCase().contains(query))
            .map((faq) => faq['question']!)
            .toList();
        
        // Add help topics to search results
        _searchResults.addAll(_helpTopics
            .where((topic) =>
                topic['title'].toLowerCase().contains(query) ||
                (topic['subtopics'] as List<dynamic>).any((subtopic) => subtopic.toString().toLowerCase().contains(query)))
            .map((topic) => topic['title'] as String)
            .toList());
      }
    });
  }

  void _contactSupport(String method) async {
    switch (method) {
      case 'support@faithandgrow.com':
        final Uri emailUri = Uri(
          scheme: 'mailto',
          path: method,
          query: 'subject=Support Request&body=I need help with...',
        );
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch email client')),
          );
        }
        break;
      case 'chat':
        // For now, show a dialog since we don't have an actual chat feature
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Live Chat'),
            content: Text('Our live chat feature is coming soon!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
        break;
      case '+1-800-FAITH-GROW':
        final Uri telUri = Uri(scheme: 'tel', path: '+18003248447');
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch phone app')),
          );
        }
        break;
      case 'calendar':
        // Show dialog for scheduling (would connect to a calendar service in production)
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Schedule a Call'),
            content: Text('Our scheduling system is coming soon!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
        break;
    }
  }

  void _showTopicDetails(Map<String, dynamic> topic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Icon(topic['icon'], color: Theme.of(context).colorScheme.primary, size: 28.r),
                  SizedBox(width: 12.w),
                  Text(
                    topic['title'],
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: (topic['subtopics'] as List<String>).length,
                  itemBuilder: (context, index) {
                    final subtopic = (topic['subtopics'] as List<String>)[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          child: Text('${index + 1}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                        ),
                        title: Text(
                          subtopic,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          // In a real app, we would navigate to a detailed help page for this subtopic
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Help for "$subtopic" is coming soon!')),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for help...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                autofocus: true,
              )
            : Text('Help Center'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
        bottom: _isSearching
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'FAQ'),
                  Tab(text: 'TOPICS'),
                  Tab(text: 'CONTACT'),
                ],
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                indicatorColor: Theme.of(context).colorScheme.primary,
              ),
      ),
      body: _isSearching
          ? _buildSearchResults()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFaqTab(),
                _buildTopicsTab(),
                _buildContactTab(),
              ],
            ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64.r,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8.h),
            Text(
              'Try different keywords or browse our help topics',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        // Check if result is a FAQ question or a help topic
        final isFaq = _faqs.any((faq) => faq['question'] == result);
        
        if (isFaq) {
          final faq = _faqs.firstWhere((faq) => faq['question'] == result);
          return _buildFaqItem(faq);
        } else {
          final topic = _helpTopics.firstWhere((topic) => topic['title'] == result);
          return _buildTopicItem(topic);
        }
      },
    );
  }

  Widget _buildFaqTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: _faqs.length,
      itemBuilder: (context, index) {
        return _buildFaqItem(_faqs[index]);
      },
    );
  }

  Widget _buildFaqItem(Map<String, String> faq) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.r,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          faq['question']!,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        iconColor: Theme.of(context).colorScheme.primary,
        collapsedIconColor: Theme.of(context).colorScheme.primary,
        childrenPadding: EdgeInsets.all(16.r).copyWith(top: 0),
        expandedAlignment: Alignment.topLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            faq['answer']!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: Icon(Icons.thumb_up_outlined, size: 16.r),
                label: Text('Helpful'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Thank you for your feedback!')),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  textStyle: TextStyle(fontSize: 12.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsTab() {
    return GridView.builder(
      padding: EdgeInsets.all(16.r),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1.2,
      ),
      itemCount: _helpTopics.length,
      itemBuilder: (context, index) {
        return _buildTopicItem(_helpTopics[index]);
      },
    );
  }

  Widget _buildTopicItem(Map<String, dynamic> topic) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: () => _showTopicDetails(topic),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                topic['icon'],
                size: 40.r,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 12.h),
              Text(
                topic['title'],
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Text(
                '${(topic['subtopics'] as List).length} articles',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTab() {
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        // Support message card
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.support_agent,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28.r,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'We\'re Here to Help!',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'Our dedicated support team is available Monday through Friday from 9:00 AM to 5:00 PM EST. We strive to respond to all inquiries within 24 hours.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Contact Options',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 16.h),
        ...List.generate(_contactOptions.length, (index) {
          final option = _contactOptions[index];
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8.r,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.r),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(option['icon'], color: Theme.of(context).colorScheme.primary),
              ),
              title: Text(
                option['title'],
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              subtitle: Text(
                option['description'],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: ElevatedButton(
                onPressed: () => _contactSupport(option['action']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text('Contact'),
              ),
            ),
          );
        }),
        SizedBox(height: 24.h),
        // Community support section
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.forum,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 28.r,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Community Support',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'Join our community forums to connect with other Faith & Grow members. Share ideas, ask questions, and learn from others\' experiences.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 16.h),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // This would navigate to community forums in a real app
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Community forums coming soon!')),
                    );
                  },
                  icon: Icon(Icons.people),
                  label: Text('Join the Conversation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}