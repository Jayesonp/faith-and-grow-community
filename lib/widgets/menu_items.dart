import 'package:flutter/material.dart';
import 'package:dreamflow/screens/pricing_example_screen.dart';

/// Helper methods to add menu items to the application
class MenuItems {
  /// Add a menu item to navigate to the pricing example screen
  static void navigateToPricingExample(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PricingExampleScreen(),
      ),
    );
  }
}