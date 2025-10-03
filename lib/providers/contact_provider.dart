import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../models/group.dart';
import '../services/api_service.dart';

class ContactProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Contact> _contacts = [];
  List<Group> _groups = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedGroup = '';

  List<Contact> get contacts {
    List<Contact> filteredContacts = _contacts;

    if (_searchQuery.isNotEmpty) {
      filteredContacts = filteredContacts.where((contact) {
        return contact.nickName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               contact.details.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               contact.details.lastName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               contact.group.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_selectedGroup.isNotEmpty && _selectedGroup != 'All') {
      filteredContacts = filteredContacts.where((contact) {
        return contact.group == _selectedGroup;
      }).toList();
    }

    return filteredContacts;
  }

  List<Group> get groups => _groups;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedGroup => _selectedGroup;

  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _contacts = await _apiService.getContacts();
    } catch (e) {
      debugPrint('Error loading contacts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGroups() async {
    try {
      _groups = await _apiService.getGroups();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading groups: $e');
    }
  }

  Future<bool> addContact(Contact contact) async {
    try {
      final newContact = await _apiService.addContact(contact);
      _contacts.add(newContact);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding contact: $e');
      return false;
    }
  }

  Future<bool> addGroup(Group group) async {
    try {
      await _apiService.addGroup(group);
      _groups.add(group);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding group: $e');
      return false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedGroup(String group) {
    _selectedGroup = group;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedGroup = '';
    notifyListeners();
  }

  Contact? getContactByNickname(String nickname) {
    try {
      return _contacts.firstWhere((contact) => contact.nickName == nickname);
    } catch (e) {
      return null;
    }
  }

  int get totalContacts => _contacts.length;

  int get totalGroups => _groups.length;

  Map<String, int> get contactsByGroup {
    Map<String, int> groupCounts = {};
    for (var contact in _contacts) {
      groupCounts[contact.group] = (groupCounts[contact.group] ?? 0) + 1;
    }
    return groupCounts;
  }

  Future<bool> updateContact(String nickName, Contact contact) async {
    try {
      final updatedContact = await _apiService.updateContact(nickName, contact);
      final index = _contacts.indexWhere((c) => c.nickName == nickName);
      if (index != -1) {
        _contacts[index] = updatedContact;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating contact: $e');
      return false;
    }
  }

  Future<bool> deleteContact(String nickName) async {
    try {
      await _apiService.deleteContact(nickName);
      _contacts.removeWhere((contact) => contact.nickName == nickName);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting contact: $e');
      return false;
    }
  }

  Future<bool> updateGroup(String name, Group group) async {
    try {
      await _apiService.updateGroup(name, group);
      final index = _groups.indexWhere((g) => g.name == name);
      if (index != -1) {
        _groups[index] = group;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating group: $e');
      return false;
    }
  }

  Future<bool> deleteGroup(String name) async {
    try {
      await _apiService.deleteGroup(name);
      _groups.removeWhere((group) => group.name == name);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting group: $e');
      return false;
    }
  }

  List<Contact> getRecentContacts({int limit = 5}) {
    List<Contact> sortedContacts = List.from(_contacts);
    return sortedContacts.take(limit).toList();
  }
}