import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/contact_provider.dart';
import '../providers/interaction_provider.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool _isExporting = false;
  bool _includeContacts = true;
  bool _includeInteractions = true;
  String _exportFormat = 'JSON';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export your data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose what data to export and in which format',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            _buildDataSelection(),
            const SizedBox(height: 24),
            _buildFormatSelection(),
            const Spacer(),
            _buildExportButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data to Export',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Contacts'),
              subtitle: const Text('All your contacts and their information'),
              value: _includeContacts,
              onChanged: (value) {
                setState(() {
                  _includeContacts = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Interactions'),
              subtitle: const Text('All your logged interactions'),
              value: _includeInteractions,
              onChanged: (value) {
                setState(() {
                  _includeInteractions = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Format',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('JSON'),
              subtitle: const Text('Machine-readable format for developers'),
              value: 'JSON',
              groupValue: _exportFormat,
              onChanged: (value) {
                setState(() {
                  _exportFormat = value ?? 'JSON';
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<String>(
              title: const Text('CSV'),
              subtitle: const Text('Spreadsheet format for Excel/Google Sheets'),
              value: 'CSV',
              groupValue: _exportFormat,
              onChanged: (value) {
                setState(() {
                  _exportFormat = value ?? 'JSON';
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isExporting || (!_includeContacts && !_includeInteractions)
            ? null
            : _exportData,
        child: _isExporting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Exporting...'),
                ],
              )
            : const Text('Export Data'),
      ),
    );
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      Map<String, dynamic> exportData = {};

      if (_includeContacts) {
        final contactProvider = context.read<ContactProvider>();
        await contactProvider.loadContacts();

        if (_exportFormat == 'JSON') {
          exportData['contacts'] = contactProvider.contacts
              .map((contact) => contact.toJson())
              .toList();
        }
      }

      if (_includeInteractions) {
        final interactionProvider = context.read<InteractionProvider>();
        // Load all interactions (you might want to modify this to load all interactions)
        await interactionProvider.loadInteractions();

        if (_exportFormat == 'JSON') {
          exportData['interactions'] = interactionProvider.interactions
              .map((interaction) => interaction.toJson())
              .toList();
        }
      }

      String content;
      String fileName;
      String mimeType;

      if (_exportFormat == 'JSON') {
        content = const JsonEncoder.withIndent('  ').convert(exportData);
        fileName = 'reconnect_export_${DateTime.now().millisecondsSinceEpoch}.json';
        mimeType = 'application/json';
      } else {
        content = _convertToCSV(exportData);
        fileName = 'reconnect_export_${DateTime.now().millisecondsSinceEpoch}.csv';
        mimeType = 'text/csv';
      }

      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path, mimeType: mimeType)],
        text: 'Reconnect Data Export',
        subject: 'Your Reconnect data export is ready',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  String _convertToCSV(Map<String, dynamic> data) {
    List<String> csvLines = [];

    if (data.containsKey('contacts')) {
      csvLines.add('--- CONTACTS ---');
      csvLines.add('Nickname,First Name,Last Name,Group,Email,Phone,Address,Notes');

      for (var contact in data['contacts']) {
        final details = contact['details'] ?? {};
        final contactInfo = details['contactInfo'] ?? {};

        csvLines.add([
          contact['nickName'] ?? '',
          details['firstName'] ?? '',
          details['lastName'] ?? '',
          contact['group'] ?? '',
          contactInfo['email'] ?? '',
          contactInfo['phone'] ?? '',
          contactInfo['address'] ?? '',
          details['notes'] ?? '',
        ].map((field) => '"${field.toString().replaceAll('"', '""')}"').join(','));
      }
      csvLines.add('');
    }

    if (data.containsKey('interactions')) {
      csvLines.add('--- INTERACTIONS ---');
      csvLines.add('Contact,Date,Type,Self Initiated,Notes');

      for (var interaction in data['interactions']) {
        final interactionDetails = interaction['interactionDetails'] ?? {};
        final timestamp = DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(interaction['timeStamp'] ?? '0') ?? 0
        );

        csvLines.add([
          interaction['contact'] ?? '',
          timestamp.toIso8601String(),
          interactionDetails['type'] ?? '',
          interactionDetails['selfInitiated']?.toString() ?? 'false',
          interaction['notes'] ?? '',
        ].map((field) => '"${field.toString().replaceAll('"', '""')}"').join(','));
      }
    }

    return csvLines.join('\n');
  }
}