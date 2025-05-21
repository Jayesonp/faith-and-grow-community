import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dreamflow/models/community_model.dart';
import 'package:dreamflow/services/community_service.dart';
import 'package:dreamflow/widgets/error_notification.dart';
import 'package:dreamflow/utils/error_messages.dart';
import 'package:dreamflow/theme.dart';
import 'package:dreamflow/screens/community_dashboard_screen.dart';
import 'package:uuid/uuid.dart';

class CommunityReviewLaunchScreen extends StatefulWidget {
  final String userId;
  final Community community;

  const CommunityReviewLaunchScreen({
    Key? key,
    required this.userId,
    required this.community,
  }) : super(key: key);

  @override
  State<CommunityReviewLaunchScreen> createState() => _CommunityReviewLaunchScreenState();
}

class _CommunityReviewLaunchScreenState extends State<CommunityReviewLaunchScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPublishing = false;
  String? _errorMessage;
  bool _isErrorVisible = false;
  bool _isCommunityFound = true;
  bool _isDisposed = false;
  int _publishAttempts = 0;
  static const int maxPublishAttempts = 3;
  Timer? _publishTimeoutTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
    _verifyCommunityExists();
  }

  Future<void> _verifyCommunityExists() async {
    try {
      final community = await CommunityService.getCommunityById(widget.community.id);
      if (mounted) {
        setState(() {
          _isCommunityFound = community != null;
          _isErrorVisible = community == null;
          if (community == null) {
            _errorMessage = 'We couldn\'t find this community. It may have been deleted or there might be a temporary issue.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCommunityFound = false;
          _errorMessage = 'There was an issue loading this community\'s details. Please try again.';
          _isErrorVisible = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _publishTimeoutTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<CommunityMembership> _createCreatorMembership(Community community) async {
    try {
      final premiumTier = community.tiers.isNotEmpty
          ? community.tiers.reduce((curr, next) => curr.monthlyPrice > next.monthlyPrice ? curr : next)
          : null;

      final membership = await CommunityService.joinCommunity(
        userId: widget.userId,
        communityId: community.id,
        tierId: premiumTier?.id ?? '',
      );

      if (membership != null) {
        return membership;
      }
    } catch (e) {
      print('Error creating creator membership: $e');
    }

    // Fallback membership if join fails
    return CommunityMembership(
      id: const Uuid().v4(),
      userId: widget.userId,
      communityId: community.id,
      tierId: community.tiers.isNotEmpty ? community.tiers.last.id : '',
      joinedAt: DateTime.now(),
    );
  }

  Future<void> _launchCommunity() async {
    if (_isDisposed || _isPublishing || _publishAttempts >= maxPublishAttempts) return;

    _publishTimeoutTimer?.cancel();
    _publishTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!_isDisposed && mounted && !_hasNavigated) {
        setState(() {
          _isPublishing = false;
          _errorMessage = 'Publishing timed out. Please try again.';
          _isErrorVisible = true;
        });
      }
    });

    setState(() {
      _publishAttempts++;
      _isPublishing = true;
      _errorMessage = null;
      _isErrorVisible = false;
    });

    try {
      final communityCheck = await CommunityService.getCommunityById(widget.community.id);
      if (communityCheck == null) {
        throw Exception('Community not found before publishing attempt');
      }

      Community? publishedCommunity;
      for (var attempt = 1; attempt <= maxPublishAttempts; attempt++) {
        try {
          publishedCommunity = await CommunityService.publishCommunity(widget.community.id);
          if (publishedCommunity != null) break;
          if (attempt < maxPublishAttempts) {
            await Future.delayed(Duration(seconds: attempt));
          }
        } catch (e) {
          print('Publishing attempt $attempt failed: $e');
          if (attempt == maxPublishAttempts) rethrow;
          await Future.delayed(Duration(seconds: attempt));
        }
      }

      if (publishedCommunity == null) {
        throw Exception('Failed to publish community after $maxPublishAttempts attempts');
      }

      if (_isDisposed) return;

      final creatorMembership = await _createCreatorMembership(publishedCommunity);

      if (!_isDisposed && mounted && !_hasNavigated) {
        setState(() => _hasNavigated = true);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => CommunityDashboardScreen(
              community: publishedCommunity!,
              userId: widget.userId,
              membership: creatorMembership,
            ),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (_isDisposed) return;

      String userFriendlyMessage = ErrorMessages.getPublishingErrorMessage(e.toString());

      if (mounted) {
        setState(() {
          _isPublishing = false;
          _errorMessage = userFriendlyMessage;
          _isErrorVisible = true;
        });
      }
    } finally {
      _publishTimeoutTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Launch'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_isErrorVisible)
                    Container(
                      padding: EdgeInsets.all(16.r),
                      margin: EdgeInsets.only(bottom: 16.r),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24.r,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Your community settings look good! Ready to launch when you are.',
                              style: AppTypography.bodyText(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_isErrorVisible && _errorMessage != null)
                    ErrorNotification.banner(
                      message: _errorMessage!,
                      context: context,
                      type: NotificationType.error,
                      onDismiss: () {
                        setState(() {
                          _isErrorVisible = false;
                          _errorMessage = null;
                        });
                      },
                    ),
                  SizedBox(height: 24.h),
                  if (_isCommunityFound) ...[
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.community.name,
                            style: AppTypography.titleLarge(context),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            widget.community.shortDescription,
                            style: AppTypography.bodyText(context),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            widget.community.fullDescription,
                            style: AppTypography.bodyText(context).copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _isPublishing ? null : () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            foregroundColor: Theme.of(context).colorScheme.primary,
                          ),
                          child: Text(
                            'Go Back',
                            style: AppTypography.buttonText(context).copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isPublishing ? null : _launchCommunity,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: _isPublishing
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20.r,
                                      height: 20.r,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.r,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Publishing...',
                                      style: AppTypography.buttonText(context).copyWith(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.rocket_launch, size: 20.r),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Launch Community',
                                      style: AppTypography.buttonText(context).copyWith(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}