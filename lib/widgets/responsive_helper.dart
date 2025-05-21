import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Responsive helper functions and extensions for consistent responsive design
class ResponsiveHelper {
  // Breakpoints for different device types
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;
  
  // Get device type based on width
  static DeviceScreenType getDeviceType(double width) {
    if (width >= tabletBreakpoint) return DeviceScreenType.desktop;
    if (width >= mobileBreakpoint) return DeviceScreenType.tablet;
    return DeviceScreenType.mobile;
  }
  
  // Get appropriate spacing based on screen size
  static double getSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      if (width >= 1600) return 32.0;
      if (width >= 1200) return 24.0;
      if (width >= 600) return 20.0;
      return 16.0;
    }
    return width < mobileBreakpoint ? 16.0 : (width < tabletBreakpoint ? 24.0 : 32.0);
  }
  
  // Get appropriate padding based on screen size
  static EdgeInsets getPadding(BuildContext context) {
    final spacing = getSpacing(context);
    return EdgeInsets.all(spacing);
  }
  
  // Get horizontal padding (for content areas)
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      if (width >= 1600) return EdgeInsets.symmetric(horizontal: 48.0);
      if (width >= 1200) return EdgeInsets.symmetric(horizontal: 40.0);
      if (width >= 600) return EdgeInsets.symmetric(horizontal: 32.0);
      return EdgeInsets.symmetric(horizontal: 20.0);
    }
    return EdgeInsets.symmetric(horizontal: getSpacing(context));
  }
  
  // Get card padding based on screen size
  static EdgeInsets getCardPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(width);
    
    if (kIsWeb) {
      if (width >= 1600) return EdgeInsets.all(20.0);
      if (width >= 1200) return EdgeInsets.all(16.0);
      if (width >= 600) return EdgeInsets.all(14.0);
      return EdgeInsets.all(12.0);
    }
    
    switch (deviceType) {
      case DeviceScreenType.desktop:
        return EdgeInsets.all(20.0);
      case DeviceScreenType.tablet:
        return EdgeInsets.all(16.0);
      case DeviceScreenType.mobile:
      default:
        return EdgeInsets.all(12.0);
    }
  }
  
  // Get grid column count based on screen size
  static int getGridColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (kIsWeb) {
      if (width >= 1600) return 4;
      if (width >= 1200) return 3;
      if (width >= 800) return 2;
      if (width >= 600) return 2;
      return 1;
    }
    
    if (width >= tabletBreakpoint) return 3;
    if (width >= mobileBreakpoint) return 2;
    return 1;
  }
  
  // Get appropriate font size adjustments
  static double getFontScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (kIsWeb) {
      if (width >= 1600) return 1.15;
      if (width >= 1200) return 1.05;
      if (width >= 600) return 0.95;
      return 0.9;
    }
    
    if (width >= tabletBreakpoint) return 1.1;
    if (width >= mobileBreakpoint) return 1.0;
    return 0.9;
  }
  
  // Determine if a hamburger menu should be used
  static bool shouldUseHamburgerMenu(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  // Get button height based on screen size
  static double getButtonHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (kIsWeb) {
      if (width >= 1600) return 48.0;
      if (width >= 1200) return 44.0;
      if (width >= 600) return 40.0;
      return 36.0;
    }
    
    if (width >= tabletBreakpoint) return 48.0;
    if (width >= mobileBreakpoint) return 44.0;
    return 40.0;
  }
  
  // Get appropriate max width constraint for web content
  static double getWebContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= 1600) return 1400.0;
    if (width >= 1200) return 1200.0;
    if (width >= 600) return 600.0;
    return width * 0.95; // 95% of screen width for smaller screens
  }
}

// Extension on BuildContext for easier responsive access
extension ResponsiveContextExtension on BuildContext {
  // Use ResponsiveHelper methods directly on context
  double get responsiveSpacing => ResponsiveHelper.getSpacing(this);
  EdgeInsets get responsivePadding => ResponsiveHelper.getPadding(this);
  EdgeInsets get horizontalPadding => ResponsiveHelper.getHorizontalPadding(this);
  EdgeInsets get cardPadding => ResponsiveHelper.getCardPadding(this);
  int get gridColumns => ResponsiveHelper.getGridColumnCount(this);
  double get fontScale => ResponsiveHelper.getFontScaleFactor(this);
  bool get useHamburgerMenu => ResponsiveHelper.shouldUseHamburgerMenu(this);
  double get buttonHeight => ResponsiveHelper.getButtonHeight(this);
  double get webContentMaxWidth => ResponsiveHelper.getWebContentMaxWidth(this);
  
  // Shorthand for getting screen size
  Size get screenSize => MediaQuery.of(this).size;
  
  // Responsive width and height percentages
  double widthPercent(double percent) => screenSize.width * percent;
  double heightPercent(double percent) => screenSize.height * percent;
  
  // Responsive constraints
  BoxConstraints get responsiveConstraints {
    if (kIsWeb) {
      final width = screenSize.width;
      
      if (width >= 1600) {
        return BoxConstraints(maxWidth: 1400, minHeight: 400);
      } else if (width >= 1200) {
        return BoxConstraints(maxWidth: 1100, minHeight: 400);
      } else if (width >= 600) {
        return BoxConstraints(maxWidth: width * 0.9, minHeight: 400);
      } else {
        return BoxConstraints(maxWidth: width * 0.95, minHeight: 300);
      }
    } else {
      return BoxConstraints(
        maxWidth: screenSize.width < 600 ? screenSize.width * 0.95 : 600,
        minHeight: 400,
      );
    }
  }
  
  // Responsive text styles with web optimizations
  TextStyle? get responsiveHeadline => Theme.of(this).textTheme.headlineMedium?.copyWith(
    fontSize: kIsWeb
        ? (screenSize.width < 600 ? 18.sp : (screenSize.width < 1200 ? 22.sp : 26.sp))
        : (screenSize.width < ResponsiveHelper.mobileBreakpoint ? 20.sp : 24.sp),
  );
  
  TextStyle? get responsiveTitle => Theme.of(this).textTheme.titleLarge?.copyWith(
    fontSize: kIsWeb
        ? (screenSize.width < 600 ? 16.sp : (screenSize.width < 1200 ? 18.sp : 20.sp))
        : (screenSize.width < ResponsiveHelper.mobileBreakpoint ? 18.sp : 22.sp),
  );
  
  TextStyle? get responsiveBody => Theme.of(this).textTheme.bodyMedium?.copyWith(
    fontSize: kIsWeb
        ? (screenSize.width < 600 ? 14.sp : (screenSize.width < 1200 ? 15.sp : 16.sp))
        : (screenSize.width < ResponsiveHelper.mobileBreakpoint ? 14.sp : 16.sp),
  );
  
  // Check if running in web
  bool get isWeb => kIsWeb;
}

// Responsive grid widget for layout
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final EdgeInsets? padding;
  final int? forceColumns;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  
  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.spacing = 16.0,
    this.padding,
    this.forceColumns,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final columns = forceColumns ?? ResponsiveHelper.getGridColumnCount(context);
    
    return GridView.builder(
      padding: padding ?? EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: kIsWeb ? 1.2 : 1.0, // Wider cells for web
      ),
      itemCount: children.length,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemBuilder: (context, index) => children[index],
    );
  }
}

// Responsive container that centers and constrains content
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;
  final BoxConstraints? constraints;
  
  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.constraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveConstraints = constraints ?? BoxConstraints(
      maxWidth: maxWidth ?? ResponsiveHelper.getWebContentMaxWidth(context),
    );
    
    return Center(
      child: Padding(
        padding: padding ?? (kIsWeb ? EdgeInsets.symmetric(horizontal: 20.0) : EdgeInsets.zero),
        child: ConstrainedBox(
          constraints: effectiveConstraints,
          child: child,
        ),
      ),
    );
  }
}

// Web-optimized card container
class WebResponsiveCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets? padding;
  final double? borderRadius;
  final bool hasShadow;
  
  const WebResponsiveCard({
    Key? key,
    required this.child,
    this.color,
    this.padding,
    this.borderRadius,
    this.hasShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? (kIsWeb ? 8.r : 12.r);
    final effectivePadding = padding ?? (kIsWeb 
        ? (MediaQuery.of(context).size.width >= 1200 ? EdgeInsets.all(20.r) : EdgeInsets.all(16.r))
        : EdgeInsets.all(16.r));
    
    return Card(
      elevation: hasShadow ? (kIsWeb ? 2 : 4) : 0,
      color: color ?? Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(effectiveBorderRadius)),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: effectivePadding,
        child: child,
      ),
    );
  }
}