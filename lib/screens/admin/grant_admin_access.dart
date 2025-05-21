import 'package:flutter/material.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/services/admin_service.dart';
import 'package:dreamflow/services/firebase_service.dart';
import 'package:dreamflow/services/firestore_service.dart';
import 'package:dreamflow/theme.dart';
import 'package:dreamflow/widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GrantAdminAccessScreen extends StatefulWidget {
  const GrantAdminAccessScreen({Key? key}) : super(key: key);

  @override
  State<GrantAdminAccessScreen> createState() => _GrantAdminAccessScreenState();
}

class _GrantAdminAccessScreenState extends State<GrantAdminAccessScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  User? _foundUser;
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _findUserByEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      _foundUser = null;
    });

    try {
      final email = _emailController.text.trim();
      
      // Find user by email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _errorMessage = 'No user found with this email address';
          _isLoading = false;
        });
        return;
      }

      final userData = querySnapshot.docs.first.data();
      final userId = querySnapshot.docs.first.id;
      
      // Convert the Firestore data to a User object
      final user = userData['isAdmin'] == true 
          ? AdminUser.fromJson({...userData, 'id': userId})
          : User.fromJson({...userData, 'id': userId});

      setState(() {
        _foundUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error finding user: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _grantAdminAccess() async {
    if (_foundUser == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Check if user is already an admin
      if (_foundUser!.isAdmin) {
        setState(() {
          _errorMessage = 'User already has admin privileges';
          _isLoading = false;
        });
        return;
      }

      // Grant admin access
      await AdminService.setUserAdminStatus(
        userId: _foundUser!.id,
        isAdmin: true,
      );

      setState(() {
        _successMessage = 'Admin access granted successfully';
        _isLoading = false;
        _foundUser = null;
        _emailController.clear();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error granting admin access: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FaithAppBar(title: 'Grant Admin Access'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header and instructions
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 48.r,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Grant Admin Access',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Use this form to grant admin privileges to a user. Enter the email address of the user you want to make an admin.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Theme.of(context).colorScheme.tertiary,
                            size: 24.r,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Warning: Admin users have full access to all data and settings in the application. Only grant admin access to trusted individuals.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.tertiary,
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
            SizedBox(height: 24.h),
            
            // Search form
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'User Email Address',
                          hintText: 'Enter the email of the user',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email address';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      FaithButton(
                        label: 'Find User',
                        icon: Icons.search,
                        onPressed: _findUserByEmail,
                        isLoading: _isLoading,
                      ),
                      if (_errorMessage != null) ...[  
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_successMessage != null) ...[  
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  _successMessage!,
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            // User details if found
            if (_foundUser != null) ...[  
              SizedBox(height: 24.h),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'User Found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16.h),
                      _buildUserDetail(context, 'Name', _foundUser!.name),
                      _buildUserDetail(context, 'Email', _foundUser!.email),
                      _buildUserDetail(
                        context, 
                        'Admin Status', 
                        _foundUser!.isAdmin ? 'Admin' : 'Regular User',
                        textColor: _foundUser!.isAdmin 
                          ? Theme.of(context).colorScheme.tertiary 
                          : null,
                      ),
                      _buildUserDetail(
                        context, 
                        'Subscription', 
                        _foundUser!.subscriptionTier.toUpperCase(),
                      ),
                      SizedBox(height: 16.h),
                      FaithButton(
                        label: 'Grant Admin Access',
                        icon: Icons.admin_panel_settings,
                        onPressed: _grantAdminAccess,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserDetail(BuildContext context, String label, String value, {Color? textColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}