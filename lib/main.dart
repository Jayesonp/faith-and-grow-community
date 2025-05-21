import 'firebase_options.dart';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dreamflow/screens/auth_screen.dart';
import 'package:dreamflow/screens/home_screen.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/screens/dashboard_tab.dart';
import 'package:dreamflow/screens/community_discovery_screen.dart';
import 'package:dreamflow/services/firebase_service.dart';
import 'package:dreamflow/services/global_fab_service.dart';
import 'package:dreamflow/services/data_initializer.dart';
import 'package:dreamflow/services/theme_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dreamflow/screens/welcome_screen.dart';
import 'package:dreamflow/screens/pricing_screen.dart';
import 'package:dreamflow/screens/pricing_demo_screen.dart';
import 'package:dreamflow/screens/pricing_example_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dreamflow/screens/admin/admin_dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'theme.dart';

void main() async {
  
  // Ensure widgets are initialized before proceeding
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase app with correct configuration
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    
    // Initialize Firebase services (auth, firestore, storage)
    await FirebaseService.initializeFirebase();
    
    // Initialize any required data (such as predefined communities)
    final communitiesInitialized = await DataInitializer.areCommunitiesInitialized();
    if (!communitiesInitialized) {
      await DataInitializer.initializePredefinedCommunities();
      await DataInitializer.markCommunititesAsInitialized();
    }
    
  } catch (e) {
    // Handle Firebase initialization errors gracefully
    print('Firebase initialization error: $e');
    // In a real app, you'd want to show a user-friendly error message
  }
  
  // Run the app with ThemeService provider
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize system UI settings for mobile optimization
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    
    // Set preferred orientations based on platform
    // For web, allow all orientations
    // For mobile, support both portrait and landscape on tablets
    if (!kIsWeb) {
      // On mobile, determine which orientations to support based on device width
      final double screenWidth = MediaQuery.of(context).size.width;
      final double screenHeight = MediaQuery.of(context).size.height;
      final bool isTablet = screenWidth > 600 || screenHeight > 600;
      
      if (isTablet) {
        // Tablets should support all orientations
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        // Phones are better optimized for portrait
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          // Still allow landscape as a fallback option
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    }
    // Setup responsive UI with ScreenUtil - optimized for both web and mobile
    return ScreenUtilInit(
      // Using standard mobile dimensions (iPhone 13) as reference design size
      designSize: const Size(390, 844), // Updated to iPhone 14/15 reference size
      minTextAdapt: true,
      splitScreenMode: true,
      // Ensure proper handling of media queries for responsive design
      useInheritedMediaQuery: true,
      // Override key responsive behaviors for web vs mobile
      builder: (context, child) {
        // Get current screen width to adapt for desktop/tablet
        final screenWidth = MediaQuery.of(context).size.width;
        final isWeb = kIsWeb;
        
        final themeService = Provider.of<ThemeService>(context);
        return MaterialApp(
          title: 'Faith & Grow - Christian Business Communities',
          routes: {
            '/pricing': (context) => const PricingDemoScreen(),
          },
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          // Apply appropriate text scaling based on platform and screen width
          builder: (context, widget) {
            if (widget == null) return const SizedBox.shrink();
            
            // Enhanced text scaling rules for improved readability across devices
            if (isWeb) {
              // Adaptive text scaling for web based on viewport width
              // Using different scaling factors for different screen sizes
              final double textScaleFactor;
              if (screenWidth >= 1600) {
                // Large desktop - slightly larger text but not too big
                textScaleFactor = 1.0;
              } else if (screenWidth >= 1200) {
                // Desktop - balanced text size
                textScaleFactor = 0.95;
              } else if (screenWidth >= 768) {
                // Tablet - slightly smaller to fit more content
                textScaleFactor = 0.9;
              } else {
                // Mobile web - more compact text
                textScaleFactor = 0.85;
              }
              
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: textScaleFactor,
                  // Adjusted padding for web
                  padding: screenWidth < 600 
                      ? MediaQuery.of(context).padding 
                      : const EdgeInsets.all(0), // Remove browser padding on larger screens
                ),
                child: widget,
              );
            } else {
              // Mobile app text scaling with accessibility considerations
              // Respect user preferences up to a reasonable limit
              final currentTextScale = MediaQuery.of(context).textScaleFactor;
              // Allow for accessibility but cap at 1.3 to maintain layout
              final cappedTextScale = currentTextScale > 1.3 ? 1.3 : currentTextScale;
              
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: cappedTextScale,
                  // Keep standard system padding and insets for mobile apps
                  padding: MediaQuery.of(context).padding,
                  viewInsets: MediaQuery.of(context).viewInsets,
                ),
                child: widget,
              );
            }
          },
          home: child,
        );
      },
      child: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isFirstTime = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkFirstTimeUser();
    _checkAuthStatus();
  }

  Future<void> _checkFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('first_time') ?? true;
      
      setState(() {
        _isFirstTime = isFirstTime;
      });
      
      if (isFirstTime) {
        // Set first time flag to false for future launches
        await prefs.setBool('first_time', false);
      }
    } catch (e) {
      print('Error checking first time status: $e');
    }
  }

  Future<void> _checkAuthStatus() async {
    setState(() => _isLoading = true);
    
    try {
      print('Checking authentication status...');
      // Debug the current Firebase auth state
      FirebaseService.printAuthState();
      
      // Check if user is logged in with Firebase
      final isLoggedIn = FirebaseService.isUserLoggedIn;
      print('Firebase auth status: ${isLoggedIn ? 'logged in' : 'not logged in'}');
      
      // If Firebase auth is active, get user data
      if (isLoggedIn) {
        final firebaseUserId = FirebaseService.currentUserId;
        print('Firebase user ID: $firebaseUserId');
        
        // Check if the user document exists in Firestore
        if (firebaseUserId != null) {
          final userExists = await FirebaseService.documentExists('users', firebaseUserId);
          print('User exists in Firestore: $userExists');
        }
        
        final user = await UserService.getCurrentUser();
        print('Retrieved user from UserService: ${user != null ? user.email : 'null'}');
        
        if (user != null) {
          setState(() {
            _isLoggedIn = true;
            _user = user;
            _isLoading = false;
          });
          return;
        } else {
          print('WARNING: Firebase auth shows logged in but could not retrieve user data');
          // Try to get basic user data directly from Firebase Auth
          final firebaseUser = FirebaseService.auth.currentUser;
          if (firebaseUser != null) {
            final fallbackUser = User(
              id: firebaseUser.uid,
              name: firebaseUser.displayName ?? 'User',
              email: firebaseUser.email ?? '',
            );
            
            setState(() {
              _isLoggedIn = true;
              _user = fallbackUser;
              _isLoading = false;
            });
            return;
          }
        }
      }
      
      // Fall back to shared preferences if Firebase auth is not active
      final isLocallyLoggedIn = await UserService.isLoggedIn();
      print('Local storage auth status: ${isLocallyLoggedIn ? 'logged in' : 'not logged in'}');
      
      if (isLocallyLoggedIn) {
        final user = await UserService.getCurrentUser();
        print('Retrieved user from local storage: ${user != null ? user.email : 'null'}');
        
        if (user != null) {
          setState(() {
            _isLoggedIn = true;
            _user = user;
            _isLoading = false;
          });
          return;
        }
      }
      
      // User is not logged in
      print('No valid authentication found. User is not logged in.');
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
      
    } catch (e) {
      print('Error checking auth status: $e');
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }
    
    if (_isFirstTime) {
      return const WelcomeScreen();
    }
    
    if (_isLoggedIn && _user != null) {
      return HomeScreen(user: _user!);
    }
    
    return const AuthScreen();
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoadingComplete = false;
  bool _disposed = false;
  
  String _loadingMessage = "Starting up...";
  final List<String> _loadMessages = [
    "Starting up...",
    "Loading your communities...",
    "Getting things ready...",
    "Almost there..."
  ];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
    
    _simulateLoading();
  }
  
  @override
  void dispose() {
    _disposed = true;
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _simulateLoading() async {
    if (_isLoadingComplete) return;
    
    for (int i = 0; i < _loadMessages.length; i++) {
      if (_disposed || !mounted || _isLoadingComplete) break;
      
      await Future.delayed(const Duration(milliseconds: 700));
      
      if (_disposed || !mounted || _isLoadingComplete) break;
      
      setState(() {
        _loadingMessage = _loadMessages[i];
      });
    }
    
    // Mark loading as complete and trigger final animation
    if (!_disposed && mounted && !_isLoadingComplete) {
      setState(() {
        _isLoadingComplete = true;
      });
      
      // Allow time for the last message to be shown
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!_disposed && mounted) {
        // Fade out animation
        await _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with shadow effect
                    Container(
                      height: isPortrait ? screenHeight * 0.25 : screenHeight * 0.4,
                      width: isPortrait ? screenWidth * 0.6 : screenWidth * 0.3,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Shadow effect
                          Container(
                            height: isPortrait ? screenHeight * 0.2 : screenHeight * 0.35,
                            width: isPortrait ? screenWidth * 0.5 : screenWidth * 0.25,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                          // Logo
                          Container(
                            height: isPortrait ? screenHeight * 0.2 : screenHeight * 0.35,
                            width: isPortrait ? screenWidth * 0.5 : screenWidth * 0.25,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.church_outlined,
                              size: isPortrait ? screenHeight * 0.1 : screenHeight * 0.15,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),
                    // App name with animated typing effect
                    Text(
                      "Faith and Grow",
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Where Faith Meets Business",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40.h),
                    // Loading indicator with text
                    Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          _loadingMessage,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}