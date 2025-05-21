import 'package:flutter/material.dart';
import 'package:dreamflow/screens/admin/user_management_screen.dart';
import 'package:dreamflow/screens/admin/community_management_screen.dart';
import 'package:dreamflow/screens/admin/grant_admin_access.dart';
import 'package:dreamflow/widgets/common_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FaithAppBar(
        title: 'Admin Dashboard',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simplified dashboard that links to key admin functions
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Functions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16.h),
                    Wrap(
                      spacing: 16.w,
                      runSpacing: 16.h,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserManagementScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 120.w,
                            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people, color: Colors.blue, size: 32.r),
                                SizedBox(height: 8.h),
                                Text(
                                  'Manage Users',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.blue),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CommunityManagementScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 120.w,
                            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.groups, color: Colors.green, size: 32.r),
                                SizedBox(height: 8.h),
                                Text(
                                  'Manage Communities',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.green),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GrantAdminAccessScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 120.w,
                            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.admin_panel_settings, color: Colors.deepPurple, size: 32.r),
                                SizedBox(height: 8.h),
                                Text(
                                  'Grant Admin Access',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.deepPurple),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}