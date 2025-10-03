import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'contacts_screen.dart';
import 'analytics_screen.dart';
import 'interactions_screen.dart';
import 'settings_screen.dart';
import '../providers/contact_provider.dart';
import '../providers/interaction_provider.dart';
import '../providers/analytics_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ContactsScreen(),
    const InteractionsScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load data completely asynchronously to avoid blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataAsync();
    });
  }

  void _loadDataAsync() {
    // Fire all loading operations without awaiting to keep UI responsive
    context.read<ContactProvider>().loadContacts();
    context.read<ContactProvider>().loadGroups();
    context.read<InteractionProvider>().loadAllInteractions();
    context.read<AnalyticsProvider>().loadOutOfTouchContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Contacts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Interactions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined),
                activeIcon: Icon(Icons.analytics),
                label: 'Analytics',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}