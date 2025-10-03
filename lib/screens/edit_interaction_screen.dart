import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/interaction.dart';
import '../models/contact.dart';
import '../providers/interaction_provider.dart';
import '../providers/contact_provider.dart';

class EditInteractionScreen extends StatefulWidget {
  final Interaction interaction;

  const EditInteractionScreen({super.key, required this.interaction});

  @override
  State<EditInteractionScreen> createState() => _EditInteractionScreenState();
}

class _EditInteractionScreenState extends State<EditInteractionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  String _selectedContact = '';
  String _selectedType = 'Text';
  bool _selfInitiated = true;
  DateTime _selectedDateTime = DateTime.now();
  List<Contact> _contacts = [];
  bool _isLoading = false;

  final List<String> _interactionTypes = [
    'Audio Call',
    'Video Call',
    'Text',
    'Social Media',
    'In Person',
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadContacts();
  }

  void _initializeForm() {
    _selectedContact = widget.interaction.contact;
    _selectedType = widget.interaction.interactionDetails.type;
    _selfInitiated = widget.interaction.interactionDetails.selfInitiated;
    _selectedDateTime = widget.interaction.timeStamp;
    _notesController.text = widget.interaction.notes;
  }

  Future<void> _loadContacts() async {
    final contactProvider = context.read<ContactProvider>();
    await contactProvider.loadContacts();
    setState(() {
      _contacts = contactProvider.contacts;
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Interaction'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveInteraction,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interaction Details',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedContact.isEmpty ? null : _selectedContact,
                      decoration: const InputDecoration(
                        labelText: 'Contact',
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _contacts.map((Contact contact) {
                        return DropdownMenuItem<String>(
                          value: contact.nickName,
                          child: Text(contact.nickName),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedContact = newValue ?? '';
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a contact';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Interaction Type',
                        prefixIcon: Icon(Icons.chat),
                      ),
                      items: _interactionTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedType = newValue ?? 'Text';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('I initiated this interaction'),
                      subtitle: Text(_selfInitiated ? 'You reached out first' : 'They reached out first'),
                      value: _selfInitiated,
                      onChanged: (bool value) {
                        setState(() {
                          _selfInitiated = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date & Time',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(DateFormat('EEEE, MMMM d, y').format(_selectedDateTime)),
                      subtitle: Text(DateFormat('h:mm a').format(_selectedDateTime)),
                      trailing: const Icon(Icons.edit),
                      onTap: _selectDateTime,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'What did you talk about?',
                        prefixIcon: Icon(Icons.note),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _showDeleteConfirmation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Interaction'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveInteraction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedInteraction = Interaction(
        id: widget.interaction.id,
        contact: _selectedContact,
        timeStamp: _selectedDateTime,
        notes: _notesController.text.trim(),
        interactionDetails: InteractionDetails(
          selfInitiated: _selfInitiated,
          type: _selectedType,
        ),
      );

      final success = await context.read<InteractionProvider>().updateInteraction(
        widget.interaction.id!,
        updatedInteraction,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interaction updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update interaction'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Interaction'),
        content: const Text(
          'Are you sure you want to delete this interaction? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteInteraction();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteInteraction() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await context.read<InteractionProvider>().deleteInteraction(
        widget.interaction.id!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interaction deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete interaction'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}