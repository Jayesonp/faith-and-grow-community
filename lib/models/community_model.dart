import 'dart:convert' show json, jsonDecode, jsonEncode;

class Community {
  final String id;
  final String creatorId;
  final String name;
  final String shortDescription;
  final String fullDescription;
  final String? coverImageUrl;
  final String? iconImageUrl;
  final String category;
  final List<CommunityTier> tiers;
  final DateTime createdAt;
  final int memberCount;
  final bool isPublished;

  Community({
    required this.id,
    required this.creatorId,
    required this.name,
    required this.shortDescription,
    required this.fullDescription,
    this.coverImageUrl,
    this.iconImageUrl,
    required this.category,
    required this.tiers,
    required this.createdAt,
    this.memberCount = 0,
    this.isPublished = false,
  });

  // Get the lowest priced tier
  CommunityTier get lowestTier {
    if (tiers.isEmpty) {
      throw Exception('Community has no tiers');
    }
    
    CommunityTier lowest = tiers.first;
    for (var tier in tiers) {
      if (tier.monthlyPrice < lowest.monthlyPrice) {
        lowest = tier;
      }
    }
    
    return lowest;
  }

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'],
      creatorId: json['creatorId'],
      name: json['name'],
      shortDescription: json['shortDescription'],
      fullDescription: json['fullDescription'],
      coverImageUrl: json['coverImageUrl'],
      iconImageUrl: json['iconImageUrl'],
      category: json['category'],
      tiers: (json['tiers'] as List<dynamic>)
          .map((tier) => CommunityTier.fromJson(tier))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      memberCount: json['memberCount'] ?? 0,
      isPublished: json['isPublished'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'name': name,
      'shortDescription': shortDescription,
      'fullDescription': fullDescription,
      'coverImageUrl': coverImageUrl,
      'iconImageUrl': iconImageUrl,
      'category': category,
      'tiers': tiers.map((tier) => tier.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'memberCount': memberCount,
      'isPublished': isPublished,
    };
  }

  Community copyWith({
    String? id,
    String? creatorId,
    String? name,
    String? shortDescription,
    String? fullDescription,
    String? coverImageUrl,
    String? iconImageUrl,
    String? category,
    List<CommunityTier>? tiers,
    DateTime? createdAt,
    int? memberCount,
    bool? isPublished,
  }) {
    return Community(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      name: name ?? this.name,
      shortDescription: shortDescription ?? this.shortDescription,
      fullDescription: fullDescription ?? this.fullDescription,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      iconImageUrl: iconImageUrl ?? this.iconImageUrl,
      category: category ?? this.category,
      tiers: tiers ?? this.tiers,
      createdAt: createdAt ?? this.createdAt,
      memberCount: memberCount ?? this.memberCount,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}

class CommunityTier {
  final String id;
  final String name;
  final double monthlyPrice;
  final List<String> features;

  CommunityTier({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    required this.features,
  });

  factory CommunityTier.fromJson(Map<String, dynamic> json) {
    return CommunityTier(
      id: json['id'],
      name: json['name'],
      monthlyPrice: (json['monthlyPrice'] is int) ? (json['monthlyPrice'] as int).toDouble() : json['monthlyPrice'],
      features: List<String>.from(json['features']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'monthlyPrice': monthlyPrice,
      'features': features,
    };
  }

  String get formattedPrice {
    return '\$${monthlyPrice.toStringAsFixed(2)}/month';
  }
}

class CommunityMembership {
  final String id;
  final String userId;
  final String communityId;
  final String tierId;
  final DateTime joinedAt;
  final DateTime? expiresAt;
  final bool isActive;

  CommunityMembership({
    required this.id,
    required this.userId,
    required this.communityId,
    required this.tierId,
    required this.joinedAt,
    this.expiresAt,
    this.isActive = true,
  });
  
  CommunityMembership copyWith({
    String? id,
    String? userId,
    String? communityId,
    String? tierId,
    DateTime? joinedAt,
    DateTime? expiresAt,
    bool? isActive,
  }) {
    return CommunityMembership(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      communityId: communityId ?? this.communityId,
      tierId: tierId ?? this.tierId,
      joinedAt: joinedAt ?? this.joinedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
    );
  }

  factory CommunityMembership.fromJson(dynamic jsonData) {
    // Handle case where jsonData might be a string instead of a map
    Map<String, dynamic> json;
    if (jsonData is String) {
      try {
        json = Map<String, dynamic>.from(jsonDecode(jsonData));
      } catch (e) {
        throw Exception('Invalid membership JSON format: $e');
      }
    } else if (jsonData is Map<String, dynamic>) {
      json = jsonData;
    } else {
      throw Exception('Invalid membership data type: ${jsonData.runtimeType}');
    }
    
    try {
      return CommunityMembership(
        id: json['id'],
        userId: json['userId'],
        communityId: json['communityId'],
        tierId: json['tierId'],
        joinedAt: DateTime.parse(json['joinedAt']),
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'])
            : null,
        isActive: json['isActive'] ?? true,
      );
    } catch (e) {
      print('Error parsing membership with data: $json');
      print('Error details: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'communityId': communityId,
      'tierId': tierId,
      'joinedAt': joinedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
    };
  }
}