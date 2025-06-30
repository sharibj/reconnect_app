import 'package:flutter/material.dart';
import 'add_contact_screen.dart';
import 'add_group_screen.dart';
import 'add_interaction_screen.dart';
import '../services/api_service.dart';
import '../models/reconnect_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  late Future<List<ReconnectModel>> futureOutOfTouchContacts;

  @override
  void initState() {
    super.initState();
    _loadOutOfTouchContacts();
  }

  void _loadOutOfTouchContacts() {
    setState(() {
      futureOutOfTouchContacts = apiService.getOutOfTouchContacts();
    });
  }

  void _navigateAndRefresh(Widget screen) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    if (result == true) {
      _loadOutOfTouchContacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconnect'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ReconnectModel>>(
              future: futureOutOfTouchContacts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No overdue contacts found.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final contact = snapshot.data![index];
                      final overdueStatus = contact.overdueStatus;
                      return ListTile(
                        title: Text(contact.nickName),
                        subtitle: Text(contact.group),
                        trailing: Text(
                          overdueStatus.status,
                          style: TextStyle(color: overdueStatus.color),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBigButton(
                  context,
                  label: 'Add Group',
                  icon: Icons.group_add,
                  onPressed: () => _navigateAndRefresh(const AddGroupScreen()),
                ),
                _buildBigButton(
                  context,
                  label: 'Add Contact',
                  icon: Icons.person_add,
                  onPressed: () => _navigateAndRefresh(const AddContactScreen()),
                ),
                _buildBigButton(
                  context,
                  label: 'Add Interaction',
                  icon: Icons.add_circle,
                  onPressed: () => _navigateAndRefresh(const AddInteractionScreen()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBigButton(BuildContext context, {required String label, required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 24),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}