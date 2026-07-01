import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/character.dart';
import '../services/firebase_service.dart';
import '../data/nationality_data.dart';
import '../widgets/character_creation_layout.dart';

class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _ageController = TextEditingController(text: '17');
  final _homeLocationController = TextEditingController();
  String? _nationality;
  String _height = 'Standard (Avg)';
  final _weightController = TextEditingController();
  String _weightUnit = 'kg';
  final _languagesController = TextEditingController();
  String _motivation = '';
  String _background = '';
  String _trademark = '';
  String _personalConflict = '';
  final _customMotivationController = TextEditingController();
  final _customBackgroundController = TextEditingController();
  final _customTrademarkController = TextEditingController();
  final _customPersonalConflictController = TextEditingController();
  bool _showCustomMotivation = false;
  bool _showCustomBackground = false;
  bool _showCustomTrademark = false;
  bool _showCustomPersonalConflict = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _ageController.dispose();
    _homeLocationController.dispose();
    _weightController.dispose();
    _languagesController.dispose();
    _customMotivationController.dispose();
    _customBackgroundController.dispose();
    _customTrademarkController.dispose();
    _customPersonalConflictController.dispose();
    super.dispose();
  }

  void _rollMotivation() {
    final motivations = [
      'Duty & Service',
      'Survival & Self-Preservation',
      'Justice & Vengeance',
      'Career Ambition',
      'Humanitarian Idealism',
      'Thrill',
      'Challenge & Skill Mastery',
    ];
    final random = Random();
    setState(() {
      _showCustomMotivation = false;
      _motivation = motivations[random.nextInt(motivations.length)];
    });
  }

  void _rollBackground() {
    final backgrounds = [
      'Outdoor Hunter',
      'High School / College Athlete',
      'EMT / Medical Volunteer',
      'Mechanical / Electrical Worker',
      'Rural Farm Worker',
      'Debate Team / Political Organizer',
      'Construction Worker',
      'Streetwise Urban Survivor',
      'Computer Hobbyist / Hacker',
      'Volunteer Firefighter',
      'Amateur Radio Operator',
      'NGO Volunteer / Aid Worker',
      'Amateur Boxer / Martial Artist',
      'Former Delivery Bicyclist / Motorcyclist',
      'Range Enthusiast / Competitive Shooter',
      'Engineering Student',
      'Lifeguard',
      'Security Guard / Mall Cop',
      'Eagle Scout / Outdoor Program',
    ];
    final random = Random();
    setState(() {
      _showCustomBackground = false;
      _background = backgrounds[random.nextInt(backgrounds.length)];
    });
  }

  void _rollPersonalConflict() {
    final conflicts = [
      'You believe your unit is being set up by higher command.',
      'You promised a local child you\'d return, but you know you can\'t.',
      'You\'re hiding an injury that flares at the worst possible moments.',
      'You distrust your team leader after a past mistake.',
      'You\'re secretly passing intel to another agency or faction.',
      'You suspect someone in your squad is stealing gear or rations.',
      'You\'re terrified of freezing under fire again.',
      'Your family back home is falling apart, and you can\'t help them.',
      'You owe a dangerous favor to a fixer, smuggler, or warlord.',
      'A comrade saved your life, you feel intense obligation.',
      'You\'re haunted by an operation gone wrong and hide your nightmares.',
      'You\'re developing feelings for someone on base, complicating ops.',
      'You believe your weapon or gear is faulty, but supply won\'t replace it.',
      'You think one of your teammates is unstable and hiding something.',
      'You\'re questioning the mission\'s legitimacy and your role in it.',
      'You\'re covering up a mistake that could compromise the unit.',
      'A local elder entrusted you with a secret you must not reveal.',
      'You\'re unsure if an ally militia can be trusted, or if they want you dead.',
      'You fear you\'re becoming too good at killing.',
    ];
    final random = Random();
    setState(() {
      _showCustomPersonalConflict = false;
      _personalConflict = conflicts[random.nextInt(conflicts.length)];
    });
  }

  void _rollTrademark() {
    final trademarks = [
      'Copenhagen can / tobacco tin',
      'Pack of cheap cigarettes or vape pen',
      'Non-issued scarf / shemagh',
      'Killed In Action memorial bracelet',
      'Photo of loved ones',
      'Beat-up baseball cap',
      'Lucky multitool or pocketknife',
      'Dog tags from someone else',
      'Custom patch',
      'Keepsake necklace or charm',
      'Always humming or singing the same tune',
      'Ritualistic weapon check',
      'Superstition about stepping on cracks, graves, or trash',
      'Talks to equipment',
      'Collects sand from deployments',
      'Uses colorful slang or military sayings',
      'Refuses to eat certain rations',
      'Sketches or writes in a small notebooks',
      'Always the first to volunteer for point or rear guard',
      'Keeps a private "good luck ritual"',
    ];
    final random = Random();
    setState(() {
      _showCustomTrademark = false;
      _trademark = trademarks[random.nextInt(trademarks.length)];
    });
  }

  void _saveAndContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final character = Character(
        id: const Uuid().v4(),
        userId: currentUserId,
        name: _nameController.text.trim(),
        nickname: _nicknameController.text.trim(),
        age: int.tryParse(_ageController.text) ?? 17,
        homeLocation: _homeLocationController.text.trim(),
        nationality: _nationality ?? '',
        height: _height,
        weight: double.tryParse(_weightController.text) ?? 0.0,
        weightUnit: _weightUnit,
        languages: _languagesController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        motivation: _showCustomMotivation
            ? _customMotivationController.text.trim()
            : _motivation,
        background: _showCustomBackground
            ? _customBackgroundController.text.trim()
            : _background,
        trademark: _showCustomTrademark
            ? _customTrademarkController.text.trim()
            : _trademark,
        personalConflict: _showCustomPersonalConflict
            ? _customPersonalConflictController.text.trim()
            : _personalConflict,
      );

      // Save locally to Hive (local-first)
      final box = Hive.box('characters');
      box.put(character.id, character.toJson());

      // Attempt to save to Firestore if Firebase available (best-effort)
      try {
        FirebaseService.saveCharacterToCloud(character.id, character.toJson());
      } catch (e) {
        // ignore errors; will sync later
      }

      // Show saved confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Basic info saved'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Return the created character as result
      Navigator.of(context).pop(character);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create a preview character for live updates
    final previewCharacter = Character(
      id: 'preview',
      userId: '',
      name: _nameController.text.trim(),
      nickname: _nicknameController.text.trim(),
      age: int.tryParse(_ageController.text) ?? 0,
      homeLocation: _homeLocationController.text.trim(),
      nationality: _nationality ?? '',
      height: _height,
      weight: double.tryParse(_weightController.text) ?? 0.0,
      weightUnit: _weightUnit,
      languages: _languagesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      motivation: _showCustomMotivation
          ? _customMotivationController.text.trim()
          : _motivation,
      background: _showCustomBackground
          ? _customBackgroundController.text.trim()
          : _background,
      trademark: _showCustomTrademark
          ? _customTrademarkController.text.trim()
          : _trademark,
      personalConflict: _showCustomPersonalConflict
          ? _customPersonalConflictController.text.trim()
          : _personalConflict,
    );

    return CharacterCreationLayout(
      character: previewCharacter,
      child: Scaffold(
        appBar: AppBar(title: const Text('Basic Info')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Enter a name'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _nicknameController,
                          decoration: const InputDecoration(
                            labelText: 'Nickname',
                            hintText: 'Optional',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _nationality,
                    items: NationalityData.nationalities
                        .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                        .toList(),
                    onChanged: (v) => setState(() => _nationality = v),
                    decoration: const InputDecoration(
                      labelText: 'National Service',
                      helperText: 'Select your nation',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null ? 'Select national service' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _homeLocationController,
                    decoration: const InputDecoration(
                      labelText: 'Home Location',
                      helperText: 'City, State/Province',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _height,
                    items:
                        const [
                              'Compact (Short)',
                              'Standard (Avg)',
                              'Rangy (Tall)',
                              'Towering (V. Tall)',
                            ]
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _height = v ?? _height),
                    decoration: const InputDecoration(labelText: 'Height'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          decoration: const InputDecoration(
                            labelText: 'Weight',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _weightUnit,
                          items: const ['kg', 'lb']
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _weightUnit = v ?? _weightUnit),
                          decoration: const InputDecoration(labelText: 'Unit'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _languagesController,
                    decoration: const InputDecoration(
                      labelText: 'Languages (comma separated)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.casino),
                        tooltip: 'Roll Random',
                        onPressed: _rollMotivation,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _showCustomMotivation
                              ? 'Custom'
                              : (_motivation.isEmpty ? null : _motivation),
                          items:
                              const [
                                    'Duty & Service',
                                    'Survival & Self-Preservation',
                                    'Justice & Vengeance',
                                    'Career Ambition',
                                    'Humanitarian Idealism',
                                    'Thrill',
                                    'Challenge & Skill Mastery',
                                    'Custom',
                                  ]
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(() {
                            if (v == 'Custom') {
                              _showCustomMotivation = true;
                              _motivation = '';
                            } else {
                              _showCustomMotivation = false;
                              _motivation = v ?? '';
                            }
                          }),
                          decoration: const InputDecoration(
                            labelText: 'Motivation',
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_showCustomMotivation) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _customMotivationController,
                      decoration: const InputDecoration(
                        labelText: 'Custom Motivation',
                        hintText: 'Enter your custom motivation',
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.casino),
                        tooltip: 'Roll Random',
                        onPressed: _rollBackground,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _showCustomBackground
                              ? 'Custom'
                              : (_background.isEmpty ? null : _background),
                          items:
                              const [
                                    'Outdoor Hunter',
                                    'High School / College Athlete',
                                    'EMT / Medical Volunteer',
                                    'Mechanical / Electrical Worker',
                                    'Rural Farm Worker',
                                    'Debate Team / Political Organizer',
                                    'Construction Worker',
                                    'Streetwise Urban Survivor',
                                    'Computer Hobbyist / Hacker',
                                    'Volunteer Firefighter',
                                    'Amateur Radio Operator',
                                    'NGO Volunteer / Aid Worker',
                                    'Amateur Boxer / Martial Artist',
                                    'Former Delivery Bicyclist / Motorcyclist',
                                    'Range Enthusiast / Competitive Shooter',
                                    'Engineering Student',
                                    'Lifeguard',
                                    'Security Guard / Mall Cop',
                                    'Eagle Scout / Outdoor Program',
                                    'Custom',
                                  ]
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(() {
                            if (v == 'Custom') {
                              _showCustomBackground = true;
                              _background = '';
                            } else {
                              _showCustomBackground = false;
                              _background = v ?? '';
                            }
                          }),
                          decoration: const InputDecoration(
                            labelText: 'Background',
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_showCustomBackground) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _customBackgroundController,
                      decoration: const InputDecoration(
                        labelText: 'Custom Background',
                        hintText: 'Enter your custom background',
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.casino),
                        tooltip: 'Roll Random',
                        onPressed: _rollTrademark,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _showCustomTrademark
                              ? 'Custom'
                              : (_trademark.isEmpty ? null : _trademark),
                          items: const [
                            'Copenhagen can / tobacco tin',
                            'Pack of cheap cigarettes or vape pen',
                            'Non-issued scarf / shemagh',
                            'Killed In Action memorial bracelet',
                            'Photo of loved ones',
                            'Beat-up baseball cap',
                            'Lucky multitool or pocketknife',
                            'Dog tags from someone else',
                            'Custom patch',
                            'Keepsake necklace or charm',
                            'Always humming or singing the same tune',
                            'Ritualistic weapon check',
                            'Superstition about stepping on cracks, graves, or trash',
                            'Talks to equipment',
                            'Collects sand from deployments',
                            'Uses colorful slang or military sayings',
                            'Refuses to eat certain rations',
                            'Sketches or writes in a small notebooks',
                            'Always the first to volunteer for point or rear guard',
                            'Keeps a private "good luck ritual"',
                            'Custom',
                          ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setState(() {
                            if (v == 'Custom') {
                              _showCustomTrademark = true;
                              _trademark = '';
                            } else {
                              _showCustomTrademark = false;
                              _trademark = v ?? '';
                            }
                          }),
                          decoration: const InputDecoration(
                            labelText: 'Trademark',
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_showCustomTrademark) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _customTrademarkController,
                      decoration: const InputDecoration(
                        labelText: 'Custom Trademark',
                        hintText: 'Enter your custom trademark',
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Personal Conflict Section
                  const Text(
                    'Personal Conflict',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.casino),
                        tooltip: 'Roll Random',
                        onPressed: _rollPersonalConflict,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _showCustomPersonalConflict
                              ? 'Custom'
                              : (_personalConflict.isEmpty
                                    ? null
                                    : _personalConflict),
                          items: const [
                            'You believe your unit is being set up by higher command.',
                            'You promised a local child you\'d return, but you know you can\'t.',
                            'You\'re hiding an injury that flares at the worst possible moments.',
                            'You distrust your team leader after a past mistake.',
                            'You\'re secretly passing intel to another agency or faction.',
                            'You suspect someone in your squad is stealing gear or rations.',
                            'You\'re terrified of freezing under fire again.',
                            'Your family back home is falling apart, and you can\'t help them.',
                            'You owe a dangerous favor to a fixer, smuggler, or warlord.',
                            'A comrade saved your life, you feel intense obligation.',
                            'You\'re haunted by an operation gone wrong and hide your nightmares.',
                            'You\'re developing feelings for someone on base, complicating ops.',
                            'You believe your weapon or gear is faulty, but supply won\'t replace it.',
                            'You think one of your teammates is unstable and hiding something.',
                            'You\'re questioning the mission\'s legitimacy and your role in it.',
                            'You\'re covering up a mistake that could compromise the unit.',
                            'A local elder entrusted you with a secret you must not reveal.',
                            'You\'re unsure if an ally militia can be trusted, or if they want you dead.',
                            'You fear you\'re becoming too good at killing.',
                            'Custom',
                          ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setState(() {
                            if (v == 'Custom') {
                              _showCustomPersonalConflict = true;
                              _personalConflict = '';
                            } else {
                              _showCustomPersonalConflict = false;
                              _personalConflict = v ?? '';
                            }
                          }),
                          decoration: const InputDecoration(
                            labelText: 'Personal Conflict',
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_showCustomPersonalConflict) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _customPersonalConflictController,
                      decoration: const InputDecoration(
                        labelText: 'Custom Personal Conflict',
                        hintText: 'Enter your custom personal conflict',
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _saveAndContinue,
                        child: const Text('Save'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ), // Column
            ), // SingleChildScrollView
          ), // Form
        ), // Padding / body
      ), // Scaffold
    ); // CharacterCreationLayout
  }
}

// Edit screen for existing characters
class BasicInfoEditScreen extends StatefulWidget {
  final String characterId;

  const BasicInfoEditScreen({super.key, required this.characterId});

  @override
  State<BasicInfoEditScreen> createState() => _BasicInfoEditScreenState();
}

class _BasicInfoEditScreenState extends State<BasicInfoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  Character? _character;
  bool _loading = true;

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
        _loading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_character == null) return;

    final box = Hive.box('characters');
    _character!.modifiedAt = DateTime.now();
    await box.put(widget.characterId, _character!.toJson());

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Changes saved')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _character == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Basic Info')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Edit ${_character!.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personal Conflict',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _character!.personalConflict.isEmpty
                      ? null
                      : _character!.personalConflict,
                  decoration: const InputDecoration(
                    labelText: 'Select Personal Conflict',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    'You believe your unit is being set up by higher command.',
                    'You promised a local child you\'d return, but you know you can\'t.',
                    'You\'re hiding an injury that flares at the worst possible moments.',
                    'You distrust your team leader after a past mistake.',
                    'You\'re secretly passing intel to another agency or faction.',
                    'You suspect someone in your squad is stealing gear or rations.',
                    'You\'re terrified of freezing under fire again.',
                    'Your family back home is falling apart, and you can\'t help them.',
                    'You owe a dangerous favor to a fixer, smuggler, or warlord.',
                    'A comrade saved your life, you feel intense obligation.',
                    'You\'re haunted by an operation gone wrong and hide your nightmares.',
                    'You\'re developing feelings for someone on base, complicating ops.',
                    'You believe your weapon or gear is faulty, but supply won\'t replace it.',
                    'You think one of your teammates is unstable and hiding something.',
                    'You\'re questioning the mission\'s legitimacy and your role in it.',
                    'You\'re covering up a mistake that could compromise the unit.',
                    'A local elder entrusted you with a secret you must not reveal.',
                    'You\'re unsure if an ally militia can be trusted, or if they want you dead.',
                    'You fear you\'re becoming too good at killing.',
                  ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() {
                    _character!.personalConflict = v ?? '';
                  }),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _character!.personalConflict,
                  decoration: const InputDecoration(
                    labelText: 'Or enter custom conflict',
                    border: OutlineInputBorder(),
                    hintText: 'Write your own personal conflict',
                  ),
                  maxLines: 3,
                  onChanged: (v) => _character!.personalConflict = v,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _saveChanges,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
