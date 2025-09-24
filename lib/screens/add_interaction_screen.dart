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
      appBar: AppBar(
        title: const Text(
          'Add Interaction',
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedContact,
                      hint: const Text('Select Contact', style: TextStyle(fontFamily: 'Montserrat')),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 18, fontFamily: 'Montserrat', color: Colors.black87),
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
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.forum_outlined),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 18, fontFamily: 'Montserrat', color: Colors.black87),
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
                      title: const Text(
                        "Interaction Time",
                        style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        DateFormat.yMMMd().add_jm().format(_selectedDateTime),
                        style: const TextStyle(fontFamily: 'Montserrat'),
                      ),
                      trailing: Icon(Icons.calendar_today, color: Colors.amber[700]),
                      onTap: _pickDateTime,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'I initiated the interaction',
                          style: TextStyle(fontFamily: 'Montserrat'),
                        ),
                        Switch(
                          value: _selfInitiated,
                          activeColor: Colors.deepPurpleAccent,
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
                        prefixIcon: Icon(Icons.note_alt_outlined),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 18, fontFamily: 'Montserrat'),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.amber[700],
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber[700]!.withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _submitForm,
                          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                          label: const Text(
                            'Add Interaction',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1.1,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}