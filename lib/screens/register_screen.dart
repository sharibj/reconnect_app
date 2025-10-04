import 'package:flutter/material.dart';
import '../models/auth.dart';
import '../services/api_service.dart';
import '../widgets/app_logo.dart';
import 'main_navigation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isWakingBackend = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final registerRequest = RegisterRequest(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await _apiService.register(registerRequest);

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
          // Show regular error for registration failures
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: ${e.toString()}'),
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
                          // Show success message and suggest trying registration again
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Server is now awake! Please try registering again.'),
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
                        'Join Reconnect',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your account to start connecting',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
                            return 'Please enter a username';
                          }
                          if (value.length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          filled: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
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
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          filled: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _register,
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
                                  'Create Account',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign In',
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
    );
  }
}