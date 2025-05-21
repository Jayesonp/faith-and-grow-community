import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dreamflow/models/community_model.dart';
import 'package:dreamflow/services/admin_service.dart';
import 'package:dreamflow/widgets/common_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CommunityManagementScreen extends StatefulWidget {
  const CommunityManagementScreen({Key? key}) : super(key: key);

  @override
  State<CommunityManagementScreen> createState() => _CommunityManagementScreenState();
}

class _CommunityManagementScreenState extends State<CommunityManagementScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Community> _communities = [];
  List<Community> _filteredCommunities = [];
  final TextEditingController _searchController = TextEditingController();
  String _sortColumn = 'createdAt';
  bool _sortAscending = false; // Default to newest first
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  List<String> _categories = ['All'];
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCommunities();
    _searchController.addListener(_filterCommunities);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCommunities() async {
    setState(() => _isLoading = true);
    try {
      final communities = await AdminService.getAllCommunities();
      final categories = await AdminService.getCommunityCategories();
      
      setState(() {
        _communities = communities;
        _filteredCommunities = List.from(communities);
        _categories = ['All', ...categories];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading communities: $e');
      setState(() => _isLoading = false);
    }
  }
  
  void _filterCommunities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCommunities = _communities.where((community) {
        // Filter by search query
        final matchesQuery = community.name.toLowerCase().contains(query) || 
                           community.shortDescription.toLowerCase().contains(query);
        
        // Filter by category if specific category is selected
        final matchesCategory = _selectedCategory == 'All' || 
                              community.category == _selectedCategory;
        
        // Filter by status if specific status is selected
        final matchesStatus = _selectedStatus == 'All' || 
                            (_selectedStatus == 'Published' && community.isPublished) ||
                            (_selectedStatus == 'Draft' && !community.isPublished);
        
        return matchesQuery && matchesCategory && matchesStatus;
      }).toList();
      
      // Apply sorting
      _sortCommunities();
    });
  }
  
  void _sortCommunities() {
    _filteredCommunities.sort((a, b) {
      dynamic aValue;
      dynamic bValue;
      
      switch (_sortColumn) {
        case 'name':
          aValue = a.name;
          bValue = b.name;
          break;
        case 'category':
          aValue = a.category;
          bValue = b.category;
          break;
        case 'memberCount':
          aValue = a.memberCount;
          bValue = b.memberCount;
          break;
        case 'createdAt':
          aValue = a.createdAt;
          bValue = b.createdAt;
          break;
        default:
          aValue = a.createdAt;
          bValue = b.createdAt;
      }
      
      int comparison;
      if (aValue is DateTime && bValue is DateTime) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is int && bValue is int) {
        comparison = aValue.compareTo(bValue);
      } else {
        comparison = aValue.toString().compareTo(bValue.toString());
      }
      
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
      
      _sortCommunities();
    });
  }

  void _onCategoryFilterChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedCategory = value;
      });
      _filterCommunities();
    }
  }
  
  void _onStatusFilterChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedStatus = value;
      });
      _filterCommunities();
    }
  }
  
  void _showCommunityDetails(Community community) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8, maxWidth: 700.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCommunityHeader(community),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(community),
                      SizedBox(height: 16.h),
                      _buildTiersSection(community),
                      SizedBox(height: 16.h),
                      _buildActionButtons(community),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCommunityHeader(Community community) {
    return Stack(
      children: [
        // Cover image with gradient overlay
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
          child: Container(
            height: 150.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              image: community.coverImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(community.coverImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Back button and community status
        Positioned(
          top: 8.h,
          left: 8.w,
          right: 8.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: community.isPublished ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  community.isPublished ? 'Published' : 'Draft',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Community name and short description
        Positioned(
          bottom: 16.h,
          left: 16.w,
          right: 16.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                community.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                community.shortDescription,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14.sp,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoSection(Community community) {
    final dateFormat = DateFormat.yMMMd().add_jm();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Community Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 8.h),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                _buildInfoItem(
                  icon: Icons.category,
                  label: 'Category',
                  value: community.category,
                ),
                _buildInfoItem(
                  icon: Icons.people,
                  label: 'Member Count',
                  value: community.memberCount.toString(),
                ),
                _buildInfoItem(
                  icon: Icons.person,
                  label: 'Creator ID',
                  value: community.creatorId,
                ),
                _buildInfoItem(
                  icon: Icons.calendar_today,
                  label: 'Created',
                  value: dateFormat.format(community.createdAt),
                ),
                SizedBox(height: 8.h),
                ExpansionTile(
                  title: Text('Full Description'),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Text(community.fullDescription),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoItem({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 20.r, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 8.w),
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTiersSection(Community community) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Membership Tiers',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 8.h),
        ...community.tiers.map((tier) => Card(
          margin: EdgeInsets.only(bottom: 8.h),
          child: ListTile(
            title: Text(tier.name),
            subtitle: Text('${tier.features.length} features'),
            trailing: Text(
              tier.formattedPrice,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('${tier.name} Tier Details'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: ${tier.formattedPrice}'),
                      SizedBox(height: 8.h),
                      Text('Features:'),
                      SizedBox(height: 4.h),
                      ...tier.features.map((feature) => Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16.r, color: Colors.green),
                            SizedBox(width: 8.w),
                            Expanded(child: Text(feature)),
                          ],
                        ),
                      )),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        )),
      ],
    );
  }
  
  Widget _buildActionButtons(Community community) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            ActionChip(
              avatar: Icon(
                community.isPublished ? Icons.visibility_off : Icons.visibility,
                color: community.isPublished ? Colors.orange : Colors.green,
              ),
              label: Text(community.isPublished ? 'Unpublish' : 'Publish'),
              onPressed: () => _toggleCommunityPublishStatus(community),
            ),
            ActionChip(
              avatar: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
              label: Text('Edit Details'),
              onPressed: () => _showEditCommunityDialog(community),
            ),
            ActionChip(
              avatar: Icon(Icons.delete, color: Colors.red),
              label: Text('Delete'),
              onPressed: () => _confirmDeleteCommunity(community),
            ),
          ],
        ),
      ],
    );
  }
  
  Future<void> _toggleCommunityPublishStatus(Community community) async {
    try {
      final newStatus = !community.isPublished;
      await AdminService.setCommunityPublishStatus(
        communityId: community.id,
        isPublished: newStatus,
      );
      
      Navigator.pop(context); // Close detail dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          newStatus 
              ? 'Community published successfully' 
              : 'Community unpublished successfully'
        )),
      );
      
      _loadCommunities(); // Refresh community list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating community: $e')),
      );
    }
  }
  
  void _showEditCommunityDialog(Community community) {
    final nameController = TextEditingController(text: community.name);
    final shortDescController = TextEditingController(text: community.shortDescription);
    final fullDescController = TextEditingController(text: community.fullDescription);
    String selectedCategory = community.category;
    
    Navigator.pop(context); // Close detail dialog
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Community'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Community Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.where((c) => c != 'All').map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedCategory = value;
                  }
                },
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: shortDescController,
                decoration: InputDecoration(
                  labelText: 'Short Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: fullDescController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Full Description',
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
              _updateCommunity(
                community.id,
                nameController.text,
                shortDescController.text,
                fullDescController.text,
                selectedCategory,
              );
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _updateCommunity(
    String communityId,
    String name,
    String shortDesc,
    String fullDesc,
    String category,
  ) async {
    try {
      await AdminService.updateCommunity(
        communityId: communityId,
        name: name,
        shortDescription: shortDesc,
        fullDescription: fullDesc,
        category: category,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Community updated successfully')),
      );
      
      _loadCommunities(); // Refresh community list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating community: $e')),
      );
    }
  }
  
  Future<void> _confirmDeleteCommunity(Community community) async {
    Navigator.pop(context); // Close detail dialog
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Community'),
        content: Text(
          'Are you sure you want to delete "${community.name}"? This will permanently remove the community and all its content. This action cannot be undone.',
        ),
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
        await AdminService.deleteCommunity(community.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Community deleted successfully')),
        );
        
        _loadCommunities(); // Refresh community list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting community: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadCommunities,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All Communities'),
            Tab(text: 'Pending Approval'),
          ],
        ),
      ),
      body: _isLoading
        ? Center(child: FaithLoadingIndicator(message: 'Loading communities...'))
        : TabBarView(
            controller: _tabController,
            children: [
              _buildCommunitiesView(false),
              _buildCommunitiesView(true),
            ],
          ),
    );
  }
  
  Widget _buildCommunitiesView(bool pendingOnly) {
    // Filter communities for pending tab if needed
    final displayCommunities = pendingOnly
        ? _filteredCommunities.where((c) => !c.isPublished).toList()
        : _filteredCommunities;
    
    return Column(
      children: [
        _buildHeader(),
        if (displayCommunities.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                pendingOnly
                    ? 'No communities pending approval'
                    : 'No communities found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          )
        else
          Expanded(child: _buildCommunityTable(displayCommunities)),
      ],
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
                    hintText: 'Search communities...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              DropdownButton<String>(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: _onCategoryFilterChanged,
              ),
              SizedBox(width: 16.w),
              DropdownButton<String>(
                value: _selectedStatus,
                items: [
                  DropdownMenuItem(value: 'All', child: Text('All Status')),
                  DropdownMenuItem(value: 'Published', child: Text('Published')),
                  DropdownMenuItem(value: 'Draft', child: Text('Draft')),
                ],
                onChanged: _onStatusFilterChanged,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '${_filteredCommunities.length} ${_filteredCommunities.length == 1 ? 'community' : 'communities'} found',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommunityTable(List<Community> communities) {
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
          label: _buildSortableColumnHeader('Category', _sortColumn == 'category', _sortAscending),
          size: ColumnSize.M,
          onSort: (_, __) => _onSort('category'),
        ),
        DataColumn2(
          label: _buildSortableColumnHeader('Members', _sortColumn == 'memberCount', _sortAscending),
          size: ColumnSize.S,
          numeric: true,
          onSort: (_, __) => _onSort('memberCount'),
        ),
        DataColumn2(
          label: _buildSortableColumnHeader('Created', _sortColumn == 'createdAt', _sortAscending),
          size: ColumnSize.M,
          onSort: (_, __) => _onSort('createdAt'),
        ),
        DataColumn2(
          label: Text('Status'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Actions'),
          size: ColumnSize.S,
        ),
      ],
      rows: communities.map((community) {
        return DataRow(
          cells: [
            DataCell(
              Row(
                children: [
                  Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: community.iconImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(community.iconImageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: community.iconImageUrl == null
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                          : null,
                    ),
                    child: community.iconImageUrl == null
                        ? Center(child: Text(community.name[0].toUpperCase()))
                        : null,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          community.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          community.shortDescription,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () => _showCommunityDetails(community),
            ),
            DataCell(
              Chip(
                label: Text(community.category),
                backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                labelStyle: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                padding: EdgeInsets.zero,
              ),
              onTap: () => _showCommunityDetails(community),
            ),
            DataCell(
              Text(community.memberCount.toString()),
              onTap: () => _showCommunityDetails(community),
            ),
            DataCell(
              Text(
                DateFormat.yMMMd().format(community.createdAt),
                style: TextStyle(fontSize: 12.sp),
              ),
              onTap: () => _showCommunityDetails(community),
            ),
            DataCell(
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: community.isPublished ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  community.isPublished ? 'Published' : 'Draft',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: community.isPublished ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            DataCell(Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    community.isPublished ? Icons.visibility_off : Icons.visibility,
                    size: 20.r,
                    color: community.isPublished ? Colors.orange : Colors.green,
                  ),
                  tooltip: community.isPublished ? 'Unpublish' : 'Publish',
                  onPressed: () => _confirmPublishStatusChange(community),
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: 20.r, color: Colors.red),
                  tooltip: 'Delete',
                  onPressed: () => _confirmDeleteCommunityDirectly(community),
                ),
              ],
            )),
          ],
        );
      }).toList(),
    );
  }
  
  Future<void> _confirmPublishStatusChange(Community community) async {
    final newStatus = !community.isPublished;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(newStatus ? 'Publish Community' : 'Unpublish Community'),
        content: Text(
          newStatus
              ? 'Are you sure you want to publish "${community.name}"? This will make it visible to all users.'
              : 'Are you sure you want to unpublish "${community.name}"? This will hide it from public view.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? Colors.green : Colors.orange,
            ),
            child: Text(newStatus ? 'Publish' : 'Unpublish'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await AdminService.setCommunityPublishStatus(
          communityId: community.id,
          isPublished: newStatus,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
            newStatus 
                ? 'Community published successfully' 
                : 'Community unpublished successfully'
          )),
        );
        
        _loadCommunities(); // Refresh community list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating community: $e')),
        );
      }
    }
  }
  
  Future<void> _confirmDeleteCommunityDirectly(Community community) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Community'),
        content: Text(
          'Are you sure you want to delete "${community.name}"? This will permanently remove the community and all its content. This action cannot be undone.',
        ),
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
        await AdminService.deleteCommunity(community.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Community deleted successfully')),
        );
        
        _loadCommunities(); // Refresh community list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting community: $e')),
        );
      }
    }
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
  
  int min(int a, int b) => a < b ? a : b;
}