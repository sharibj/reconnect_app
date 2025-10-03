import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add `intl: ^0.19.0` to your pubspec.yaml
import '../models/contact.dart';
import '../models/interaction.dart';
import '../services/api_service.dart';

class AddInteractionScreen extends StatefulWidget {
  final String? preselectedContactNickName;

  const AddInteractionScreen({super.key, this.preselectedContactNickName});

  @override
  _AddInteractionScreenState createState() => _AddInteractionScreenState();
}

class _AddInteractionScreenState extends State<AddInteractionScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  String? _selectedContact;
  List<Contact> _contacts = [];
  bool _selfInitiated = true;
  String _interactionType = 'Audio Call';
  DateTime _selectedDateTime = DateTime.now();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _selectedContact = widget.preselectedContactNickName; // Set the preselected contact if available
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

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedContact == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a contact')),
        );
        return;
      }

      final newInteraction = Interaction(
        contact: _selectedContact!,
        timeStamp: _selectedDateTime, // Pass the DateTime object directly
        notes: _notesController.text,
        interactionDetails: InteractionDetails(
          selfInitiated: _selfInitiated,
          type: _interactionType,
        ),
      );

      _apiService.addInteraction(newInteraction).then((_) {
        Navigator.pop(context, true);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add interaction: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Add Interaction'),
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Information',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedContact,
                            hint: const Text('Select Contact'),
                            decoration: const InputDecoration(
                              labelText: 'Contact',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                              filled: true,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedContact = newValue;
                              });
                            },
                            items: _contacts.map<DropdownMenuItem<String>>((Contact contact) {
                              return DropdownMenuItem<String>(
                                value: contact.nickName,
                                child: Text(contact.nickName),
                              );
                            }).toList(),
                            validator: (value) => value == null ? 'Please select a contact' : null,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Interaction Details',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _interactionType,
                            decoration: const InputDecoration(
                              labelText: 'Interaction Type',
                              prefixIcon: Icon(Icons.forum_outlined),
                              filled: true,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                _interactionType = newValue!;
                              });
                            },
                            items: <String>['Audio Call', 'Video Call', 'Text', 'Social Media', 'In Person']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          Card(
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.access_time_rounded,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              title: const Text('Interaction Time'),
                              subtitle: Text(
                                DateFormat.yMMMd().add_jm().format(_selectedDateTime),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                              onTap: _pickDateTime,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Card(
                            child: SwitchListTile(
                              secondary: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _selfInitiated
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _selfInitiated ? Icons.call_made_rounded : Icons.call_received_rounded,
                                  color: _selfInitiated ? Colors.green : Colors.blue,
                                ),
                              ),
                              title: const Text('Who initiated?'),
                              subtitle: Text(_selfInitiated ? 'You reached out first' : 'They reached out first'),
                              value: _selfInitiated,
                              onChanged: (bool value) {
                                setState(() {
                                  _selfInitiated = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Additional Notes',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes (optional)',
                              prefixIcon: Icon(Icons.note_alt_outlined),
                              filled: true,
                              alignLabelWithHint: true,
                            ),
                            maxLines: 4,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _submitForm,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add Interaction'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
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
}