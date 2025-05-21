import 'package:flutter/material.dart';
import 'package:dreamflow/services/dev_mode_service.dart';
import 'package:dreamflow/services/dev_mode_service_fix.dart';
import 'package:dreamflow/services/firebase_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dreamflow/widgets/error_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DevModeDebugScreen extends StatefulWidget {
  const DevModeDebugScreen({Key? key}) : super(key: key);

  @override
  State<DevModeDebugScreen> createState() => _DevModeDebugScreenState();
}

class _DevModeDebugScreenState extends State<DevModeDebugScreen> {
  bool _isDevModeEnabled = false;
  bool _bypassPayment = false;
  bool _isLoading = true;
  Map<String, dynamic> _allPrefs = {};
  String _userId = '';
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      setState(() => _isLoading = true);
      
      // Load developer mode settings
      final devModeEnabled = await DevModeService.isDevModeEnabled();
      final bypassPayment = await DevModeService.shouldBypassPayment();
      
      // Attempt to get current user ID
      final userId = FirebaseService.currentUserId;
      String currentUserId = userId ?? 'Not logged in';
      Map<String, dynamic> userData = {};
      
      // If logged in, fetch user data
      if (userId != null) {
        try {
          final userDoc = await FirebaseService.firestore
              .collection('users')
              .doc(userId)
              .get();
          
          if (userDoc.exists) {
            userData = userDoc.data() as Map<String, dynamic>;
          } else {
            userData = {'error': 'User document does not exist'};
          }
        } catch (e) {
          userData = {'error': e.toString()};
        }
      }
      
      // Get all preferences for debugging
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      Map<String, dynamic> allPrefs = {};
      
      for (var key in allKeys) {
        if (prefs.get(key) != null) {
          allPrefs[key] = prefs.get(key);
        }
      }
      
      if (mounted) {
        setState(() {
          _isDevModeEnabled = devModeEnabled;
          _bypassPayment = bypassPayment;
          _allPrefs = allPrefs;
          _userId = currentUserId;
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading settings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ErrorNotification.showToast(
          context: context,
          message: 'Error loading settings: $e',
          type: NotificationType.error,
        );
      }
    }
  }

  Future<void> _toggleDevMode(bool value) async {
    try {
      setState(() => _isLoading = true);
      
      await DevModeService.setDevModeEnabled(value);
      
      // If turning off dev mode, also turn off all other dev settings
      if (!value) {
        await DevModeService.setBypassPayment(false);
      } else {
        // If turning on dev mode, turn on bypass payment by default
        await DevModeService.setBypassPayment(true);
      }
      
      await _loadSettings();
      
      ErrorNotification.showToast(
        context: context,
        message: 'Developer mode ${value ? 'enabled' : 'disabled'} successfully',
        type: NotificationType.success,
      );
    } catch (e) {
      print('Error toggling dev mode: $e');
      setState(() => _isLoading = false);
      ErrorNotification.showToast(
        context: context,
        message: 'Error toggling dev mode: $e',
        type: NotificationType.error,
      );
    }
  }

  Future<void> _toggleBypassPayment(bool value) async {
    try {
      setState(() => _isLoading = true);
      
      await DevModeService.setBypassPayment(value);
      await _loadSettings();
      
      ErrorNotification.showToast(
        context: context,
        message: 'Bypass payment ${value ? 'enabled' : 'disabled'} successfully',
        type: NotificationType.success,
      );
    } catch (e) {
      print('Error toggling bypass payment: $e');
      setState(() => _isLoading = false);
      ErrorNotification.showToast(
        context: context,
        message: 'Error toggling bypass payment: $e',
        type: NotificationType.error,
      );
    }
  }
  
  Future<void> _resetSettings() async {
    try {
      setState(() => _isLoading = true);
      
      // Use the fix service to reset all settings
      await DevModeServiceFix.resetDevSettings();
      await _loadSettings();
      
      ErrorNotification.showToast(
        context: context,
        message: 'Developer settings reset successfully',
        type: NotificationType.success,
      );
    } catch (e) {
      print('Error resetting settings: $e');
      setState(() => _isLoading = false);
      ErrorNotification.showToast(
        context: context,
        message: 'Error resetting settings: $e',
        type: NotificationType.error,
      );
    }
  }
  
  Future<void> _forceEnableDeveloperMode() async {
    try {
      setState(() => _isLoading = true);
      
      // Use the fix service to force enable developer mode
      await DevModeServiceFix.setDevModeEnabled(true);
      await DevModeServiceFix.setBypassPayment(true);
      
      // If the user is logged in, update their user document to have dev_mode privileges
      if (_userId != 'Not logged in') {
        try {
          await FirebaseService.firestore
              .collection('users')
              .doc(_userId)
              .update({
                'subscriptionTier': 'dev_mode',
                'canCreateCommunity': true,
                'communityLimit': -1, // Unlimited
              });
          
          ErrorNotification.showToast(
            context: context,
            message: 'User document updated with dev_mode privileges',
            type: NotificationType.success,
          );
        } catch (e) {
          print('Error updating user document: $e');
          ErrorNotification.showToast(
            context: context,
            message: 'Error updating user document: $e. Local settings still updated.',
            type: NotificationType.warning,
          );
        }
      }
      
      await _loadSettings();
      
      ErrorNotification.showToast(
        context: context,
        message: 'Developer mode forcefully enabled',
        type: NotificationType.success,
      );
    } catch (e) {
      print('Error force enabling dev mode: $e');
      setState(() => _isLoading = false);
      ErrorNotification.showToast(
        context: context,
        message: 'Error force enabling dev mode: $e',
        type: NotificationType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Mode Debugger'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSettings,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.bug_report,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 24.r,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Developer Mode Debugger',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Theme.of(context).colorScheme.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'This screen helps troubleshoot developer mode issues. You can check settings, reset preferences, and force enable developer mode.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Current Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SwitchListTile(
                              title: Text(
                                'Developer Mode',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              subtitle: Text(
                                'Master toggle for developer features',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              value: _isDevModeEnabled,
                              onChanged: _toggleDevMode,
                              activeColor: Theme.of(context).colorScheme.primary,
                              contentPadding: EdgeInsets.zero,
                            ),
                            Divider(),
                            SwitchListTile(
                              title: Text(
                                'Bypass Payment',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: _isDevModeEnabled
                                          ? null
                                          : Theme.of(context).disabledColor,
                                    ),
                              ),
                              subtitle: Text(
                                'Skip payment checks for community creation',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _isDevModeEnabled
                                          ? null
                                          : Theme.of(context).disabledColor,
                                    ),
                              ),
                              value: _bypassPayment,
                              onChanged: _isDevModeEnabled ? _toggleBypassPayment : null,
                              activeColor: Theme.of(context).colorScheme.primary,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Troubleshooting Actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _resetSettings,
                              icon: Icon(Icons.refresh),
                              label: Text('Reset All Developer Settings'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.error,
                                foregroundColor: Theme.of(context).colorScheme.onError,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            ElevatedButton.icon(
                              onPressed: _forceEnableDeveloperMode,
                              icon: Icon(Icons.power_settings_new),
                              label: Text('Force Enable Developer Mode'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.tertiary,
                                foregroundColor: Theme.of(context).colorScheme.onTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'User Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User ID: $_userId',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Divider(),
                            Text(
                              'User Data:',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: 8.h),
                            ..._userData.entries.map((entry) => Padding(
                                  padding: EdgeInsets.only(bottom: 4.h),
                                  child: Text(
                                    '${entry.key}: ${entry.value}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'All SharedPreferences',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ..._allPrefs.entries.map((entry) => Padding(
                                  padding: EdgeInsets.only(bottom: 4.h),
                                  child: Text(
                                    '${entry.key}: ${entry.value}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}