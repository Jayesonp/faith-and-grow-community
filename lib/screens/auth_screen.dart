import 'package:flutter/material.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/widgets/common_widgets.dart';
import 'package:dreamflow/theme.dart';
import 'package:dreamflow/screens/home_screen.dart';
import 'package:dreamflow/services/auth_service.dart';
import 'package:dreamflow/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dreamflow/screens/welcome_screen.dart';
import 'package:dreamflow/widgets/responsive_layout.dart';

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  AuthMode _authMode = AuthMode.login;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn)
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut)
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.register;
      });
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid form
      return;
    }
    
    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Print current Firebase auth state for debugging
      FirebaseService.printAuthState();
      
      if (_authMode == AuthMode.login) {
        print('Attempting to log in with email: ${_emailController.text.trim()}');
        
        // Login
        final user = await AuthService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        
        if (user != null) {
          // Verify if the user document exists in Firestore
          final userExists = await FirebaseService.documentExists('users', user.id);
          print('User document exists in Firestore: $userExists');
          
          // Store user in shared preferences
          await UserService.saveUser(user);
          await UserService.setLoggedIn(true);
          
          // Print statement for debugging
          print('Authentication successful for user: ${user.email}');
          
          // Print Firebase auth state after successful login
          FirebaseService.printAuthState();
          
          // Navigate to home screen
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(user: user),
              ),
            );
          }
        } else {
          // Show error message
          _showErrorDialog('Failed to login. Please check your credentials and make sure you have registered.');
        }
      } else {
        print('Attempting to register with email: ${_emailController.text.trim()}');
        
        // Register
        final user = await AuthService.registerWithEmailAndPassword(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          businessName: _businessNameController.text.trim(),
        );
        
        if (user != null) {
          // Verify if the user document was created in Firestore
          final userExists = await FirebaseService.documentExists('users', user.id);
          print('User document created in Firestore: $userExists');
          
          // Store user in shared preferences
          await UserService.saveUser(user);
          await UserService.setLoggedIn(true);
          
          // Save first time flag as false since user has registered
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('has_seen_welcome', true);
          
          // Print Firebase auth state after successful registration
          FirebaseService.printAuthState();
          
          // Navigate to home screen
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(user: user),
              ),
            );
          }
        } else {
          // Show error message
          _showErrorDialog('Failed to register. Please try again.');
        }
      }
    } on firebase_auth.FirebaseAuthException catch (error) {
      String errorMessage = AuthService.getErrorMessage(error);
      _showErrorDialog(
        errorMessage,
        technicalDetails: '${error.code}: ${error.message}',
        isNetworkError: error.code == 'network-request-failed',
      );
      print('Firebase Auth Error: ${error.code} - ${error.message}');
    } catch (error) {
      print('Authentication error: $error');
      if (error.toString().contains('network')) {
        _showErrorDialog(
          'Network error. Please check your internet connection and try again.',
          isNetworkError: true,
          technicalDetails: error.toString(),
        );
      } else if (error.toString().contains('Firebase')) {
        _showErrorDialog(
          'Firebase initialization error. Please restart the app and try again.',
          technicalDetails: error.toString(),
        );
      } else {
        _showErrorDialog(
          'An error occurred during authentication. Please try again.',
          technicalDetails: error.toString(),
        );
      }
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  void _showErrorDialog(String message, {String? technicalDetails, bool isNetworkError = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isNetworkError ? 'Network Error' : 'Authentication Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (technicalDetails != null) ...[              
              SizedBox(height: 12),
              Text(
                'Technical details:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(
                technicalDetails,
                style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ],
            if (isNetworkError) ...[              
              SizedBox(height: 16),
              Text(
                'Troubleshooting tips:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text('• Check your internet connection'),
              Text('• Make sure you\'re not using a restricted network'),
              Text('• Try again in a few moments'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions and orientation
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    // Use responsive layout pattern for different device types and orientations
    return Scaffold(
      body: ResponsiveLayout(
        mobilePortraitBody: _buildMobilePortraitLayout(),
        mobileLandscapeBody: _buildMobileLandscapeLayout(),
        tabletPortraitBody: _buildTabletLayout(isLandscape: false),
        tabletLandscapeBody: _buildTabletLayout(isLandscape: true),
        desktopBody: _buildDesktopLayout(),
      ),
    );
  }

  // Mobile portrait layout (stacked vertically)
  Widget _buildMobilePortraitLayout() {
    return SingleChildScrollView(
      child: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.primary.withOpacity(0.05),
              ],
            ),
          ),
          child: Center(
            child: Card(
              margin: const EdgeInsets.all(20.0),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo and Title
                    Center(child: const FaithGrowLogo(size: 80)),
                    const SizedBox(height: 32),
                    Text(
                      _authMode == AuthMode.login ? 'Welcome Back' : 'Create Account',
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _authMode == AuthMode.login
                          ? 'Sign in to continue'
                          : 'Create your account',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Auth Form
                    _buildAuthForm(),
                    const SizedBox(height: 16),
                    // Switch Auth Mode Button
                    Center(
                      child: TextButton(
                        onPressed: _switchAuthMode,
                        child: Text(
                          _authMode == AuthMode.login
                              ? 'Don\'t have an account? Sign Up'
                              : 'Already have an account? Sign In',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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

  // Mobile landscape layout (side by side)
  Widget _buildMobileLandscapeLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.primary.withOpacity(0.05),
              ],
            ),
          ),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left side - Branding
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FaithGrowLogo(size: 60),
                          const SizedBox(height: 24),
                          Text(
                            'Faith',
                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 0.9,
                            ),
                          ),
                          Text(
                            '&',
                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 0.9,
                            ),
                          ),
                          Text(
                            'Grow',
                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 0.9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Right side - Login form
                  Expanded(
                    flex: 6,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back',
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _authMode == AuthMode.login
                                ? 'Sign in to continue'
                                : 'Create your account',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildAuthForm(),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: _switchAuthMode,
                              child: Text(
                                _authMode == AuthMode.login
                                    ? 'Don\'t have an account? Sign Up'
                                    : 'Already have an account? Sign In',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Tablet layout (portrait or landscape)
  Widget _buildTabletLayout({required bool isLandscape}) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: isLandscape ? Alignment.centerLeft : Alignment.topCenter,
                end: isLandscape ? Alignment.centerRight : Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ],
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Container(
                  constraints: BoxConstraints(maxWidth: isLandscape ? 800 : 600),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: isLandscape
                      ? Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  bottomLeft: Radius.circular(24),
                                ),
                                child: Container(
                                  color: Theme.of(context).colorScheme.primary,
                                  height: 600, // Fixed height
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 20),
                                        // Logo in top corner
                                        const FaithGrowLogo(size: 80),
                                        const SizedBox(height: 60),
                                        // Large Faith & Grow text
                                        Text(
                                          'Faith',
                                          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 0.9,
                                          ),
                                        ),
                                        Text(
                                          '&',
                                          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 0.9,
                                          ),
                                        ),
                                        Text(
                                          'Grow',
                                          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 0.9,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      _authMode == AuthMode.login ? 'Welcome Back' : 'Create Account',
                                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _authMode == AuthMode.login
                                          ? 'Sign in to continue your faith and business journey'
                                          : 'Join our community of Christian entrepreneurs',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: 32),
                                    _buildAuthForm(),
                                    const SizedBox(height: 16),
                                    TextButton(
                                      onPressed: _switchAuthMode,
                                      child: Text(
                                        _authMode == AuthMode.login
                                            ? 'Don\'t have an account? Sign Up'
                                            : 'Already have an account? Sign In',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            // Top with branding
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                              ),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 32.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const FaithGrowLogo(size: 80),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Faith & Grow',
                                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Bottom with sign-in form
                            Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome Back',
                                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _authMode == AuthMode.login
                                        ? 'Sign in to continue'
                                        : 'Create your account',
                                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  _buildAuthForm(),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: _switchAuthMode,
                                    child: Text(
                                      _authMode == AuthMode.login
                                          ? 'Don\'t have an account? Sign Up'
                                          : 'Already have an account? Sign In',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Desktop layout (wide screen)
  Widget _buildDesktopLayout() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Card(
            margin: const EdgeInsets.all(64.0),
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 650),
              child: Row(
                children: [
                  // Left side with branding
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          bottomLeft: Radius.circular(24),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            // Logo in top corner
                            const FaithGrowLogo(size: 80),
                            const SizedBox(height: 80),
                            // Large Faith & Grow text
                            Text(
                              'Faith',
                              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 72,
                                height: 0.9,
                              ),
                            ),
                            Text(
                              '&',
                              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 72,
                                height: 0.9,
                              ),
                            ),
                            Text(
                              'Grow',
                              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 72,
                                height: 0.9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Right side with login form
                  Expanded(
                    flex: 6,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Large "Welcome Back" text
                          Text(
                            'Welco',
                            style: Theme.of(context).textTheme.displaySmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 42,
                              height: 0.9,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'me',
                            style: Theme.of(context).textTheme.displaySmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 42,
                              height: 0.9,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Back',
                            style: Theme.of(context).textTheme.displaySmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 42,
                              height: 0.9,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _authMode == AuthMode.login 
                                ? 'Sign in to continue'
                                : 'Create your account',
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 40),
                          _buildAuthForm(),
                          const SizedBox(height: 20),
                          Center(
                            child: TextButton(
                              onPressed: _switchAuthMode,
                              child: Text(
                                _authMode == AuthMode.login
                                    ? 'Don\'t have an account? Sign Up'
                                    : 'Already have an account? Sign In',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Shared auth form for all layouts
  Widget _buildAuthForm() {
    final isDesktop = MediaQuery.of(context).size.width > 1200;
    final forgotPasswordMargin = isDesktop ? 16.0 : 12.0;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_authMode == AuthMode.register)
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              if (_authMode == AuthMode.register)
                const SizedBox(height: 20),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (_authMode == AuthMode.register && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              if (_authMode == AuthMode.login)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(top: forgotPasswordMargin, right: 4),
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement password reset
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerRight,
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: isDesktop ? 14 : 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              if (_authMode == AuthMode.register)
                _buildTextField(
                  controller: _businessNameController,
                  label: 'Business Name (Optional)',
                  icon: Icons.business,
                ),
              if (_authMode == AuthMode.register)
                const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: isDesktop ? 50 : 45,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isDesktop ? 6 : 8),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _authMode == AuthMode.login ? 'Sign In' : 'Sign Up',
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 1200;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobileView = screenWidth < 600;
    
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 8 : 12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 8 : 12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 8 : 12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 8 : 12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          vertical: isDesktop ? 16 : (isMobileView ? 12 : 14),
          horizontal: isDesktop ? 16 : (isMobileView ? 12 : 14),
        ),
        labelStyle: TextStyle(
          color: Colors.black54,
          fontSize: isDesktop ? 14 : (isMobileView ? 12 : 13),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: isDesktop ? 15 : (isMobileView ? 13 : 14),
        color: Colors.black87,
      ),
    );
  }
}