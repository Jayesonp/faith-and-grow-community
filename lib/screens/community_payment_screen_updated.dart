import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dreamflow/widgets/common_widgets.dart';
import 'package:dreamflow/screens/community_creation_screen.dart';
import 'package:dreamflow/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPaymentScreen extends StatefulWidget {
  final String userId;
  final String selectedPlan;

  const CommunityPaymentScreen({
    Key? key, 
    required this.userId,
    required this.selectedPlan,
  }) : super(key: key);

  @override
  State<CommunityPaymentScreen> createState() => _CommunityPaymentScreenState();
}

class _CommunityPaymentScreenState extends State<CommunityPaymentScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isProcessing = false;

  // Selected plan
  late String _selectedPlan;

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
    // Initialize selected plan from widget parameter
    _selectedPlan = widget.selectedPlan;
    
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
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _selectPlan(String plan) {
    setState(() {
      _selectedPlan = plan;
    });
  }

  Future<void> _processSubscription(String plan) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Check if the user is downgrading and if they have more communities than the new plan allows
      final newPlanData = _plans[plan]!;
      final int newCommunityLimit = newPlanData['communityLimit'] as int;
      
      // Get the current user document to check subscription tier
      final userDoc = await FirebaseService.firestore.collection('users').doc(widget.userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final currentSubscriptionTier = userData['subscriptionTier'] as String?;
        
        // Only check if user is downgrading (current plan is higher tier than new plan)
        if (currentSubscriptionTier != null && _isDowngrade(currentSubscriptionTier, plan)) {
          // Count the user's communities
          final ownedCommunitiesQuery = await FirebaseService.firestore
              .collection('communities')
              .where('creatorId', isEqualTo: widget.userId)
              .get();
          
          final int ownedCommunitiesCount = ownedCommunitiesQuery.docs.length;
          
          // Prevent downgrade if the user has more communities than the new plan allows
          if (newCommunityLimit != -1 && ownedCommunitiesCount > newCommunityLimit) {
            setState(() {
              _isProcessing = false;
            });
            
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Unable to Downgrade Plan'),
                  content: Text(
                    'You currently have $ownedCommunitiesCount community ${ownedCommunitiesCount == 1 ? "group" : "groups"}, but the ${newPlanData['name']} plan only allows $newCommunityLimit. Please delete some community groups before downgrading.'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
            return;
          }
        }
      }
      
      // Simulated payment processing delay
      await Future.delayed(Duration(seconds: 2));
      
      final planData = _plans[plan]!;
      
      // Store subscription in Firestore
      await FirebaseService.firestore.collection('subscriptions').add({
        'userId': widget.userId,
        'plan': plan,
        'price': planData['price'],
        'canCreateCommunity': planData['canCreateCommunity'],
        'communityLimit': planData['communityLimit'],
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
        'cardLast4': _cardNumberController.text.substring(_cardNumberController.text.length - 4),
      });

      // Update user document with subscription information
      await FirebaseService.firestore.collection('users').doc(widget.userId).update({
        'subscriptionTier': plan,
        'canCreateCommunity': planData['canCreateCommunity'],
        'communityLimit': planData['communityLimit'],
      });

      // Show success animation and navigate to appropriate screen based on plan
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        // Show success dialog with different messages based on plan
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Payment Successful!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    planData['canCreateCommunity']
                        ? 'Your ${planData['name']} plan is now active! ${planData['communityLimit'] == 1 ? "You can now create 1 community group." : (planData['communityLimit'] == -1 ? "You can now create unlimited community groups." : "You can now create up to ${planData['communityLimit']} community groups.")}'
                        : 'Your ${planData['name']} plan is now active! Enjoy all the benefits of our platform.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      
                      if (planData['canCreateCommunity']) {
                        // Navigate to community creation
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => CommunityCreationScreen(
                              userId: widget.userId,
                            ),
                          ),
                        );
                      } else {
                        // Navigate back to home
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: planData['color'],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      planData['canCreateCommunity'] ? 'Create Community Group' : 'Start Exploring',
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Payment Failed'),
              content: Text('There was an error processing your payment. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get standardized screen measurements
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      appBar: FaithAppBar(
        title: 'Membership Payment',
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan selection header
                  Text(
                    'Select Your Plan',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : (isDesktop ? 28 : 24),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Choose the membership that works best for you',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Plan selection cards - responsive layout
                  if (isDesktop || isTablet)
                    // Desktop/Tablet: Show plans in a row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final plan in ['community', 'growth', 'mastermind'])
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: _buildPlanCard(plan),
                            ),
                          ),
                      ],
                    )
                  else
                    // Mobile: Show plans as scrollable cards
                    Container(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          final plans = ['community', 'growth', 'mastermind'];
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            margin: EdgeInsets.only(right: 16),
                            child: _buildPlanCard(plans[index]),
                          );
                        },
                      ),
                    ),
                  
                  SizedBox(height: 32),
                  
                  // Payment section
                  Text(
                    'Payment Details',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : (isDesktop ? 28 : 24),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Selected plan summary 
                  _buildSelectedPlanSummary(),
                  
                  SizedBox(height: 24),
                  
                  // Payment form
                  _buildPaymentForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(String plan) {
    final data = _plans[plan]!;
    final isPopular = data['isPopular'] == true;
    final planColor = data['color'] as Color;
    final isSelected = _selectedPlan == plan;
    
    // Use screen size to determine appropriate spacing and sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isDesktop = screenWidth >= 1024;
    
    return GestureDetector(
      onTap: () => _selectPlan(plan),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? planColor.withOpacity(0.1) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? planColor : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
            ? [BoxShadow(color: planColor.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: Offset(0, 2))],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan header with icon and name
                  Row(
                    children: [
                      Icon(
                        data['icon'] as IconData,
                        color: planColor,
                        size: isSmallScreen ? 20 : 24,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data['name'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: planColor,
                            fontSize: isSmallScreen ? 16 : 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Price display with consistent sizing
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${data['price']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: isSmallScreen ? 22 : 26,
                        ),
                      ),
                      Text(
                        '/month',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    data['description'] as String,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16),
                  // Community limit highlight
                  if (data['canCreateCommunity'])
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: planColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        data['communityLimit'] == 1
                            ? 'Create 1 Community'
                            : data['communityLimit'] == -1
                                ? 'Create Unlimited Communities'
                                : 'Create up to ${data["communityLimit"]} Communities',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w500,
                          color: planColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(height: 16),
                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _selectPlan(plan),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? planColor : Colors.transparent,
                        foregroundColor: isSelected ? Colors.white : planColor,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: planColor),
                        ),
                      ),
                      child: Text(
                        isSelected ? 'Selected' : 'Select',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Most Popular badge
            if (isPopular)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: planColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Popular',
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
      ),
    );
  }

  Widget _buildSelectedPlanSummary() {
    final planData = _plans[_selectedPlan]!;
    final planColor = planData['color'] as Color;
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: planColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    planData['icon'],
                    color: planColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Plan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      planData['name'] + ' Plan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Text(
                  '\$${planData['price']}/month',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: planColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            const Divider(height: 1),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total payment today',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${planData['price']}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final planColor = _plans[_selectedPlan]!['color'] as Color;

    return Form(
      key: _formKey,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card number
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                  prefixIcon: Icon(Icons.credit_card),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your card number';
                  }
                  value = value.replaceAll(' ', '');
                  if (value.length < 16) {
                    return 'Please enter a valid card number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Expiry and CVV in a row
              Row(
                children: [
                  // Expiry date
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: 'Expiry Date',
                        hintText: 'MM/YY',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryDateFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (value.length < 5) {
                          return 'Invalid format';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  // CVV
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        prefixIcon: Icon(Icons.security),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (value.length < 3) {
                          return 'Invalid CVV';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Cardholder name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Cardholder Name',
                  hintText: 'John Smith',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the cardholder name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              // Payment button
              SizedBox(
                width: double.infinity,
                height: isSmallScreen ? 48 : 52,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : () => _processSubscription(_selectedPlan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: planColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Processing...'),
                          ],
                        )
                      : Text(
                          'Pay \$${_plans[_selectedPlan]!["price"]}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 16),
              // Secure payment notice
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Secure payment. Your card information is encrypted.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to determine if changing from oldPlan to newPlan is a downgrade
  bool _isDowngrade(String oldPlan, String newPlan) {
    // Define plan hierarchy
    final planRanks = {
      'mastermind': 3, // Highest tier
      'growth': 2,     // Middle tier
      'community': 1   // Lowest tier
    };
    
    final oldRank = planRanks[oldPlan] ?? 0;
    final newRank = planRanks[newPlan] ?? 0;
    
    // If the new plan has a lower rank than the old plan, it's a downgrade
    return newRank < oldRank;
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    // Remove all non-digits
    String value = newValue.text.replaceAll(' ', '');
    
    // Add a space after every 4 digits
    String formatted = '';
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += value[i];
    }
    
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;
    
    if (text.length == 2 && oldValue.text.length == 1) {
      text = '$text/';
    }
    
    return newValue.copyWith(text: text);
  }
}