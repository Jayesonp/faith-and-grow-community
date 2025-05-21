import 'package:flutter/material.dart';
import 'package:dreamflow/services/dev_mode_service.dart';
import 'package:dreamflow/services/dev_mode_service_fix.dart';
import 'package:dreamflow/services/firebase_service.dart';
import 'package:dreamflow/theme.dart';
import 'package:dreamflow/widgets/common_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dreamflow/widgets/error_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  String _lastError = '';
  bool _isUpdating = false;

  @override
  void initState() {
    _loadSettings();
    super.initState();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      // Get dev mode settings
      final devMode = await DevModeServiceFix.isDevModeEnabled();
      final bypassPayment = await DevModeServiceFix.shouldBypassPayment();
      
      // Get current user ID
      final userId = FirebaseService.currentUserId;
      
      // Load all preferences for debugging
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final allPrefs = <String, dynamic>{};
      
      for (var key in keys) {
        allPrefs[key] = prefs.get(key);
      }
      
      // Load user data from Firestore if available
      Map<String, dynamic> userData = {};
      if (userId != null) {
        try {
          final doc = await FirebaseService.firestore.collection('users').doc(userId).get();
          if (doc.exists) {
            userData = doc.data() as Map<String, dynamic>;
          } else {
            userData = {'error': 'Document does not exist'};
          }
        } catch (e) {
          userData = {'error': 'Failed to load user data: $e'};
        }
      }
      
      setState(() {
        _isDevModeEnabled = devMode;
        _bypassPayment = bypassPayment;
        _allPrefs = allPrefs;
        _userId = userId ?? 'Not signed in';
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _lastError = 'Error loading settings: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleDevMode(bool value) async {
    setState(() => _isUpdating = true);
    
    try {
      if (value) {
        // Use the improved service for enabling
        await DevModeServiceFix.setDevModeEnabled(true);
        
        // Try to update user document in Firestore
        if (FirebaseService.currentUserId != null) {
          try {
            await FirebaseService.firestore.collection('users').doc(FirebaseService.currentUserId).update({
              'subscriptionTier': 'dev_mode',
              'canCreateCommunity': true,
              'communityLimit': -1, // Unlimited communities
            });
          } catch (e) {
            setState(() => _lastError = 'Failed to update Firestore: $e');
          }
        }
      } else {
        await DevModeServiceFix.setDevModeEnabled(false);
      }
      
      // Refresh settings
      await _loadSettings();
      
      // Show result
      if (mounted) {
        ErrorNotification.showSnackBar(
          context: context, 
          message: 'Developer Mode ${value ? 'Enabled' : 'Disabled'}',
          type: NotificationType.success,
        );
      }
    } catch (e) {
      setState(() => _lastError = 'Error toggling dev mode: $e');
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _toggleBypassPayment(bool value) async {
    setState(() => _isUpdating = true);
    
    try {
      await DevModeServiceFix.setBypassPayment(value);
      
      // If enabling bypass and dev mode is off, also enable dev mode for consistency
      if (value && !_isDevModeEnabled) {
        await DevModeServiceFix.setDevModeEnabled(true);
        
        // Try to update user document in Firestore
        if (FirebaseService.currentUserId != null) {
          try {
            await FirebaseService.firestore.collection('users').doc(FirebaseService.currentUserId).update({
              'subscriptionTier': 'dev_mode',
              'canCreateCommunity': true,
            });
          } catch (e) {
            setState(() => _lastError = 'Failed to update Firestore: $e');
          }
        }
      }
      
      // Refresh settings
      await _loadSettings();
      
      // Show result
      if (mounted) {
        ErrorNotification.showSnackBar(
          context: context, 
          message: 'Payment Bypass ${value ? 'Enabled' : 'Disabled'}',
          type: NotificationType.success,
        );
      }
    } catch (e) {
      setState(() => _lastError = 'Error toggling payment bypass: $e');
    } finally {
      setState(() => _isUpdating = false);
    }
  }
  
  Future<void> _resetSettings() async {
    setState(() => _isUpdating = true);
    
    try {
      // Reset shared preferences
      await DevModeServiceFix.resetDevSettings();
      
      // Reset Firestore user document if signed in
      if (FirebaseService.currentUserId != null) {
        try {
          await FirebaseService.firestore.collection('users').doc(FirebaseService.currentUserId).update({
            'subscriptionTier': 'community', // Reset to basic tier
            'canCreateCommunity': false,
            'communityLimit': 0,
          });
        } catch (e) {
          setState(() => _lastError = 'Failed to reset Firestore: $e');
        }
      }
      
      // Refresh settings
      await _loadSettings();
      
      // Show result
      if (mounted) {
        ErrorNotification.showSnackBar(
          context: context, 
          message: 'All developer settings reset',
          type: NotificationType.success,
        );
      }
    } catch (e) {
      setState(() => _lastError = 'Error resetting settings: $e');
    } finally {
      setState(() => _isUpdating = false);
    }
  }
  
  Future<void> _forceEnableDeveloperMode() async {
    setState(() => _isUpdating = true);
    
    try {
      // Use the improved service to force enable dev mode
      final result = await DevModeServiceFix.forceEnableDeveloperMode();
      
      // Refresh settings
      await _loadSettings();
      
      // Show result based on what happened
      if (mounted) {
        if (result['success']) {
          String message = 'Developer Mode Enabled';
          if (result['firestoreUpdated']) {
            message += ' (Local + Firestore)';
          } else {
            message += ' (Local Only)';
          }
          
          ErrorNotification.showSnackBar(
            context: context, 
            message: message,
            type: NotificationType.success,
          );
        } else {
          ErrorNotification.showSnackBar(
            context: context, 
            message: 'Failed to enable Developer Mode: ${result['error']}',
            type: NotificationType.error,
          );
        }
      }
    } catch (e) {
      setState(() => _lastError = 'Error enabling developer mode: $e');
      
      if (mounted) {
        ErrorNotification.showSnackBar(
          context: context,
          message: 'Error enabling developer mode: $e',
          type: NotificationType.error,
        );
      }
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Mode Debugger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isUpdating ? null : _loadSettings,
            tooltip: 'Refresh Settings',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSettings,
              child: ListView(
                padding: EdgeInsets.all(16.r),
                children: [
                  _buildWarningCard(),
                  SizedBox(height: 16.h),
                  _buildSettingsCard(),
                  SizedBox(height: 16.h),
                  _buildActionButtons(),
                  SizedBox(height: 16.h),
                  _buildUserDataCard(),
                  SizedBox(height: 16.h),
                  if (_lastError.isNotEmpty) _buildErrorCard(),
                  if (_lastError.isNotEmpty) SizedBox(height: 16.h),
                  _buildAllPrefsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildWarningCard() {
    return Card(
      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                  size: 24.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Developer Mode Debugger',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'This screen helps diagnose and fix community creation permission issues. Using the "Force Enable Developer Mode" button will update both your local app settings AND your user document in Firestore.',
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Developer Settings',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            SwitchListTile(
              title: const Text('Developer Mode'),
              subtitle: const Text('Enables special developer capabilities'),
              value: _isDevModeEnabled,
              onChanged: _isUpdating ? null : _toggleDevMode,
            ),
            SwitchListTile(
              title: const Text('Bypass Payment Verification'),
              subtitle: const Text('Skip payment checks when creating communities'),
              value: _bypassPayment,
              onChanged: _isUpdating ? null : _toggleBypassPayment,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Developer Actions',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              icon: const Icon(Icons.security),
              label: const Text('Force Enable Developer Mode'),
              onPressed: _isUpdating ? null : _forceEnableDeveloperMode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: Size(double.infinity, 50.h),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'This will update both local settings AND your Firestore user document with dev_mode privileges',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            SizedBox(height: 16.h),
            OutlinedButton.icon(
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset All Developer Settings'),
              onPressed: _isUpdating ? null : _resetSettings,
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
                minimumSize: Size(double.infinity, 50.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDataCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Data',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text('User ID: $_userId'),
            SizedBox(height: 16.h),
            if (_userData.isEmpty)
              const Text('No user data available')
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var entry in _userData.entries)
                    if (entry.key != 'password' && entry.key != 'token')
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                            children: [
                              TextSpan(
                                text: '${entry.key}: ',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: '${entry.value}'),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Error',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.error),
            ),
            SizedBox(height: 8.h),
            Text(_lastError),
          ],
        ),
      ),
    );
  }

  Widget _buildAllPrefsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All SharedPreferences',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('About Preferences'),
                        content: const Text('This shows all values stored in your device\'s SharedPreferences, which can help diagnose persistent state issues.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 8.h),
            if (_allPrefs.isEmpty)
              const Text('No preferences stored')
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var entry in _allPrefs.entries)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          children: [
                            TextSpan(
                              text: '${entry.key}: ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: '${entry.value}'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}