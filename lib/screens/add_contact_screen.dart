import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../models/group.dart';
import '../services/api_service.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  // State for groups dropdown
  List<Group> _groups = [];
  String? _selectedGroup;

  // Controllers for the form fields
  final _nickNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() async {
    try {
      final groups = await apiService.getGroups();
      setState(() {
        _groups = groups;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load groups: $e')),
      );
    }
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _nickNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _notesController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedGroup == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a group')),
        );
        return;
      }
      final newContact = Contact(
        nickName: _nickNameController.text,
        group: _selectedGroup!,
        details: ContactDetails(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          notes: _notesController.text,
          contactInfo: ContactInfo(
            email: _emailController.text,
            phone: _phoneController.text,
            address: _addressController.text,
          ),
        ),
      );

      apiService.addContact(newContact).then((_) {
        Navigator.pop(context, true); // Pass true to indicate success
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add contact: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nickNameController,
                decoration: const InputDecoration(labelText: 'Nickname'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a nickname';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedGroup,
                hint: const Text('Select Group'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGroup = newValue;
                  });
                },
                items: _groups.map<DropdownMenuItem<String>>((Group group) {
                  return DropdownMenuItem<String>(
                    value: group.name,
                    child: Text(group.name),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Please select a group' : null,
              ),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}