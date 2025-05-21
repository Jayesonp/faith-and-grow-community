import 'package:flutter/material.dart';
import 'package:dreamflow/services/import_service.dart';
import 'package:dreamflow/widgets/common_widgets.dart';

class MembershipImportScreen extends StatefulWidget {
  const MembershipImportScreen({Key? key}) : super(key: key);

  @override
  State<MembershipImportScreen> createState() => _MembershipImportScreenState();
}

class _MembershipImportScreenState extends State<MembershipImportScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _jsonController = TextEditingController();
  bool _isLoading = false;
  String _resultMessage = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _jsonController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _importMemberships() async {
    if (_jsonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid JSON data')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _resultMessage = '';
    });
    
    try {
      // Preprocess the JSON input to handle potential formatting issues
      String jsonInput = _jsonController.text.trim();
      
      // Debug message to show what we're importing
      print('Importing membership data: $jsonInput');
      
      final newMemberships = await ImportService.importMemberships(jsonInput);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _resultMessage = 'Successfully imported ${newMemberships.length} membership(s)';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _resultMessage = 'Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Scaffold(
          appBar: FaithAppBar(
            title: 'Import Memberships',
            showBackButton: true,
          ),
          body: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Card(
                  elevation: 0,
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.file_upload_outlined,
                          size: 32,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Import Memberships',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Paste JSON data below to import community memberships',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // JSON input area
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: TextField(
                              controller: _jsonController,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: 'Paste JSON data here...',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                              ),
                            ),
                          ),
                          if (_isLoading)
                            Positioned.fill(
                              child: Container(
                                color: theme.colorScheme.surface.withOpacity(0.7),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Result message
                if (_resultMessage.isNotEmpty) ...[  
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _resultMessage.startsWith('Error')
                          ? theme.colorScheme.error.withOpacity(0.1)
                          : theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _resultMessage.startsWith('Error')
                              ? theme.colorScheme.error.withOpacity(0.1)
                              : theme.colorScheme.primary.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _resultMessage.startsWith('Error') ? Icons.error_outline : Icons.check_circle_outline,
                          color: _resultMessage.startsWith('Error') ? theme.colorScheme.error : theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _resultMessage,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _resultMessage.startsWith('Error') ? theme.colorScheme.error : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _importMemberships,
                        icon: Icon(Icons.upload, color: theme.colorScheme.onPrimary),
                        label: Text(
                          _isLoading ? 'Importing...' : 'Import Memberships',
                          style: TextStyle(color: theme.colorScheme.onPrimary),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(
                        'Back',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: theme.colorScheme.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}