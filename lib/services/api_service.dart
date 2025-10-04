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
  static const String _usernameKey = 'username';

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
      await _storage.write(key: _usernameKey, value: authResponse.username);
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
      await _storage.write(key: _usernameKey, value: authResponse.username);
      return authResponse;
    } else {
      throw Exception('Failed to register. Status code: ${response.statusCode}');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _usernameKey);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
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

  Future<List<Interaction>> getAllInteractions({int page = 0, int size = 100}) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/interactions?page=$page&size=$size'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Interaction> interactions = body
          .map((dynamic item) => Interaction.fromJson(item))
          .toList();
      return interactions;
    } else {
      throw Exception('Failed to load all interactions');
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

  // Contact CRUD operations
  Future<Contact> updateContact(String nickName, Contact contact) async {
    final headers = await _getAuthHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/contacts/$nickName'),
      headers: headers,
      body: jsonEncode({
        'group': contact.group,
        'details': contact.details.toJson(),
      }),
    );

    if (response.statusCode == 200) {
      return Contact.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to update contact. Status code: ${response.statusCode}',
      );
    }
  }

  Future<void> deleteContact(String nickName) async {
    final headers = await _getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/contacts/$nickName'),
      headers: headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Failed to delete contact. Status code: ${response.statusCode}',
      );
    }
  }

  // Group CRUD operations
  Future<Group> updateGroup(String name, Group group) async {
    final headers = await _getAuthHeaders();

    print('🔍 DEBUG: Updating group - URL: $_baseUrl/groups/$name');
    print('🔍 DEBUG: Original group data: ${jsonEncode(group.toJson())}');

    // Send the complete group object like other PUT requests
    final response = await http.put(
      Uri.parse('$_baseUrl/groups/${Uri.encodeComponent(name)}'),
      headers: headers,
      body: jsonEncode(group.toJson()),
    );

    print('🔍 DEBUG: Update response status: ${response.statusCode}');
    print('🔍 DEBUG: Update response body: ${response.body}');

    if (response.statusCode == 200) {
      // Handle empty response body from backend
      if (response.body.isEmpty) {
        return group; // Return the updated group object we sent
      }
      try {
        return Group.fromJson(jsonDecode(response.body));
      } catch (e) {
        print('🔍 DEBUG: Failed to parse response JSON: $e');
        // If JSON parsing fails, return the group object we sent
        return group;
      }
    } else {
      throw Exception(
        'Failed to update group. Status code: ${response.statusCode}, Response: ${response.body}',
      );
    }
  }

  Future<void> deleteGroup(String name) async {
    final headers = await _getAuthHeaders();

    print('🔍 DEBUG: Deleting group - URL: $_baseUrl/groups/${Uri.encodeComponent(name)}');

    final response = await http.delete(
      Uri.parse('$_baseUrl/groups/${Uri.encodeComponent(name)}'),
      headers: headers,
    );

    print('🔍 DEBUG: Delete response status: ${response.statusCode}');
    print('🔍 DEBUG: Delete response body: ${response.body}');

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Failed to delete group. Status code: ${response.statusCode}, Response: ${response.body}',
      );
    }
  }

  // Interaction CRUD operations
  Future<Interaction> updateInteraction(String interactionId, Interaction interaction) async {
    final headers = await _getAuthHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/interactions/$interactionId'),
      headers: headers,
      body: jsonEncode(interaction.toJson()),
    );

    if (response.statusCode == 200) {
      return interaction;
    } else {
      throw Exception(
        'Failed to update interaction. Status code: ${response.statusCode}',
      );
    }
  }

  Future<bool> wakeUpBackend() async {
    // Try multiple wake-up strategies and verify backend is responsive
    final wakeUpEndpoints = [
      '$_authBaseUrl/health',
      '$_authBaseUrl/login',
      _baseUrl.replaceAll('/api/reconnect', '/health'),
      _baseUrl.replaceAll('/api/reconnect', ''),
    ];

    // First, try to wake up the backend
    for (final endpoint in wakeUpEndpoints) {
      try {
        if (endpoint.contains('/login')) {
          await http.post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'username': '__wake_up__', 'password': '__wake_up__'}),
          ).timeout(const Duration(seconds: 15));
        } else {
          await http.get(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
          ).timeout(const Duration(seconds: 15));
        }
        break; // If any request succeeds, stop trying
      } catch (e) {
        // Continue to next endpoint
        continue;
      }
    }

    // Wait for backend to fully initialize
    await Future.delayed(const Duration(seconds: 2));

    // Now verify the backend is actually responsive
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await http.get(
          Uri.parse('$_authBaseUrl/login'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        ).timeout(const Duration(seconds: 10));

        // If we get any response (even error), backend is awake
        if (response.statusCode >= 200 && response.statusCode < 600) {
          return true;
        }
      } catch (e) {
        if (attempt < 2) {
          // Wait longer between verification attempts
          await Future.delayed(const Duration(seconds: 5));
        }
      }
    }

    return false; // Backend is still not responding
  }
}
