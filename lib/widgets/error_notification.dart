import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dreamflow/theme.dart';
import 'dart:async';

/// Types of notifications that can be displayed
enum NotificationType {
  error,
  warning,
  success,
  info
}

/// ErrorNotification provides various non-intrusive ways to display error messages.
/// Includes toast notifications, banners, and inline messages.
class ErrorNotification {
  /// Creates a toast notification that appears at the bottom of the screen
  /// and automatically dismisses after a few seconds
  static void showToast({
    required BuildContext context,
    required String message,
    NotificationType type = NotificationType.error,
    Duration duration = const Duration(seconds: 5),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final FToast fToast = FToast();
    fToast.init(context);
    
    final Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: _getSnackbarColor(type),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getIcon(context, type, size: 20.0),
          const SizedBox(width: 14.0),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onAction != null && actionLabel != null) ...[      
            const SizedBox(width: 12.0),
            TextButton(
              onPressed: () {
                fToast.removeCustomToast();
                onAction();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: duration,
    );
  }

  /// Creates a dismissible banner that appears at the top of the content area
  static Widget banner({
    required String message,
    required BuildContext context,
    NotificationType type = NotificationType.error,
    VoidCallback? onDismiss,
    VoidCallback? onAction,
    String? actionLabel,
    String? supportingText,
  }) {
    return DismissibleBanner(
      message: message,
      type: type,
      onAction: onAction,
      actionLabel: actionLabel,
      supportingText: supportingText,
    );
  }

  /// Creates an inline message that appears near the action that triggered it
  static Widget inline({
    required String message,
    required BuildContext context,
    NotificationType type = NotificationType.error,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context, type).withOpacity(0.08),
        border: Border.all(
          color: _getBorderColor(context, type),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _getIcon(context, type),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: _getTextColor(context, type),
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0,
                  ),
                ),
                if (onAction != null && actionLabel != null) ...[      
                  const SizedBox(height: 10.0),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: _getActionColor(context, type),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      minimumSize: const Size(0, 36),
                      backgroundColor: _getBackgroundColor(context, type).withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                    child: Text(
                      actionLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a snackbar with an error message
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar({
    required BuildContext context,
    required String message,
    NotificationType type = NotificationType.error,
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            _getIcon(context, type, size: 20.0),
            const SizedBox(width: 14.0),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: _getSnackbarColor(type),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        action: onAction != null && actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  // Helper methods to get colors and icons based on notification type
  
  static Color _getBackgroundColor(BuildContext context, NotificationType type) {
    switch (type) {
      case NotificationType.error:
        return Theme.of(context).colorScheme.error;
      case NotificationType.warning:
        return const Color(0xFFFFA726); // Orange A400
      case NotificationType.success:
        return const Color(0xFF66BB6A); // Green 400
      case NotificationType.info:
        return Theme.of(context).colorScheme.primary;
    }
  }

  static Color _getTextColor(BuildContext context, NotificationType type) {
    switch (type) {
      case NotificationType.error:
        return Theme.of(context).colorScheme.error;
      case NotificationType.warning:
        return const Color(0xFFFFA726); // Orange A400
      case NotificationType.success:
        return const Color(0xFF66BB6A); // Green 400
      case NotificationType.info:
        return Theme.of(context).colorScheme.primary;
    }
  }

  static Color _getActionColor(BuildContext context, NotificationType type) {
    switch (type) {
      case NotificationType.error:
        return Theme.of(context).colorScheme.error;
      case NotificationType.warning:
        return const Color(0xFFFFA726); // Orange A400
      case NotificationType.success:
        return const Color(0xFF66BB6A); // Green 400
      case NotificationType.info:
        return Theme.of(context).colorScheme.primary;
    }
  }

  static Color _getBorderColor(BuildContext context, NotificationType type) {
    switch (type) {
      case NotificationType.error:
        return Theme.of(context).colorScheme.error;
      case NotificationType.warning:
        return const Color(0xFFFFA726); // Orange A400
      case NotificationType.success:
        return const Color(0xFF66BB6A); // Green 400
      case NotificationType.info:
        return Theme.of(context).colorScheme.primary;
    }
  }

  static Color _getSnackbarColor(NotificationType type) {
    switch (type) {
      case NotificationType.error:
        return const Color(0xFFE53935); // Red 600
      case NotificationType.warning:
        return const Color(0xFFFB8C00); // Orange 800
      case NotificationType.success:
        return const Color(0xFF43A047); // Green 700
      case NotificationType.info:
        return const Color(0xFF1E88E5); // Blue 600
    }
  }

  static Widget _getIcon(BuildContext context, NotificationType type, {double size = 24.0}) {
    return Icon(
      type == NotificationType.error ? Icons.error_outline :
      type == NotificationType.warning ? Icons.warning_amber_rounded :
      type == NotificationType.success ? Icons.check_circle_outline :
      Icons.info_outline,
      color: type == NotificationType.error ? Colors.white : // Override for error to ensure visibility
             type == NotificationType.warning ? Colors.white : // Override for warning
             type == NotificationType.success ? Colors.white : // Override for success
             Colors.white, // Override for info
      size: size,
    );
  }
}

/// A stateful widget that displays a dismissible banner
class DismissibleBanner extends StatefulWidget {
  final String message;
  final NotificationType type;
  final VoidCallback? onAction;
  final String? actionLabel;
  final String? supportingText;
  final Duration autoDismissAfter;

  const DismissibleBanner({
    Key? key,
    required this.message,
    this.type = NotificationType.error,
    this.onAction,
    this.actionLabel,
    this.supportingText,
    this.autoDismissAfter = const Duration(seconds: 0), // 0 means don't auto-dismiss
  }) : super(key: key);

  @override
  State<DismissibleBanner> createState() => _DismissibleBannerState();
}

class _DismissibleBannerState extends State<DismissibleBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _position;
  Timer? _autoDismissTimer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut)
    );
    
    _position = Tween<Offset>(begin: const Offset(0.0, -0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut)
    );
    
    _controller.forward();
    
    if (widget.autoDismissAfter.inSeconds > 0) {
      _autoDismissTimer = Timer(widget.autoDismissAfter, _dismiss);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    if (!mounted) return;
    setState(() => _dismissed = true);
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    
    // Get the correct background color based on notification type
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    
    switch (widget.type) {
      case NotificationType.error:
        backgroundColor = const Color(0xFFFFF3F2); // Light red
        textColor = const Color(0xFFD32F2F); // Darker red for text
        borderColor = const Color(0xFFEF5350); // Red for border
        break;
      case NotificationType.warning:
        backgroundColor = const Color(0xFFFFF8E1); // Light amber
        textColor = const Color(0xFFF57C00); // Darker amber for text
        borderColor = const Color(0xFFFFB74D); // Amber for border
        break;
      case NotificationType.success:
        backgroundColor = const Color(0xFFE8F5E9); // Light green
        textColor = const Color(0xFF2E7D32); // Darker green for text
        borderColor = const Color(0xFF66BB6A); // Green for border
        break;
      case NotificationType.info:
        backgroundColor = const Color(0xFFE3F2FD); // Light blue
        textColor = const Color(0xFF1976D2); // Darker blue for text
        borderColor = const Color(0xFF42A5F5); // Blue for border
        break;
    }
    
    return SlideTransition(
      position: _position,
      child: FadeTransition(
        opacity: _opacity,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(0), // Remove margins for a cleaner appearance
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              left: BorderSide(color: borderColor, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    widget.type == NotificationType.error ? Icons.error_outline :
                    widget.type == NotificationType.warning ? Icons.warning_amber_rounded :
                    widget.type == NotificationType.success ? Icons.check_circle_outline :
                    Icons.info_outline,
                    color: textColor,
                    size: 22.0,
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.message,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                            color: textColor,
                          ),
                        ),
                        if (widget.supportingText != null) ...[      
                          const SizedBox(height: 4.0),
                          Text(
                            widget.supportingText!,
                            style: TextStyle(
                              fontSize: 13.0,
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.onAction != null && widget.actionLabel != null) ...[      
                    TextButton(
                      onPressed: widget.onAction,
                      style: TextButton.styleFrom(
                        foregroundColor: textColor,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      child: Text(
                        widget.actionLabel!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.0,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: textColor.withOpacity(0.8)),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    onPressed: _dismiss,
                    tooltip: 'Dismiss',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}