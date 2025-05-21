import 'package:shared_preferences/shared_preferences.dart';
import 'package:dreamflow/models/community_model.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class DataInitializer {
  static const String _initializedKey = 'communities_initialized';
  static const String _communitiesKey = 'communities_data';
  
  // Check if communities have been initialized
  static Future<bool> areCommunitiesInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_initializedKey) ?? false;
  }
  
  // Mark communities as initialized
  static Future<void> markCommunititesAsInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_initializedKey, true);
  }
  
  // Initialize predefined communities with improved performance
  static Future<void> initializePredefinedCommunities() async {
    // Check initialization status - use a more efficient approach
    final prefs = await SharedPreferences.getInstance();
    final alreadyInitialized = prefs.getBool(_initializedKey) ?? false;
    
    if (alreadyInitialized) {
      print('Communities already initialized - skipping');
      return;
    }
    
    print('Initializing predefined communities');
    // Get communities using a cached approach
    final communities = _getPredefinedCommunities();
    
    // Convert communities to JSON string and save
    final communitiesJson = jsonEncode(
      communities.map((community) => community.toJson()).toList(),
    );
    
    // Save in a single operation
    await Future.wait([
      prefs.setString(_communitiesKey, communitiesJson),
      prefs.setBool(_initializedKey, true)
    ]);
    
    print('Communities initialized successfully');
  }
  
  // Get the predefined communities from hardcoded data
  static List<Community> _getPredefinedCommunities() {
    final communitiesData = _getRawCommunityData();
    final List<Community> communities = [];
    
    for (final communityData in communitiesData) {
      try {
        final List<CommunityTier> tiers = [];
        
        for (final tierData in communityData['tiers']) {
          tiers.add(CommunityTier(
            id: tierData['id'],
            name: tierData['name'],
            monthlyPrice: tierData['monthlyPrice'].toDouble(),
            features: List<String>.from(tierData['features']),
          ));
        }
        
        communities.add(Community(
          id: communityData['id'],
          creatorId: communityData['creatorId'],
          name: communityData['name'],
          shortDescription: communityData['shortDescription'],
          fullDescription: communityData['fullDescription'],
          coverImageUrl: communityData['coverImageUrl'],
          iconImageUrl: communityData['iconImageUrl'],
          category: communityData['category'],
          tiers: tiers,
          createdAt: DateTime.parse(communityData['createdAt']),
          memberCount: communityData['memberCount'],
          isPublished: true, // Mark all predefined communities as published
        ));
      } catch (e) {
        print('Error parsing community data: $e');
      }
    }
    
    return communities;
  }
  
  // Raw JSON data for predefined communities
  static List<Map<String, dynamic>> _getRawCommunityData() {
    return [
      {
        "id": "91c4f661-5d43-4951-8ae3-5b8bf56a78e3",
        "creatorId": "user1",
        "name": "Faith Leaders Network",
        "shortDescription": "A community for church and ministry leaders to connect and grow together.",
        "fullDescription": "The Faith Leaders Network brings together pastors, ministers, and church administrators to share resources, discuss leadership challenges, and support each other in building thriving faith communities. Join us to access exclusive webinars, discussion forums, and practical ministry tools.",
        "coverImageUrl": "https://pixabay.com/get/gabaae441bc00c8d45b191bd9e0953b3e36a1bea4246eeea4636c4f514e4ab4bf085bd7388b2c22b9199d73eb490711d6a5d44406b817119ddef23a9348d3914084bf3feb1280.jpg",
        "iconImageUrl": "https://pixabay.com/get/gebae441bc00c8d45b191bd9e0953b3e36a1bea4246eeea4636c4f514e4ab4bf085bd7388b2c22b9199d73017571db15fbd166aacf5046c9c91b45e9755791039_1280.jpg",
        "category": "Ministry",
        "tiers": [
          {
            "id": "4e300117-ac79-4e31-8b53-9abe2f935d27",
            "name": "Essentials",
            "monthlyPrice": 0,
            "features": [
              "Access to community forums",
              "Weekly devotionals",
              "Monthly virtual prayer gatherings"
            ]
          },
          {
            "id": "25b51694-782b-4204-befc-55a16167b9c8",
            "name": "Leadership",
            "monthlyPrice": 19.99,
            "features": [
              "All Essentials features",
              "Ministry leadership resources",
              "Monthly leadership webinars",
              "Church growth case studies"
            ]
          },
          {
            "id": "80d1ce09-701d-4720-b11c-3ba50781951c",
            "name": "Executive",
            "monthlyPrice": 49.99,
            "features": [
              "All Leadership features",
              "One-on-one ministry consulting",
              "Exclusive mastermind group",
              "Annual leadership retreat access"
            ]
          }
        ],
        "createdAt": "2025-01-15T02:15:04.087",
        "memberCount": 143
      },
      {
        "id": "24094316-ceb6-4ae2-8e78-63af2d03913e",
        "creatorId": "user2",
        "name": "Christian Entrepreneurs Hub",
        "shortDescription": "Where faith meets business excellence.",
        "fullDescription": "The Christian Entrepreneurs Hub is dedicated to helping business owners integrate their faith with sound business principles. We provide biblical insights into entrepreneurship, peer mentoring, and practical strategies for building Kingdom-minded businesses that make an impact and generate profit.",
        "coverImageUrl": "https://pixabay.com/get/gc26b4ab023196a3226b94173e5ede6cb32b4c87fa45ac34447f67e8e29355f622c770304152b5ab69a3eebaf0c94fd280c3284a41681afc89cda0bd04066b84_1280.jpg",
        "iconImageUrl": "https://pixabay.com/get/g83dabe4f4aa14aecd7f733607fb002b2aaf367385ce6cdb95364508c11b0d243b426894bf6a9572348d2c85acfee041cb46d28890b59aaf196c1dd34dcdf560_1280.jpg",
        "category": "Business",
        "tiers": [
          {
            "id": "54d64284-1504-4fef-9c6a-61560c3add2d",
            "name": "Connect",
            "monthlyPrice": 0,
            "features": [
              "Community forums access",
              "Weekly business devotionals",
              "Business directory listing"
            ]
          },
          {
            "id": "226f8cf4-2f4a-4046-8f52-977b76bce6c4",
            "name": "Grow",
            "monthlyPrice": 29.99,
            "features": [
              "All Connect features",
              "Monthly business webinars",
              "Faith-based marketing templates",
              "Quarterly business planning workshops"
            ]
          },
          {
            "id": "8c64506b-800d-4227-ab16-ad229995cf41",
            "name": "Transform",
            "monthlyPrice": 79.99,
            "features": [
              "All Grow features",
              "One-on-one business coaching",
              "Mastermind group membership",
              "Annual business retreat",
              "Kingdom Business certification"
            ]
          }
        ],
        "createdAt": "2025-02-09T02:15:04.087",
        "memberCount": 217
      },
      {
        "id": "fcc6e69b-fa60-46ee-88c7-f788207924f8",
        "creatorId": "user3",
        "name": "Christian Creative Collective",
        "shortDescription": "A community for faith-driven artists, designers, musicians, writers, and creatives.",
        "fullDescription": "The Christian Creative Collective is a supportive community for artists, musicians, writers, designers, and other creatives who want to use their talents for God's glory. Share your work, get constructive feedback, collaborate on projects, and learn how to build a sustainable creative business while staying true to your faith.",
        "coverImageUrl": "https://pixabay.com/get/gaa38ae905bb6e82a9ae73f30d2e4e4d0561863bef89d86ce6242fdcd991db531b3d4f2f1d359aff14d54e9f8bf7b16c85b0d4835b3fb3a2cb705d1fbf0a6_1280.jpg",
        "iconImageUrl": "https://pixabay.com/get/gd607a7dae3af961b632c8dc5198dfd64f49fb5e1675008912314dcd19f8dd21a230371e2042599c17c2ada0541118b682656495e1c294862cbde98a9ec830853c3_1280.jpg",
        "category": "Arts & Media",
        "tiers": [
          {
            "id": "d3560959-3c5c-4df7-9266-67b857bde9aa",
            "name": "Creator",
            "monthlyPrice": 0,
            "features": [
              "Community forums access",
              "Creative showcase opportunities",
              "Weekly inspiration prompts"
            ]
          },
          {
            "id": "109d6503-0ada-48c6-a449-636c6d8b000c",
            "name": "Craftsman",
            "monthlyPrice": 14.99,
            "features": [
              "All Creator features",
              "Monthly creative workshops",
              "Feedback from professional artists",
              "Exclusive resource library"
            ]
          },
          {
            "id": "Occb7075-255b-40ff-a103-336bca684979",
            "name": "Maestro",
            "monthlyPrice": 39.99,
            "features": [
              "All Craftsman features",
              "Personal portfolio review",
              "Exhibition opportunities",
              "Christian galleries connection",
              "Quarterly creative retreats"
            ]
          }
        ],
        "createdAt": "2025-03-11T02:15:04.087",
        "memberCount": 90
      }
    ];
  }
}