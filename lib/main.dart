import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'screens/main_navigation.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/contact_provider.dart';
import 'providers/interaction_provider.dart';
import 'providers/analytics_provider.dart';

// To set up flutter_dotenv:
// 1. Add `flutter_dotenv: ^5.2.1` to your `pubspec.yaml` dependencies.
// 2. Create a file named `.env` in the root of your project.
// 3. Add your API base URL to the `.env` file like this:
//    API_BASE_URL=http://192.168.178.57:8080/api/reconnect
// 4. Add the `.env` file to your assets in `pubspec.yaml`:
//    flutter:
//      assets:
//        - .env
// 5. Make sure to add `.env` to your `.gitignore` file to keep your secrets safe.

Future<void> main() async {
  // Load the environment variables from the .env file
  await dotenv.load(fileName: ".env");
  runApp(const ReconnectApp());
}

class ReconnectApp extends StatelessWidget {
  const ReconnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ContactProvider()),
        ChangeNotifierProvider(create: (_) => InteractionProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Reconnect',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String _loadingMessage = 'Initializing...';
  bool _isBackendWaking = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // First check if we have a token locally (fast check)
    setState(() {
      _loadingMessage = 'Checking authentication...';
    });

    final token = await _apiService.getToken();
    final hasToken = token != null && token.isNotEmpty;

    if (hasToken) {
      // If we have a token, try to wake up the backend
      setState(() {
        _loadingMessage = 'Connecting to server...';
        _isBackendWaking = true;
      });

      try {
        // Wake up the backend and verify it's responsive
        final backendAwake = await _apiService.wakeUpBackend();

        if (backendAwake) {
          setState(() {
            _loadingMessage = 'Verifying credentials...';
          });

          final isLoggedIn = await _apiService.isLoggedIn();
          setState(() {
            _isLoggedIn = isLoggedIn;
            _isLoading = false;
            _isBackendWaking = false;
          });
        } else {
          // Backend still not responsive, go to login
          setState(() {
            _isLoggedIn = false;
            _isLoading = false;
            _isBackendWaking = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
          _isBackendWaking = false;
        });
      }
    } else {
      // No token, skip backend wake-up and go to login
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
        _isBackendWaking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.amber[50],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_sync_rounded,
                  size: 80,
                  color: Colors.amber[700],
                ),
                const SizedBox(height: 32),
                Text(
                  'Reconnect',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
                const SizedBox(height: 16),
                if (_isBackendWaking) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Server is waking up (hosted on free tier)',
                          style: TextStyle(
                            color: Colors.amber[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  _loadingMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.amber[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                CircularProgressIndicator(
                  color: Colors.amber[600],
                  strokeWidth: 3,
                ),
                if (_isBackendWaking) ...[
                  const SizedBox(height: 16),
                  Text(
                    'This may take up to a minute',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return _isLoggedIn ? const MainNavigation() : const LoginScreen();
  }
}