import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'models/character.dart';
import 'screens/dashboard.dart';
import 'screens/screen_a_basic_info.dart';
import 'screens/screen_b_enlistment.dart';
import 'screens/screen_c_deployments.dart';
import 'screens/screen_c2_reenlistment.dart';
import 'screens/screen_d_abilities.dart';
import 'screens/screen_e_inventory.dart';
import 'screens/screen_f_appearance.dart';
import 'screens/character_create.dart';
import 'screens/auth.dart';
import 'screens/mode_selector.dart';
import 'services/firebase_service.dart';

Future<void> main() async {
  // Provide global error handling so startup crashes are logged when running
  // the compiled executable.
  FlutterError.onError = (details) {
    // Print Flutter framework errors to console
    FlutterError.presentError(details);
    // Also print to stdout for native launcher capture
    debugPrint('FlutterError: ${details.exceptionAsString()}');
    if (details.stack != null) debugPrint(details.stack.toString());
  };

  await runZonedGuarded(
    () async {
      debugPrint('main: begin initialization');
      WidgetsFlutterBinding.ensureInitialized();
      debugPrint('main: WidgetsFlutterBinding.ensureInitialized complete');

      // Initialize Hive for local-first persistence
      debugPrint('main: initializing Hive');
      await Hive.initFlutter('patrol_app_data');
      debugPrint('main: Hive.initFlutter complete');

      debugPrint('main: opening Hive box characters');
      await Hive.openBox('characters');
      debugPrint('main: Hive boxes opened');

      // Initialize Firebase if config is present in the project
      try {
        debugPrint('main: attempting Firebase.initializeApp');
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        await FirebaseService.init();
        debugPrint('main: Firebase initialized successfully');
      } catch (e, st) {
        // Firebase not configured yet; app will still run local-first
        debugPrint('Firebase initialization skipped or failed: $e');
        debugPrint(st.toString());
      }

      debugPrint('main: about to runApp');
      runApp(const PatrolApp());
    },
    (error, stack) {
      // Log uncaught errors to console so they appear in logs when running the exe
      debugPrint('Uncaught error: $error');
      debugPrint(stack.toString());
    },
  );
}

class PatrolApp extends StatelessWidget {
  const PatrolApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('PatrolApp.build called');
    // sample hard-coded roster for prototype / wireframe demo
    final roster = <Character>[];

    return MaterialApp(
      title: '*** NEW VERSION 2025 *** Outside the Wire — Character Generator',
      theme: ThemeData(
        // Military color palette: OD Green primary, Desert Tan accents
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A5D3E), // OD Green
          primary: const Color(0xFF4A5D3E),
          secondary: const Color(0xFFB8956A), // Desert Tan
          tertiary: const Color(0xFF2B2B2B), // Black
          surface: const Color(0xFFF7F3EE), // Cream paper
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F3EE), // Cream
        cardTheme: const CardThemeData(
          color: Color(0xFFF7F3EE),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            side: BorderSide(color: Color(0xFF2B2B2B), width: 1),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A5D3E), // OD Green
          foregroundColor: Color(0xFFF7F3EE), // Cream text
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A5D3E), // OD Green
            foregroundColor: const Color(0xFFF7F3EE), // Cream text
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4A5D3E),
            side: const BorderSide(color: Color(0xFF4A5D3E), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF4A5D3E), width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF4A5D3E), width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ModeSelectorScreen(),
        '/auth': (context) => const AuthScreen(),
        '/dashboard': (context) => DashboardScreen(sampleRoster: roster),
        '/basicInfo': (context) => const BasicInfoScreen(),
        '/createCharacter': (context) => const CharacterCreateScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle routes with arguments
        if (settings.name == '/enlistment') {
          final characterId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => EnlistmentScreen(characterId: characterId),
          );
        }
        if (settings.name == '/deployments') {
          final characterId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => DeploymentsScreen(characterId: characterId),
          );
        }
        if (settings.name == '/reenlistment') {
          final characterId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ReenlistmentScreen(characterId: characterId),
          );
        }
        if (settings.name == '/abilities') {
          final characterId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) =>
                AbilitiesNarrativeScreen(characterId: characterId),
          );
        }
        if (settings.name == '/inventory') {
          final characterId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) =>
                InventoryEquipmentScreen(characterId: characterId),
          );
        }
        if (settings.name == '/appearance') {
          final characterId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => AppearanceScreen(characterId: characterId),
          );
        }
        return null;
      },
    );
  }
}
