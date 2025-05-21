import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:dreamflow/screens/pricing_screen.dart';

class PricingFAB extends StatefulWidget {
  const PricingFAB({Key? key}) : super(key: key);

  @override
  State<PricingFAB> createState() => _PricingFABState();
}

class _PricingFABState extends State<PricingFAB> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    // Start the animation with a slight delay for better UX
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _animationController.forward();
      }
    });
    
    // Add periodic animation to draw attention
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _startPulseAnimation();
      }
    });
  }
  
  void _startPulseAnimation() {
    _animationController.reverse().then((_) {
      if (mounted) {
        _animationController.forward().then((_) {
          if (mounted) {
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) {
                _startPulseAnimation();
              }
            });
          }
        });
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: OpenContainer(
              transitionDuration: const Duration(milliseconds: 500),
              openBuilder: (context, _) => const PricingScreen(),
              closedElevation: 6,
              closedShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              closedColor: Theme.of(context).colorScheme.secondary,
              closedBuilder: (context, openContainer) {
                return InkWell(
                  onTap: openContainer,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Subscription Plans',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}