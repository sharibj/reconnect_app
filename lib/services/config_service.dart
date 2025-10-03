import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:js' as js;

class ConfigService {
  static String? _apiBaseUrl;

  static String get apiBaseUrl {
    if (_apiBaseUrl != null) return _apiBaseUrl!;

    // For web builds, try to get config from runtime environment first
    if (kIsWeb) {
      try {
        // Use the simple window.getApiBaseUrl() function from index.html
        final runtimeApiUrl = js.context.callMethod('getApiBaseUrl');
        if (runtimeApiUrl != null && runtimeApiUrl.toString().isNotEmpty) {
          _apiBaseUrl = runtimeApiUrl.toString();
          return _apiBaseUrl!;
        }
      } catch (e) {
        print('Warning: Could not read runtime config: $e');
      }
    }

    // Fallback to dotenv for development or if runtime config is not available
    _apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/reconnect';
    return _apiBaseUrl!;
  }

  // Method to explicitly set the API base URL (useful for testing)
  static void setApiBaseUrl(String url) {
    _apiBaseUrl = url;
  }

  // Method to reset the cached URL (useful for testing)
  static void reset() {
    _apiBaseUrl = null;
  }
}