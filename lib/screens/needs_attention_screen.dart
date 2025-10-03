import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';
import '../widgets/loading_widget.dart';
import '../widgets/out_of_touch_contact_card.dart';
import '../models/reconnect_model.dart';

class NeedsAttentionScreen extends StatefulWidget {
  const NeedsAttentionScreen({super.key});

  @override
  State<NeedsAttentionScreen> createState() => _NeedsAttentionScreenState();
}

class _NeedsAttentionScreenState extends State<NeedsAttentionScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _currentPage = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadOutOfTouchContacts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreContacts();
    }
  }

  Future<void> _loadMoreContacts() async {
    if (_isLoadingMore) return;

    final analyticsProvider = context.read<AnalyticsProvider>();
    final currentContacts = analyticsProvider.outOfTouchContacts;

    // For now, we'll simulate pagination by loading more data
    // In a real app, this would call an API with page parameters
    if (currentContacts.length >= (_currentPage + 1) * _pageSize) {
      setState(() {
        _isLoadingMore = true;
      });

      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _currentPage++;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _currentPage = 0;
    });
    await context.read<AnalyticsProvider>().loadOutOfTouchContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('Needs Attention'),
              pinned: true,
              expandedHeight: 140,
              toolbarHeight: 60,
              forceElevated: innerBoxIsScrolled,
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
          ];
        },
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: Consumer<AnalyticsProvider>(
            builder: (context, analyticsProvider, child) {
              if (analyticsProvider.isLoading) {
                return const InteractionLoadingList();
              }

              final outOfTouchContacts = analyticsProvider.outOfTouchContacts;

              if (outOfTouchContacts.isEmpty) {
                return _buildEmptyState();
              }

              return _buildContactsList(outOfTouchContacts);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration,
              size: 64,
              color: Colors.green.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
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
      ),
    );
  }

  Widget _buildContactsList(List<ReconnectModel> contacts) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: contacts.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == contacts.length) {
          return _buildLoadingIndicator();
        }

        final contact = contacts[index];
        return OutOfTouchContactCard(contact: contact);
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}