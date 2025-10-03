import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';

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
    return MaterialApp(
      title: 'Reconnect App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
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

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Wake up the backend
    _apiService.wakeUpBackend();

    try {
      final isLoggedIn = await _apiService.isLoggedIn();
      setState(() {
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.amber[50],
        body: const Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      );
    }

    return _isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}