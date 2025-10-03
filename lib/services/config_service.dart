import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  static String? _apiBaseUrl;

  static String get apiBaseUrl {
    if (_apiBaseUrl != null) return _apiBaseUrl!;

    // Use dotenv configuration - this will be set at Docker runtime
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