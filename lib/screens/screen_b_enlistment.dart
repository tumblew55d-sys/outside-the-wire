import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/character.dart';
import '../data/nationality_data.dart';
import '../services/quick_build_service.dart';
import '../services/firebase_service.dart';
import 'screen_c_deployments.dart';
import 'screen_f_final_review.dart';

class EnlistmentScreen extends StatefulWidget {
  final String characterId;

  const EnlistmentScreen({super.key, required this.characterId});

  @override
  State<EnlistmentScreen> createState() => _EnlistmentScreenState();
}

class _EnlistmentScreenState extends State<EnlistmentScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _service;
  String? _rankType; // 'Enlisted' or 'Officer'
  String _enlistedRank = 'Private (E-1)';
  String _officerRank = '2nd Lieutenant (O-1)';
  String? _militarySpecialty;
  final bool _isSOF = false;
  String _characterHook = '';
  String? _hookSelection; // 'roll', 'choose', or 'custom'
  bool _showCustomHook = false;
  final _customHookController = TextEditingController();

  // Attributes
  int _remainingPoints = 22;
  final Map<String, int> _attributes = {
    'Strength': 0,
    'Agility': 0,
    'Combat Wisdom': 0,
    'Combat Knowledge': 0,
  };

  // Skills
  final Map<String, int> _skills = {
    'Small Arms': 0,
    'Heavy Weapons': 0,
    'First Aid': 0,
    'Radio Ops': 0,
    'Civil Affairs': 0,
    'Spying': 0,
    'Fires': 0,
    'Signals Intel': 0,
    'Explosives': 0,
  };

  // Experience
  final Map<String, int> _experience = {'Combat': 0, 'Training': 0};

  bool _saving = false;
  Character? _character;

  @override
  void initState() {
    super.initState();
    _loadCharacter();
  }

  @override
  void dispose() {
    _customHookController.dispose();
    super.dispose();
  }

  Future<void> _loadCharacter() async {
    final box = Hive.box('characters');
    final data = box.get(widget.characterId);
    if (data != null) {
      setState(() {
        _character = Character.fromJson(Map<String, dynamic>.from(data));

        // Initialize skills with background bonuses from character creation
        if (_character!.skills.isNotEmpty) {
          _skills.addAll(_character!.skills);
        }

        // Initialize default ranks based on nationality
        final enlistedRanks = NationalityData.getInitialEnlistedRanks(
          _character!.nationality,
        )['ranks']!;
        final officerRanks = NationalityData.getInitialOfficerRanks(
          _character!.nationality,
        )['ranks']!;
        _enlistedRank = enlistedRanks.isNotEmpty
            ? enlistedRanks.first
            : 'Private';
        _officerRank = officerRanks.isNotEmpty
            ? officerRanks.first
            : 'Lieutenant';

        // Don't load attributes from character - they should be allocated fresh in enlistment
        // Background bonuses to attributes will be added during save
      });
    }
  }

  /// Apply specialty bonuses to skills
  void _applySpecialtyBonuses(String? specialty) {
    // Reset specialty skills (keep background bonuses)
    final backgroundSkills = Map<String, int>.from(_character?.skills ?? {});
    _skills.forEach((key, value) => _skills[key] = backgroundSkills[key] ?? 0);

    if (specialty == null) return;

    if (specialty.contains('Rifleman')) {
      _skills['Small Arms'] = (_skills['Small Arms'] ?? 0) + 3;
      _skills['Heavy Weapons'] = (_skills['Heavy Weapons'] ?? 0) + 1;
      _skills['First Aid'] = (_skills['First Aid'] ?? 0) + 1;
    } else if (specialty.contains('Heavy Weapons')) {
      _skills['Heavy Weapons'] = (_skills['Heavy Weapons'] ?? 0) + 3;
      _skills['Small Arms'] = (_skills['Small Arms'] ?? 0) + 1;
      _skills['First Aid'] = (_skills['First Aid'] ?? 0) + 1;
    } else if (specialty.contains('Sniper')) {
      _skills['Small Arms'] = (_skills['Small Arms'] ?? 0) + 4;
      _skills['Radio Ops'] = (_skills['Radio Ops'] ?? 0) + 1;
      _skills['First Aid'] = (_skills['First Aid'] ?? 0) + 1;
    } else if (specialty.contains('Radio Operator')) {
      _skills['Radio Ops'] = (_skills['Radio Ops'] ?? 0) + 3;
      _skills['Small Arms'] = (_skills['Small Arms'] ?? 0) + 1;
      _skills['First Aid'] = (_skills['First Aid'] ?? 0) + 1;
    } else if (specialty.contains('Signals/Cyber Intel')) {
      _skills['Signals Intel'] = (_skills['Signals Intel'] ?? 0) + 3;
      _skills['Small Arms'] = (_skills['Small Arms'] ?? 0) + 1;
      _skills['Radio Ops'] = (_skills['Radio Ops'] ?? 0) + 1;
    } else if (specialty.contains('Medical')) {
      _skills['First Aid'] = (_skills['First Aid'] ?? 0) + 3;
      _skills['Small Arms'] = (_skills['Small Arms'] ?? 0) + 1;
    } else if (specialty.contains('Civil Affairs')) {
      _skills['Civil Affairs'] = (_skills['Civil Affairs'] ?? 0) + 3;
      _skills['Small Arms'] = (_skills['Small Arms'] ?? 0) + 1;
      _skills['First Aid'] = (_skills['First Aid'] ?? 0) + 1;
    } else if (specialty.contains('JTAC')) {
      _skills['Fires'] = (_skills['Fires'] ?? 0) + 3;
      _skills['Small Arms'] = (_skills['Small Arms'] ?? 0) + 1;
      _skills['Radio Ops'] = (_skills['Radio Ops'] ?? 0) + 1;
    } else if (specialty.contains('EOD')) {
      _skills['Explosives'] = (_skills['Explosives'] ?? 0) + 3;
      _skills['Small Arms'] = (_skills['Small Arms'] ?? 0) + 1;
      _skills['First Aid'] = (_skills['First Aid'] ?? 0) + 1;
    } else if (specialty.contains('Agent')) {
      _skills['Spying'] = (_skills['Spying'] ?? 0) + 3;
      _skills['Small Arms'] = (_skills['Small Arms'] ?? 0) + 1;
      _skills['Civil Affairs'] = (_skills['Civil Affairs'] ?? 0) + 1;
    }
  }

  /// Roll 1D10 for attributes
  void _rollAttributes() {
    final random = Random();
    final rolls = List.generate(4, (index) => random.nextInt(10) + 1);

    showDialog(
      context: context,
      builder: (context) => _AttributeRollDialog(
        rolls: rolls,
        onAssign: (assignments) {
          if (mounted) {
            setState(() {
              _attributes['Strength'] = assignments['Strength'] ?? 0;
              _attributes['Agility'] = assignments['Agility'] ?? 0;
              _attributes['Combat Wisdom'] = assignments['Combat Wisdom'] ?? 0;
              _attributes['Combat Knowledge'] =
                  assignments['Combat Knowledge'] ?? 0;
              _remainingPoints = 0;
            });
          }
        },
        onReroll: () {
          Navigator.of(context).pop();
          _rollAttributes();
        },
      ),
    );
  }

  /// Get attribute descriptor
  String _getAttributeDescription(String attribute) {
    if (attribute == 'Strength') {
      return 'Weight lift, running speed, throwing distance, damage taken';
    } else if (attribute == 'Agility') {
      return 'Manual dexterity, agility, balance. Affects climbing, jumping, etc.';
    } else if (attribute == 'Combat Wisdom') {
      return 'Abstract reasoning, connecting multiple inputs/events';
    } else if (attribute == 'Combat Knowledge') {
      return 'Alertness and streetwise to notice environmental changes';
    }
    return '';
  }

  String _getAttributeDescriptor(String attribute, int value) {
    if (attribute == 'Strength') {
      if (value <= 3) return 'Scrawny';
      if (value <= 6) return 'Average';
      if (value <= 8) return 'Strong';
      return 'Beast';
    } else if (attribute == 'Agility') {
      if (value <= 3) return 'Clumsy';
      if (value <= 6) return 'Average';
      if (value <= 8) return 'Nimble';
      return 'Ninja';
    } else if (attribute == 'Combat Wisdom') {
      if (value <= 3) return 'Slow minded... Gets there eventually';
      if (value <= 6) return 'Average';
      if (value <= 8) return 'Smart';
      return 'Wicked smart';
    } else if (attribute == 'Combat Knowledge') {
      if (value <= 3) return 'None... human bait';
      if (value <= 6) return 'Average';
      if (value <= 8) return 'Cat-like reflexes';
      return 'Killer Instincts';
    }
    return '';
  }

  /// Show Quick Build specialty selection dialog
  Future<void> _showQuickBuildDialog() async {
    final specialty = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Build - Select MOS'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Basic Infantry:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildQuickBuildOption('Rifleman'),
              _buildQuickBuildOption('Heavy Weapons'),
              _buildQuickBuildOption('Sniper'),
              const SizedBox(height: 16),
              const Text(
                'Support:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildQuickBuildOption('Radio Operator'),
              _buildQuickBuildOption('Signals/Cyber Intel'),
              _buildQuickBuildOption('Medical'),
              _buildQuickBuildOption('Civil Affairs'),
              const SizedBox(height: 16),
              const Text(
                'Advanced (Auto-generated path):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildQuickBuildOption('EOD', isAdvanced: true),
              _buildQuickBuildOption('JTAC', isAdvanced: true),
              _buildQuickBuildOption('SOF', isAdvanced: true),
              _buildQuickBuildOption('Agent', isAdvanced: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );

    if (specialty != null && mounted) {
      await _executeQuickBuild(specialty);
    }
  }

  /// Build a quick build specialty option
  Widget _buildQuickBuildOption(String specialty, {bool isAdvanced = false}) {
    return ListTile(
      leading: Icon(
        isAdvanced ? Icons.military_tech : Icons.person,
        color: isAdvanced ? Colors.orange : Colors.blue,
      ),
      title: Text(specialty),
      subtitle: isAdvanced
          ? const Text(
              'Requires prerequisites',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            )
          : null,
      onTap: () => Navigator.pop(context, specialty),
    );
  }

  /// Execute quick build for selected specialty
  Future<void> _executeQuickBuild(String specialty) async {
    setState(() => _saving = true);

    try {
      final box = Hive.box('characters');
      final data = box.get(widget.characterId);
      if (data == null) throw Exception('Character not found');

      final baseCharacter = Character.fromJson(Map<String, dynamic>.from(data));

      // Show progress dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Generating character...'),
              ],
            ),
          ),
        );
      }

      // Generate character using quick build service
      final character = await QuickBuildService.generateQuickCharacter(
        widget.characterId,
        specialty,
        baseCharacter,
      );

      // Debug: Check what was generated
      debugPrint('=== Quick Build Complete ===');
      debugPrint('Character ID: ${character.id}');
      debugPrint('Name: ${character.name}');
      debugPrint('Attributes: ${character.attributes}');
      debugPrint('Skills: ${character.skills}');
      debugPrint('Enlistment: ${character.enlistment}');
      debugPrint('Inventory: ${character.inventory}');
      debugPrint('isSOF: ${character.isSOF}');

      // Save to Hive
      final jsonData = character.toJson();
      debugPrint('=== Saving to Hive ===');
      debugPrint('JSON attributes: ${jsonData['attributes']}');
      debugPrint('JSON skills: ${jsonData['skills']}');
      await box.put(widget.characterId, jsonData);

      // Force Hive to flush to disk to ensure data is persisted
      await box.flush();
      debugPrint('=== Hive flushed to disk ===');

      // Save to Firebase (best effort)
      try {
        await FirebaseService.saveCharacterToCloud(
          widget.characterId,
          jsonData,
        );
        debugPrint('=== Saved to Firebase ===');
      } catch (e) {
        debugPrint('Firebase save failed (will sync later): $e');
      }

      // Verify save
      final saved = box.get(widget.characterId);
      debugPrint('=== Verified from Hive ===');
      debugPrint('Saved attributes: ${saved['attributes']}');
      debugPrint('Saved skills: ${saved['skills']}');

      if (mounted) {
        // Close progress dialog
        Navigator.pop(context);

        // Show success and navigate to final review
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$specialty character generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to final review screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                FinalReviewScreen(characterId: widget.characterId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quick build failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;
    if (_remainingPoints > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please allocate all $_remainingPoints attribute points',
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final box = Hive.box('characters');
      final data = box.get(widget.characterId);
      if (data == null) throw Exception('Character not found');

      final character = Character.fromJson(Map<String, dynamic>.from(data));

      // Get background bonuses from character creation
      final backgroundAttributes = Map<String, int>.from(character.attributes);
      final backgroundSkills = Map<String, int>.from(character.skills);

      // Start with allocated attributes and add background bonuses
      final finalAttributes = Map<String, int>.from(_attributes);
      backgroundAttributes.forEach((key, value) {
        finalAttributes[key] = (finalAttributes[key] ?? 0) + value;
      });

      // Apply officer bonuses if selected
      if (_rankType == 'Officer') {
        finalAttributes['Strength'] = (finalAttributes['Strength'] ?? 0) + 1;
        finalAttributes['Agility'] = (finalAttributes['Agility'] ?? 0) + 1;
        finalAttributes['Combat Knowledge'] =
            (finalAttributes['Combat Knowledge'] ?? 0) + 1;
        character.age = 21; // Officers start at age 21
      } else {
        character.age =
            character.age + 4; // Add 4 years for enlisted after basic training
      }

      // Apply SOF bonuses if selected
      if (_isSOF) {
        _experience['Training'] = (_experience['Training'] ?? 0) + 1;
      }

      // Combine background skills with enlistment skills (specialty bonuses already in _skills)
      final finalSkills = Map<String, int>.from(_skills);
      backgroundSkills.forEach((key, value) {
        finalSkills[key] = (finalSkills[key] ?? 0) + value;
      });

      // Determine final rank (with SOF promotion if applicable)
      String finalRank = _rankType == 'Officer' ? _officerRank : _enlistedRank;
      if (_isSOF) {
        // Get the appropriate rank list based on rank type
        final ranks = _rankType == 'Officer'
            ? NationalityData.getInitialOfficerRanks(
                character.nationality,
              )['ranks']!
            : NationalityData.getInitialEnlistedRanks(
                character.nationality,
              )['ranks']!;

        // Find current rank index and promote by one level if possible
        final currentIndex = ranks.indexOf(finalRank);
        if (currentIndex >= 0 && currentIndex < ranks.length - 1) {
          finalRank = ranks[currentIndex + 1];
        }
      }

      // Determine final specialty name (add SOF prefix if applicable)
      String finalSpecialty = _militarySpecialty ?? '';
      if (_isSOF && !finalSpecialty.startsWith('SOF ')) {
        final specialtyName = finalSpecialty.split(' ').first;
        finalSpecialty = 'SOF $specialtyName';
      }

      // Update character
      character.attributes = finalAttributes;
      character.skills = finalSkills;
      character.isSOF = _isSOF;
      character.specialtyHook = _showCustomHook
          ? _customHookController.text.trim()
          : _characterHook;
      character.enlistment = {
        'service': _service ?? '',
        'rankType': _rankType ?? '',
        'rank': finalRank,
        'specialty': finalSpecialty,
        'experience': Map<String, int>.from(_experience),
        // Store base values for Screen C to reset from
        'baseAttributes': Map<String, int>.from(finalAttributes),
        'baseSkills': Map<String, int>.from(finalSkills),
      };
      character.modifiedAt = DateTime.now();

      debugPrint('Saving enlistment for ${character.name}:');
      debugPrint('  Service: $_service, Rank: $finalRank');
      debugPrint('  Specialty: $finalSpecialty, SOF: $_isSOF');
      debugPrint('  Hook: ${character.characterHook}');
      debugPrint('  Attributes: $finalAttributes');
      debugPrint('  Skills: $finalSkills');

      await box.put(widget.characterId, character.toJson());
      debugPrint(
        'Enlistment saved successfully for character ${widget.characterId}',
      );

      if (mounted) {
        // Navigate to Screen C (Deployments)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                DeploymentsScreen(characterId: widget.characterId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_character == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Enlistment')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Enlistment Selection')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enlisting: ${_character!.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Service Selection
              DropdownButtonFormField<String>(
                initialValue: _service,
                decoration: const InputDecoration(labelText: 'Select Service'),
                items: const ['Army', 'Navy', 'Marines']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() {
                  _service = v;
                  // Reset ranks when service changes
                  if (_character != null) {
                    if (v == 'Navy') {
                      _enlistedRank =
                          NationalityData.getInitialNavyEnlistedRanks(
                            _character!.nationality,
                          )['ranks']!.first;
                      _officerRank = NationalityData.getInitialNavyOfficerRanks(
                        _character!.nationality,
                      )['ranks']!.first;
                    } else {
                      _enlistedRank = NationalityData.getInitialEnlistedRanks(
                        _character!.nationality,
                      )['ranks']!.first;
                      _officerRank = NationalityData.getInitialOfficerRanks(
                        _character!.nationality,
                      )['ranks']!.first;
                    }
                  }
                }),
                validator: (v) => v == null ? 'Select a service' : null,
              ),
              const SizedBox(height: 12),

              // Rank Type Selection
              DropdownButtonFormField<String>(
                initialValue: _rankType,
                decoration: const InputDecoration(
                  labelText: 'Rank Type',
                  helperText: 'Officer: Age 21, +1 Strength/Agility/Knowledge',
                ),
                items: const ['Enlisted', 'Officer']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() {
                  _rankType = v;
                  // Reset ranks when rank type changes
                  if (_character != null) {
                    if (_service == 'Navy') {
                      _enlistedRank =
                          NationalityData.getInitialNavyEnlistedRanks(
                            _character!.nationality,
                          )['ranks']!.first;
                      _officerRank = NationalityData.getInitialNavyOfficerRanks(
                        _character!.nationality,
                      )['ranks']!.first;
                    } else {
                      _enlistedRank = NationalityData.getInitialEnlistedRanks(
                        _character!.nationality,
                      )['ranks']!.first;
                      _officerRank = NationalityData.getInitialOfficerRanks(
                        _character!.nationality,
                      )['ranks']!.first;
                    }
                  }
                }),
                validator: (v) => v == null ? 'Select rank type' : null,
              ),
              const SizedBox(height: 12),

              // Conditional Rank Selection
              if (_rankType == 'Enlisted' && _character != null)
                DropdownButtonFormField<String>(
                  key: const Key('enlisted_rank'),
                  initialValue: _enlistedRank,
                  decoration: const InputDecoration(
                    labelText: 'Enlisted Rank',
                    helperText: 'Can change due to deployment results',
                  ),
                  items: _service == 'Navy'
                      ? NationalityData.getInitialNavyEnlistedRanks(
                              _character!.nationality,
                            )['ranks']!
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList()
                      : NationalityData.getInitialEnlistedRanks(
                              _character!.nationality,
                            )['ranks']!
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                  onChanged: (v) => setState(() {
                    if (v != null) _enlistedRank = v;
                  }),
                ),

              if (_rankType == 'Officer' && _character != null)
                DropdownButtonFormField<String>(
                  key: const Key('officer_rank'),
                  initialValue: _officerRank,
                  decoration: const InputDecoration(
                    labelText: 'Officer Rank',
                    helperText: 'Can change due to deployment results',
                  ),
                  items: _service == 'Navy'
                      ? NationalityData.getInitialNavyOfficerRanks(
                              _character!.nationality,
                            )['ranks']!
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList()
                      : NationalityData.getInitialOfficerRanks(
                              _character!.nationality,
                            )['ranks']!
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                  onChanged: (v) => setState(() {
                    if (v != null) _officerRank = v;
                  }),
                ),
              const SizedBox(height: 12),

              // Military Specialty
              DropdownButtonFormField<String>(
                initialValue: _militarySpecialty,
                decoration: const InputDecoration(
                  labelText: 'Military Specialty',
                  helperText:
                      'JTAC, EOD, and Agent available through deployments',
                ),
                items: const [
                  'Rifleman (Small Arms 3, Heavy Weapons 1, First Aid 1, Tactics +1)',
                  'Heavy Weapons (Heavy Weapons 3, Small Arms 1, First Aid 1)',
                  'Sniper (Small Arms 4, Communications 1, First Aid 1)',
                  'Radio Operator (Communications 3, Small Arms 1, First Aid 1)',
                  'Signals/Cyber Intel (Signals Intel 3, Small Arms 1, Communications 1)',
                  'Medical (First Aid 3, Small Arms 1)',
                  'Civil Affairs (Civil Affairs 3, Small Arms 1, First Aid 1)',
                ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) {
                  setState(() {
                    _militarySpecialty = v;
                    _applySpecialtyBonuses(v);
                    // Reset hook when specialty changes
                    _characterHook = '';
                    _hookSelection = null;
                    _showCustomHook = false;
                    _customHookController.clear();
                  });
                },
                validator: (v) => v == null ? 'Select specialty' : null,
              ),
              const SizedBox(height: 20),

              // Quick Build Option
              if (_militarySpecialty != null) ...[
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Quick Build Available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Auto-generate a complete character with appropriate gear, '
                          'deployments, and backstory. Or continue manually.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _showQuickBuildDialog,
                                icon: const Icon(Icons.flash_on),
                                label: const Text('QUICK BUILD'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // User chooses manual - just close this hint
                                  setState(() {});
                                },
                                icon: const Icon(Icons.build),
                                label: const Text('MANUAL BUILD'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Character Hook Selection
              if (_militarySpecialty != null) ...[
                const Text(
                  'Character Hook',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _hookSelection,
                  decoration: const InputDecoration(
                    labelText: 'Hook Selection Method',
                    helperText: 'Choose how to select your character hook',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'roll',
                      child: Text('Roll Random (1D10)'),
                    ),
                    DropdownMenuItem(
                      value: 'choose',
                      child: Text('Choose from List'),
                    ),
                    DropdownMenuItem(
                      value: 'custom',
                      child: Text('Custom (Write Your Own)'),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _hookSelection = v;
                      if (v == 'roll') {
                        final specialty = _militarySpecialty!.split(' ').first;
                        _characterHook = NationalityData.getRandomHook(
                          specialty,
                        );
                        _showCustomHook = false;
                      } else if (v == 'choose') {
                        _characterHook = '';
                        _showCustomHook = false;
                      } else if (v == 'custom') {
                        _characterHook = '';
                        _showCustomHook = true;
                      }
                    });
                  },
                ),
                const SizedBox(height: 8),

                // Show hook options based on selection
                if (_hookSelection == 'roll' && _characterHook.isNotEmpty) ...[
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(_characterHook),
                    ),
                  ),
                ],

                if (_hookSelection == 'choose') ...[
                  DropdownButtonFormField<String>(
                    initialValue: _characterHook.isEmpty
                        ? null
                        : _characterHook,
                    decoration: const InputDecoration(
                      labelText: 'Select Your Hook',
                    ),
                    items:
                        NationalityData.getSpecialtyHooks(
                              _militarySpecialty!.split(' ').first,
                            )
                            .map(
                              (hook) => DropdownMenuItem(
                                value: hook,
                                child: Text(hook),
                              ),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _characterHook = v ?? ''),
                  ),
                ],

                if (_showCustomHook) ...[
                  TextFormField(
                    controller: _customHookController,
                    decoration: const InputDecoration(
                      labelText: 'Custom Character Hook',
                      helperText: 'Write your own unique character hook',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (v) => _characterHook = v,
                  ),
                ],
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 20),

              // Military Skills Section
              Text(
                'Military Skills',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(),
              ..._skills.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.key)),
                      Text(
                        '${e.value}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Roll button (moved above attributes)
              OutlinedButton.icon(
                onPressed: _rollAttributes,
                icon: const Icon(Icons.casino),
                label: const Text('Roll 1D10 for Attributes (Random)'),
              ),
              const SizedBox(height: 20),

              // Attributes Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Attributes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Points remaining: $_remainingPoints',
                    style: TextStyle(
                      color: _remainingPoints > 0
                          ? Colors.orange
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(),

              // Manual attribute allocation
              ..._attributes.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _getAttributeDescription(e.key),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: e.value > 0
                                ? () {
                                    setState(() {
                                      _attributes[e.key] = e.value - 1;
                                      _remainingPoints++;
                                    });
                                  }
                                : null,
                          ),
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                              '${e.value}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: _remainingPoints > 0
                                ? () {
                                    setState(() {
                                      _attributes[e.key] = e.value + 1;
                                      _remainingPoints--;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                      if (e.value > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            _getAttributeDescriptor(e.key, e.value),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Next button
              ElevatedButton.icon(
                onPressed: _saving ? null : _saveAndContinue,
                icon: const Icon(Icons.arrow_forward),
                label: Text(_saving ? 'Saving...' : 'Next: Deployments'),
              ),
              const SizedBox(height: 8),
              // Back button
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back: Basic Info'),
              ),
              const SizedBox(height: 8),
              // Save button
              OutlinedButton.icon(
                onPressed: _saving
                    ? null
                    : () async {
                        await _saveAndContinue();
                        if (mounted) {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        }
                      },
                icon: const Icon(Icons.save),
                label: const Text('Save & Return to Roster'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dialog for attribute roll assignment
class _AttributeRollDialog extends StatefulWidget {
  final List<int> rolls;
  final Function(Map<String, int>) onAssign;
  final VoidCallback onReroll;

  const _AttributeRollDialog({
    required this.rolls,
    required this.onAssign,
    required this.onReroll,
  });

  @override
  State<_AttributeRollDialog> createState() => _AttributeRollDialogState();
}

class _AttributeRollDialogState extends State<_AttributeRollDialog> {
  // Track which roll index is assigned to which attribute
  final Map<String, int?> assignedRollIndices = {
    'Strength': null,
    'Agility': null,
    'Combat Wisdom': null,
    'Combat Knowledge': null,
  };

  @override
  Widget build(BuildContext context) {
    final allAssigned = assignedRollIndices.values.every((v) => v != null);

    // Get list of available (unassigned) roll indices
    final usedIndices = assignedRollIndices.values
        .where((v) => v != null)
        .toSet();
    final availableIndices = List.generate(
      4,
      (i) => i,
    ).where((i) => !usedIndices.contains(i)).toList();

    return AlertDialog(
      title: const Text('Assign Attribute Rolls'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rolled: ${widget.rolls.join(', ')}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...assignedRollIndices.keys.map((key) {
              final currentIndex = assignedRollIndices[key];

              // Build dropdown items: available indices + current selection
              final optionIndices = [
                ...availableIndices,
                if (currentIndex != null) currentIndex,
              ]..sort((a, b) => widget.rolls[b].compareTo(widget.rolls[a]));

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(key)),
                    DropdownButton<int>(
                      value: currentIndex,
                      hint: const Text('Select roll'),
                      items: optionIndices
                          .map(
                            (idx) => DropdownMenuItem(
                              value: idx,
                              child: Text('${widget.rolls[idx]}'),
                            ),
                          )
                          .toList(),
                      onChanged: (newIndex) {
                        setState(() {
                          assignedRollIndices[key] = newIndex;
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: widget.onReroll,
          icon: const Icon(Icons.refresh),
          label: const Text('Re-roll'),
        ),
        ElevatedButton(
          onPressed: allAssigned
              ? () {
                  // Convert indices to actual values
                  final values = <String, int>{};
                  assignedRollIndices.forEach((key, idx) {
                    if (idx != null) {
                      values[key] = widget.rolls[idx];
                    }
                  });
                  widget.onAssign(values);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Assign'),
        ),
      ],
    );
  }
}
