import 'package:flutter/material.dart';
import 'package:dreamflow/models/community_model.dart';
import 'package:dreamflow/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:dreamflow/widgets/responsive_layout.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class CommunityCard extends StatelessWidget {
  final Community community;
  final Function()? onTap;

  const CommunityCard({
    Key? key,
    required this.community,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Community cover image
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                image: DecorationImage(
                  image: NetworkImage(
                    community.coverImageUrl ?? 
                      "https://pixabay.com/get/gce601ed3c1bb0994283dbf71cc42a5239b9b5fb9f1a88aaf93f8d82167561037ff6d1de5ffc01eef95f219bea2910d5c9150992089e3d1f87ead1bee0dea4ecd_1280.jpg",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Community info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Community icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        width: 2,
                      ),
                      image: community.iconImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(community.iconImageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: community.iconImageUrl == null
                        ? Center(
                            child: Text(
                              community.name[0].toUpperCase(),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  
                  // Community text info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          community.name,
                          style: theme.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.2, // Ensure consistent line height
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          community.shortDescription,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.2, // Ensure consistent line height
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Category chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                community.category,
                                style: theme.textTheme.labelSmall!.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Member count
                            Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 14,
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${community.memberCount} members',
                                  style: theme.textTheme.labelSmall!.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Pricing badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: community.lowestTier.monthlyPrice > 0
                              ? theme.colorScheme.secondary.withOpacity(0.1)
                              : theme.colorScheme.tertiary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          community.lowestTier.monthlyPrice > 0
                              ? 'From \$${community.lowestTier.monthlyPrice.toStringAsFixed(2)}'
                              : 'Free Tier',
                          style: theme.textTheme.labelSmall!.copyWith(
                            color: community.lowestTier.monthlyPrice > 0
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.tertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TierSelectionCard extends StatelessWidget {
  final CommunityTier tier;
  final bool isSelected;
  final VoidCallback onSelect;

  const TierSelectionCard({
    Key? key,
    required this.tier,
    required this.isSelected,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Pick icon and color based on price tier
    IconData tierIcon;
    Color tierColor;
    Color bgColor;
    
    if (tier.monthlyPrice == 0) {
      tierIcon = Icons.star_outline;
      tierColor = theme.colorScheme.tertiary;
      bgColor = isSelected
          ? theme.colorScheme.tertiary.withOpacity(0.15)
          : theme.colorScheme.surface;
    } else if (tier.monthlyPrice >= 0 && tier.monthlyPrice <= 20) {
      tierIcon = Icons.star_half;
      tierColor = theme.colorScheme.secondary;
      bgColor = isSelected
          ? theme.colorScheme.secondary.withOpacity(0.15)
          : theme.colorScheme.surface;
    } else {
      tierIcon = Icons.star;
      tierColor = theme.colorScheme.primary;
      bgColor = isSelected
          ? theme.colorScheme.primary.withOpacity(0.15)
          : theme.colorScheme.surface;
    }
    
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? tierColor.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 10 : 5,
              spreadRadius: isSelected ? 1 : 0,
              offset: isSelected ? const Offset(0, 2) : const Offset(0, 1),
            ),
          ],
          border: Border.all(
            color: isSelected
                ? tierColor
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selection indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? tierColor : theme.colorScheme.surface,
                border: Border.all(
                  color: isSelected
                      ? tierColor
                      : theme.colorScheme.outline.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            
            // Tier content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Tier icon and name
                      Icon(tierIcon, color: tierColor),
                      const SizedBox(width: 4),
                      Text(
                        tier.name,
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2, // Ensure consistent line height
                          color: tierColor,
                        ),
                      ),
                      const Spacer(),
                      // Price
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: tierColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          tier.monthlyPrice > 0
                              ? '\$${tier.monthlyPrice.toStringAsFixed(2)}/mo'
                              : 'Free',
                          style: theme.textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: tierColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Features list
                  ...tier.features.map((feature) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: tierColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityMembershipBadge extends StatelessWidget {
  final String tierName;
  final double size;

  const CommunityMembershipBadge({
    Key? key,
    required this.tierName,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine badge color based on tier name
    Color badgeColor;
    IconData badgeIcon;
    
    switch (tierName.toLowerCase()) {
      case 'basic':
      case 'free':
        badgeColor = theme.colorScheme.tertiary;
        badgeIcon = Icons.star_outline;
        break;
      case 'pro':
      case 'plus':
      case 'standard':
        badgeColor = theme.colorScheme.secondary;
        badgeIcon = Icons.star_half;
        break;
      case 'premium':
      case 'vip':
      case 'ultimate':
        badgeColor = theme.colorScheme.primary;
        badgeIcon = Icons.star;
        break;
      default:
        badgeColor = theme.colorScheme.primary;
        badgeIcon = Icons.verified;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            size: size * 0.6,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            tierName,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.5,
            ),
          ),
        ],
      ),
    );
  }
}