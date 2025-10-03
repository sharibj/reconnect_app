import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../models/group.dart';
import '../services/api_service.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
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
        title: Text(
          'Add Contact',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nickNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nickname',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a nickname';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGroup,
                      hint: const Text('Select Group'),
                      decoration: const InputDecoration(
                        labelText: 'Group',
                        prefixIcon: Icon(Icons.group_rounded),
                        filled: true,
                      ),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(Icons.badge_outlined),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: Icon(Icons.badge),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        prefixIcon: Icon(Icons.note_alt_outlined),
                        filled: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        filled: true,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone_outlined),
                        filled: true,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.home_outlined),
                        filled: true,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.person_add_rounded),
                        label: Text(
                          'Add Contact',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
        ),
      ),
    );
  }
}