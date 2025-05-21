// This is an improved version of the community_review_launch_screen.dart file focusing on better error handling

import 'dart:async';
import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:confetti/confetti.dart';
import 'package:dreamflow/models/community_model.dart';
import 'package:dreamflow/services/community_service.dart';
import 'package:dreamflow/widgets/error_notification.dart';
import 'package:dreamflow/utils/error_messages.dart';
import 'package:dreamflow/theme.dart';
import 'package:dreamflow/screens/community_dashboard_screen.dart';
import 'package:uuid/uuid.dart';

class CommunityReviewLaunchScreenImproved extends StatefulWidget {
  final String userId;
  final Community community;

  const CommunityReviewLaunchScreenImproved({
    Key? key,
    required this.userId,
    required this.community,
  }) : super(key: key);

  @override
  State<CommunityReviewLaunchScreenImproved> createState() => _CommunityReviewLaunchScreenImprovedState();
}

class _CommunityReviewLaunchScreenImprovedState extends State<CommunityReviewLaunchScreenImproved> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ConfettiController _confettiController;
  bool _isPublishing = false;
  bool _showConfetti = false;
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
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _verifyCommunityExists();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _publishTimeoutTimer?.cancel();
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _verifyCommunityExists() async {
    try {
      final community = await CommunityService.getCommunityById(widget.community.id);
      if (mounted) {
        setState(() {
          _isCommunityFound = community != null;
        });
      }
      
      if (community == null) {
        setState(() {
          _errorMessage = 'We couldn\'t find this community. It may have been deleted or there might be a temporary issue.';
          _isErrorVisible = true;
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

  Future<Community> _publishCommunityWithRetry() async {
    for (var attempt = 1; attempt <= maxPublishAttempts; attempt++) {
      try {
        final publishedCommunity = await CommunityService.publishCommunity(widget.community.id);
        if (publishedCommunity != null) {
          return publishedCommunity;
        }
        if (attempt < maxPublishAttempts) {
          await Future.delayed(Duration(seconds: attempt));
        }
      } catch (e) {
        print('Publishing attempt $attempt failed: $e');
        if (attempt == maxPublishAttempts) rethrow;
        await Future.delayed(Duration(seconds: attempt));
      }
    }
    throw Exception('Failed to publish community after $maxPublishAttempts attempts');
  }

  Future<CommunityMembership> _createCreatorMembershipWithRetry(Community publishedCommunity) async {
    for (var attempt = 1; attempt <= maxPublishAttempts; attempt++) {
      try {
        final premiumTier = publishedCommunity.tiers.isNotEmpty 
          ? publishedCommunity.tiers.reduce(
              (curr, next) => curr.monthlyPrice > next.monthlyPrice ? curr : next
            )
          : null;

        final membership = await CommunityService.joinCommunity(
          userId: widget.userId,
          communityId: publishedCommunity.id,
          tierId: premiumTier?.id ?? '',
        );

        if (membership != null) {
          return membership;
        }

        if (attempt < maxPublishAttempts) {
          await Future.delayed(Duration(seconds: attempt));
        }
      } catch (e) {
        print('Creator membership attempt $attempt failed: $e');
        if (attempt == maxPublishAttempts) break;
        await Future.delayed(Duration(seconds: attempt));
      }
    }
    
    return CommunityMembership(
      id: const Uuid().v4(),
      userId: widget.userId,
      communityId: publishedCommunity.id,
      tierId: publishedCommunity.tiers.isNotEmpty ? publishedCommunity.tiers.last.id : '',
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

      final publishedCommunity = await _publishCommunityWithRetry();
      
      print('Community published successfully with ID: ${publishedCommunity.id}');
      
      final creatorMembership = await _createCreatorMembershipWithRetry(publishedCommunity);
      
      if (_isDisposed) return;

      if (mounted) {
        _showSuccessAnimation();

        Future.delayed(const Duration(seconds: 2), () {
          if (!_isDisposed && mounted && !_hasNavigated) {
            setState(() => _hasNavigated = true);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => CommunityDashboardScreen(
                  community: publishedCommunity,
                  userId: widget.userId,
                  membership: creatorMembership,
                ),
              ),
              (route) => false,
            );
          }
        });
      }
    } catch (e) {
      if (_isDisposed) return;

      String userFriendlyMessage = ErrorMessages.getPublishingErrorMessage(e.toString());
      
      if (mounted) {
        setState(() {
          _isPublishing = false;
          _errorMessage = userFriendlyMessage;
          _isErrorVisible = true;
          _showConfetti = false;
        });
      }
    } finally {
      _publishTimeoutTimer?.cancel();
    }
  }

  void _showSuccessAnimation() {
    setState(() => _showConfetti = true);
    _confettiController.play();
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: _isPublishing ? null : () {
            Navigator.of(context).pop();
          },
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            elevation: 2,
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
                        fontWeight: FontWeight.w600,
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Review & Launch'),
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          body: _isCommunityFound
              ? FadeTransition(
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
                                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
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
                                      'Once you launch your community, you can start customizing it and grow your audience.',
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
                          _buildActionButtons(context),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.r,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Community Not Found',
                        style: AppTypography.sectionTitle(context).copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.w),
                        child: Text(
                          'We couldn\'t find this community. It may have been deleted or there might be a temporary issue.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyText(context),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Go Back',
                          style: AppTypography.buttonText(context).copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        if (_showConfetti)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // straight up
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              shouldLoop: false,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.tertiary,
                Colors.pink,
                Colors.yellow,
                Colors.lightBlue,
              ],
            ),
          ),
      ],
    );
  }
}