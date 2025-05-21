import 'package:flutter/material.dart';
import 'package:dreamflow/services/dev_mode_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DevModeScreen extends StatefulWidget {
  const DevModeScreen({Key? key}) : super(key: key);

  @override
  State<DevModeScreen> createState() => _DevModeScreenState();
}

class _DevModeScreenState extends State<DevModeScreen> {
  bool _isDevModeEnabled = false;
  bool _bypassPayment = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final devModeEnabled = await DevModeService.isDevModeEnabled();
    final bypassPayment = await DevModeService.shouldBypassPayment();
    
    if (mounted) {
      setState(() {
        _isDevModeEnabled = devModeEnabled;
        _bypassPayment = bypassPayment;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleDevMode(bool value) async {
    setState(() {
      _isLoading = true;
    });
    
    await DevModeService.setDevModeEnabled(value);
    
    // If turning off dev mode, also turn off all other dev settings
    if (!value) {
      await DevModeService.setBypassPayment(false);
    }
    
    await _loadSettings();
  }

  Future<void> _toggleBypassPayment(bool value) async {
    setState(() {
      _isLoading = true;
    });
    
    await DevModeService.setBypassPayment(value);
    await _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Options'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWarningCard(),
                  SizedBox(height: 24.h),
                  Text(
                    'Developer Mode Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 16.h),
                  _buildSettingsCard(),
                  SizedBox(height: 24.h),
                  _buildDocumentation(),
                ],
              ),
            ),
    );
  }

  Widget _buildWarningCard() {
    return Card(
      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: Theme.of(context).colorScheme.error,
                  size: 24.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Warning',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Developer mode is for testing purposes only. These settings should not be enabled in production.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text(
                'Enable Developer Mode',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                'Master toggle for all developer features',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: _isDevModeEnabled,
              onChanged: _toggleDevMode,
              activeColor: Theme.of(context).colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
            Divider(),
            SwitchListTile(
              title: Text(
                'Bypass Payment Verification',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _isDevModeEnabled
                          ? null
                          : Theme.of(context).disabledColor,
                    ),
              ),
              subtitle: Text(
                'Skip payment checks when creating communities',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _isDevModeEnabled
                          ? null
                          : Theme.of(context).disabledColor,
                    ),
              ),
              value: _bypassPayment,
              onChanged: _isDevModeEnabled ? _toggleBypassPayment : null,
              activeColor: Theme.of(context).colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentation() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documentation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Bypass Payment Verification:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 4.h),
            Text(
              'When enabled, you can create communities without subscription or payment verification. This is useful for testing the community creation flow without having to enter payment information.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16.h),
            Text(
              'How to use:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 4.h),
            Text(
              '1. Enable Developer Mode\n2. Enable Bypass Payment Verification\n3. Return to the app and try creating a community',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}