import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/auth.dart';
import '../models/contact.dart';
import '../models/group.dart';
import '../models/interaction.dart';
import '../models/reconnect_model.dart';
import 'config_service.dart';

class ApiService {
  // Get base URLs from ConfigService
  String get _baseUrl => ConfigService.apiBaseUrl;
  String get _authBaseUrl {
    final baseUrl = ConfigService.apiBaseUrl;
    // More explicit URL construction to avoid string replacement issues
    if (baseUrl.contains('/api/reconnect')) {
      // Replace only the last part: /api/reconnect -> /api/auth
      return baseUrl.substring(0, baseUrl.lastIndexOf('/api/reconnect')) + '/api/auth';
    } else {
      // Fallback: extract base domain and add /api/auth
      final uri = Uri.parse(baseUrl);
      return '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}/api/auth';
    }
  }

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';

  // Authentication methods
  Future<AuthResponse> login(LoginRequest request) async {
    print('🔍 DEBUG: Base URL: $_baseUrl');
    print('🔍 DEBUG: Auth URL: $_authBaseUrl');
    print('🔍 DEBUG: Full login URL: $_authBaseUrl/login');

    final response = await http.post(
      Uri.parse('$_authBaseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
      await _storage.write(key: _tokenKey, value: authResponse.token);
      return authResponse;
    } else {
      throw Exception('Failed to login. Status code: ${response.statusCode}');
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    print('🔍 DEBUG: Base URL: $_baseUrl');
    print('🔍 DEBUG: Auth URL: $_authBaseUrl');
    print('🔍 DEBUG: Full register URL: $_authBaseUrl/register');

    final response = await http.post(
      Uri.parse('$_authBaseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
      await _storage.write(key: _tokenKey, value: authResponse.token);
      return authResponse;
    } else {
      throw Exception('Failed to register. Status code: ${response.statusCode}');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Contact>> getContacts() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/contacts?page=0&size=100'),
      headers: headers,
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
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/out-of-touch?page=0&size=100'),
      headers: headers,
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
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/contacts'),
      headers: headers,
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
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/groups?page=0&size=100'),
      headers: headers,
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
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/groups'),
      headers: headers,
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
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/interactions'),
      headers: headers,
      body: jsonEncode(interaction.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to add interaction. Status code: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

  Future<List<Interaction>> getContactInteractions(String contactNickname, int page, int size) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/contacts/$contactNickname/interactions?page=$page&size=$size'),
      headers: headers,
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
    final headers = await _getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/interactions/$interactionId'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to delete interaction. Status code: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }
}
