import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:js_interop';

@JS('window.ENV')
external JSObject? get windowEnv;

@JS()
@anonymous
extension type EnvConfig._(JSObject _) implements JSObject {
  external String? get API_BASE_URL;
}

class ConfigService {
  static String? _apiBaseUrl;

  static String get apiBaseUrl {
    if (_apiBaseUrl != null) return _apiBaseUrl!;

    // For web builds, try to get config from runtime environment first
    if (kIsWeb) {
      try {
        // Try to access window.ENV from the injected env-config.js
        final env = windowEnv;
        if (env != null) {
          final envConfig = env as EnvConfig;
          final String? runtimeApiUrl = envConfig.API_BASE_URL;
          if (runtimeApiUrl != null && runtimeApiUrl.isNotEmpty) {
            _apiBaseUrl = runtimeApiUrl;
            return _apiBaseUrl!;
          }
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