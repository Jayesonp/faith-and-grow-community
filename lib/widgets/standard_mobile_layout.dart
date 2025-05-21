import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dreamflow/theme.dart';

/// A helper widget for standardizing mobile layouts across the app
/// This provides consistent padding, spacing, and organizational structure
class StandardMobileLayout extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool hasScrollableBody;
  final EdgeInsetsGeometry? padding;
  final bool centerTitle;
  final bool showBackButton;
  final Color? backgroundColor;
  final Widget? bottomSheet;
  final Widget? drawer;
  final PreferredSizeWidget? appBar;

  const StandardMobileLayout({
    Key? key,
    this.title,
    this.actions,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.hasScrollableBody = true,
    this.padding,
    this.centerTitle = true,
    this.showBackButton = true,
    this.backgroundColor,
    this.bottomSheet,
    this.drawer,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultPadding = EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h);
    
    return Scaffold(
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      appBar: appBar ?? (title != null ? _buildAppBar(context) : null),
      body: _buildBody(context),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      drawer: drawer,
      // Use safe area to handle notches and system UI properly
      resizeToAvoidBottomInset: true, // Standard for handling keyboard
    );
  }
  
  // Build a standard app bar with proper mobile styling
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      title: Text(
        title!,
        style: theme.textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: centerTitle,
      actions: actions,
      automaticallyImplyLeading: showBackButton,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      elevation: 0,
      titleSpacing: 16.w,
    );
  }
  
  // Build body with proper padding and scroll behavior
  Widget _buildBody(BuildContext context) {
    final bodyWidget = Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: body,
    );
    
    // Wrap in SafeArea for proper inset handling
    final safeAreaWidget = SafeArea(
      bottom: bottomNavigationBar == null,
      child: bodyWidget,
    );
    
    // Add scrolling if needed
    return hasScrollableBody
        ? SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: safeAreaWidget,
          )
        : safeAreaWidget;
  }
}

/// Extension for standardized mobile spacing
extension MobileSpacing on num {
  // Standard mobile margins and paddings
  double get xs => 4.r;
  double get sm => 8.r;
  double get md => 16.r;
  double get lg => 24.r;
  double get xl => 32.r;
  
  // Standard mobile icon sizes
  double get iconXs => 16.r;
  double get iconSm => 20.r;
  double get iconMd => 24.r;
  double get iconLg => 32.r;
  double get iconXl => 48.r;
  
  // Standard mobile button heights
  double get buttonHeight => 48.h;
  double get smallButtonHeight => 36.h;
  
  // Standard mobile container sizes
  double get cardElevation => 2.0;
  double get cardBorderRadius => 8.r;
}