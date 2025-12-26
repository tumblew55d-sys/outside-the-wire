import 'package:flutter/material.dart';
import 'theme/tactical_theme.dart';
import 'screens/enlistment_screen.dart';
import 'screens/deployment_screen.dart';
import 'screens/bio_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/inspection_screen.dart';

void main() {
  runApp(const PatrolCharacterGeneratorApp());
}

class PatrolCharacterGeneratorApp extends StatelessWidget {
  const PatrolCharacterGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Outside the Wire',
      theme: TacticalTheme.themeData,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentScreenIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalTheme.gunmetal,
      appBar: AppBar(
        title: const Text('Outside the Wire'),
        backgroundColor: TacticalTheme.oliveDrab,
      ),
      body: IndexedStack(
        index: _currentScreenIndex,
        children: const [
          BioScreen(),
          EnlistmentScreen(),
          DeploymentScreen(),
          InspectionScreen(),
          SummaryScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentScreenIndex,
        backgroundColor: TacticalTheme.gunmetal,
        selectedItemColor: TacticalTheme.safetyOrange,
        unselectedItemColor: TacticalTheme.desertTan,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Bio'),
          BottomNavigationBarItem(icon: Icon(Icons.military_tech), label: 'Enlistment'),
          BottomNavigationBarItem(icon: Icon(Icons.flight_takeoff), label: 'Deployment'),
          BottomNavigationBarItem(icon: Icon(Icons.build_circle), label: 'Inspection'),
          BottomNavigationBarItem(icon: Icon(Icons.picture_as_pdf), label: 'Summary'),
        ],
        onTap: (int index) {
          setState(() {
            _currentScreenIndex = index;
          });
        },
      ),
    );
  }
}
