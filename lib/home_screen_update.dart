// This is a helper file to show changes needed for the HomeScreen class to add admin functionality

/*

Add these imports at the top of the file:

import 'package:dreamflow/screens/admin/admin_dashboard_screen.dart';

Then update the build method to check for admin status and add admin navigation:

  @override
  Widget build(BuildContext context) {
    // First check if the user is an admin
    final isAdmin = widget.user.isAdmin;
    
    // For desktop view, add admin section to side navigation:
    // Inside the desktop side navigation Column's ListView, add:

    if (isAdmin) Divider(height: 32.h, thickness: 1),
    if (isAdmin)
      Padding(
        padding: EdgeInsets.only(left: 16.w, bottom: 8.h),
        child: Text(
          'ADMIN',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    if (isAdmin)
      ListTile(
        leading: Icon(Icons.admin_panel_settings),
        title: Text('Admin Portal'),
        selected: false,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminDashboardScreen(),
            ),
          );
        },
      ),
      
    // For tablet view, add admin access at the bottom of the navigation rail:
    // Inside the NavigationRail trailing parameter:
    
    trailing: isAdmin
      ? Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(thickness: 1),
                  SizedBox(height: 8.h),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminDashboardScreen(),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      : null,
      
    // For mobile view, add admin access through an app bar menu:
    // Add this appBar parameter to the mobile Scaffold:
    
    appBar: isAdmin && _currentIndex == 0
      ? AppBar(
          title: const Text('Faith and Grow'),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Portal',
              onSelected: (value) {
                if (value == 'admin') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminDashboardScreen(),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'admin',
                  child: Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20.r,
                      ),
                      SizedBox(width: 8.w),
                      Text('Admin Portal'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        )
      : null,
*/