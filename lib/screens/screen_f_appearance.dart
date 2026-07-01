import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../models/character.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';
import '../utils/body_type_descriptor.dart';
import 'screen_e_inventory.dart';

class AppearanceScreen extends StatefulWidget {
  final String characterId;
  const AppearanceScreen({super.key, required this.characterId});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  Character? _character;
  bool _saving = false;

  // Appearance traits
  String _skinTone = 'Fair';
  String _hairColor = 'Brown';
  String _hairStyle = 'Short';
  String _eyeColor = 'Brown';
  String _facialHair = 'None';
  String _build = 'Average';
  String _scars = 'None';
  String _tattoos = 'None';
  String _distinguishingMarks = '';

  final List<String> _skinTones = [
    'Very Fair',
    'Fair',
    'Light',
    'Medium',
    'Olive',
    'Tan',
    'Brown',
    'Dark Brown',
    'Very Dark',
  ];

  final List<String> _hairColors = [
    'Black',
    'Dark Brown',
    'Brown',
    'Light Brown',
    'Blonde',
    'Red',
    'Auburn',
    'Gray',
    'White',
    'Dyed',
  ];

  final List<String> _hairStyles = [
    'Bald/Shaved',
    'Buzz Cut',
    'Short',
    'Medium',
    'Long',
    'Crew Cut',
    'High and Tight',
    'Mohawk',
    'Dreadlocks',
  ];

  final List<String> _eyeColors = [
    'Brown',
    'Dark Brown',
    'Hazel',
    'Green',
    'Blue',
    'Gray',
    'Amber',
  ];

  final List<String> _facialHairOptions = [
    'None',
    'Stubble',
    'Goatee',
    'Full Beard',
    'Mustache',
    'Van Dyke',
    'Mutton Chops',
  ];

  final List<String> _buildOptions = [
    'Slim',
    'Average',
    'Athletic',
    'Muscular',
    'Stocky',
    'Heavy',
  ];

  final List<String> _scarOptions = [
    'None',
    'Face scar',
    'Neck scar',
    'Arm scar',
    'Hand scar',
    'Multiple scars',
    'Burn scar',
  ];

  final List<String> _tattooOptions = [
    'None',
    'Arm sleeve',
    'Military insignia',
    'Memorial tattoo',
    'Cultural design',
    'Multiple tattoos',
  ];

  @override
  void initState() {
    super.initState();
    _loadCharacter();
  }

  Future<void> _uploadPortrait() async {
    try {
      final imageSource = await StorageService.showImageSourceDialog(context);
      if (imageSource == null) return;

      setState(() => _saving = true);

      String? portraitUrl;
      if (imageSource == ImageSource.gallery) {
        portraitUrl = await StorageService.uploadPortrait(widget.characterId);
      } else {
        portraitUrl = await StorageService.uploadPortraitFromCamera(
          widget.characterId,
        );
      }

      if (portraitUrl != null && mounted) {
        final box = Hive.box('characters');
        final data = box.get(widget.characterId);
        if (data != null) {
          final c = Character.fromJson(Map<String, dynamic>.from(data));
          c.portraitUrl = portraitUrl;
          c.modifiedAt = DateTime.now();
          await box.put(widget.characterId, c.toJson());

          // Save to cloud
          try {
            await FirebaseService.saveCharacterToCloud(
              widget.characterId,
              c.toJson(),
            );
          } catch (e) {
            print('Cloud sync failed: $e');
          }

          setState(() => _character = c);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Portrait uploaded successfully!')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _loadCharacter() async {
    final box = Hive.box('characters');
    final data = box.get(widget.characterId);
    if (data != null) {
      final c = Character.fromJson(Map<String, dynamic>.from(data));
      setState(() {
        _character = c;
        final appearance = c.enlistment['appearance'];
        if (appearance is Map) {
          _skinTone = appearance['skinTone']?.toString() ?? _skinTone;
          _hairColor = appearance['hairColor']?.toString() ?? _hairColor;
          _hairStyle = appearance['hairStyle']?.toString() ?? _hairStyle;
          _eyeColor = appearance['eyeColor']?.toString() ?? _eyeColor;
          _facialHair = appearance['facialHair']?.toString() ?? _facialHair;
          _build = appearance['build']?.toString() ?? _build;
          _scars = appearance['scars']?.toString() ?? _scars;
          _tattoos = appearance['tattoos']?.toString() ?? _tattoos;
          _distinguishingMarks =
              appearance['distinguishingMarks']?.toString() ?? '';
        }
      });
    }
  }

  Future<void> _save() async {
    if (_character == null) return;
    setState(() => _saving = true);
    try {
      final box = Hive.box('characters');
      final data = box.get(widget.characterId);
      if (data == null) throw Exception('Character not found');
      final c = Character.fromJson(Map<String, dynamic>.from(data));

      c.enlistment['appearance'] = {
        'skinTone': _skinTone,
        'hairColor': _hairColor,
        'hairStyle': _hairStyle,
        'eyeColor': _eyeColor,
        'facialHair': _facialHair,
        'build': _build,
        'scars': _scars,
        'tattoos': _tattoos,
        'distinguishingMarks': _distinguishingMarks,
      };
      c.modifiedAt = DateTime.now();

      await box.put(widget.characterId, c.toJson());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Character complete! Returning to roster'),
            duration: Duration(seconds: 2),
          ),
        );
        // Navigate back to character roster screen after character completion
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
        }
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

  Widget _buildPaperDoll() {
    final inventory = _character?.enlistment['inventory'];
    List<String> loadoutWeapons = [];
    List<String> equipment = [];

    if (inventory is Map) {
      loadoutWeapons = List<String>.from(inventory['loadoutWeapons'] ?? []);
      equipment = List<String>.from(inventory['equipment'] ?? []);
    }

    return Container(
      width: 300,
      height: 450,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3EE), // Cream paper background
        border: Border.all(color: const Color(0xFF2B2B2B), width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base figure layer (always shown)
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/paper_doll/base/figure_base.svg',
              fit: BoxFit.contain,
            ),
          ),

          // Equipment layers (Z-index order: back to front)
          ...(() {
            final layers = <Widget>[];

            // 1. Rucksack layer (behind everything)
            if (equipment.contains('Backpack Radio') ||
                equipment.contains('Thor Backpack signal jammer') ||
                loadoutWeapons.isNotEmpty) {
              layers.add(
                Positioned.fill(
                  child: SvgPicture.asset(
                    'assets/paper_doll/back/rucksack_standard.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              );
            }

            // 2. Vest layer
            if (loadoutWeapons.isNotEmpty) {
              layers.add(
                Positioned.fill(
                  child: SvgPicture.asset(
                    'assets/paper_doll/torso/vests/load_bearing_vest.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              );
            }

            // 3. Weapon layer (slung on back - behind helmet)
            if (loadoutWeapons.isNotEmpty) {
              // Map first weapon to asset
              String weaponAsset =
                  'assets/paper_doll/weapons/rifles/m4_carbine.svg';
              final firstWeapon = loadoutWeapons.first.toLowerCase();

              if (firstWeapon.contains('m4') ||
                  firstWeapon.contains('carbine')) {
                weaponAsset = 'assets/paper_doll/weapons/rifles/m4_carbine.svg';
              }
              // Add more weapon mappings as assets are created

              layers.add(
                Positioned.fill(
                  child: SvgPicture.asset(weaponAsset, fit: BoxFit.contain),
                ),
              );
            }

            // 4. Helmet layer
            if (equipment.contains('Kevlar helmet') ||
                loadoutWeapons.isNotEmpty) {
              layers.add(
                Positioned.fill(
                  child: SvgPicture.asset(
                    'assets/paper_doll/head/helmets/kevlar_standard.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              );
            }

            // 5. NVG layer (front-most equipment)
            if (equipment.contains('Night Vision Goggles')) {
              layers.add(
                Positioned(
                  top: 50,
                  child: Container(
                    width: 60,
                    height: 25,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF6B6B6B),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'NVG',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            return layers;
          })(),

          // Equipment count overlay (bottom info bar)
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2B2B2B).withOpacity(0.85),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF4A5D3E), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'EQUIPPED:',
                    style: TextStyle(
                      color: Color(0xFFB8956A),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loadoutWeapons.isEmpty && equipment.isEmpty
                        ? 'No equipment selected'
                        : '${loadoutWeapons.length} weapons, ${equipment.length} items',
                    style: const TextStyle(
                      color: Color(0xFFF7F3EE),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_character == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Appearance')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance & Traits'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    InventoryEquipmentScreen(characterId: widget.characterId),
              ),
            );
          },
        ),
      ),
      body: Row(
        children: [
          // Left panel - Paper Doll
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Character Visualization',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Portrait Section
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _character?.portraitUrl.isNotEmpty == true
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _character!.portraitUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.person, size: 60),
                                );
                              },
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _uploadPortrait,
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: Text(
                      _character?.portraitUrl.isNotEmpty == true
                          ? 'Change Portrait'
                          : 'Upload Portrait',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Equipment from Screen E',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  _buildPaperDoll(),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      border: Border.all(color: Colors.orange[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.orange[800],
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Asset Pipeline',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Paper doll system ready for image layers.\n\n'
                          'Asset generation strategy:\n'
                          '• Photo-real military gear images\n'
                          '• Apply filter: bold edges, gritty contrast\n'
                          '• Add canvas texture overlay\n'
                          '• Result: 1980s acrylic art style\n\n'
                          'Required layers:\n'
                          '- Base figure\n'
                          '- Helmet variants\n'
                          '- Vest/gear\n'
                          '- Weapons (50+)\n'
                          '- Equipment items\n'
                          '- Rucksack/packs',
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right panel - Trait Selection
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${_character!.name} - Physical Traits',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'From Screen A:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Nationality: ${_character!.nationality}'),
                          Text('Age: ${_character!.age}'),
                          Text('Height: ${_character!.height}'),
                          Text(
                            'Weight: ${_character!.weight} ${_character!.weightUnit}',
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const Text(
                            'Body Type:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            BodyTypeDescriptor.getFullBodyTypeDescription(
                              _character!.height,
                              _character!.weightUnit == 'kg'
                                  ? _character!.weight * 2.20462
                                  : _character!.weight,
                            ),
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Appearance traits
                  _buildDropdown(
                    'Skin Tone',
                    _skinTone,
                    _skinTones,
                    (v) => setState(() => _skinTone = v!),
                  ),
                  _buildDropdown(
                    'Hair Color',
                    _hairColor,
                    _hairColors,
                    (v) => setState(() => _hairColor = v!),
                  ),
                  _buildDropdown(
                    'Hair Style',
                    _hairStyle,
                    _hairStyles,
                    (v) => setState(() => _hairStyle = v!),
                  ),
                  _buildDropdown(
                    'Eye Color',
                    _eyeColor,
                    _eyeColors,
                    (v) => setState(() => _eyeColor = v!),
                  ),
                  _buildDropdown(
                    'Facial Hair',
                    _facialHair,
                    _facialHairOptions,
                    (v) => setState(() => _facialHair = v!),
                  ),
                  _buildDropdown(
                    'Build',
                    _build,
                    _buildOptions,
                    (v) => setState(() => _build = v!),
                  ),
                  _buildDropdown(
                    'Scars',
                    _scars,
                    _scarOptions,
                    (v) => setState(() => _scars = v!),
                  ),
                  _buildDropdown(
                    'Tattoos',
                    _tattoos,
                    _tattooOptions,
                    (v) => setState(() => _tattoos = v!),
                  ),

                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _distinguishingMarks,
                    decoration: const InputDecoration(
                      labelText: 'Distinguishing Marks',
                      hintText: 'Birthmarks, unique features, etc.',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (v) => _distinguishingMarks = v,
                  ),

                  const SizedBox(height: 24),
                  // Finish button (end of character creation flow)
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.check_circle),
                    label: Text(_saving ? 'Saving...' : 'Finish Character'),
                  ),
                  const SizedBox(height: 8),
                  // Back button
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => InventoryEquipmentScreen(
                            characterId: widget.characterId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back: Inventory'),
                  ),
                  const SizedBox(height: 8),
                  // Save button
                  OutlinedButton.icon(
                    onPressed: _saving
                        ? null
                        : () async {
                            await _save();
                            if (mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/dashboard',
                                (route) => false,
                              );
                            }
                          },
                    icon: const Icon(Icons.save),
                    label: const Text('Save & Return to Roster'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
