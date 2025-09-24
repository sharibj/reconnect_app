import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/contact.dart';
import '../models/interaction.dart';
import '../services/api_service.dart';
import 'add_interaction_screen.dart';

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
      _loadInteractions();
    }
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
    if (_selectedContact == null) return;

    setState(() {
      _isLoading = true;
      _interactions.clear();
      _currentPage = 0;
      _hasMoreData = true;
    });

    try {
      final interactions = await _apiService.getContactInteractions(_selectedContact!, _currentPage, _pageSize);
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
    if (_selectedContact == null || _isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final moreInteractions = await _apiService.getContactInteractions(
        _selectedContact!,
        _currentPage + 1,
        _pageSize
      );

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

  Widget _buildInteractionCard(Interaction interaction, int index) {
    final DateTime date = interaction.timeStamp;
    final String formattedDate = DateFormat.yMMMd().add_jm().format(date);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber[700]?.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    interaction.interactionDetails.type,
                    style: TextStyle(
                      color: Colors.amber[700],
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      interaction.interactionDetails.selfInitiated
                        ? 'Initiated by me'
                        : 'They initiated',
                      style: TextStyle(
                        fontSize: 12,
                        color: interaction.interactionDetails.selfInitiated
                          ? Colors.green
                          : Colors.blue,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _deleteInteraction(interaction, index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.red[400],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Montserrat',
              ),
            ),
            if (interaction.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                interaction.notes,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Interactions',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.amber[700],
        elevation: 2,
      ),
      body: Container(
        color: Colors.amber[50],
        child: Column(
          children: [
            // Contact Selection Dropdown
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedContact,
                hint: const Text(
                  'Select a contact to view interactions',
                  style: TextStyle(fontFamily: 'Montserrat'),
                ),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                  labelText: 'Contact',
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  color: Colors.black87,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedContact = newValue;
                  });
                  _loadInteractions();
                },
                items: () {
                  // Create a sorted copy of contacts for the dropdown
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
            ),

            // Add Interaction Button (only show when contact is selected)
            if (_selectedContact != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _navigateToAddInteraction,
                  icon: const Icon(Icons.add_circle, color: Colors.white),
                  label: Text(
                    'Add Interaction for $_selectedContact',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),

            // Interactions List
            Expanded(
              child: _selectedContact == null
                  ? const Center(
                      child: Text(
                        'Please select a contact to view interactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Montserrat',
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.amber,
                          ),
                        )
                      : _interactions.isEmpty
                          ? const Center(
                              child: Text(
                                'No interactions found for this contact',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Montserrat',
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: _interactions.length + (_isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _interactions.length) {
                                  // Loading indicator at the bottom
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(
                                        color: Colors.amber,
                                      ),
                                    ),
                                  );
                                }
                                return _buildInteractionCard(_interactions[index], index);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
