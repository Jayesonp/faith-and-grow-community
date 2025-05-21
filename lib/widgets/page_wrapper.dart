import 'package:flutter/material.dart';

/// This class is no longer used - we're using GlobalFABService instead
/// to show the marketing button as an overlay.
class PageWrapper extends StatelessWidget {
  final Widget child;

  const PageWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}