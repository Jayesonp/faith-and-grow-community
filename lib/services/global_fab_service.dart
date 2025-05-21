import 'package:flutter/material.dart';
import 'package:dreamflow/widgets/pricing_fab.dart';

/// A service to manage the global floating action button for marketing
class GlobalFABService {
  static OverlayEntry? _fabEntry;

  /// Add the marketing button to the current overlay
  static void showMarketingButton(BuildContext context) {
    // Remove any existing button first
    removeMarketingButton();
    
    // Create the overlay entry with the pricing button
    _fabEntry = OverlayEntry(
      builder: (context) => Positioned(
        right: 20,
        bottom: 80, // Position above the bottom nav bar
        child: Material(
          color: Colors.transparent,
          child: PricingFAB(),
        ),
      ),
    );
    
    // Add the button to the overlay
    if (_fabEntry != null) {
      Overlay.of(context).insert(_fabEntry!);
    }
  }

  /// Remove the marketing button from the overlay
  static void removeMarketingButton() {
    _fabEntry?.remove();
    _fabEntry = null;
  }
}

/// Navigation observer that shows the marketing button on each page
class MarketingNavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _showButtonIfNeeded(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _showButtonIfNeeded(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _showButtonIfNeeded(previousRoute);
    }
  }

  void _showButtonIfNeeded(Route<dynamic> route) {
    // Get the context from the route
    final BuildContext? context = route.navigator?.context;
    if (context == null) return;
    
    // Delay slightly to ensure the screen is ready
    Future.delayed(const Duration(milliseconds: 300), () {
      // Show the marketing button only on specific screens
      final String routeName = route.settings.name ?? '';
      
      // Do not show on the pricing screen itself or payment screens
      if (routeName.contains('pricing') || routeName.contains('payment')) {
        GlobalFABService.removeMarketingButton();
        return;
      }
      
      // Show the button on screens where it makes sense
      if (context.mounted) {
        GlobalFABService.showMarketingButton(context);
      }
    });
  }
}