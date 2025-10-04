import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/auth.dart';
import '../services/api_service.dart';
import '../widgets/app_logo.dart';
import 'register_screen.dart';
import 'main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isWakingBackend = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final loginRequest = LoginRequest(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      await _apiService.login(loginRequest);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().toLowerCase();

        // Check if error indicates backend is unavailable/sleeping
        if (errorMessage.contains('connection') ||
            errorMessage.contains('timeout') ||
            errorMessage.contains('network') ||
            errorMessage.contains('host') ||
            errorMessage.contains('resolve') ||
            errorMessage.contains('502') ||
            errorMessage.contains('503') ||
            errorMessage.contains('504')) {

          _showBackendWakeupDialog();
        } else {
          // Show regular error for authentication failures
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showBackendWakeupDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isWakingBackend ? Icons.cloud_sync_rounded : Icons.cloud_off_rounded,
                    size: 60,
                    color: _isWakingBackend ? Colors.amber[600] : Colors.orange[600],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isWakingBackend ? 'Waking up server...' : 'Server appears to be sleeping',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isWakingBackend
                        ? 'Please wait while we start up the server. This may take up to a minute.'
                        : 'The app is hosted on a free tier service that sleeps when inactive. Would you like to wake it up?',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (_isWakingBackend) ...[
                    const SizedBox(height: 20),
                    CircularProgressIndicator(
                      color: Colors.amber[600],
                    ),
                  ],
                ],
              ),
              actions: _isWakingBackend ? null : [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    setDialogState(() {
                      _isWakingBackend = true;
                    });

                    try {
                      // Wake up backend and verify it's responsive
                      final backendAwake = await _apiService.wakeUpBackend();

                      if (mounted) {
                        Navigator.of(context).pop();

                        if (backendAwake) {
                          // Show success message and suggest trying login again
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Server is now awake! Please try logging in again.'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 4),
                            ),
                          );
                        } else {
                          // Backend still not responsive
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('⚠️ Server is taking longer than expected to wake up. Please wait a moment and try again.'),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 6),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ Failed to wake server. Please check your connection and try again.'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 5),
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isWakingBackend = false;
                        });
                      }
                    }
                  },
                  child: const Text('Wake Up Server'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 20,
                shadowColor: Colors.black.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (KeyEvent event) {
                      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                        if (!_isLoading) {
                          _login();
                        }
                      }
                    },
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        const AppLogo(
                          size: 100,
                          showShadow: true,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Welcome Back',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: MediaQuery.of(context).size.width < 400 ? 22 : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to reconnect with your contacts',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: MediaQuery.of(context).size.width < 400 ? 14 : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onFieldSubmitted: (_) {
                            if (!_isLoading) {
                              _login();
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _login,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Sign In',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}