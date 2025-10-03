import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/analytics_provider.dart';
import '../providers/contact_provider.dart';
import '../providers/interaction_provider.dart';
import '../widgets/loading_widget.dart';
import '../widgets/out_of_touch_contact_card.dart';
import 'needs_attention_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('Analytics'),
              pinned: true,
              expandedHeight: 180,
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
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.white,
                    tabs: const [
                      Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
                      Tab(text: 'Contacts', icon: Icon(Icons.people)),
                      Tab(text: 'Interactions', icon: Icon(Icons.chat)),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildContactsTab(),
            _buildInteractionsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<AnalyticsProvider>().loadOutOfTouchContacts();
        await context.read<ContactProvider>().loadContacts();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHealthScoreCard(),
          const SizedBox(height: 16),
          _buildUrgencyDistributionCard(),
          const SizedBox(height: 16),
          _buildOutOfTouchListCard(),
        ],
      ),
    );
  }

  Widget _buildContactsTab() {
    return Consumer<ContactProvider>(
      builder: (context, contactProvider, child) {
        if (contactProvider.isLoading) {
          return const LoadingCard();
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildContactsOverviewCard(),
            const SizedBox(height: 16),
            _buildGroupDistributionCard(),
            const SizedBox(height: 16),
            _buildRecentContactsCard(),
          ],
        );
      },
    );
  }

  Widget _buildInteractionsTab() {
    return Consumer<InteractionProvider>(
      builder: (context, interactionProvider, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInteractionsOverviewCard(),
            const SizedBox(height: 16),
            _buildInteractionTypesCard(),
            const SizedBox(height: 16),
            _buildInitiationRatioCard(),
          ],
        );
      },
    );
  }

  Widget _buildHealthScoreCard() {
    return Consumer<AnalyticsProvider>(
      builder: (context, analyticsProvider, child) {
        if (analyticsProvider.isLoading) {
          return const LoadingCard();
        }

        final analytics = analyticsProvider.analytics;
        final healthScore = analytics['overallHealthScore'] ?? 100.0;
        final scoreColor = analyticsProvider.getHealthScoreColor(healthScore);
        final scoreLabel = analyticsProvider.getHealthScoreLabel(healthScore);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Relationship Health Score',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    height: 150,
                    width: 150,
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            startDegreeOffset: -90,
                            sectionsSpace: 0,
                            centerSpaceRadius: 50,
                            sections: [
                              PieChartSectionData(
                                color: scoreColor,
                                value: healthScore,
                                title: '',
                                radius: 20,
                              ),
                              PieChartSectionData(
                                color: Colors.grey.withOpacity(0.2),
                                value: (100 - healthScore).toDouble(),
                                title: '',
                                radius: 20,
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${healthScore.round()}%',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: scoreColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                scoreLabel,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scoreColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildScoreLegend(analytics),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreLegend(Map<String, dynamic> analytics) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('Urgent', analytics['urgentCount'] ?? 0, Colors.red),
        _buildLegendItem('Moderate', analytics['moderateCount'] ?? 0, Colors.orange),
        _buildLegendItem('Good', analytics['lowCount'] ?? 0, Colors.green),
      ],
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildUrgencyDistributionCard() {
    return Consumer<AnalyticsProvider>(
      builder: (context, analyticsProvider, child) {
        if (analyticsProvider.isLoading) {
          return const LoadingCard();
        }

        final urgencyDistribution = analyticsProvider.analytics['urgencyDistribution'] as Map<String, int>? ?? {};

        if (urgencyDistribution.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attention Priority Distribution',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: _createUrgencyBars(urgencyDistribution),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const titles = ['Urgent', 'Moderate', 'Low'];
                              if (value.toInt() < titles.length) {
                                return Text(
                                  titles[value.toInt()],
                                  style: Theme.of(context).textTheme.bodySmall,
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<BarChartGroupData> _createUrgencyBars(Map<String, int> urgencyDistribution) {
    final urgentCount = urgencyDistribution['Urgent'] ?? 0;
    final moderateCount = urgencyDistribution['Moderate'] ?? 0;
    final lowCount = urgencyDistribution['Low'] ?? 0;

    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: urgentCount.toDouble(),
            color: Colors.red,
            width: 30,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: moderateCount.toDouble(),
            color: Colors.orange,
            width: 30,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: lowCount.toDouble(),
            color: Colors.green,
            width: 30,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      ),
    ];
  }

  Widget _buildOutOfTouchListCard() {
    return Consumer<AnalyticsProvider>(
      builder: (context, analyticsProvider, child) {
        if (analyticsProvider.isLoading) {
          return const LoadingCard();
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
                      'Contacts Needing Attention',
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
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('All contacts are up to date! 🎉'),
                    ),
                  )
                else
                  ...outOfTouchContacts.take(5).map((contact) => OutOfTouchContactCard(contact: contact)),
                if (outOfTouchContacts.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'And ${outOfTouchContacts.length - 5} more...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactsOverviewCard() {
    return Consumer<ContactProvider>(
      builder: (context, contactProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contacts Overview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        'Total Contacts',
                        contactProvider.totalContacts.toString(),
                        Icons.people_rounded,
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        'Total Groups',
                        contactProvider.totalGroups.toString(),
                        Icons.group_rounded,
                        Theme.of(context).colorScheme.tertiary,
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

  Widget _buildGroupDistributionCard() {
    return Consumer<ContactProvider>(
      builder: (context, contactProvider, child) {
        final contactsByGroup = contactProvider.contactsByGroup;

        if (contactsByGroup.isEmpty) {
          return const SizedBox.shrink();
        }

        final sortedGroups = contactsByGroup.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contacts by Group',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ...sortedGroups.take(5).map((entry) {
                  final percentage = (entry.value / contactProvider.totalContacts * 100).round();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          '${entry.value} ($percentage%)',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentContactsCard() {
    return Consumer<ContactProvider>(
      builder: (context, contactProvider, child) {
        final recentContacts = contactProvider.getRecentContacts();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Contacts',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                if (recentContacts.isEmpty)
                  const Text('No contacts yet')
                else
                  ...recentContacts.map((contact) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        contact.nickName.isNotEmpty
                            ? contact.nickName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(contact.nickName),
                    subtitle: Text(contact.group),
                    contentPadding: EdgeInsets.zero,
                  )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInteractionsOverviewCard() {
    return Consumer<InteractionProvider>(
      builder: (context, interactionProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interactions Overview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        'Total Interactions',
                        interactionProvider.totalInteractions.toString(),
                        Icons.chat_bubble_rounded,
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        'Self-Initiated',
                        '${interactionProvider.selfInitiatedPercentage.round()}%',
                        Icons.person_rounded,
                        Theme.of(context).colorScheme.secondary,
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

  Widget _buildInteractionTypesCard() {
    return Consumer<InteractionProvider>(
      builder: (context, interactionProvider, child) {
        final typeCounts = interactionProvider.getInteractionCountsByType();

        if (typeCounts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interaction Types',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ...typeCounts.entries.map((entry) {
                  final percentage = (entry.value / interactionProvider.totalInteractions * 100).round();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          '${entry.value} ($percentage%)',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInitiationRatioCard() {
    return Consumer<InteractionProvider>(
      builder: (context, interactionProvider, child) {
        if (interactionProvider.totalInteractions == 0) {
          return const SizedBox.shrink();
        }

        final selfInitiatedCount = interactionProvider.selfInitiatedCount;
        final otherInitiatedCount = interactionProvider.otherInitiatedCount;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Initiation Ratio',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    height: 150,
                    width: 150,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            color: Theme.of(context).colorScheme.primary,
                            value: selfInitiatedCount.toDouble(),
                            title: '${(selfInitiatedCount / interactionProvider.totalInteractions * 100).round()}%',
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: Theme.of(context).colorScheme.secondary,
                            value: otherInitiatedCount.toDouble(),
                            title: '${(otherInitiatedCount / interactionProvider.totalInteractions * 100).round()}%',
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem('You Initiated', selfInitiatedCount, Theme.of(context).colorScheme.primary),
                    _buildLegendItem('They Initiated', otherInitiatedCount, Theme.of(context).colorScheme.secondary),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

}