import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// A responsive layout widget that adjusts its layout based on screen size and orientation
class ResponsiveLayout extends StatelessWidget {
  final Widget mobilePortraitBody;
  final Widget? mobileLandscapeBody;
  final Widget? tabletPortraitBody;
  final Widget? tabletLandscapeBody;
  final Widget? desktopBody;

  const ResponsiveLayout({
    Key? key,
    required this.mobilePortraitBody,
    this.mobileLandscapeBody,
    this.tabletPortraitBody,
    this.tabletLandscapeBody,
    this.desktopBody,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get current device width and orientation for more precise layout decisions
    final width = MediaQuery.of(context).size.width;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    // Enhanced breakpoints with width-based fine tuning
    Widget selectLayout() {
      // Web-specific adjustments with proper breakpoints
      if (kIsWeb) {
        if (width >= 1200) { // Desktop breakpoint (769px+, but using 1200 for larger screens)
          return desktopBody ?? (tabletLandscapeBody ?? tabletPortraitBody ?? mobileLandscapeBody ?? mobilePortraitBody);
        } else if (width >= 768) { // Tablet breakpoint (481-768px)
          return tabletLandscapeBody ?? (tabletPortraitBody ?? mobileLandscapeBody ?? mobilePortraitBody);
        } else if (width >= 480) { // Large mobile breakpoint (480-768px)
          return tabletPortraitBody ?? mobileLandscapeBody ?? mobilePortraitBody;
        } else { // Mobile breakpoint (320-480px)
          return mobileLandscapeBody ?? mobilePortraitBody;
        }
      }
      
      // Mobile app-specific breakpoints
      // Desktop - Large screens (always use desktop layout regardless of orientation)
      if (width >= 1200) {
        return desktopBody ?? (tabletLandscapeBody ?? tabletPortraitBody ?? mobileLandscapeBody ?? mobilePortraitBody);
      }
      
      // Tablet - Medium screens
      if (width >= 600) {
        if (isPortrait) {
          return tabletPortraitBody ?? mobilePortraitBody;
        } else {
          return tabletLandscapeBody ?? (tabletPortraitBody ?? mobileLandscapeBody ?? mobilePortraitBody);
        }
      }
      
      // Mobile - Small screens
      if (isPortrait) {
        return mobilePortraitBody;
      } else {
        return mobileLandscapeBody ?? mobilePortraitBody;
      }
    }
    
    return selectLayout();
  }
}

/// A widget that adjusts its padding based on screen size and orientation
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double? mobileHorizontal;
  final double? mobileLandscapeHorizontal;
  final double? tabletHorizontal;
  final double? tabletLandscapeHorizontal;
  final double? desktopHorizontal;
  final double? vertical;
  final double? mobileVertical;
  final double? tabletVertical;
  final double? desktopVertical;

  const ResponsivePadding({
    Key? key,
    required this.child,
    this.mobileHorizontal = 16.0,
    this.mobileLandscapeHorizontal,
    this.tabletHorizontal = 24.0,
    this.tabletLandscapeHorizontal,
    this.desktopHorizontal = 32.0,
    this.vertical,
    this.mobileVertical,
    this.tabletVertical,
    this.desktopVertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        // Get device details
        final width = MediaQuery.of(context).size.width;
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
        
        // Determine horizontal padding with improved proportions for web
        double horizontalPadding;
        if (kIsWeb) {
          if (width >= 1200) { // Desktop
            horizontalPadding = desktopHorizontal ?? 48.0;
          } else if (width >= 768) { // Tablet
            horizontalPadding = tabletHorizontal ?? 32.0;
          } else if (width >= 480) { // Large mobile
            horizontalPadding = tabletHorizontal ?? 24.0;
          } else { // Small mobile
            horizontalPadding = mobileHorizontal ?? 16.0;
          }
        } else if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
          horizontalPadding = desktopHorizontal ?? 32.0;
        } else if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
          horizontalPadding = isLandscape
              ? (tabletLandscapeHorizontal ?? tabletHorizontal ?? 24.0)
              : (tabletHorizontal ?? 24.0);
        } else {
          horizontalPadding = isLandscape
              ? (mobileLandscapeHorizontal ?? mobileHorizontal ?? 16.0)
              : (mobileHorizontal ?? 16.0);
        }
        
        // Determine vertical padding
        double verticalPadding;
        if (kIsWeb) {
          if (width >= 1200) { // Desktop
            verticalPadding = desktopVertical ?? vertical ?? 24.0;
          } else if (width >= 768) { // Tablet
            verticalPadding = tabletVertical ?? vertical ?? 20.0;
          } else { // Mobile
            verticalPadding = mobileVertical ?? vertical ?? 16.0;
          }
        } else if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
          verticalPadding = desktopVertical ?? vertical ?? 24.0;
        } else if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
          verticalPadding = tabletVertical ?? vertical ?? 20.0;
        } else {
          verticalPadding = mobileVertical ?? vertical ?? 16.0;
        }
        
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: child,
        );
      },
    );
  }
}

/// A widget that adjusts the constraints of its child based on screen size
class ResponsiveConstraints extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final double? maxHeight;
  final double? mobileMaxWidth;
  final double? tabletMaxWidth;
  final double? desktopMaxWidth;
  final double? webMaxWidth;

  const ResponsiveConstraints({
    Key? key,
    required this.child,
    this.maxWidth,
    this.maxHeight,
    this.mobileMaxWidth,
    this.tabletMaxWidth,
    this.desktopMaxWidth,
    this.webMaxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        final width = MediaQuery.of(context).size.width;
        double effectiveMaxWidth;
        
        // Web-specific handling with more appropriate max-widths
        if (kIsWeb) {
          if (width >= 1600) { // Extra large desktop
            effectiveMaxWidth = webMaxWidth ?? 1400.0;
          } else if (width >= 1200) { // Desktop
            effectiveMaxWidth = webMaxWidth ?? 1140.0;
          } else if (width >= 768) { // Tablet
            effectiveMaxWidth = webMaxWidth ?? 720.0;
          } else if (width >= 480) { // Large mobile
            effectiveMaxWidth = webMaxWidth ?? 450.0;  
          } else { // Small mobile
            effectiveMaxWidth = webMaxWidth ?? 400.0;
          }
        } else {
          switch (sizingInformation.deviceScreenType) {
            case DeviceScreenType.desktop:
              effectiveMaxWidth = desktopMaxWidth ?? maxWidth ?? 1200.0;
              break;
            case DeviceScreenType.tablet:
              effectiveMaxWidth = tabletMaxWidth ?? maxWidth ?? 700.0;
              break;
            case DeviceScreenType.mobile:
            default:
              effectiveMaxWidth = mobileMaxWidth ?? maxWidth ?? 450.0;
              break;
          }
        }
        
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: effectiveMaxWidth,
              maxHeight: maxHeight ?? double.infinity,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// Responsive grid layout for multi-column content
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? padding;
  final int? forceCrossAxisCount;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final Axis scrollDirection;
  final Widget? emptyWidget;
  final bool mobileOptimized;

  const ResponsiveGridView({
    Key? key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.padding,
    this.forceCrossAxisCount,
    this.shrinkWrap = false,
    this.physics,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.emptyWidget,
    this.mobileOptimized = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Show empty widget if children is empty
    if (children.isEmpty && emptyWidget != null) {
      return emptyWidget!;
    }
    
    // Get crossAxisCount based on screen width - optimized for mobile first
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    
    // If mobileOptimized is true, use stricter breakpoints for mobile
    if (mobileOptimized) {
      // Mobile-optimized grid layout with better breakpoints
      crossAxisCount = forceCrossAxisCount ?? (
        screenWidth < 480 ? 1 : 
        (screenWidth < 768 ? 2 : 
         screenWidth < 1200 ? 3 : 4)
      );
      
      // Use a more touch-friendly grid on small screens
      if (screenWidth < 480) {
        return ListView.separated(
          itemCount: children.length,
          shrinkWrap: shrinkWrap,
          physics: physics,
          scrollDirection: scrollDirection,
          controller: controller,
          padding: padding ?? EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h
          ),
          separatorBuilder: (context, index) => SizedBox(height: runSpacing),
          itemBuilder: (context, index) => children[index],
        );
      }
    } else {
      // Standard responsive grid layout
      crossAxisCount = forceCrossAxisCount ?? (screenWidth < 600 ? 1 : (screenWidth < 960 ? 2 : 3));
    }
    
    // Use GridView for larger screens
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: mobileOptimized ? (screenWidth < 768 ? 1.2 : 1.0) : 1.0,
      ),
      itemCount: children.length,
      shrinkWrap: shrinkWrap,
      physics: physics,
      scrollDirection: scrollDirection,
      controller: controller,
      padding: padding ?? EdgeInsets.all(16.r),
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Enhanced extension methods for responsive design
extension ResponsiveExtensions on BuildContext {
  // Screen size breakpoints with more precision
  bool get isMobile => MediaQuery.of(this).size.width < 480;
  bool get isTablet => MediaQuery.of(this).size.width >= 480 && MediaQuery.of(this).size.width < 768;
  bool get isDesktop => MediaQuery.of(this).size.width >= 768;
  bool get isLargeDesktop => MediaQuery.of(this).size.width >= 1200;
  bool get isWeb => kIsWeb;
  
  // Orientation helpers
  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;
  
  // Combined device + orientation helpers
  bool get isMobilePortrait => isMobile && isPortrait;
  bool get isMobileLandscape => isMobile && isLandscape;
  bool get isTabletPortrait => isTablet && isPortrait;
  bool get isTabletLandscape => isTablet && isLandscape;
  
  // Screen dimensions
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  Size get screenSize => MediaQuery.of(this).size;
  
  // Percentage-based dimensions with improved clamping for extremes
  double percentWidth(double percent) => (MediaQuery.of(this).size.width * percent).clamp(0.0, double.infinity);
  double percentHeight(double percent) => (MediaQuery.of(this).size.height * percent).clamp(0.0, double.infinity);
  
  // Dynamic text scaling based on screen width - adjusted to prevent oversized text on desktop
  double get textScaleFactor {
    if (kIsWeb) {
      final width = screenWidth;
      if (width >= 1600) return 1.0;     // Extra large desktop - standard scale
      if (width >= 1200) return 0.95;    // Desktop - slightly smaller
      if (width >= 768) return 0.9;      // Tablet - smaller
      if (width >= 480) return 0.85;     // Large mobile - even smaller
      return 0.8;                        // Small mobile - smallest
    }
    return isMobile ? 1.0 : (isTablet ? 1.1 : 1.2);
  }
  
  // Responsive spacing that scales proportionally
  double get spacing {
    if (kIsWeb) {
      final width = screenWidth;
      if (width >= 1600) return 32.0;    // Extra large desktop
      if (width >= 1200) return 24.0;    // Desktop
      if (width >= 768) return 20.0;     // Tablet 
      if (width >= 480) return 16.0;     // Large mobile
      return 12.0;                       // Small mobile
    }
    return isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
  }
  
  // Responsive padding options with increased consistency across screen sizes
  EdgeInsets get responsivePadding => EdgeInsets.all(spacing);
  EdgeInsets get responsiveHorizontalPadding => EdgeInsets.symmetric(horizontal: spacing);
  EdgeInsets get responsiveVerticalPadding => EdgeInsets.symmetric(vertical: spacing * 0.75);
  
  // Content margin that adapts to screen size - improved for desktop
  EdgeInsets get contentMargin {
    if (kIsWeb) {
      final width = screenWidth;
      if (width >= 1600) return EdgeInsets.symmetric(horizontal: 64.0, vertical: 32.0);
      if (width >= 1200) return EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0);
      if (width >= 768) return EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0);
      if (width >= 480) return EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);
      return EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
    }
    return isMobile ? EdgeInsets.all(16.0) : (isTablet ? EdgeInsets.all(24.0) : EdgeInsets.all(32.0));
  }
  
  // Dynamic font sizes with web-specific adjustments - modified for better desktop scaling
  // For web platforms, scale factors are reduced to prevent oversized text
  double get headingFontSize {
    if (kIsWeb) {
      final width = screenWidth;
      if (width >= 1600) return 28.0;     // Extra large desktop
      if (width >= 1200) return 26.0;     // Desktop
      if (width >= 768) return 24.0;      // Tablet
      if (width >= 480) return 22.0;      // Large mobile
      return 20.0;                        // Small mobile
    }
    return isMobile ? 24.0.sp : (isTablet ? 28.0.sp : 32.0.sp);
  }
  
  double get titleFontSize {
    if (kIsWeb) {
      final width = screenWidth;
      if (width >= 1600) return 24.0;     // Extra large desktop
      if (width >= 1200) return 22.0;     // Desktop
      if (width >= 768) return 20.0;      // Tablet
      if (width >= 480) return 18.0;      // Large mobile
      return 16.0;                        // Small mobile
    }
    return isMobile ? 20.0.sp : (isTablet ? 22.0.sp : 24.0.sp);
  }
  
  double get subtitleFontSize {
    if (kIsWeb) {
      final width = screenWidth;
      if (width >= 1600) return 20.0;     // Extra large desktop
      if (width >= 1200) return 18.0;     // Desktop
      if (width >= 768) return 17.0;      // Tablet
      if (width >= 480) return 16.0;      // Large mobile
      return 15.0;                        // Small mobile
    }
    return isMobile ? 18.0.sp : (isTablet ? 20.0.sp : 22.0.sp);
  }
  
  double get bodyFontSize {
    if (kIsWeb) {
      final width = screenWidth;
      if (width >= 1600) return 16.0;     // Extra large desktop
      if (width >= 1200) return 15.0;     // Desktop
      if (width >= 768) return 14.0;      // Tablet
      if (width >= 480) return 14.0;      // Large mobile
      return 13.0;                        // Small mobile
    }
    return isMobile ? 16.0.sp : (isTablet ? 17.0.sp : 18.0.sp);
  }
  
  double get smallTextFontSize {
    if (kIsWeb) {
      final width = screenWidth;
      if (width >= 1600) return 14.0;     // Extra large desktop
      if (width >= 1200) return 13.0;     // Desktop
      if (width >= 768) return 12.0;      // Tablet 
      if (width >= 480) return 12.0;      // Large mobile
      return 11.0;                        // Small mobile
    }
    return isMobile ? 14.0.sp : (isTablet ? 15.0.sp : 16.0.sp);
  }
  
  // Spacing factor for layout multipliers
  double get spacingFactor {
    if (kIsWeb) {
      final width = screenWidth; 
      if (width >= 1600) return 1.5;      // Extra large desktop
      if (width >= 1200) return 1.4;      // Desktop
      if (width >= 768) return 1.25;      // Tablet
      if (width >= 480) return 1.1;       // Large mobile 
      return 1.0;                         // Small mobile
    }
    return isMobile ? 1.0 : (isTablet ? 1.25 : 1.5);
  }
  
  // Responsive border radius
  double get borderRadius {
    if (kIsWeb) {
      final width = screenWidth;
      if (width >= 1600) return 12.0;     // Extra large desktop
      if (width >= 1200) return 10.0;     // Desktop
      if (width >= 768) return 8.0;       // Tablet
      return 8.0;                         // Mobile
    }
    return (isMobile ? 8.0 : (isTablet ? 10.0 : 12.0)).r;
  }
  
  // Get appropriate grid column count based on screen size
  int get gridColumnCount {
    if (kIsWeb) {
      final width = screenWidth;
      if (width >= 1600) return 4;        // Extra large desktop: 4 columns
      if (width >= 1200) return 3;        // Desktop: 3 columns
      if (width >= 768) return 2;         // Tablet: 2 columns
      return 1;                           // Mobile: 1 column
    }
    return isMobile ? 1 : (isTablet ? 2 : 3);
  }
  
  // Helper functions for min and max
  int min(int a, int b) => a < b ? a : b;
  int max(int a, int b) => a > b ? a : b;
}