import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    // Create a custom toast
    final FToast fToast = FToast();
    fToast.init(context);
    
    // Create the widget
    final Widget toast = Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: _getBackgroundColor(context, type),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8.0,
            offset: Offset(0, 4.0),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getIcon(context, type),
          SizedBox(width: 12.0),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: _getTextColor(context, type),
                fontSize: 14.0,
              ),
            ),
          ),
          if (onAction != null && actionLabel != null) ...[  
            SizedBox(width: 8.0),
            TextButton(
              onPressed: () {
                fToast.removeCustomToast();
                onAction();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: _getActionColor(context, type),
              ),
              child: Text(
                actionLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
            ),
          ],
          SizedBox(width: 8.0),
          InkWell(
            onTap: () {
              fToast.removeCustomToast();
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.close,
                size: 16.0,
                color: _getTextColor(context, type).withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
    
    // Show the toast
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
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context, type).withOpacity(0.1),
        border: Border.all(
          color: _getBorderColor(context, type),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getIcon(context, type, size: 16.0),
              SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: _getTextColor(context, type),
                    fontSize: 14.0,
                  ),
                ),
              ),
            ],
          ),
          if (onAction != null && actionLabel != null) ...[  
            SizedBox(height: 8.0),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  foregroundColor: _getActionColor(context, type),
                ),
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ],
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
    // Make sure we have a Scaffold to show the snackbar on
    final scaffold = ScaffoldMessenger.of(context);
    
    // Create and show the snackbar
    final snackBar = SnackBar(
      content: Row(
        children: [
          _getIcon(context, type, size: 20.0),
          SizedBox(width: 12.0),
          Expanded(
            child: Text(message),
          ),
        ],
      ),
      backgroundColor: _getSnackbarColor(type),
      duration: duration,
      action: onAction != null && actionLabel != null 
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onAction,
            )
          : null,
    );
    
    return scaffold.showSnackBar(snackBar);
  }

  // Helper methods to get colors and icons based on notification type
  
  static Color _getBackgroundColor(BuildContext context, NotificationType type) {
    switch (type) {
      case NotificationType.error:
        return Theme.of(context).colorScheme.error;
      case NotificationType.warning:
        return Colors.amber[700]!;
      case NotificationType.success:
        return Colors.green[600]!;
      case NotificationType.info:
        return Theme.of(context).colorScheme.primary;
    }
  }

  static Color _getTextColor(BuildContext context, NotificationType type) {
    switch (type) {
      case NotificationType.error:
      case NotificationType.warning:
      case NotificationType.success:
      case NotificationType.info:
        return Colors.white;
    }
  }

  static Color _getActionColor(BuildContext context, NotificationType type) {
    switch (type) {
      case NotificationType.error:
      case NotificationType.warning:
      case NotificationType.success:
      case NotificationType.info:
        return Colors.white;
    }
  }

  static Color _getBorderColor(BuildContext context, NotificationType type) {
    switch (type) {
      case NotificationType.error:
        return Theme.of(context).colorScheme.error;
      case NotificationType.warning:
        return Colors.amber[700]!;
      case NotificationType.success:
        return Colors.green[600]!;
      case NotificationType.info:
        return Theme.of(context).colorScheme.primary;
    }
  }

  static Color _getSnackbarColor(NotificationType type) {
    switch (type) {
      case NotificationType.error:
        return Colors.red[700]!;
      case NotificationType.warning:
        return Colors.amber[700]!;
      case NotificationType.success:
        return Colors.green[600]!;
      case NotificationType.info:
        return Colors.blue[600]!;
    }
  }

  static Widget _getIcon(BuildContext context, NotificationType type, {double size = 24.0}) {
    IconData iconData;
    switch (type) {
      case NotificationType.error: iconData = Icons.error_outline; break;
      case NotificationType.warning: iconData = Icons.warning_amber_rounded; break;
      case NotificationType.success: iconData = Icons.check_circle_outline; break;
      case NotificationType.info: iconData = Icons.info_outline; break;
    }
    return Icon(iconData, color: _getTextColor(context, type), size: size);
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
    
    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _position = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
    
    // Set up auto-dismiss timer if needed
    if (widget.autoDismissAfter.inMilliseconds > 0) {
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
    if (!_dismissed) {
      setState(() => _dismissed = true);
      _controller.reverse().then((_) {
        // Additional cleanup could happen here
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) {
      return SizedBox.shrink();
    }
    
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _position,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: ErrorNotification._getBackgroundColor(context, widget.type).withOpacity(0.1),
            border: Border.all(
              color: ErrorNotification._getBorderColor(context, widget.type),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with message and dismiss button
                Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 12.0, right: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ErrorNotification._getIcon(context, widget.type),
                      SizedBox(width: 12.0),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Text(
                            widget.message,
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                              color: ErrorNotification._getBorderColor(context, widget.type),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 20.0,
                          color: ErrorNotification._getBorderColor(context, widget.type).withOpacity(0.7),
                        ),
                        constraints: BoxConstraints(minWidth: 40.0, minHeight: 40.0),
                        padding: EdgeInsets.zero,
                        onPressed: _dismiss,
                        tooltip: 'Dismiss',
                      ),
                    ],
                  ),
                ),
                
                // Supporting text if provided
                if (widget.supportingText != null)
                  Padding(
                    padding: EdgeInsets.only(left: 52.0, right: 16.0, bottom: 12.0),
                    child: Text(
                      widget.supportingText!,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                
                // Action button if provided
                if (widget.onAction != null && widget.actionLabel != null)
                  Padding(
                    padding: EdgeInsets.only(left: 52.0, right: 16.0, bottom: 12.0),
                    child: TextButton(
                      onPressed: () {
                        _dismiss();
                        widget.onAction!();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: ErrorNotification._getBorderColor(context, widget.type),
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(widget.actionLabel!),
                    ),
                  )
                else
                  SizedBox(height: 12.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}