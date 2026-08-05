import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe && savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_email', _emailController.text.trim());
      await prefs.setString('saved_password', _passwordController.text);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<void> _syncFirebaseCharacters() async {
    try {
      debugPrint('=== Starting Firebase Sync ===');
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      debugPrint('Current User ID: $currentUserId');

      final firebaseCharacters = await FirebaseService.fetchAllUserCharacters();
      debugPrint('Found ${firebaseCharacters.length} characters in Firebase');

      if (firebaseCharacters.isEmpty) {
        debugPrint('No characters to sync from Firebase');
        return;
      }

      final box = await Hive.openBox('characters');

      // Also migrate existing local characters to add userId
      for (final key in box.keys) {
        try {
          final localData = box.get(key);
          if (localData is Map &&
              (localData['userId'] == null || localData['userId'] == '')) {
            final updatedData = Map<String, dynamic>.from(localData);
            updatedData['userId'] = currentUserId;
            await box.put(key, updatedData);
            debugPrint('Migrated local character $key to add userId');
          }
        } catch (e) {
          debugPrint('Error migrating local character $key: $e');
        }
      }

      // Sync from Firebase (smart merge - don't overwrite good local data with empty Firebase data)
      for (var charData in firebaseCharacters) {
        final charId = charData['id'];
        if (charId != null) {
          // Ensure userId is set
          if (charData['userId'] == null || charData['userId'] == '') {
            charData['userId'] = currentUserId;
          }

          // Check if character already exists locally
          final existingData = box.get(charId);

          if (existingData != null && existingData is Map) {
            // Character exists locally - check if Firebase version has more data
            final firebaseName = charData['name'] ?? '';
            final localName = existingData['name'] ?? '';

            debugPrint('Character $charId exists both locally and in Firebase');
            debugPrint('  Firebase name: "$firebaseName"');
            debugPrint('  Local name: "$localName"');

            // If Firebase version is essentially empty, keep local version
            if (firebaseName.isEmpty && localName.isNotEmpty) {
              debugPrint('  → Keeping local version (Firebase version is empty)');
              // Update local version with userId and push to Firebase
              final updatedLocal = Map<String, dynamic>.from(existingData);
              updatedLocal['userId'] = currentUserId;
              await box.put(charId, updatedLocal);
              try {
                await FirebaseService.saveCharacterToCloud(
                  charId,
                  updatedLocal,
                );
                debugPrint('  → Pushed complete local data to Firebase');
              } catch (e) {
                debugPrint('  → Error pushing to Firebase: $e');
              }
              continue;
            }
          }

          // Either no local version, or Firebase version has data - use Firebase version
          await box.put(charId, charData);
          debugPrint(
            'Synced character ${charData['name']} (ID: $charId) from Firebase to Hive',
          );
          debugPrint('  - Name: ${charData['name']}');
          debugPrint('  - Nationality: ${charData['nationality']}');
          debugPrint('  - Age: ${charData['age']}');
          debugPrint('  - Service: ${charData['enlistment']?['service']}');
        }
      }
      debugPrint(
        'Successfully synced ${firebaseCharacters.length} characters from Firebase',
      );
    } catch (e) {
      debugPrint('Error syncing Firebase characters: $e');
    }
  }

  bool _isValidEmail(String email) {
    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validate email format
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your password')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseService.signInWithEmail(email, password);
      await _saveCredentials();
      await _syncFirebaseCharacters();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Sign-in failed';
        if (e.toString().contains('user-not-found')) {
          errorMessage = 'No account found with this email';
        } else if (e.toString().contains('wrong-password')) {
          errorMessage = 'Incorrect password';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'Invalid email address';
        } else if (e.toString().contains('too-many-requests')) {
          errorMessage = 'Too many attempts. Please try again later';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validate email format
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a password')));
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseService.signUpWithEmail(email, password);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Sign-up failed';
        if (e.toString().contains('email-already-in-use')) {
          errorMessage = 'An account already exists with this email';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'Invalid email address';
        } else if (e.toString().contains('weak-password')) {
          errorMessage = 'Password is too weak. Use at least 6 characters';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mission access background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/patrol_silhouette.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to gradient if image fails to load
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFD4A574), // Desert Tan sky
                        const Color(0xFFB8956A), // Mid Tan
                        const Color(0xFF4A5D3E), // OD Green ground
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Silhouette overlay (simple geometric shapes representing patrol)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF1A1A1A).withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),

          // Motto in top left
          Positioned(
            top: 40,
            left: 40,
            child: Text(
              '"Every step outside the wire is our story"',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF2B2B2B),
                letterSpacing: 1,
                shadows: [
                  Shadow(
                    color: Colors.white.withOpacity(0.8),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // Kazmo Studios on right side
          Positioned(
            bottom: 40,
            right: 40,
            child: Text(
              'Kazmo Studios',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2B2B2B).withOpacity(0.5),
                letterSpacing: 1,
              ),
            ),
          ),

          // Main content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title treatment
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF2B2B2B),
                          width: 3,
                        ),
                        color: const Color(0xFFF7F3EE).withOpacity(0.9),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'OUTSIDE THE WIRE',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF2B2B2B),
                              letterSpacing: 4,
                              shadows: [
                                Shadow(
                                  color: const Color(0xFFB8956A),
                                  offset: const Offset(2, 2),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'CHARACTER GENERATION SYSTEM',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4A5D3E),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'A Modern Tabletop Roleplaying Game',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2B2B2B).withOpacity(0.7),
                              letterSpacing: 1,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Auth card
                    Card(
                      elevation: 8,
                      child: Container(
                        width: 400,
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Mission Access',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2B2B2B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              enableSuggestions: false,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'user@example.com',
                                prefixIcon: Icon(Icons.email),
                              ),
                              onSubmitted: (_) => _signIn(),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                hintText: 'At least 6 characters',
                                prefixIcon: Icon(Icons.lock),
                              ),
                              obscureText: true,
                              onSubmitted: (_) => _signIn(),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(
                                      () => _rememberMe = value ?? false,
                                    );
                                  },
                                ),
                                const Text('Remember Me'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _loading ? null : _signIn,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'SIGN IN',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _loading ? null : _signUp,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'CREATE ACCOUNT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => Navigator.of(
                                context,
                              ).pushReplacementNamed('/dashboard'),
                              child: const Text(
                                'Continue as Guest',
                                style: TextStyle(color: Color(0xFF6B6B6B)),
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
        ],
      ),
    );
  }
}
