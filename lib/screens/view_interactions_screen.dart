import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/contact.dart';
import '../models/interaction.dart';
import '../services/api_service.dart';
import 'add_interaction_screen.dart';
import 'edit_interaction_screen.dart';

class ViewInteractionsScreen extends StatefulWidget {
  final String? preselectedContactNickName;

  const ViewInteractionsScreen({super.key, this.preselectedContactNickName});

  @override
  _ViewInteractionsScreenState createState() => _ViewInteractionsScreenState();
}

class _ViewInteractionsScreenState extends State<ViewInteractionsScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  List<Contact> _contacts = [];
  List<Interaction> _interactions = [];
  String? _selectedContact;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _scrollController.addListener(_onScroll);

    // Set the preselected contact if available
    if (widget.preselectedContactNickName != null) {
      _selectedContact = widget.preselectedContactNickName;
    }

    // Always load interactions (all interactions if no contact selected)
    _loadInteractions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreInteractions();
    }
  }

  void _loadContacts() async {
    try {
      final contacts = await _apiService.getContacts();
      setState(() {
        _contacts = contacts;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load contacts: $e')),
      );
    }
  }

  void _loadInteractions() async {
    setState(() {
      _isLoading = true;
      _interactions.clear();
      _currentPage = 0;
      _hasMoreData = true;
    });

    try {
      final List<Interaction> interactions;
      if (_selectedContact == null) {
        // Load all interactions when no contact is selected
        interactions = await _apiService.getAllInteractions(page: _currentPage, size: _pageSize);
      } else {
        // Load interactions for specific contact
        interactions = await _apiService.getContactInteractions(_selectedContact!, _currentPage, _pageSize);
      }

      setState(() {
        _interactions = interactions;
        _isLoading = false;
        _hasMoreData = interactions.length == _pageSize;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load interactions: $e')),
      );
    }
  }

  void _loadMoreInteractions() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final List<Interaction> moreInteractions;
      if (_selectedContact == null) {
        // Load more from all interactions
        moreInteractions = await _apiService.getAllInteractions(page: _currentPage + 1, size: _pageSize);
      } else {
        // Load more for specific contact
        moreInteractions = await _apiService.getContactInteractions(
          _selectedContact!,
          _currentPage + 1,
          _pageSize
        );
      }

      setState(() {
        _interactions.addAll(moreInteractions);
        _currentPage++;
        _isLoadingMore = false;
        _hasMoreData = moreInteractions.length == _pageSize;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load more interactions: $e')),
      );
    }
  }

  void _navigateToAddInteraction() async {
    if (_selectedContact == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddInteractionScreen(
          preselectedContactNickName: _selectedContact!,
        ),
      ),
    );

    // Refresh interactions list if an interaction was added
    if (result == true) {
      _loadInteractions();
    }
  }

  void _editInteraction(Interaction interaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditInteractionScreen(
          interaction: interaction,
        ),
      ),
    );

    // Refresh interactions list if the interaction was updated
    if (result == true) {
      _loadInteractions();
    }
  }

  Future<void> _deleteInteraction(Interaction interaction, int index) async {
    // Show confirmation dialog
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Interaction',
            style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to delete this interaction? This action cannot be undone.',
            style: TextStyle(fontFamily: 'Montserrat'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && interaction.id != null) {
      try {
        await _apiService.deleteInteraction(interaction.id!);

        // Remove the interaction from the local list
        setState(() {
          _interactions.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interaction deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete interaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('View Interactions'),
            floating: true,
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
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Contact Selection Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Contact',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedContact,
                          hint: const Text('Select a contact to view interactions'),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline_rounded),
                            filled: true,
                            labelText: 'Contact',
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedContact = newValue;
                            });
                            _loadInteractions();
                          },
                          items: () {
                            final sortedContacts = List<Contact>.from(_contacts)
                              ..sort((a, b) => a.nickName.toLowerCase().compareTo(b.nickName.toLowerCase()));

                            return sortedContacts.map<DropdownMenuItem<String>>((Contact contact) {
                              return DropdownMenuItem<String>(
                                value: contact.nickName,
                                child: Text(contact.nickName),
                              );
                            }).toList();
                          }(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Add Interaction Button
                if (_selectedContact != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _navigateToAddInteraction,
                          icon: const Icon(Icons.add_rounded),
                          label: Text('Add Interaction for $_selectedContact'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // Interactions Display
                if (_isLoading)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  )
                else if (_interactions.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Interactions Yet',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedContact == null
                              ? 'No interactions have been logged yet. Add some contacts and start logging your conversations!'
                              : 'Start logging conversations with $_selectedContact',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // Interactions List
                  ..._interactions.map((interaction) => _buildModernInteractionCard(interaction)).toList(),

                // Loading more indicator
                if (_isLoadingMore)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInteractionCard(Interaction interaction) {
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: interaction.interactionDetails.selfInitiated
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getInteractionIcon(interaction.interactionDetails.type),
                    color: interaction.interactionDetails.selfInitiated
                        ? Colors.green
                        : Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedContact == null) ...[
                        Text(
                          interaction.contact,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          interaction.interactionDetails.type,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else
                        Text(
                          interaction.interactionDetails.type,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      Text(
                        '$interactionDate at $interactionTime',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: interaction.interactionDetails.selfInitiated
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    interaction.interactionDetails.selfInitiated
                        ? 'You initiated'
                        : 'They initiated',
                    style: TextStyle(
                      color: interaction.interactionDetails.selfInitiated
                          ? Colors.green
                          : Colors.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit' && interaction.id != null) {
                      _editInteraction(interaction);
                    } else if (value == 'delete' && interaction.id != null) {
                      final index = _interactions.indexOf(interaction);
                      if (index != -1) {
                        _deleteInteraction(interaction, index);
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded, color: Colors.red),
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
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

  IconData _getInteractionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'audio call':
        return Icons.phone_rounded;
      case 'video call':
        return Icons.videocam_rounded;
      case 'text':
        return Icons.message_rounded;
      case 'social media':
        return Icons.share_rounded;
      case 'in person':
        return Icons.person_rounded;
      default:
        return Icons.chat_rounded;
    }
  }
}
