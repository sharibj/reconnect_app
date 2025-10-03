import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contact_provider.dart';
import '../widgets/loading_widget.dart';
import 'add_contact_screen.dart';
import 'add_group_screen.dart';
import 'contact_detail_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactProvider>().loadContacts();
      context.read<ContactProvider>().loadGroups();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('Contacts'),
              floating: true,
              pinned: true,
              expandedHeight: 160,
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
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(100),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 12),
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        indicatorColor: Colors.white,
                        tabs: const [
                          Tab(text: 'Contacts', icon: Icon(Icons.people)),
                          Tab(text: 'Groups', icon: Icon(Icons.group)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildContactsTab(),
            _buildGroupsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOptions(context),
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Consumer<ContactProvider>(
      builder: (context, contactProvider, child) {
        return TextField(
          controller: _searchController,
          onChanged: (value) {
            contactProvider.setSearchQuery(value);
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search contacts...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.7)),
                    onPressed: () {
                      _searchController.clear();
                      contactProvider.setSearchQuery('');
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        );
      },
    );
  }

  Widget _buildContactsTab() {
    return Consumer<ContactProvider>(
      builder: (context, contactProvider, child) {
        if (contactProvider.isLoading) {
          return const ContactLoadingGrid();
        }

        final contacts = contactProvider.contacts;

        if (contacts.isEmpty) {
          return _buildEmptyState(
            icon: Icons.people_outline,
            title: 'No contacts found',
            subtitle: contactProvider.searchQuery.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'Add your first contact to get started',
            actionLabel: 'Add Contact',
            onAction: () => _navigateToAddContact(),
          );
        }

        return Column(
          children: [
            if (contactProvider.groups.isNotEmpty) _buildGroupFilter(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Added bottom padding for FAB
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return _buildContactCard(contact);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGroupFilter() {
    return Consumer<ContactProvider>(
      builder: (context, contactProvider, child) {
        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFilterChip('All', contactProvider.selectedGroup.isEmpty),
              ...contactProvider.groups.map((group) =>
                _buildFilterChip(group.name, contactProvider.selectedGroup == group.name)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          final contactProvider = context.read<ContactProvider>();
          contactProvider.setSelectedGroup(selected ? label : '');
        },
        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        checkmarkColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildContactCard(contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToContactDetail(contact),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(
                  tag: 'contact-${contact.nickName}',
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.tertiary,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        contact.nickName.isNotEmpty
                            ? contact.nickName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.nickName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${contact.details.firstName} ${contact.details.lastName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    contact.group,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsTab() {
    return Consumer<ContactProvider>(
      builder: (context, contactProvider, child) {
        if (contactProvider.isLoading) {
          return const LoadingCard();
        }

        final groups = contactProvider.groups;
        final contactsByGroup = contactProvider.contactsByGroup;

        if (groups.isEmpty) {
          return _buildEmptyState(
            icon: Icons.group_outlined,
            title: 'No groups found',
            subtitle: 'Create groups to organize your contacts',
            actionLabel: 'Add Group',
            onAction: () => _navigateToAddGroup(),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Added bottom padding for FAB
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            final contactCount = contactsByGroup[group.name] ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    contactProvider.setSelectedGroup(group.name);
                    _tabController.animateTo(0);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.tertiary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.group_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Contact every ${group.frequencyInDays} days',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$contactCount',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Add Contact'),
                subtitle: const Text('Add a new person to your contacts'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToAddContact();
                },
              ),
              ListTile(
                leading: const Icon(Icons.group_add),
                title: const Text('Add Group'),
                subtitle: const Text('Create a new group to organize contacts'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToAddGroup();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToAddContact() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddContactScreen()),
    );
    if (result == true) {
      context.read<ContactProvider>().loadContacts();
    }
  }

  void _navigateToAddGroup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddGroupScreen()),
    );
    if (result == true) {
      context.read<ContactProvider>().loadGroups();
    }
  }

  void _navigateToContactDetail(contact) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactDetailScreen(contact: contact),
      ),
    );
    if (result == true) {
      context.read<ContactProvider>().loadContacts();
    }
  }
}