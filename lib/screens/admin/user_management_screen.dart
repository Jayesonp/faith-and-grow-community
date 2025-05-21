import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dreamflow/models/user_model.dart';
import 'package:dreamflow/services/admin_service.dart';
import 'package:dreamflow/widgets/common_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  bool _isLoading = true;
  List<User> _users = [];
  List<User> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  String _sortColumn = 'name';
  bool _sortAscending = true;
  String _selectedRole = 'All';
  
  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await AdminService.getAllUsers();
      setState(() {
        _users = users;
        _filteredUsers = List.from(users);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() => _isLoading = false);
    }
  }
  
  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        // Filter by search query
        final matchesQuery = user.name.toLowerCase().contains(query) || 
                           user.email.toLowerCase().contains(query) ||
                           (user.businessName?.toLowerCase().contains(query) ?? false);
        
        // Filter by role if a specific role is selected
        final matchesRole = _selectedRole == 'All' || 
                          (_selectedRole == 'Admin' && (user is AdminUser)) ||
                          (_selectedRole == 'User' && !(user is AdminUser));
        
        return matchesQuery && matchesRole;
      }).toList();
      
      // Apply sorting
      _sortUsers();
    });
  }
  
  void _sortUsers() {
    _filteredUsers.sort((a, b) {
      dynamic aValue;
      dynamic bValue;
      
      switch (_sortColumn) {
        case 'name':
          aValue = a.name;
          bValue = b.name;
          break;
        case 'email':
          aValue = a.email;
          bValue = b.email;
          break;
        case 'business':
          aValue = a.businessName ?? '';
          bValue = b.businessName ?? '';
          break;
        default:
          aValue = a.name;
          bValue = b.name;
      }
      
      int comparison = aValue.compareTo(bValue);
      return _sortAscending ? comparison : -comparison;
    });
  }
  
  void _onSort(String column) {
    setState(() {
      if (_sortColumn == column) {
        // Toggle sort direction
        _sortAscending = !_sortAscending;
      } else {
        // Change sort column
        _sortColumn = column;
        _sortAscending = true;
      }
      
      _sortUsers();
    });
  }

  void _onRoleFilterChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedRole = value;
      });
      _filterUsers();
    }
  }
  
  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUserAvatar(user),
              SizedBox(height: 16.h),
              _buildDetailItem('Name', user.name),
              _buildDetailItem('Email', user.email),
              _buildDetailItem('Business', user.businessName ?? 'N/A'),
              _buildDetailItem('Description', user.businessDescription ?? 'N/A'),
              _buildDetailItem('Admin', (user is AdminUser) ? 'Yes' : 'No'),
              Divider(),
              Text('Actions', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    label: 'Edit',
                    icon: Icons.edit,
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditUserDialog(user);
                    },
                  ),
                  _buildActionButton(
                    label: (user is AdminUser) ? 'Remove Admin' : 'Make Admin',
                    icon: (user is AdminUser) ? Icons.remove_moderator : Icons.admin_panel_settings,
                    onPressed: () {
                      Navigator.pop(context);
                      _toggleAdminStatus(user);
                    },
                  ),
                  _buildActionButton(
                    label: 'Delete',
                    icon: Icons.delete,
                    color: Colors.red,
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDeleteUser(user);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserAvatar(User user) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40.r,
            backgroundImage: user.profileImageUrl != null
                ? NetworkImage(user.profileImageUrl!)
                : null,
            child: user.profileImageUrl == null
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(fontSize: 30.sp),
                  )
                : null,
          ),
          SizedBox(height: 8.h),
          if (user is AdminUser)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                'Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
      ),
    );
  }
  
  void _showEditUserDialog(User user) {
    final nameController = TextEditingController(text: user.name);
    final businessNameController = TextEditingController(text: user.businessName ?? '');
    final businessDescController = TextEditingController(text: user.businessDescription ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: businessNameController,
                decoration: InputDecoration(
                  labelText: 'Business Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: businessDescController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Business Description',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateUser(
                user.id,
                nameController.text,
                businessNameController.text,
                businessDescController.text,
              );
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _updateUser(String userId, String name, String businessName, String businessDesc) async {
    try {
      await AdminService.updateUser(
        userId: userId,
        name: name,
        businessName: businessName.isNotEmpty ? businessName : null,
        businessDescription: businessDesc.isNotEmpty ? businessDesc : null,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User updated successfully')),
      );
      
      _loadUsers(); // Refresh user list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user: $e')),
      );
    }
  }
  
  Future<void> _toggleAdminStatus(User user) async {
    try {
      final isAdmin = user is AdminUser;
      
      if (isAdmin) {
        // Confirm removing admin privileges
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Remove Admin Privileges'),
            content: Text('Are you sure you want to remove admin privileges from ${user.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Remove'),
              ),
            ],
          ),
        );
        
        if (confirm != true) return;
      }
      
      await AdminService.setUserAdminStatus(
        userId: user.id,
        isAdmin: !isAdmin,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isAdmin ? 'Admin privileges removed' : 'Admin privileges granted')),
      );
      
      _loadUsers(); // Refresh user list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating admin status: $e')),
      );
    }
  }
  
  Future<void> _confirmDeleteUser(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await AdminService.deleteUser(user.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User deleted successfully')),
        );
        
        _loadUsers(); // Refresh user list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting user: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _isLoading
        ? Center(child: FaithLoadingIndicator(message: 'Loading users...'))
        : Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildUserTable()),
            ],
          ),
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              DropdownButton<String>(
                value: _selectedRole,
                items: [
                  DropdownMenuItem(value: 'All', child: Text('All Roles')),
                  DropdownMenuItem(value: 'Admin', child: Text('Admins')),
                  DropdownMenuItem(value: 'User', child: Text('Regular Users')),
                ],
                onChanged: _onRoleFilterChanged,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '${_filteredUsers.length} ${_filteredUsers.length == 1 ? 'user' : 'users'} found',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserTable() {
    return DataTable2(
      columnSpacing: 12.w,
      horizontalMargin: 12.w,
      minWidth: 600,
      columns: [
        DataColumn2(
          label: _buildSortableColumnHeader('Name', _sortColumn == 'name', _sortAscending),
          size: ColumnSize.L,
          onSort: (_, __) => _onSort('name'),
        ),
        DataColumn2(
          label: _buildSortableColumnHeader('Email', _sortColumn == 'email', _sortAscending),
          size: ColumnSize.L,
          onSort: (_, __) => _onSort('email'),
        ),
        DataColumn2(
          label: _buildSortableColumnHeader('Business', _sortColumn == 'business', _sortAscending),
          size: ColumnSize.L,
          onSort: (_, __) => _onSort('business'),
        ),
        DataColumn2(
          label: Text('Role'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Actions'),
          size: ColumnSize.S,
        ),
      ],
      rows: _filteredUsers.map((user) {
        return DataRow(
          cells: [
            DataCell(
              Row(
                children: [
                  CircleAvatar(
                    radius: 16.r,
                    backgroundImage: user.profileImageUrl != null
                        ? NetworkImage(user.profileImageUrl!)
                        : null,
                    child: user.profileImageUrl == null
                        ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?')
                        : null,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      user.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              onTap: () => _showUserDetails(user),
            ),
            DataCell(
              Text(
                user.email,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _showUserDetails(user),
            ),
            DataCell(
              Text(
                user.businessName ?? 'N/A',
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _showUserDetails(user),
            ),
            DataCell(
              user is AdminUser
                  ? Chip(
                      label: Text('Admin'),
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12.sp,
                      ),
                      padding: EdgeInsets.zero,
                    )
                  : Text('User'),
            ),
            DataCell(Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, size: 20.r),
                  tooltip: 'Edit User',
                  onPressed: () => _showEditUserDialog(user),
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: 20.r, color: Colors.red),
                  tooltip: 'Delete User',
                  onPressed: () => _confirmDeleteUser(user),
                ),
              ],
            )),
          ],
        );
      }).toList(),
    );
  }
  
  Widget _buildSortableColumnHeader(String label, bool isCurrentSortColumn, bool isAscending) {
    return Row(
      children: [
        Text(label),
        SizedBox(width: 4.w),
        if (isCurrentSortColumn)
          Icon(
            isAscending ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16.r,
          ),
      ],
    );
  }
}