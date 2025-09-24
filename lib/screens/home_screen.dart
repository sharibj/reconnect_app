import 'package:flutter/material.dart';
import 'add_contact_screen.dart';
import 'add_group_screen.dart';
import 'add_interaction_screen.dart';
import 'view_interactions_screen.dart';
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
        title: const Text(
          'Reconnect',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.amber[700],
        elevation: 4,
      ),
      body: Container(
        color: Colors.amber[50],
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<ReconnectModel>>(
                future: futureOutOfTouchContacts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No overdue contacts found.',
                        style: TextStyle(color: Colors.white, fontFamily: 'Montserrat', fontSize: 18),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final contact = snapshot.data![index];
                        final overdueStatus = contact.overdueStatus;
                        return Card(
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            onTap: () {
                              _navigateAndRefresh(ViewInteractionsScreen(preselectedContactNickName: contact.nickName));
                            },
                            leading: CircleAvatar(
                              backgroundColor: Colors.amber[700],
                              child: Text(
                                contact.nickName.isNotEmpty ? contact.nickName[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                            title: Text(
                              contact.nickName,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              contact.group,
                              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: overdueStatus.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                overdueStatus.status,
                                style: TextStyle(
                                  color: overdueStatus.color,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 500) {
                    // Stack vertically for narrow screens
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBigButton(
                          context,
                          label: 'Add Group',
                          icon: Icons.group_add,
                          onPressed: () => _navigateAndRefresh(const AddGroupScreen()),
                        ),
                        const SizedBox(height: 12),
                        _buildBigButton(
                          context,
                          label: 'Add Contact',
                          icon: Icons.person_add,
                          onPressed: () => _navigateAndRefresh(const AddContactScreen()),
                        ),
                        const SizedBox(height: 12),
                        _buildBigButton(
                          context,
                          label: 'Add Interaction',
                          icon: Icons.add_circle,
                          onPressed: () => _navigateAndRefresh(const AddInteractionScreen()),
                        ),
                        const SizedBox(height: 12),
                        _buildBigButton(
                          context,
                          label: 'View Interactions',
                          icon: Icons.visibility,
                          onPressed: () => _navigateAndRefresh(const ViewInteractionsScreen()),
                        ),
                      ],
                    );
                  } else {
                    // Row for wide screens
                    return Row(
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
                        _buildBigButton(
                          context,
                          label: 'View Interactions',
                          icon: Icons.visibility,
                          onPressed: () => _navigateAndRefresh(const ViewInteractionsScreen()),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigButton(BuildContext context, {required String label, required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 1.1,
          color: Colors.white,
        ),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber[700],
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 6,
      ),
    );
  }
}