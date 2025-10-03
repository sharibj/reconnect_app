import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'export_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Settings'),
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              _buildSectionTitle('Appearance'),
              _buildThemeSettings(),
              const SizedBox(height: 24),
              _buildSectionTitle('Data & Export'),
              _buildDataSettings(),
              const SizedBox(height: 24),
              _buildSectionTitle('About'),
              _buildAboutSettings(),
              const SizedBox(height: 24),
              _buildSectionTitle('Account'),
              _buildAccountSettings(),
              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeSettings() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Dark Mode'),
                subtitle: Text(
                  themeProvider.isDarkMode ? 'Enabled' : 'Disabled',
                ),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Theme Mode'),
                subtitle: Text(_getThemeModeText(themeProvider.themeMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeModeDialog(themeProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataSettings() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.file_download,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Export Data'),
            subtitle: const Text('Export your contacts and interactions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToExport(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.share,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Share App'),
            subtitle: const Text('Tell your friends about Reconnect'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _shareApp(),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSettings() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.info,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('About Reconnect'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.privacy_tip,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Privacy Policy'),
            subtitle: const Text('How we protect your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _launchPrivacyPolicy(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.description,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Terms of Service'),
            subtitle: const Text('Terms and conditions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _launchTermsOfService(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.feedback,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Send Feedback'),
            subtitle: const Text('Help us improve the app'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _sendFeedback(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Sign out of your account'),
            trailing: const Icon(Icons.chevron_right, color: Colors.red),
            onTap: () => _showLogoutDialog(),
          ),
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Always Light';
      case ThemeMode.dark:
        return 'Always Dark';
      case ThemeMode.system:
        return 'Follow System';
    }
  }

  void _showThemeModeDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Always Light'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Always Dark'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Follow System'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToExport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExportScreen()),
    );
  }

  void _shareApp() {
    Share.share(
      'Check out Reconnect - the app that helps you stay connected with your contacts! '
      'Never lose touch with important people in your life.',
      subject: 'Reconnect App',
    );
  }


  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Reconnect',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.people,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [
        const Text(
          'Reconnect helps you maintain meaningful relationships by tracking your interactions '
          'with contacts and reminding you when it\'s time to reach out.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Built with Flutter and designed with love for staying connected.',
        ),
      ],
    );
  }

  Future<void> _launchPrivacyPolicy() async {
    // In a real app, this would link to your privacy policy
    const url = 'https://example.com/privacy';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchTermsOfService() async {
    // In a real app, this would link to your terms of service
    const url = 'https://example.com/terms';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _sendFeedback() async {
    const email = 'feedback@reconnectapp.com';
    const subject = 'Reconnect App Feedback';
    const body = 'Hi Reconnect team,\n\nI have some feedback about the app:\n\n';

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // Fallback to share
      Share.share(
        'Reconnect App Feedback:\n\n$body',
        subject: subject,
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout? You\'ll need to sign in again to access your data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _logout(),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    Navigator.pop(context); // Close dialog

    try {
      await _apiService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}