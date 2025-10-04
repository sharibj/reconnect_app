import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/interaction_provider.dart';
import '../providers/contact_provider.dart';
import '../widgets/loading_widget.dart';
import 'add_interaction_screen.dart';
import 'edit_interaction_screen.dart';

class InteractionsScreen extends StatefulWidget {
  const InteractionsScreen({super.key});

  @override
  State<InteractionsScreen> createState() => _InteractionsScreenState();
}

class _InteractionsScreenState extends State<InteractionsScreen> {
  String _selectedContact = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactProvider>().loadContacts();
      context.read<InteractionProvider>().loadInteractions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              title: const Text('Interactions'),
              pinned: true,
              toolbarHeight: 120,
              forceElevated: innerBoxIsScrolled,
              backgroundColor: Theme.of(context).colorScheme.primary,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildContactSelector(),
                      const SizedBox(height: 12),
                      _buildSearchBar(),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: _buildInteractionsList(),
      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "interactions_fab",
        onPressed: () => _navigateToAddInteraction(),
        label: const Text('Add Interaction'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContactSelector() {
    return Consumer<ContactProvider>(
      builder: (context, contactProvider, child) {
        final contacts = contactProvider.contacts;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: DropdownButton<String>(
            value: _selectedContact.isEmpty ? null : _selectedContact,
            hint: const Text(
              'All Contacts',
              style: TextStyle(color: Colors.white),
            ),
            isExpanded: true,
            underline: const SizedBox.shrink(),
            dropdownColor: Theme.of(context).colorScheme.surface,
            style: const TextStyle(color: Colors.white),
            items: [
              DropdownMenuItem<String>(
                value: '',
                child: Text(
                  'All Contacts',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              ...contacts.map((contact) => DropdownMenuItem<String>(
                value: contact.nickName,
                child: Text(
                  contact.nickName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedContact = value ?? '';
              });
              _loadInteractions();
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        // Implement search functionality
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search interactions...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.7)),
                onPressed: () {
                  _searchController.clear();
                  // Clear search
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildInteractionsList() {
    return Consumer<InteractionProvider>(
      builder: (context, interactionProvider, child) {
        if (interactionProvider.isLoading) {
          return const InteractionLoadingList();
        }

        final interactions = interactionProvider.interactions;

        if (interactions.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => _loadInteractions(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Added bottom padding for FAB
            itemCount: interactions.length,
            itemBuilder: (context, index) {
              final interaction = interactions[index];
              return _buildInteractionCard(interaction);
            },
          ),
        );
      },
    );
  }

  Widget _buildInteractionCard(interaction) {
    final interactionDate = DateFormat('MMM dd, yyyy').format(interaction.timeStamp);
    final interactionTime = DateFormat('HH:mm').format(interaction.timeStamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    interaction.contact.isNotEmpty
                        ? interaction.contact[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            interaction.contact,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: interaction.interactionDetails.selfInitiated
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              interaction.interactionDetails.selfInitiated ? 'You initiated' : 'They initiated',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: interaction.interactionDetails.selfInitiated
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _getInteractionIcon(interaction.interactionDetails.type),
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            interaction.interactionDetails.type,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$interactionDate at $interactionTime',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit' && interaction.id != null) {
                      _editInteraction(interaction);
                    } else if (value == 'delete' && interaction.id != null) {
                      _showDeleteConfirmation(interaction.id!);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (interaction.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  interaction.notes,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ],
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
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              _selectedContact.isEmpty
                  ? 'No interactions yet'
                  : 'No interactions with $_selectedContact',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start logging your conversations and meetings',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddInteraction(),
              icon: const Icon(Icons.add),
              label: const Text('Add Interaction'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getInteractionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'audio call':
        return Icons.phone;
      case 'video call':
        return Icons.videocam;
      case 'text':
        return Icons.message;
      case 'social media':
        return Icons.share;
      case 'in person':
        return Icons.person;
      default:
        return Icons.chat;
    }
  }

  Future<void> _loadInteractions() async {
    await context.read<InteractionProvider>().loadInteractions(
          contactNickname: _selectedContact.isEmpty ? null : _selectedContact,
        );
  }

  void _navigateToAddInteraction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddInteractionScreen()),
    );
    if (result == true) {
      _loadInteractions();
    }
  }

  void _editInteraction(interaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditInteractionScreen(interaction: interaction),
      ),
    );
    if (result == true) {
      _loadInteractions();
    }
  }

  void _showDeleteConfirmation(String interactionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Interaction'),
        content: const Text('Are you sure you want to delete this interaction? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<InteractionProvider>().deleteInteraction(interactionId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Interaction deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete interaction'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}