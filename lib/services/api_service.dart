import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/contact.dart';
import '../models/group.dart';
import '../models/interaction.dart';
import '../models/reconnect_model.dart';

class ApiService {
  // Fetch the base URL from environment variables
  final String _baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/reconnect';

  Future<List<Contact>> getContacts() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/contacts?page=0&size=100'),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Contact> contacts = body
          .map((dynamic item) => Contact.fromJson(item))
          .toList();
      return contacts;
    } else {
      throw Exception('Failed to load contacts');
    }
  }

  Future<List<ReconnectModel>> getOutOfTouchContacts() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/out-of-touch?page=0&size=100'),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<ReconnectModel> contacts = body
          .map((dynamic item) => ReconnectModel.fromJson(item))
          .toList();
      return contacts;
    } else {
      throw Exception('Failed to load out-of-touch contacts');
    }
  }

  Future<Contact> addContact(Contact contact) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/contacts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(contact.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Contact.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to add contact. Status code: ${response.statusCode}',
      );
    }
  }

  Future<List<Group>> getGroups() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/groups?page=0&size=100'),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Group> groups = body
          .map((dynamic item) => Group.fromJson(item))
          .toList();
      return groups;
    } else {
      throw Exception('Failed to load groups');
    }
  }

  Future<Group> addGroup(Group group) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/groups'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(group.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return group;
    } else {
      throw Exception(
        'Failed to add group. Status code: ${response.statusCode}',
      );
    }
  }

  Future<void> addInteraction(Interaction interaction) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/interactions'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(interaction.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to add interaction. Status code: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

  Future<List<Interaction>> getContactInteractions(String contactNickname, int page, int size) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/contacts/$contactNickname/interactions?page=$page&size=$size'),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Interaction> interactions = body
          .map((dynamic item) => Interaction.fromJson(item))
          .toList();
      return interactions;
    } else {
      throw Exception('Failed to load interactions for contact: $contactNickname');
    }
  }

  Future<void> deleteInteraction(String interactionId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/interactions/$interactionId'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to delete interaction. Status code: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }
}
