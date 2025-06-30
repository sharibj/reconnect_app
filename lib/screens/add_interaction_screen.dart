import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add `intl: ^0.19.0` to your pubspec.yaml
import '../models/contact.dart';
import '../models/interaction.dart';
import '../services/api_service.dart';

class AddInteractionScreen extends StatefulWidget {
  const AddInteractionScreen({super.key});

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
      appBar: AppBar(
        title: const Text('Add Interaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedContact,
                hint: const Text('Select Contact'),
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _interactionType,
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
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Interaction Time"),
                subtitle: Text(DateFormat.yMMMd().add_jm().format(_selectedDateTime)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('I initiated the interaction'),
                  Switch(
                    value: _selfInitiated,
                    onChanged: (bool value) {
                      setState(() {
                        _selfInitiated = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Interaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}