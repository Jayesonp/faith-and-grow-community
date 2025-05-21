import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A standardized text field optimized for mobile interfaces
/// Provides consistent styling and behavior for text inputs
class MobileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? style;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final bool autofocus;
  final bool readOnly;
  final TextAlign textAlign;

  const MobileTextField({
    Key? key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIcon,
    this.suffixIcon,
    this.fillColor,
    this.contentPadding,
    this.style,
    this.focusNode,
    this.validator,
    this.autofocus = false,
    this.readOnly = false,
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultPadding = EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      onTap: onTap,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      style: style ?? theme.textTheme.bodyLarge,
      focusNode: focusNode,
      validator: validator,
      autofocus: autofocus,
      readOnly: readOnly,
      textAlign: textAlign,
      // Apply mobile-optimized decoration
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        filled: true,
        fillColor: fillColor ?? theme.colorScheme.surface,
        contentPadding: contentPadding ?? defaultPadding,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        // Mobile-friendly border styling
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2.0),
        ),
        // Ensure hints and labels are properly sized for mobile
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.hintColor,
        ),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

/// A standardized button optimized for mobile interfaces
/// Provides consistent styling and behavior for buttons
class MobileButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double? elevation;

  const MobileButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.isFullWidth = false,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.padding,
    this.borderRadius,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultHeight = 48.h;
    final defaultPadding = EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h);
    final defaultRadius = 8.r;
    
    // Determine colors based on style and theme
    final bgColor = isOutlined ? Colors.transparent : (backgroundColor ?? theme.colorScheme.primary);
    final txtColor = isOutlined 
        ? (textColor ?? theme.colorScheme.primary) 
        : (textColor ?? theme.colorScheme.onPrimary);
    
    // Create button style
    final buttonStyle = ElevatedButton.styleFrom(
      elevation: elevation ?? (isOutlined ? 0 : 2),
      padding: padding ?? defaultPadding,
      backgroundColor: bgColor,
      foregroundColor: txtColor,
      disabledBackgroundColor: theme.disabledColor,
      disabledForegroundColor: theme.colorScheme.onSurface.withOpacity(0.38),
      textStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? defaultRadius),
        side: isOutlined ? BorderSide(color: txtColor) : BorderSide.none,
      ),
      minimumSize: Size(isFullWidth ? double.infinity : 0, height ?? defaultHeight),
    );

    // Build the button content with icon and/or loading state
    Widget buttonContent;
    if (isLoading) {
      buttonContent = SizedBox(
        height: 20.h,
        width: 20.w,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(txtColor),
        ),
      );
    } else if (icon != null) {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20.r),
          SizedBox(width: 8.w),
          Text(label),
        ],
      );
    } else {
      buttonContent = Text(label);
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: buttonContent,
    );
  }
}