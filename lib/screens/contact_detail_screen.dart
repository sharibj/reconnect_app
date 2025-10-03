import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact.dart';
import 'view_interactions_screen.dart';
import 'edit_contact_screen.dart';

class ContactDetailScreen extends StatelessWidget {
  final Contact contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editContact(context),
                tooltip: 'Edit Contact',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(contact.nickName),
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
                child: Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Text(
                      contact.nickName.isNotEmpty
                          ? contact.nickName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildBasicInfoCard(context),
                const SizedBox(height: 16),
                _buildContactInfoCard(context),
                const SizedBox(height: 16),
                if (contact.details.notes.isNotEmpty) _buildNotesCard(context),
                if (contact.details.notes.isNotEmpty) const SizedBox(height: 16),
                _buildActionsCard(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              'Full Name',
              '${contact.details.firstName} ${contact.details.lastName}',
              Icons.person,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Nickname',
              contact.nickName,
              Icons.badge,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Group',
              contact.group,
              Icons.group,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard(BuildContext context) {
    final hasEmail = contact.details.contactInfo.email.isNotEmpty;
    final hasPhone = contact.details.contactInfo.phone.isNotEmpty;
    final hasAddress = contact.details.contactInfo.address.isNotEmpty;

    if (!hasEmail && !hasPhone && !hasAddress) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (hasEmail) ...[
              _buildContactInfoRow(
                context,
                'Email',
                contact.details.contactInfo.email,
                Icons.email,
                onTap: () => _launchEmail(contact.details.contactInfo.email),
              ),
              if (hasPhone || hasAddress) const SizedBox(height: 12),
            ],
            if (hasPhone) ...[
              _buildContactInfoRow(
                context,
                'Phone',
                contact.details.contactInfo.phone,
                Icons.phone,
                onTap: () => _launchPhone(contact.details.contactInfo.phone),
              ),
              if (hasAddress) const SizedBox(height: 12),
            ],
            if (hasAddress)
              _buildContactInfoRow(
                context,
                'Address',
                contact.details.contactInfo.address,
                Icons.location_on,
                onTap: () => _launchMaps(contact.details.contactInfo.address),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Text(
                contact.details.notes,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _viewInteractions(context),
                icon: const Icon(Icons.history),
                label: const Text('View Interaction History'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : 'Not provided',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: value.isNotEmpty
                      ? null
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: onTap != null ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.open_in_new,
                size: 16,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
          ],
        ),
      ),
    );
  }

  void _viewInteractions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewInteractionsScreen(
          preselectedContactNickName: contact.nickName,
        ),
      ),
    );
  }

  void _editContact(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditContactScreen(contact: contact),
      ),
    );

    if (result == true && context.mounted) {
      // Contact was updated, go back to previous screen
      Navigator.pop(context, true);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchMaps(String address) async {
    final Uri mapsUri = Uri(
      scheme: 'https',
      host: 'maps.google.com',
      path: '/search/',
      queryParameters: {'api': '1', 'query': address},
    );
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
  }
}