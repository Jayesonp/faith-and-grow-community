import 'package:flutter/material.dart';
import 'package:dreamflow/models/content_model.dart';
import 'package:dreamflow/services/data_service.dart';
import 'package:dreamflow/widgets/common_widgets.dart';

import 'package:url_launcher/url_launcher.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({Key? key}) : super(key: key);

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> with AutomaticKeepAliveClientMixin {
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  List<Business> _businesses = [];
  List<Business> _filteredBusinesses = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterBusinesses();
    });
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final categories = await DataService.getBusinessCategories();
      final businesses = await DataService.getBusinesses(
        category: _selectedCategory != 'All' ? _selectedCategory : null,
      );
      
      setState(() {
        _categories = categories;
        _businesses = businesses;
        _filteredBusinesses = List.from(businesses);
        _isLoading = false;
      });
      
      // Apply any existing search filter
      if (_searchQuery.isNotEmpty) {
        _filterBusinesses();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading directory: $e')),
      );
    }
  }
  
  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
      _searchQuery = '';
    });
    _loadData();
  }
  
  void _filterBusinesses() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredBusinesses = List.from(_businesses);
      });
      return;
    }
    
    final query = _searchQuery.toLowerCase();
    setState(() {
      _filteredBusinesses = _businesses.where((business) {
        return business.name.toLowerCase().contains(query) ||
               business.description.toLowerCase().contains(query) ||
               business.category.toLowerCase().contains(query) ||
               business.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    });
  }
  
  void _showBusinessDetail(Business business) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessDetailScreen(business: business),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Faith Business Directory',
          style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search businesses...',
                prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          // Category filter
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _categories.length > 1 ? 50 : 0,
            child: _categories.length > 1
                ? FilterChips(
                    categories: _categories,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: _selectCategory,
                  )
                : null,
          ),
          
          // Business list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: _isLoading
                  ? const FaithLoadingIndicator(message: 'Loading business directory...')
                  : _filteredBusinesses.isEmpty
                      ? EmptyStateWidget(
                          message: 'No Businesses Found',
                          description: _selectedCategory != 'All'
                              ? 'There are no businesses in the "$_selectedCategory" category yet.'
                              : 'No businesses found. Try a different search term.',
                          icon: Icons.business,
                          actionLabel: 'Clear Search',
                          onActionPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                              _selectedCategory = 'All';
                              _filterBusinesses();
                            });
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 24),
                          itemCount: _filteredBusinesses.length,
                          itemBuilder: (context, index) {
                            final business = _filteredBusinesses[index];
                            // TODO: Implement BusinessCard widget
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text(business.name),
                                subtitle: Text(business.description),
                                onTap: () => _showBusinessDetail(business),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class BusinessDetailScreen extends StatelessWidget {
  final Business business;
  
  const BusinessDetailScreen({Key? key, required this.business}) : super(key: key);
  
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Business header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Business logo or placeholder
                  business.logoUrl != null
                      ? Image.network(
                          business.logoUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.business_rounded,
                            size: 80,
                            color: theme.colorScheme.primary.withOpacity(0.7),
                          ),
                        ),
                  // Gradient overlay
                  Container(
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
                  // Business name
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      business.name,
                      style: theme.textTheme.headlineSmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: theme.colorScheme.surface,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () {
                  // Share functionality would be implemented in a full version
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share functionality would be implemented in a full version')),
                  );
                },
              ),
            ],
          ),
          
          // Business information
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          business.category,
                          style: theme.textTheme.labelSmall!.copyWith(
                            color: theme.colorScheme.onSecondary,
                          ),
                        ),
                        backgroundColor: theme.colorScheme.secondary,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      ...business.tags.map((tag) => Chip(
                            label: Text(
                              tag,
                              style: theme.textTheme.labelSmall,
                            ),
                            backgroundColor: theme.colorScheme.surface,
                            side: BorderSide(color: theme.colorScheme.outline),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    'About the Business',
                    style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    business.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  
                  // Contact information
                  Text(
                    'Contact Information',
                    style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(context, business),
                  
                  // Scripture for businesses
                  const SizedBox(height: 24),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.format_quote,
                            size: 24,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '"Whatever you do, work at it with all your heart, as working for the Lord, not for human masters."',
                            style: theme.textTheme.bodyMedium!.copyWith(
                              fontStyle: FontStyle.italic,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Colossians 3:23',
                            style: theme.textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Similar businesses section would go here in a full implementation
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactCard(BuildContext context, Business business) {
    final theme = Theme.of(context);
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (business.website != null) ...[  
              _buildContactItem(
                context,
                icon: Icons.language_rounded,
                title: 'Website',
                value: business.website!,
                onTap: () => _launchUrl('https://${business.website}'),
              ),
              const Divider(height: 16),
            ],
            if (business.email != null) ...[  
              _buildContactItem(
                context,
                icon: Icons.email_rounded,
                title: 'Email',
                value: business.email!,
                onTap: () => _launchUrl('mailto:${business.email}'),
              ),
              const Divider(height: 16),
            ],
            if (business.phoneNumber != null) ...[  
              _buildContactItem(
                context,
                icon: Icons.phone_rounded,
                title: 'Phone',
                value: business.phoneNumber!,
                onTap: () => _launchUrl('tel:${business.phoneNumber}'),
              ),
            ],
            if (business.website == null && business.email == null && business.phoneNumber == null)
              Text(
                'No contact information available',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContactItem(BuildContext context, {required IconData icon, required String title, required String value, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}