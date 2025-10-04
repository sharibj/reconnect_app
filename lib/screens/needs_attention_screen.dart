import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';
import '../widgets/loading_widget.dart';
import '../widgets/out_of_touch_contact_card.dart';
import '../models/reconnect_model.dart';

class NeedsAttentionScreen extends StatefulWidget {
  final String? initialPriority;

  const NeedsAttentionScreen({super.key, this.initialPriority});

  @override
  State<NeedsAttentionScreen> createState() => _NeedsAttentionScreenState();
}

class _NeedsAttentionScreenState extends State<NeedsAttentionScreen> {
  final ScrollController _listScrollController = ScrollController();
  bool _isLoadingMore = false;
  int _currentPage = 0;
  final int _pageSize = 20;
  String _selectedPriority = 'All';

  @override
  void initState() {
    super.initState();
    _selectedPriority = widget.initialPriority ?? 'All';
    _listScrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadOutOfTouchContacts();
    });
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_listScrollController.position.pixels >= _listScrollController.position.maxScrollExtent - 200) {
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
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('Needs Attention'),
              pinned: true,
              toolbarHeight: 60,
              forceElevated: innerBoxIsScrolled,
              backgroundColor: Theme.of(context).colorScheme.primary,
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

              final outOfTouchContacts = _getFilteredContacts(analyticsProvider);

              if (outOfTouchContacts.isEmpty) {
                return _buildEmptyState();
              }

              return _buildContactsList(outOfTouchContacts, analyticsProvider);
            },
          ),
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

  Widget _buildContactsList(List<ReconnectModel> contacts, AnalyticsProvider analyticsProvider) {
    return Column(
      children: [
        Container(
          height: 60,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: _buildPriorityFilter(analyticsProvider),
        ),
        Expanded(
          child: ListView.builder(
            controller: _listScrollController,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: contacts.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == contacts.length) {
                return _buildLoadingIndicator();
              }

              final contact = contacts[index];
              return OutOfTouchContactCard(contact: contact);
            },
          ),
        ),
      ],
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

  Widget _buildPriorityFilter(AnalyticsProvider analyticsProvider) {
    final totalContacts = analyticsProvider.outOfTouchContacts.length;
    final criticalCount = analyticsProvider.getContactsByUrgency('urgent').length;
    final moderateCount = analyticsProvider.getContactsByUrgency('moderate').length;
    final minorCount = analyticsProvider.getContactsByUrgency('low').length;

    // Auto-reset to 'All' if currently selected filter has no contacts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedPriority != 'All') {
        int currentCount = 0;
        switch (_selectedPriority) {
          case 'Critical':
            currentCount = criticalCount;
            break;
          case 'Moderate':
            currentCount = moderateCount;
            break;
          case 'Minor':
            currentCount = minorCount;
            break;
        }
        if (currentCount == 0 && mounted) {
          setState(() {
            _selectedPriority = 'All';
          });
        }
      }
    });

    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _buildFilterChip('All', null, totalContacts),
        const SizedBox(width: 8),
        _buildFilterChip('Critical', Colors.red, criticalCount),
        const SizedBox(width: 8),
        _buildFilterChip('Moderate', Colors.orange, moderateCount),
        const SizedBox(width: 8),
        _buildFilterChip('Minor', Colors.green, minorCount),
      ],
    );
  }

  Widget _buildFilterChip(String label, Color? color, int count) {
    final isSelected = _selectedPriority == label;
    final isEnabled = count > 0;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isEnabled ? color : color.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text('$label ($count)'),
          ],
        ),
        selected: isSelected && isEnabled,
        onSelected: isEnabled ? (selected) {
          setState(() {
            _selectedPriority = selected ? label : 'All';
          });
        } : null,
        backgroundColor: isEnabled
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.surface.withOpacity(0.5),
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
        checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
        labelStyle: TextStyle(
          color: isEnabled
              ? (isSelected
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurface)
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isEnabled
              ? (isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline)
              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        elevation: isSelected && isEnabled ? 2 : 0,
      ),
    );
  }

  List<ReconnectModel> _getFilteredContacts(AnalyticsProvider analyticsProvider) {
    switch (_selectedPriority) {
      case 'Critical':
        return analyticsProvider.getContactsByUrgency('urgent');
      case 'Moderate':
        return analyticsProvider.getContactsByUrgency('moderate');
      case 'Minor':
        return analyticsProvider.getContactsByUrgency('low');
      default:
        return analyticsProvider.outOfTouchContacts;
    }
  }
}