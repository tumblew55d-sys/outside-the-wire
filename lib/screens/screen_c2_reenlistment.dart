import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/character.dart';
import '../widgets/character_creation_layout.dart';
import 'screen_c_deployments.dart';
import 'screen_d_abilities.dart';

class ReenlistmentScreen extends StatefulWidget {
  final String characterId;

  const ReenlistmentScreen({super.key, required this.characterId});

  @override
  State<ReenlistmentScreen> createState() => _ReenlistmentScreenState();
}

class _ReenlistmentScreenState extends State<ReenlistmentScreen> {
  Character? _character;

  @override
  void initState() {
    super.initState();
    _loadCharacter();
  }

  Future<void> _loadCharacter() async {
    final box = Hive.box('characters');
    final data = box.get(widget.characterId);
    if (data != null) {
      setState(() {
        _character = Character.fromJson(Map<String, dynamic>.from(data));
      });
    }
  }

  void _handleContinue() {
    // Finalize character - proceed to Abilities screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            AbilitiesNarrativeScreen(characterId: widget.characterId),
      ),
    );
  }

  Future<void> _handleReenlist() async {
    // Update character data before re-enlisting
    if (_character != null) {
      final box = Hive.box('characters');

      // Increment re-enlistment count
      final currentCount = _character!.enlistment['reenlistmentCount'] ?? 0;
      _character!.enlistment['reenlistmentCount'] = currentCount + 1;

      // Add 4 years to age per re-enlistment
      _character!.age += 4;

      // Save updated character
      _character!.modifiedAt = DateTime.now();
      await box.put(widget.characterId, _character!.toJson());

      debugPrint(
        'Re-enlisted: count=${currentCount + 1}, new age=${_character!.age}',
      );
    }

    // Send character back through Career & Deployments
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              DeploymentsScreen(characterId: widget.characterId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_character == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Re-enlistment')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return CharacterCreationLayout(
      character: _character!,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Re-enlistment'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      DeploymentsScreen(characterId: widget.characterId),
                ),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                'Re-enlistment Decision',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Character summary card
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _character!.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_character!.enlistment['rank'] ?? 'Unknown Rank'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${_character!.enlistment['service'] ?? 'Unknown Service'} - ${_character!.enlistment['specialty'] ?? 'Unknown Specialty'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Age: ${_character!.age}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Deployments completed: ${(_character!.enlistment['deployments'] as List?)?.length ?? 0}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      if ((_character!.enlistment['reenlistmentCount'] ?? 0) >
                          0)
                        Text(
                          'Re-enlistments: ${_character!.enlistment['reenlistmentCount']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Design intent message
              Card(
                color: Colors.amber[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber[900]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Design intent is not to re-enlist.',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.amber[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Instructions
              Text(
                'Your character has completed their initial career. You can now:',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Continue button (finalize character)
              SizedBox(
                height: 100,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 32),
                      const SizedBox(height: 6),
                      const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Finalize character and proceed',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Re-enlist button
              SizedBox(
                height: 100,
                child: OutlinedButton(
                  onPressed: _handleReenlist,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    side: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.replay, size: 32, color: Colors.blue),
                      const SizedBox(height: 6),
                      const Text(
                        'Re-enlist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Continue career for more experience',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Back button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          DeploymentsScreen(characterId: widget.characterId),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back: Review Deployments'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
