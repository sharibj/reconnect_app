import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_contact_screen.dart';
import 'add_group_screen.dart';
import 'add_interaction_screen.dart';
import 'view_interactions_screen.dart';
import 'analytics_screen.dart';
import 'needs_attention_screen.dart';
import 'contacts_screen.dart';
import 'login_screen.dart';
import '../services/api_service.dart';
import '../models/reconnect_model.dart';
import '../providers/analytics_provider.dart';
import '../providers/contact_provider.dart';
import '../widgets/loading_widget.dart';
import '../widgets/app_logo.dart';
import '../widgets/out_of_touch_contact_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final username = await apiService.getUsername();
    if (mounted) {
      setState(() {
        _username = username ?? '';
      });
    }
  }

  Future<void> _refreshData() async {
    await context.read<AnalyticsProvider>().loadOutOfTouchContacts();
    await context.read<ContactProvider>().loadContacts();
  }

  void _navigateAndRefresh(Widget screen) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    if (result == true) {
      _refreshData();
    }
  }

  Future<void> _logout() async {
    try {
      await apiService.logout();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLogo(size: 28),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        _username.isNotEmpty
                          ? 'Welcome back, $_username!'
                          : 'Welcome back!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                  tooltip: 'Logout',
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildOutOfTouchSection(),
                  const SizedBox(height: 24),
                  _buildDashboardStats(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardStats() {
    return Consumer2<AnalyticsProvider, ContactProvider>(
      builder: (context, analyticsProvider, contactProvider, child) {
        if (analyticsProvider.isLoading || contactProvider.isLoading) {
          return const LoadingCard();
        }

        final analytics = analyticsProvider.analytics;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Contacts',
                        '${contactProvider.totalContacts}',
                        Icons.people,
                        Theme.of(context).colorScheme.primary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ContactsScreen(initialTabIndex: 0),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Out of Touch',
                        '${analytics['totalOutOfTouch'] ?? 0}',
                        Icons.schedule,
                        Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NeedsAttentionScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Groups',
                        '${contactProvider.totalGroups}',
                        Icons.group,
                        Theme.of(context).colorScheme.tertiary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ContactsScreen(initialTabIndex: 1),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Health Score',
                        '${(analytics['overallHealthScore'] ?? 100.0).round()}%',
                        Icons.favorite,
                        analyticsProvider.getHealthScoreColor(analytics['overallHealthScore'] ?? 100.0),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AnalyticsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildActionButton(
                  'Add Contact',
                  Icons.person_add_rounded,
                  Theme.of(context).colorScheme.primary,
                  () => _navigateAndRefresh(const AddContactScreen()),
                ),
                _buildActionButton(
                  'Add Group',
                  Icons.group_add_rounded,
                  Theme.of(context).colorScheme.tertiary,
                  () => _navigateAndRefresh(const AddGroupScreen()),
                ),
                _buildActionButton(
                  'Log Interaction',
                  Icons.add_circle_rounded,
                  Theme.of(context).colorScheme.secondary,
                  () => _navigateAndRefresh(const AddInteractionScreen()),
                ),
                _buildActionButton(
                  'View All',
                  Icons.visibility_rounded,
                  const Color(0xFF4CAF50), // Green color that's always vibrant
                  () => _navigateAndRefresh(const ViewInteractionsScreen()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutOfTouchSection() {
    return Consumer<AnalyticsProvider>(
      builder: (context, analyticsProvider, child) {
        if (analyticsProvider.isLoading) {
          return const InteractionLoadingList();
        }

        final outOfTouchContacts = analyticsProvider.outOfTouchContacts;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Needs Attention',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (outOfTouchContacts.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NeedsAttentionScreen(),
                            ),
                          );
                        },
                        child: const Text('View All'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (outOfTouchContacts.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.celebration,
                          size: 48,
                          color: Colors.green.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Great job! 🎉',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You\'re staying connected with all your contacts',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...outOfTouchContacts.take(5).map((contact) => OutOfTouchContactCard(
                    contact: contact,
                    onTap: () => _navigateAndRefresh(ViewInteractionsScreen(preselectedContactNickName: contact.nickName)),
                  )),
              ],
            ),
          ),
        );
      },
    );
  }

}