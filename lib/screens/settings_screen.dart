import 'package:flutter/material.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/services/auth_service.dart';
import 'package:dreamflow/services/theme_service.dart';
import 'package:dreamflow/screens/pricing_screen.dart';
import 'package:dreamflow/screens/profile_screen.dart';
import 'package:dreamflow/screens/help_center_screen.dart';
import 'package:dreamflow/screens/dev_mode_debug_screen_fixed.dart' as fixed;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  final String userId;
  
  const SettingsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  User? _user;
  bool _darkModeEnabled = false;
  bool _notificationsEnabled = true;
  bool _emailUpdatesEnabled = true;
  int _devModeClickCounter = 0; // Counter for developer mode activation
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkThemeMode();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = await UserService.getCurrentUser();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _checkThemeMode() {
    // Get the current theme state from the provider
    final themeService = Provider.of<ThemeService>(context, listen: false);
    setState(() {
      _darkModeEnabled = themeService.isDarkMode;
    });
  }
  
  Future<void> _toggleDarkMode(bool value) async {
    // Update the theme using the provider
    final themeService = Provider.of<ThemeService>(context, listen: false);
    await themeService.toggleTheme(value);
    setState(() {
      _darkModeEnabled = value;
    });
  }
  
  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });
    // This would normally save the preference
  }
  
  Future<void> _toggleEmailUpdates(bool value) async {
    setState(() {
      _emailUpdatesEnabled = value;
    });
    // This would normally save the preference
  }
  
  Future<void> _logout() async {
    try {
      await AuthService.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }
  
  Future<void> _deleteAccount() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
    
    if (confirmed) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Delete user account logic would go here
        // For this demo, we'll just sign out
        await AuthService.signOut();
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.r),
              children: [
                _buildProfileSection(),
                SizedBox(height: 24.h),
                _buildPreferencesSection(),
                SizedBox(height: 24.h),
                _buildMembershipSection(),
                SizedBox(height: 24.h),
                _buildSecuritySection(),
                SizedBox(height: 24.h),
                _buildAboutSection(),
                SizedBox(height: 32.h),
                _buildLogoutButton(),
                SizedBox(height: 16.h),
                _buildDeleteAccountButton(),
              ],
            ),
    );
  }

  Widget _buildProfileSection() {
    return _buildSection(
      title: 'Profile',
      icon: Icons.person,
      children: [
        ListTile(
          title: Text('Edit Profile'),
          subtitle: Text('Update your personal information'),
          leading: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(userId: widget.userId),
              ),
            );
          },
        ),
        ListTile(
          title: Text('Change Profile Picture'),
          subtitle: Text('Update your avatar'),
          leading: Icon(Icons.image, color: Theme.of(context).colorScheme.primary),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () async {
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            try {
              // This would use the image_upload utility in a complete implementation
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('Profile picture update coming in the next update!')),
              );
            } catch (e) {
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('Error updating profile picture: $e')),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSection(
      title: 'Preferences',
      icon: Icons.settings,
      children: [
        SwitchListTile(
          title: Text('Dark Mode'),
          subtitle: Text('Use dark theme'),
          secondary: Icon(Icons.dark_mode, color: Theme.of(context).colorScheme.primary),
          value: _darkModeEnabled,
          onChanged: _toggleDarkMode,
        ),
        SwitchListTile(
          title: Text('Push Notifications'),
          subtitle: Text('Receive push notifications'),
          secondary: Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary),
          value: _notificationsEnabled,
          onChanged: _toggleNotifications,
        ),
        SwitchListTile(
          title: Text('Email Updates'),
          subtitle: Text('Receive email updates'),
          secondary: Icon(Icons.email, color: Theme.of(context).colorScheme.primary),
          value: _emailUpdatesEnabled,
          onChanged: _toggleEmailUpdates,
        ),
      ],
    );
  }

  Widget _buildMembershipSection() {
    return _buildSection(
      title: 'Membership',
      icon: Icons.card_membership,
      children: [
        ListTile(
          title: Text('Subscription Plans'),
          subtitle: Text(_user?.subscriptionTier != null ? 
              'Current plan: ${_user!.subscriptionTier.toUpperCase()}' : 
              'Select a subscription plan'),
          leading: Icon(Icons.monetization_on, color: Theme.of(context).colorScheme.primary),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PricingScreen(),
              ),
            );
          },
        ),
        ListTile(
          title: Text('Billing Information'),
          subtitle: Text('Manage payment methods'),
          leading: Icon(Icons.credit_card, color: Theme.of(context).colorScheme.primary),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showBillingInformationDialog();
          },
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildSection(
      title: 'Security',
      icon: Icons.security,
      children: [
        ListTile(
          title: Text('Change Password'),
          subtitle: Text('Update your password'),
          leading: Icon(Icons.lock, color: Theme.of(context).colorScheme.primary),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showChangePasswordDialog();
          },
        ),
        ListTile(
          title: Text('Privacy Settings'),
          subtitle: Text('Manage your privacy preferences'),
          leading: Icon(Icons.privacy_tip, color: Theme.of(context).colorScheme.primary),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showPrivacySettingsDialog();
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'About',
      icon: Icons.info,
      children: [
        ListTile(
          title: Text('Help Center'),
          leading: Icon(Icons.help_outline, color: Theme.of(context).colorScheme.primary),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HelpCenterScreen(),
              ),
            );
          },
        ),
        ListTile(
          title: Text('Terms of Service'),
          leading: Icon(Icons.description, color: Theme.of(context).colorScheme.primary),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showLegalDocumentDialog('Terms of Service');
          },
        ),
        ListTile(
          title: Text('Privacy Policy'),
          leading: Icon(Icons.policy, color: Theme.of(context).colorScheme.primary),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showLegalDocumentDialog('Privacy Policy');
          },
        ),
        ListTile(
          title: Text('App Version'),
          subtitle: Text('1.0.0'),
          leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
          onTap: null,
        ),
        // Hidden developer options - tap 5 times to activate
        GestureDetector(
          onTap: () {
            _devModeClickCounter++;
            if (_devModeClickCounter >= 5) {
              _devModeClickCounter = 0;
              // Open the improved debug screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const fixed.DevModeDebugScreen(),
                ),
              );
            }
          },
          child: ListTile(
            title: Text('Build Number'),
            subtitle: Text('${DateTime.now().year}.${DateTime.now().month}.${DateTime.now().day}'),
            leading: Icon(Icons.build, color: Theme.of(context).colorScheme.primary),
            onTap: null,
          ),
        ),
        ListTile(
          title: Text('Developer Mode Debugger'),
          leading: Icon(Icons.bug_report, color: Theme.of(context).colorScheme.tertiary),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const fixed.DevModeDebugScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: _logout,
      icon: Icon(Icons.logout),
      label: Text('Log Out'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return OutlinedButton.icon(
      onPressed: _deleteAccount,
      icon: Icon(Icons.delete_forever),
      label: Text('Delete Account'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: BorderSide(color: Colors.red),
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showLegalDocumentDialog(String documentType) {
    // Sample text for demonstration
    String content;
    if (documentType == 'Terms of Service') {
      content = '''# TERMS OF SERVICE

## Last Updated: May 1, 2023

### 1. AGREEMENT TO TERMS

These Terms of Service constitute a legally binding agreement made between you and Faith and Grow, concerning your access to and use of the Faith and Grow platform.

### 2. INTELLECTUAL PROPERTY RIGHTS

Unless otherwise indicated, the Platform is our proprietary property and all source code, databases, functionality, software, website designs, audio, video, text, photographs, and graphics on the Platform and the trademarks, service marks, and logos contained therein are owned or controlled by us or licensed to us.

### 3. USER REPRESENTATIONS

By using the Platform, you represent and warrant that: (1) you have the legal capacity to accept these Terms of Service; (2) you are not a minor in the jurisdiction in which you reside; (3) you will not access the Platform through automated or non-human means; (4) you will not use the Platform for any illegal or unauthorized purpose; and (5) your use of the Platform will not violate any applicable law or regulation.

### 4. PROHIBITED ACTIVITIES

You may not access or use the Platform for any purpose other than that for which we make the Platform available. As examples of prohibited activities, you agree not to:

- Systematically retrieve data to create a collection or database
- Trick, defraud, or mislead us
- Disparage, tarnish, or harm our platform
- Use information obtained from the Platform to harass, abuse, or harm another person
- Make improper use of our support services
- Use the Platform in any manner that could disable, overburden, damage, or impair the Platform

### 5. SUBMISSIONS

You acknowledge and agree that any questions, comments, suggestions, ideas, feedback, or other information regarding the Platform provided by you are non-confidential and shall become our sole property.''';
    } else {
      content = '''# PRIVACY POLICY

## Last Updated: May 1, 2023

### INTRODUCTION

Faith and Grow ("we" or "us" or "our") respects the privacy of our users ("user" or "you"). This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you visit our mobile application and platform. Please read this policy carefully. 

### INFORMATION WE COLLECT

We may collect information about you in a variety of ways. The information we may collect via the Platform includes:

**Personal Data:** Personally identifiable information, such as your name, shipping address, email address, and telephone number, and demographic information, such as your age, gender, hometown, and interests, that you voluntarily give to us when you register with the Platform or when you choose to participate in various activities related to the Platform.

**Derivative Data:** Information our servers automatically collect when you access the Platform, such as your IP address, browser type, operating system, access times, and the pages you have viewed directly before and after accessing the Platform.

**Mobile Device Data:** Device information, such as your mobile device ID, model, and manufacturer, and information about the location of your device, if you access the Platform from a mobile device.

**Data From Social Networks:** Information from social networking sites, such as Facebook, Twitter, Instagram, LinkedIn, including your name, your social network username, location, gender, birth date, email address, profile picture, and public data for contacts.

### USE OF YOUR INFORMATION

Having accurate information about you enables us to provide you with a smooth, efficient, and customized experience. Specifically, we may use information collected about you via the Platform to:

- Create and manage your account
- Email you regarding your account or order
- Fulfill and manage purchases, orders, payments, and other transactions
- Increase the efficiency and operation of the Platform
- Monitor and analyze usage and trends
- Notify you of updates to the Platform
- Resolve disputes and troubleshoot problems
- Process payments''';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(documentType),
        content: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: SingleChildScrollView(
            child: SelectableText(content),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBillingInformationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Billing Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current payment method
            Text(
              'Current Payment Method',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Card(
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.credit_card, color: Theme.of(context).colorScheme.primary),
                title: Text('Visa ending in 4242'),
                subtitle: Text('Expires 12/2025'),
                trailing: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showUpdatePaymentMethodDialog();
                  },
                  child: Text('Update'),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Billing history
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView(
                padding: EdgeInsets.all(0),
                children: [
                  ListTile(
                    title: Text('Growth Plan Subscription'),
                    subtitle: Text('May 15, 2023'),
                    trailing: Text(
                      '\$97.00',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Growth Plan Subscription'),
                    subtitle: Text('April 15, 2023'),
                    trailing: Text(
                      '\$97.00',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Growth Plan Subscription'),
                    subtitle: Text('March 15, 2023'),
                    trailing: Text(
                      '\$97.00',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUpdatePaymentMethodDialog() {
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Payment Method'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: expiryController,
                      decoration: InputDecoration(
                        labelText: 'Expiry Date',
                        hintText: 'MM/YY',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Cardholder Name',
                  hintText: 'John Smith',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cardholder name';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // In a real app, this would update the payment method
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment method updated successfully')),
                );
              }
            },
            child: Text('Update Payment Method'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettingsDialog() {
    bool showProfileToPublic = true;
    bool allowMessagesFromAnyone = false;
    bool shareActivityWithFollowers = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Privacy Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('Public Profile'),
                subtitle: Text('Allow others to view your profile'),
                value: showProfileToPublic,
                onChanged: (value) {
                  setState(() {
                    showProfileToPublic = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Message Privacy'),
                subtitle: Text('Allow messages from anyone'),
                value: allowMessagesFromAnyone,
                onChanged: (value) {
                  setState(() {
                    allowMessagesFromAnyone = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Activity Visibility'),
                subtitle: Text('Share your activity with followers'),
                value: shareActivityWithFollowers,
                onChanged: (value) {
                  setState(() {
                    shareActivityWithFollowers = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // In a real app, this would save the privacy settings
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Privacy settings updated')),
                );
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // In a real app, this would call the auth service to update the password
                // For this demo, we'll just show a success message
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password updated successfully')),
                );
              }
            },
            child: Text('Update Password'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ...children,
          ],
        ),
      ),
    );
  }
}