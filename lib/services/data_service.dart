import 'package:dreamflow/models/content_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class DataService {
  static const String _postsKey = 'posts_data';
  static const String _coursesKey = 'courses_data';
  static const String _businessesKey = 'businesses_data';
  
  // Load posts from local storage or generate mock data if none exists
  static Future<List<Post>> getPosts({String? category}) async {
    final prefs = await SharedPreferences.getInstance();
    final postsData = prefs.getString(_postsKey);
    
    List<Post> posts = [];
    
    if (postsData != null) {
      final List<dynamic> decodedData = jsonDecode(postsData);
      posts = decodedData.map((item) => Post(
        id: item['id'],
        userId: item['userId'],
        userName: item['userName'],
        userImageUrl: item['userImageUrl'],
        content: item['content'],
        imageUrl: item['imageUrl'],
        createdAt: DateTime.parse(item['createdAt']),
        category: item['category'] ?? 'General',
        comments: (item['comments'] as List<dynamic>? ?? []).map((c) => Comment(
          id: c['id'],
          userId: c['userId'],
          userName: c['userName'],
          userImageUrl: c['userImageUrl'],
          content: c['content'],
          createdAt: DateTime.parse(c['createdAt']),
        )).toList(),
        likes: List<String>.from(item['likes'] ?? []),
      )).toList();
    } else {
      // Generate mock data if none exists
      posts = _generateMockPosts();
      await savePosts(posts);
    }
    
    // Filter by category if specified
    if (category != null && category.isNotEmpty && category != 'All') {
      posts = posts.where((post) => post.category == category).toList();
    }
    
    // Sort by most recent
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return posts;
  }
  
  // Save posts to local storage
  static Future<void> savePosts(List<Post> posts) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = jsonEncode(posts.map((post) => {
      'id': post.id,
      'userId': post.userId,
      'userName': post.userName,
      'userImageUrl': post.userImageUrl,
      'content': post.content,
      'imageUrl': post.imageUrl,
      'createdAt': post.createdAt.toIso8601String(),
      'category': post.category,
      'comments': post.comments.map((c) => {
        'id': c.id,
        'userId': c.userId,
        'userName': c.userName,
        'userImageUrl': c.userImageUrl,
        'content': c.content,
        'createdAt': c.createdAt.toIso8601String(),
      }).toList(),
      'likes': post.likes,
    }).toList());
    
    await prefs.setString(_postsKey, encodedData);
  }
  
  // Add a new post
  static Future<Post> addPost(String userId, String userName, String content, {String? imageUrl, String category = 'General', String? userImageUrl}) async {
    final posts = await getPosts();
    
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: userName,
      userImageUrl: userImageUrl,
      content: content,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      category: category,
    );
    
    posts.add(newPost);
    await savePosts(posts);
    
    return newPost;
  }
  
  // Toggle like on a post
  static Future<Post> toggleLike(String postId, String userId) async {
    final posts = await getPosts();
    final postIndex = posts.indexWhere((post) => post.id == postId);
    
    if (postIndex != -1) {
      final post = posts[postIndex];
      final likes = List<String>.from(post.likes);
      
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }
      
      final updatedPost = post.copyWith(likes: likes);
      posts[postIndex] = updatedPost;
      await savePosts(posts);
      
      return updatedPost;
    }
    
    throw Exception('Post not found');
  }
  
  // Add a comment to a post
  static Future<Post> addComment(String postId, String userId, String userName, String content, {String? userImageUrl}) async {
    final posts = await getPosts();
    final postIndex = posts.indexWhere((post) => post.id == postId);
    
    if (postIndex != -1) {
      final post = posts[postIndex];
      final comments = List<Comment>.from(post.comments);
      
      comments.add(Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        userName: userName,
        userImageUrl: userImageUrl,
        content: content,
        createdAt: DateTime.now(),
      ));
      
      final updatedPost = post.copyWith(comments: comments);
      posts[postIndex] = updatedPost;
      await savePosts(posts);
      
      return updatedPost;
    }
    
    throw Exception('Post not found');
  }
  
  // Get courses from local storage or generate mock data if none exists
  static Future<List<Course>> getCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final coursesData = prefs.getString(_coursesKey);
    
    if (coursesData != null) {
      // Parse the stored courses data
      // This would be more complex in a real app
      return _generateMockCourses(); // For simplicity, still returning mock data
    } else {
      // Generate mock data if none exists
      final courses = _generateMockCourses();
      // Save courses to local storage would go here
      return courses;
    }
  }
  
  // Get businesses from local storage or generate mock data if none exists
  static Future<List<Business>> getBusinesses({String? category}) async {
    final prefs = await SharedPreferences.getInstance();
    final businessesData = prefs.getString(_businessesKey);
    
    List<Business> businesses = [];
    
    if (businessesData != null) {
      // Parse the stored businesses data
      // This would be more complex in a real app
      businesses = _generateMockBusinesses(); // For simplicity, still returning mock data
    } else {
      // Generate mock data if none exists
      businesses = _generateMockBusinesses();
      // Save businesses to local storage would go here
    }
    
    // Filter by category if specified
    if (category != null && category.isNotEmpty && category != 'All') {
      businesses = businesses.where((business) => business.category == category).toList();
    }
    
    return businesses;
  }
  
  // Mock data generation methods
  static List<Post> _generateMockPosts() {
    final categories = ['Testimonials', 'Business Tips', 'Prayer Requests', 'General'];
    final Random random = Random();
    
    return List.generate(10, (index) {
      final hasImage = random.nextBool();
      final commentsCount = random.nextInt(5);
      final likesCount = random.nextInt(20);
      final categoryIndex = random.nextInt(categories.length);
      
      return Post(
        id: (1000 + index).toString(),
        userId: (100 + index).toString(),
        userName: 'Christian Entrepreneur ${index + 1}',
        userImageUrl: index % 3 == 0 ? null : 'https://source.unsplash.com/random/100x100/?portrait&i=$index',
        content: _getMockPostContent(index),
        imageUrl: hasImage ? 'https://source.unsplash.com/random/400x300/?business,faith&i=$index' : null,
        createdAt: DateTime.now().subtract(Duration(hours: index * 5)),
        category: categories[categoryIndex],
        comments: List.generate(commentsCount, (commentIndex) => Comment(
          id: '${1000 + index}-$commentIndex',
          userId: (200 + commentIndex).toString(),
          userName: 'Faith Member ${commentIndex + 1}',
          content: 'This is so inspiring! Thank you for sharing your journey.',
          createdAt: DateTime.now().subtract(Duration(hours: index * 5, minutes: (1 + commentIndex) * 30)),
        )),
        likes: List.generate(likesCount, (likeIndex) => (300 + likeIndex).toString()),
      );
    });
  }
  
  static String _getMockPostContent(int index) {
    final List<String> contents = [
      'Just launched my new Christian business coaching program! Excited to help fellow entrepreneurs grow their businesses while staying true to their faith. #FaithAndGrow',
      'Today I\'m grateful for how God has guided my business decisions. Sometimes the path isn\'t clear, but faith always leads the way. Anyone else experiencing this in their business journey?',
      'Would appreciate prayers for an upcoming business presentation. Feeling nervous but trusting God\'s plan!',
      'Just finished reading "The Purpose Driven Business." Highly recommend for all Christian entrepreneurs looking to align their business with their calling.',
      'Celebrating 5 years of my faith-based consulting business today! God has been so faithful through all the ups and downs.',
      'Looking for recommendations on faith-based accounting services for small businesses. Any suggestions from the community?',
      'Sharing my testimony of how God provided an amazing business opportunity when I least expected it. Never doubt His timing!',
      'How do you incorporate your faith into your daily business operations? Looking for practical ideas to implement.',
      'Just hired my first employee for my Christian bookstore! Excited and nervous at the same time. Any advice on faith-based leadership?',
      'Attended an amazing Christian business conference last weekend. So inspired by all the entrepreneurs living out their faith through business!',
    ];
    
    return contents[index % contents.length];
  }
  
  static List<Course> _generateMockCourses() {
    return [
      Course(
        id: '101',
        title: 'Faith-Based Business Fundamentals',
        description: 'Learn how to start and grow a business that honors your faith while creating sustainable value.',
        imageUrl: 'https://source.unsplash.com/random/400x300/?business,office',
        authorName: 'Pastor David Johnson',
        totalLessons: 12,
        estimatedDuration: Duration(hours: 8, minutes: 30),
        modules: [
          Module(
            id: '101-1',
            title: 'Foundations of Faith in Business',
            lessons: [
              Lesson(
                id: '101-1-1',
                title: 'Biblical Principles for Business',
                content: 'This lesson explores the core biblical principles that can guide your business decisions and strategy.',
                duration: Duration(minutes: 45),
              ),
              Lesson(
                id: '101-1-2',
                title: 'Identifying Your Business Calling',
                content: 'Discover how to align your business with your personal calling and purpose.',
                videoUrl: 'https://www.youtube.com/watch?v=example1',
                duration: Duration(minutes: 40),
              ),
            ],
          ),
          Module(
            id: '101-2',
            title: 'Ethical Business Practices',
            lessons: [
              Lesson(
                id: '101-2-1',
                title: 'Integrity in Business Transactions',
                content: 'Learn how to maintain integrity in all your business dealings and transactions.',
                duration: Duration(minutes: 35),
              ),
            ],
          ),
        ],
      ),
      Course(
        id: '102',
        title: 'Christian Marketing Strategies',
        description: 'Ethical marketing approaches that reflect your faith while effectively reaching your target audience.',
        imageUrl: 'https://source.unsplash.com/random/400x300/?marketing',
        authorName: 'Sarah Williams',
        totalLessons: 8,
        estimatedDuration: Duration(hours: 6, minutes: 15),
        modules: [],
      ),
      Course(
        id: '103',
        title: 'Biblical Financial Management',
        description: 'Handle your business finances according to biblical principles of stewardship and generosity.',
        imageUrl: 'https://source.unsplash.com/random/400x300/?finance',
        authorName: 'Michael Taylor, CPA',
        totalLessons: 10,
        estimatedDuration: Duration(hours: 7, minutes: 45),
        modules: [],
      ),
    ];
  }
  
  static List<Business> _generateMockBusinesses() {
    return [
      Business(
        id: '201',
        ownerId: '101',
        name: 'Grace & Wisdom Consulting',
        description: 'Faith-based business consulting helping Christian entrepreneurs align their business strategies with biblical principles.',
        logoUrl: 'https://source.unsplash.com/random/200x200/?logo,consulting',
        category: 'Consulting',
        tags: ['Business Strategy', 'Christian Values', 'Mentoring'],
        website: 'www.graceandwisdom.com',
        email: 'contact@graceandwisdom.com',
      ),
      Business(
        id: '202',
        ownerId: '102',
        name: 'Faithful Designs',
        description: 'Christian graphic design studio creating visuals that spread the message of faith for churches and ministries.',
        logoUrl: 'https://source.unsplash.com/random/200x200/?logo,design',
        category: 'Creative Services',
        tags: ['Graphic Design', 'Branding', 'Church Media'],
        website: 'www.faithfuldesigns.com',
        phoneNumber: '(555) 123-4567',
      ),
      Business(
        id: '203',
        ownerId: '103',
        name: 'Abundance Bookkeeping',
        description: 'Providing financial services with integrity and biblical stewardship principles for small businesses.',
        logoUrl: 'https://source.unsplash.com/random/200x200/?logo,accounting',
        category: 'Financial Services',
        tags: ['Bookkeeping', 'Tax Preparation', 'Financial Planning'],
        email: 'info@abundancebooks.com',
      ),
      Business(
        id: '204',
        ownerId: '104',
        name: 'Living Water Coaching',
        description: 'Life and business coaching from a Christian perspective, helping you discover your God-given purpose.',
        logoUrl: 'https://source.unsplash.com/random/200x200/?logo,coaching',
        category: 'Coaching',
        tags: ['Life Coaching', 'Business Coaching', 'Purpose Discovery'],
        website: 'www.livingwatercoaching.com',
        phoneNumber: '(555) 987-6543',
      ),
      Business(
        id: '205',
        ownerId: '105',
        name: 'Cornerstone Real Estate',
        description: 'Honest, faith-based real estate services for families and businesses in our community.',
        logoUrl: 'https://source.unsplash.com/random/200x200/?logo,realestate',
        category: 'Real Estate',
        tags: ['Residential', 'Commercial', 'Property Management'],
        website: 'www.cornerstonerealty.com',
        email: 'homes@cornerstonerealty.com',
        phoneNumber: '(555) 456-7890',
      ),
    ];
  }
  
  // Get post categories
  static Future<List<String>> getPostCategories() async {
    return ['All', 'General', 'Testimonials', 'Business Tips', 'Prayer Requests'];
  }
  
  // Get business categories
  static Future<List<String>> getBusinessCategories() async {
    return ['All', 'Consulting', 'Creative Services', 'Financial Services', 'Coaching', 'Real Estate', 'Retail', 'Technology', 'Ministry'];
  }
}