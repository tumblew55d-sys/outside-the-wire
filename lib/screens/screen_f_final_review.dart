import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/character.dart';
import '../services/pdf_character_sheet_service.dart';
import '../services/firebase_service.dart';
import '../widgets/character_creation_layout.dart';
import 'screen_b_enlistment.dart';
import 'screen_c_deployments.dart';
import 'screen_d_abilities.dart';
import 'screen_e_inventory.dart';

class FinalReviewScreen extends StatefulWidget {
  final String characterId;
  const FinalReviewScreen({super.key, required this.characterId});

  @override
  State<FinalReviewScreen> createState() => _FinalReviewScreenState();
}

class _FinalReviewScreenState extends State<FinalReviewScreen> {
  Character? _character;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadCharacter();
  }

  /// Handle equipment checkbox changes from the preview
  Future<void> _handleEquipmentChanged(String item, bool isChecked) async {
    if (_character == null) return;

    debugPrint('=== Equipment Changed ===');
    debugPrint('Item: $item');
    debugPrint('Checked: $isChecked');

    // Get current equipment list
    final selectedEquipment = List<String>.from(
      _character!.inventory['selectedEquipment'] ?? [],
    );
    final loadoutWeapons = List<String>.from(
      _character!.inventory['loadoutWeapons'] ?? [],
    );
    final customWeapons = List<String>.from(
      _character!.inventory['customWeapons'] ?? [],
    );

    // Update the appropriate list
    if (isChecked) {
      // Add item if not already present
      if (!selectedEquipment.contains(item) &&
          !loadoutWeapons.contains(item) &&
          !customWeapons.contains(item)) {
        // Determine which list this item should go into
        // For now, add to selectedEquipment
        selectedEquipment.add(item);
      }
    } else {
      // Remove item from all lists
      selectedEquipment.remove(item);
      loadoutWeapons.remove(item);
      customWeapons.remove(item);
    }

    // Update character inventory
    _character!.inventory['selectedEquipment'] = selectedEquipment;
    _character!.inventory['loadoutWeapons'] = loadoutWeapons;
    _character!.inventory['customWeapons'] = customWeapons;
    _character!.modifiedAt = DateTime.now();

    // Save to Hive immediately
    final box = Hive.box('characters');
    await box.put(_character!.id, _character!.toJson());
    await box.flush();

    debugPrint('✓ Equipment change saved to Hive');
    debugPrint('Selected equipment: $selectedEquipment');
    
    // Mark as saved so PDF export is enabled
    if (mounted) {
      setState(() {
        _isSaved = true;
      });
    }
  }

  Future<void> _loadCharacter() async {
    final box = Hive.box('characters');
    final data = box.get(widget.characterId);
    if (data != null) {
      debugPrint('=== Final Review Loading Character ===');
      debugPrint('Character ID: ${widget.characterId}');
      debugPrint('Raw data attributes: ${data['attributes']}');
      debugPrint('Raw data skills: ${data['skills']}');
      debugPrint('Raw data enlistment: ${data['enlistment']}');

      setState(() {
        _character = Character.fromJson(Map<String, dynamic>.from(data));
        debugPrint('Loaded character attributes: ${_character!.attributes}');
        debugPrint('Loaded character skills: ${_character!.skills}');
        debugPrint('Loaded character enlistment: ${_character!.enlistment}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_character == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Final Review')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final c = _character!;

    return CharacterCreationLayout(
      character: c,
      onEquipmentChanged: _handleEquipmentChanged,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Character Complete'),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Save Character?'),
                    content: const Text(
                      'Make sure to SAVE your character to the roster before exiting!\n\nHave you saved your character?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Yes, Return to Roster'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
                }
              },
              tooltip: 'Return to Roster',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Card(
                elevation: 4,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Character Complete!',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        c.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      if (c.nickname.isNotEmpty)
                        Text(
                          '"${c.nickname}"',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Dossier Preview
              _buildDossierPreview(c),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  // Save Button (always enabled)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final box = Hive.box('characters');
                        final jsonData = c.toJson();
                        await box.put(c.id, jsonData);

                        // Force Hive to flush to disk immediately
                        await box.flush();
                        debugPrint(
                          '=== Character saved to Hive and flushed ===',
                        );

                        // Save to Firebase (best effort)
                        try {
                          await FirebaseService.saveCharacterToCloud(
                            c.id,
                            jsonData,
                          );
                          debugPrint('=== Character saved to Firebase ===');
                        } catch (e) {
                          debugPrint(
                            'Firebase save failed (will sync later): $e',
                          );
                        }

                        if (mounted) {
                          setState(() {
                            _isSaved = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Character saved successfully! You can now export to PDF.',
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save Character'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Export Button (enabled only after save)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSaved
                          ? () async {
                              try {
                                // CRITICAL: Reload character from Hive to get latest edits
                                // This ensures any changes made via Edit button are included in PDF
                                final box = Hive.box('characters');
                                final latestData = box.get(c.id);
                                if (latestData == null) {
                                  throw Exception(
                                    'Character not found in database',
                                  );
                                }
                                final latestCharacter = Character.fromJson(
                                  Map<String, dynamic>.from(latestData),
                                );

                                debugPrint(
                                  '=== PDF Export - Fresh Data Load ===',
                                );
                                debugPrint('Character ID: ${c.id}');
                                debugPrint(
                                  'Weapons: ${latestCharacter.inventory['loadoutWeapons']}',
                                );
                                debugPrint(
                                  'Equipment: ${latestCharacter.inventory['selectedEquipment']}',
                                );
                                debugPrint(
                                  'Custom Weapons: ${latestCharacter.inventory['customWeapons']}',
                                );

                                final path =
                                    await PdfCharacterSheetService.exportCharacterSheet(
                                      latestCharacter, // Use fresh data, not stale `c`
                                    );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Character sheet exported: ${path.split('\n').first}',
                                      ),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Export failed: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          : null,
                      icon: Icon(
                        Icons.picture_as_pdf,
                        color: _isSaved ? Colors.white : Colors.grey.shade400,
                      ),
                      label: Text(
                        _isSaved ? 'Export to PDF' : 'Export (Save First)',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: _isSaved
                            ? Colors.red.shade700
                            : Colors.grey.shade300,
                        foregroundColor: _isSaved
                            ? Colors.white
                            : Colors.grey.shade600,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final choice = await showDialog<String>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Edit Character'),
                            content: const Text(
                              'Which section would you like to edit?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'enlistment'),
                                child: const Text('Enlistment'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'deployments'),
                                child: const Text('Deployments'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'abilities'),
                                child: const Text('Abilities & Narrative'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'inventory'),
                                child: const Text('Inventory'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        );

                        if (choice == 'enlistment') {
                          await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EnlistmentScreen(characterId: c.id),
                            ),
                          );
                        } else if (choice == 'deployments') {
                          await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DeploymentsScreen(characterId: c.id),
                            ),
                          );
                        } else if (choice == 'abilities') {
                          await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AbilitiesNarrativeScreen(characterId: c.id),
                            ),
                          );
                        } else if (choice == 'inventory') {
                          await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  InventoryEquipmentScreen(characterId: c.id),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // Verify character is saved before returning
                        final box = Hive.box('characters');
                        final saved = box.get(c.id);

                        debugPrint('=== Return to Roster - Verifying Save ===');
                        debugPrint('Character ID: ${c.id}');
                        debugPrint('Character in Hive: ${saved != null}');
                        if (saved != null) {
                          debugPrint(
                            'Saved attributes: ${saved['attributes']}',
                          );
                          debugPrint('Saved skills: ${saved['skills']}');
                          debugPrint(
                            'Saved rank: ${saved['enlistment']?['rank']}',
                          );
                        }

                        if (saved == null) {
                          // Character not saved - show warning
                          final shouldSave = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Character Not Saved!'),
                              content: const Text(
                                'Your character has not been saved to the roster yet.\n\nWould you like to save it now?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Exit Without Saving'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Save Now'),
                                ),
                              ],
                            ),
                          );

                          if (shouldSave == true) {
                            debugPrint('User chose to save character');
                            await box.put(c.id, c.toJson());

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Character saved successfully!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else if (shouldSave == false) {
                            // User chose to exit without saving - show final confirmation
                            final finalConfirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Exit'),
                                content: const Text(
                                  'Are you sure you want to exit WITHOUT saving?\n\nYour character will be lost!',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Go Back'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Exit Without Saving'),
                                  ),
                                ],
                              ),
                            );

                            if (finalConfirm != true) {
                              return; // Don't exit if user cancels
                            }
                          } else {
                            return; // User dismissed dialog, don't exit
                          }
                        } else {
                          // Character is already saved - show reminder popup
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Return to Roster?'),
                              content: const Text(
                                'Your character is saved!\n\nReady to return to the roster?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Stay Here'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Return to Roster'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed != true) {
                            return; // Don't exit if user cancels
                          }
                        }

                        if (mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/dashboard',
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Return to Roster'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ), // Scaffold
    ); // CharacterCreationLayout
  }

  Widget _buildDossierPreview(Character c) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DOSSIER PREVIEW',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(),
            const SizedBox(height: 12),

            // Narrative (if available)
            if (c.enlistment['narrative'] != null &&
                c.enlistment['narrative'].toString().isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.shade200, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_stories,
                          color: Colors.amber.shade900,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'NARRATIVE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c.enlistment['narrative'].toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Specialty Hook
            if (c.specialtyHook.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.military_tech,
                      color: Colors.purple.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SPECIALTY HOOK',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c.specialtyHook,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Key Stats
            _buildInfoRow('Service', '${c.enlistment['service'] ?? 'N/A'}'),
            _buildInfoRow('Rank', '${c.enlistment['rank'] ?? 'N/A'}'),
            _buildInfoRow('Specialty', '${c.enlistment['specialty'] ?? 'N/A'}'),
            if (c.isSOF) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.military_tech,
                      color: Colors.red.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SPECIAL OPERATIONS FORCES (SOF)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),

            // Canine Companion
            if (c.canineName.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.pets, color: Colors.orange.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CANINE COMPANION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${c.canineName} (${c.canineBreed})',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Attributes Summary
            if (c.attributes.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Attributes',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: c.attributes.entries.map((e) {
                  return Container(
                    constraints: const BoxConstraints(
                      minWidth: 80,
                      maxWidth: 140,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            e.key,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${e.value}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],

            // Abilities Summary
            if (c.enlistment['abilities'] != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Abilities',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: (c.enlistment['abilities'] as Map).entries.map((e) {
                  return Container(
                    constraints: const BoxConstraints(
                      minWidth: 80,
                      maxWidth: 140,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            e.key.toString(),
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${e.value}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],

            // Equipment Summary
            if (c.enlistment['inventory'] != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Equipment',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              if ((c.enlistment['inventory'] as Map)['loadoutWeapons'] !=
                      null &&
                  ((c.enlistment['inventory'] as Map)['loadoutWeapons'] as List)
                      .isNotEmpty) ...[
                _buildInfoRow(
                  'Weapons',
                  ((c.enlistment['inventory'] as Map)['loadoutWeapons'] as List)
                      .join(', '),
                ),
              ],
              if ((c.enlistment['inventory'] as Map)['customWeapons'] != null &&
                  ((c.enlistment['inventory'] as Map)['customWeapons'] as List)
                      .isNotEmpty) ...[
                _buildInfoRow(
                  'Custom Weapons',
                  ((c.enlistment['inventory'] as Map)['customWeapons'] as List)
                      .join(', '),
                ),
              ],
              if ((c.enlistment['inventory'] as Map)['equipment'] != null &&
                  ((c.enlistment['inventory'] as Map)['equipment'] as List)
                      .isNotEmpty) ...[
                _buildInfoRow(
                  'Equipment',
                  ((c.enlistment['inventory'] as Map)['equipment'] as List)
                      .join(', '),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
