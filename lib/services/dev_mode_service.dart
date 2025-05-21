import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing developer mode settings
/// This allows bypassing certain restrictions during development and testing
class DevModeService {
  static const String _devModeKey = 'dev_mode_enabled';
  static const String _bypassPaymentKey = 'bypass_payment_verification';
  
  /// Check if developer mode is enabled
  static Future<bool> isDevModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_devModeKey) ?? false;
  }
  
  /// Enable or disable developer mode
  static Future<void> setDevModeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_devModeKey, enabled);
  }
  
  /// Check if payment verification should be bypassed
  static Future<bool> shouldBypassPayment() async {
    final prefs = await SharedPreferences.getInstance();
    final devModeEnabled = prefs.getBool(_devModeKey) ?? false;
    
    // Only check the bypass setting if dev mode is enabled
    if (devModeEnabled) {
      return prefs.getBool(_bypassPaymentKey) ?? true; // Default to true for development
    }
    
    // If dev mode is not enabled, return false
    return false;
  }
  
  /// Enable or disable payment verification bypass
  static Future<void> setBypassPayment(bool bypass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bypassPaymentKey, bypass);
  }
  
  /// Toggle developer mode
  static Future<bool> toggleDevMode() async {
    final prefs = await SharedPreferences.getInstance();
    final currentValue = prefs.getBool(_devModeKey) ?? false;
    await prefs.setBool(_devModeKey, !currentValue);
    return !currentValue;
  }
  
  /// Toggle payment verification bypass
  static Future<bool> toggleBypassPayment() async {
    final prefs = await SharedPreferences.getInstance();
    final currentValue = prefs.getBool(_bypassPaymentKey) ?? false;
    await prefs.setBool(_bypassPaymentKey, !currentValue);
    return !currentValue;
  }
}