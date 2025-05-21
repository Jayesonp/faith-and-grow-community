import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dreamflow/theme.dart';

/// A standardized card widget optimized for mobile displays
/// Provides consistent styling and layout for card elements
class MobileCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Clip clipBehavior;
  final bool hasBorder;
  final Color? borderColor;
  final double borderWidth;
  
  const MobileCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
    this.hasBorder = false,
    this.borderColor,
    this.borderWidth = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultRadius = BorderRadius.circular(8.r);
    final defaultPadding = EdgeInsets.all(16.r);
    final defaultMargin = EdgeInsets.only(bottom: 16.h);
    
    // Apply standard border if requested
    final BoxDecoration? decoration = hasBorder 
        ? BoxDecoration(
            border: Border.all(
              color: borderColor ?? theme.colorScheme.outline.withOpacity(0.5),
              width: borderWidth,
            ),
            borderRadius: borderRadius ?? defaultRadius,
          )
        : null;
    
    // Create properly styled card with touch feedback
    return Container(
      margin: margin ?? defaultMargin,
      decoration: decoration,
      child: Material(
        color: color ?? theme.colorScheme.surface,
        elevation: elevation ?? 2.0,
        borderRadius: borderRadius ?? defaultRadius,
        clipBehavior: clipBehavior,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? defaultRadius,
          child: Padding(
            padding: padding ?? defaultPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A mobile-optimized list item with standard styling and touch feedback
class MobileListItem extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? contentPadding;
  final bool dense;
  final Color? backgroundColor;
  final ShapeBorder? shape;
  
  const MobileListItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.contentPadding,
    this.dense = false,
    this.backgroundColor,
    this.shape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultPadding = EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h);
    
    return Material(
      color: backgroundColor ?? Colors.transparent,
      shape: shape ?? const RoundedRectangleBorder(),
      child: ListTile(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        onLongPress: onLongPress,
        contentPadding: contentPadding ?? defaultPadding,
        dense: dense,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Standard mobile touch target minimum size
        minVerticalPadding: 12.h,
        minLeadingWidth: 24.w,
      ),
    );
  }
}