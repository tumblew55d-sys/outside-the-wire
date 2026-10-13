import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

/// Landing page - user selects Character Generator, View Roster, or Sign In
class ModeSelectorScreen extends StatelessWidget {
  const ModeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/patrol_silhouette.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Sign In button (top right)
                Positioned(
                  top: 16,
                  right: 16,
                  child: StreamBuilder<User?>(
                    stream: Firebase.apps.isEmpty
                        ? const Stream<User?>.empty()
                        : FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snap) {
                      final user = snap.data;
                      const cream = Color(0xFFF7F3EE);
                      const tan = Color(0xFFB8956A);
                      if (user != null && !user.isAnonymous) {
                        final name = (user.displayName?.trim().isNotEmpty ?? false)
                            ? user.displayName!
                            : (user.email ?? 'Signed in').split('@').first;
                        return PopupMenuButton<String>(
                          tooltip: 'Account',
                          onSelected: (v) async {
                            if (v == 'out') await FirebaseService.signOut();
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'out', child: Text('Sign out')),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: tan, width: 2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.greenAccent, size: 20),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('LOGGED IN',
                                        style: TextStyle(
                                            color: Colors.greenAccent,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                    Text(name,
                                        style: const TextStyle(
                                            color: cream,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return OutlinedButton.icon(
                        icon: const Icon(Icons.login, color: cream),
                        label: const Text(
                          'SIGN IN',
                          style: TextStyle(
                            color: cream,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: tan, width: 2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/auth');
                        },
                      );
                    },
                  ),
                ),
                // Main content centered
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 72),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        const Text(
                          'OUTSIDE THE WIRE',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB8956A),
                            letterSpacing: 4,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'MODERN WAR TACTICAL TTRPG',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFFF7F3EE),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 80),

                        // Mode selection buttons
                        _ModeButton(
                          icon: Icons.person_add,
                          label: 'CHARACTER GENERATOR',
                          subtitle: 'Create and manage operators',
                          onTap: () {
                            Navigator.of(context).pushNamed('/createCharacter');
                          },
                        ),
                        const SizedBox(height: 24),
                        _ModeButton(
                          icon: Icons.people,
                          label: 'VIEW ROSTER',
                          subtitle: 'Browse saved characters',
                          onTap: () {
                            Navigator.of(context).pushNamed('/dashboard');
                          },
                        ),
                        const SizedBox(height: 24),
                        _ModeButton(
                          icon: Icons.military_tech,
                          label: 'CAMPAIGNS (BETA)',
                          subtitle: 'Under construction: GM or join a campaign',
                          onTap: () {
                            Navigator.of(context).pushNamed('/campaigns');
                          },
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
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B).withOpacity(0.9),
          border: Border.all(color: const Color(0xFF4A5D3E), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 48, color: const Color(0xFFB8956A)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF7F3EE),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFFF7F3EE).withOpacity(0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 32, color: Color(0xFF4A5D3E)),
          ],
        ),
      ),
    );
  }
}
