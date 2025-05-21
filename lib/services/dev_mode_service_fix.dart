import 'package:shared_preferences/shared_preferences.dart';
import 'package:dreamflow/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for managing developer mode settings with improved reliability
/// This allows bypassing certain restrictions during development and testing
class DevModeServiceFix {
  static const String _devModeKey = 'dev_mode_enabled';
  static const String _bypassPaymentKey = 'bypass_payment_verification';
  
  /// Check if developer mode is enabled
  static Future<bool> isDevModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_devModeKey) ?? false;
  }
  
  /// Enable or disable developer mode with additional validation
  static Future<void> setDevModeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_devModeKey, enabled);
    // If enabling dev mode, ensure bypass payment is also enabled for consistency
    if (enabled) {
      await prefs.setBool(_bypassPaymentKey, true);
    }
  }
  
  /// Check if payment verification should be bypassed
  /// Includes fallback check to ensure consistency with dev mode
  static Future<bool> shouldBypassPayment() async {
    final prefs = await SharedPreferences.getInstance();
    bool explicitBypass = prefs.getBool(_bypassPaymentKey) ?? false;
    
    // If not explicitly bypassed, check if dev mode is enabled as a fallback
    if (!explicitBypass) {
      bool devModeEnabled = prefs.getBool(_devModeKey) ?? false;
      if (devModeEnabled) {
        // Auto-enable bypass if dev mode is on but bypass isn't
        await prefs.setBool(_bypassPaymentKey, true);
        return true;
      }
    }
    
    return explicitBypass;
  }
  
  /// Enable or disable payment verification bypass
  static Future<void> setBypassPayment(bool bypass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bypassPaymentKey, bypass);
  }
  
  /// Toggle developer mode with improved validation
  static Future<bool> toggleDevMode() async {
    final prefs = await SharedPreferences.getInstance();
    final currentValue = prefs.getBool(_devModeKey) ?? false;
    final newValue = !currentValue;
    
    await prefs.setBool(_devModeKey, newValue);
    
    // Sync the bypass payment setting with dev mode for consistency
    if (newValue) {
      await prefs.setBool(_bypassPaymentKey, true);
    }
    
    // Update user document in Firestore if user is logged in
    String? userId = FirebaseService.currentUserId;
    if (userId != null && newValue) {
      try {
        await FirebaseService.firestore.collection('users').doc(userId).update({
          'subscriptionTier': 'dev_mode',
          'canCreateCommunity': true,
          'communityLimit': -1, // -1 means unlimited
        });
      } catch (e) {
        print('Error updating user dev mode in Firestore: $e');
        // Don't fail the operation if Firestore update fails
      }
    }
    
    return newValue;
  }
  
  /// Toggle payment verification bypass with validation
  static Future<bool> toggleBypassPayment() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !(prefs.getBool(_bypassPaymentKey) ?? false);
    await prefs.setBool(_bypassPaymentKey, newValue);
    return newValue;
  }
  
  /// Reset all developer settings
  static Future<void> resetDevSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_devModeKey);
    await prefs.remove(_bypassPaymentKey);
  }
  
  /// Force enable developer mode and update Firestore user document
  static Future<Map<String, dynamic>> forceEnableDeveloperMode() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, dynamic>{
      'success': false,
      'error': null,
      'localUpdated': false,
      'firestoreUpdated': false,
    };
    
    try {
      // Update local preferences
      await prefs.setBool(_devModeKey, true);
      await prefs.setBool(_bypassPaymentKey, true);
      result['localUpdated'] = true;
      
      // Update Firestore user document if signed in
      String? userId = FirebaseService.currentUserId;
      if (userId != null) {
        try {
          await FirebaseService.firestore.collection('users').doc(userId).update({
            'subscriptionTier': 'dev_mode',
            'canCreateCommunity': true,
            'communityLimit': -1, // -1 means unlimited
          });
          result['firestoreUpdated'] = true;
        } catch (e) {
          result['error'] = 'Firestore update failed: $e';
          // Continue even if Firestore update fails
        }
      } else {
        result['error'] = 'User not signed in, Firestore not updated';
      }
      
      result['success'] = result['localUpdated'];
    } catch (e) {
      result['error'] = 'Error enabling developer mode: $e';
    }
    
    return result;
  }
}