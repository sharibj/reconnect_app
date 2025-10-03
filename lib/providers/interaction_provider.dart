import 'package:flutter/material.dart';
import '../models/interaction.dart';
import '../models/contact.dart';
import '../services/api_service.dart';

class InteractionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Interaction> _interactions = [];
  List<Interaction> _allInteractions = []; // For analytics - all interactions across all contacts
  bool _isLoading = false;
  String _selectedContact = '';

  List<Interaction> get interactions => _interactions;
  List<Interaction> get allInteractions => _allInteractions;
  bool get isLoading => _isLoading;
  String get selectedContact => _selectedContact;

  Future<void> loadInteractions({String? contactNickname, int page = 0, int size = 100}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (contactNickname != null && contactNickname.isNotEmpty) {
        _interactions = await _apiService.getContactInteractions(contactNickname, page, size);
        _selectedContact = contactNickname;
      } else {
        _interactions = await _apiService.getAllInteractions(page: page, size: size);
        _selectedContact = '';
      }
    } catch (e) {
      debugPrint('Error loading interactions: $e');
      _interactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all interactions across all contacts for analytics
  Future<void> loadAllInteractions() async {
    _isLoading = true;
    notifyListeners();

    try {
      // First get all contacts
      List<Contact> contacts = await _apiService.getContacts();
      List<Interaction> allInteractions = [];

      // Then fetch interactions for each contact
      for (Contact contact in contacts) {
        try {
          List<Interaction> contactInteractions = await _apiService.getContactInteractions(
            contact.nickName, 0, 1000 // Large size to get all interactions
          );
          allInteractions.addAll(contactInteractions);
        } catch (e) {
          debugPrint('Error loading interactions for ${contact.nickName}: $e');
          // Continue with other contacts even if one fails
        }
      }

      _allInteractions = allInteractions;
    } catch (e) {
      debugPrint('Error loading all interactions: $e');
      _allInteractions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addInteraction(Interaction interaction) async {
    try {
      await _apiService.addInteraction(interaction);
      if (_selectedContact == interaction.contact || _selectedContact.isEmpty) {
        _interactions.insert(0, interaction);
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error adding interaction: $e');
      return false;
    }
  }

  Future<bool> updateInteraction(String interactionId, Interaction interaction) async {
    try {
      final updatedInteraction = await _apiService.updateInteraction(interactionId, interaction);
      final index = _interactions.indexWhere((i) => i.id == interactionId);
      if (index != -1) {
        _interactions[index] = updatedInteraction;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating interaction: $e');
      return false;
    }
  }

  Future<bool> deleteInteraction(String interactionId) async {
    try {
      await _apiService.deleteInteraction(interactionId);
      _interactions.removeWhere((interaction) => interaction.id == interactionId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting interaction: $e');
      return false;
    }
  }

  void clearInteractions() {
    _interactions = [];
    _selectedContact = '';
    notifyListeners();
  }

  List<Interaction> getInteractionsByType(String type) {
    return _interactions.where((interaction) =>
      interaction.interactionDetails.type == type).toList();
  }

  List<Interaction> getRecentInteractions({int limit = 10}) {
    List<Interaction> sortedInteractions = List.from(_interactions);
    sortedInteractions.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
    return sortedInteractions.take(limit).toList();
  }

  Map<String, int> getInteractionCountsByType() {
    final interactionsToUse = _allInteractions.isNotEmpty ? _allInteractions : _interactions;
    Map<String, int> typeCounts = {};
    for (var interaction in interactionsToUse) {
      String type = interaction.interactionDetails.type;
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }
    return typeCounts;
  }

  Map<String, int> getInteractionCountsByContact() {
    Map<String, int> contactCounts = {};
    for (var interaction in _interactions) {
      String contact = interaction.contact;
      contactCounts[contact] = (contactCounts[contact] ?? 0) + 1;
    }
    return contactCounts;
  }

  int get totalInteractions => _allInteractions.isNotEmpty ? _allInteractions.length : _interactions.length;

  int get selfInitiatedCount {
    final interactionsToUse = _allInteractions.isNotEmpty ? _allInteractions : _interactions;
    return interactionsToUse
        .where((interaction) => interaction.interactionDetails.selfInitiated)
        .length;
  }

  int get otherInitiatedCount {
    final interactionsToUse = _allInteractions.isNotEmpty ? _allInteractions : _interactions;
    return interactionsToUse
        .where((interaction) => !interaction.interactionDetails.selfInitiated)
        .length;
  }

  double get selfInitiatedPercentage {
    final interactionsToUse = _allInteractions.isNotEmpty ? _allInteractions : _interactions;
    if (interactionsToUse.isEmpty) return 0.0;
    final selfInitiated = interactionsToUse
        .where((interaction) => interaction.interactionDetails.selfInitiated)
        .length;
    return (selfInitiated / interactionsToUse.length) * 100;
  }

  List<Interaction> getInteractionsInDateRange(DateTime start, DateTime end) {
    return _interactions.where((interaction) {
      return interaction.timeStamp.isAfter(start) &&
             interaction.timeStamp.isBefore(end);
    }).toList();
  }

  Map<DateTime, int> getInteractionsByDay({int days = 30}) {
    Map<DateTime, int> dailyCounts = {};
    DateTime now = DateTime.now();

    for (int i = 0; i < days; i++) {
      DateTime day = DateTime(now.year, now.month, now.day - i);
      dailyCounts[day] = 0;
    }

    for (var interaction in _interactions) {
      DateTime day = DateTime(
        interaction.timeStamp.year,
        interaction.timeStamp.month,
        interaction.timeStamp.day,
      );
      if (dailyCounts.containsKey(day)) {
        dailyCounts[day] = (dailyCounts[day] ?? 0) + 1;
      }
    }

    return dailyCounts;
  }
}