import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/character.dart';
import '../data/nationality_data.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';
import '../widgets/character_creation_layout.dart';
import 'screen_d_abilities.dart';
import 'screen_f_final_review.dart';

class InventoryEquipmentScreen extends StatefulWidget {
  final String characterId;
  const InventoryEquipmentScreen({super.key, required this.characterId});

  @override
  State<InventoryEquipmentScreen> createState() =>
      _InventoryEquipmentScreenState();
}

class _InventoryEquipmentScreenState extends State<InventoryEquipmentScreen> {
  Character? _character;
  bool _saving = false;

  String? _selectedLoadout;
  List<String> _loadoutWeapons = [];
  List<String> _customWeapons = [];
  List<String> _selectedEquipment = [];

  // Categorized inventory
  List<String> _clothing = [];
  List<String> _pouches = [];
  List<String> _dayPack = [];
  List<String> _rucksack = [];
  List<String> _hands = [];
  List<String> _holster = [];
  Map<String, List<String>> _customSlots = {};

  final List<String> _baseInventory = [
    'Deployer camouflage uniforms',
    'Kevlar helmet',
    'Day patrol pack',
    'Personal medical kit',
    'Load bearing vest (with attachments)',
    'Flashlight',
    'Compass',
    'Sleeping bag',
    'Rucksack',
    'Gas mask',
    'Combat jacket',
  ];

  final Map<String, List<String>> _specialtyLoadouts = {
    'Rifleman': [
      'M4 carbine, combat knife, (2) frag grenades, LAW',
      'M249 Squad Automatic Weapon, M9 pistol, combat knife',
      'M4 Carbine with M320A1 grenade launcher, combat knife',
    ],
    'Sniper': [
      'M4 carbine, M40A4 sniper rifle, M9 pistol, combat knife, smoke/CS grenades',
      'M110 SASS, M9 pistol, combat knife, smoke/CS grenades',
      'M24 sniper rifle, M9 pistol, combat knife, smoke/CS grenades',
    ],
    'Radio Operator': ['M4 carbine, combat knife, (2) smoke grenades'],
    'Heavy Weapons': [
      'M240 GPMG, M9 pistol, combat knife',
      'M4 carbine, combat knife with tripod or ammunition',
      'M32 grenade launcher, M4 carbine, combat knife',
    ],
    'Signals/Cyber Intel': ['M4 carbine, combat knife, (2) smoke grenades'],
    'Medical': ['M4 carbine, combat knife, (2) smoke grenades'],
    'Civil Affairs': ['M4 carbine, combat knife, (2) smoke grenades'],
    'JTAC': [
      'M4 carbine, M9 pistol, combat knife, (2) smoke grenades',
      'M4 carbine with M320A1, M9 pistol, combat knife, (2) smoke grenades',
    ],
    'EOD': ['M4 carbine, combat knife, M9 Pistol'],
    'Spy': ['Makarov Pistol'],
  };

  final Map<String, String> _weaponDescriptions = {
    'M16A4 Rifle': 'Standard service rifle, 5.56mm, burst/semi-auto',
    'M203 Grenade Launcher': '40mm underslung grenade launcher',
    'M4 Carbine': 'Compact carbine, 5.56mm, full/semi-auto',
    'M320 Grenade Launcher': 'Standalone 40mm grenade launcher',
    'M320A1 Grenade Launcher': 'Enhanced 40mm GL with improved sights',
    'M249 SAW Light Machinegun': 'Squad Automatic Weapon, 5.56mm belt-fed',
    'M40 Sniper Rifle': 'Bolt-action sniper rifle, 7.62mm',
    'M24 Sniper Rifle': 'Bolt-action precision rifle, 7.62mm',
    'M2010 ESR Sniper Rifle': 'Enhanced Sniper Rifle, .300 Win Mag',
    'M13 Sniper Rifle': 'Long-range precision rifle, .300 Win Mag',
    'M110 SASS Sniper Rifle': 'Semi-auto sniper system, 7.62mm',
    'Barrett M82 Sniper Rifle': 'Anti-material rifle, .50 BMG',
    'M240 Machine Gun': 'General Purpose MG, 7.62mm belt-fed',
    'M32 Grenade Launcher (GL)': 'Revolving 6-shot 40mm grenade launcher',
    '870 Shotgun': 'Pump-action shotgun, 12 gauge',
    'LAW': 'Light Anti-armor Weapon, disposable rocket',
    'AT-4': 'Anti-tank weapon, 84mm rocket',
    'M9 Pistol': 'Standard sidearm, 9mm Beretta',
    '1911 Pistol': 'Classic .45 ACP semi-auto pistol',
    'Glock 17 Pistol': 'Austrian 9mm polymer-frame pistol',
    'Makarov Pistol': 'Soviet/Russian 9x18mm semi-auto pistol',
    'AK-47 Rifle': 'Soviet 7.62x39mm assault rifle, full/semi-auto',
    'AKM Rifle': 'Modernized AK-47, 7.62x39mm assault rifle',
    'AK-74 Rifle': 'Soviet 5.45x39mm assault rifle',
    'AK-12 Rifle': 'Modern Russian assault rifle, 5.45x39mm/7.62x39mm',
    'VSS Vintorez': 'Russian integrally suppressed sniper rifle, 9x39mm',
    'RPD Light Machine Gun': 'Soviet 7.62x39mm belt-fed LMG',
    'PKP Pecheneg': 'Russian general purpose machine gun, 7.62x54mmR',
    'SV-98 Sniper Rifle': 'Russian bolt-action sniper rifle, 7.62x54mmR',
    // French weapons
    'FAMAS rifle': 'French bullpup assault rifle, 5.56mm',
    'FAMAS rifle with GL': 'FAMAS with 40mm grenade launcher',
    'FRF2 Sniper Rifle': 'French bolt-action sniper rifle, 7.62mm',
    'PGM Hecate II Sniper Rifle': 'French anti-material rifle, .50 BMG',
    'FN MAG 58 Machine Gun': 'Belgian GPMG, 7.62mm belt-fed',
    // UK weapons
    'L85A2 Rifle': 'British bullpup rifle, 5.56mm',
    'L85A2 Rifle with GL': 'L85A2 with underslung grenade launcher',
    'L115A3 Sniper Rifle': 'British sniper rifle, .338 Lapua Magnum',
    'L7A2 Machine Gun': 'British GPMG, 7.62mm',
    '2 inch mortar': 'Light infantry mortar',
    'Browning HP Pistol': 'Browning Hi-Power 9mm pistol',
    // Australian weapons
    'F88 Steyr Rifle': 'Australian bullpup rifle, 5.56mm',
    'F88 Steyr Rifle with GL': 'F88 with grenade launcher attachment',
    'SR-98 Sniper Rifle': 'Australian sniper rifle, 7.62mm',
    // Canadian weapons
    'C7A2': 'Canadian assault rifle, 5.56mm',
    'C7A2 with GL': 'C7A2 with M203 grenade launcher',
    'McMillan TAC-50 (C15) Sniper Rifle': 'Canadian sniper rifle, .50 BMG',
    'C14 Timberwolf MRSWS Sniper Rifle': 'Canadian sniper rifle, .338 Lapua',
    // German weapons
    'HKG36E': 'German assault rifle, 5.56mm',
    'HKG36E with GL': 'HKG36E with grenade launcher',
    'G22A2 Sniper rifle': 'German sniper rifle, .300 Win Mag',
    'Rheinmetall MG3': 'German GPMG, 7.62mm belt-fed',
    // Spanish weapons
    'Accuracy International AW308 Sniper': 'Precision sniper rifle, .308 Win',
    // Norwegian weapons
    'HK416': 'German assault rifle, 5.56mm',
    'HK416 with GL': 'HK416 with grenade launcher',
    // Polish weapons
    'Wz 96 Beryl': 'Polish assault rifle, 5.56mm',
    'Wz 96 Beryl with GL': 'Beryl with grenade launcher',
    'TRG-42 Sniper Rifle': 'Finnish sniper rifle, .338 Lapua',
    'SVD Dragonov Sniper Rifle': 'Soviet semi-auto sniper, 7.62x54mmR',
    'PKM machinegun': 'Soviet GPMG, 7.62x54mmR belt-fed',
    // Swedish weapons
    'AK5C Rifle': 'Swedish assault rifle, 5.56mm',
    'FN Minimi (KSP 90)': 'Swedish designation for FN Minimi',
    'FN MAG GPMG': 'Belgian general purpose machine gun',
    'AS90 Sniper Rifle': 'Swedish sniper rifle, .338 Lapua',
    // Philippine weapons
    'M16A1 Rifle': 'Classic M16 rifle, 5.56mm',
    'M16A1 Rifle with M203 GL': 'M16A1 with M203 grenade launcher',
    'HK416 Rifle': 'German piston-driven rifle, 5.56mm',
    'DSAR-15 Rifle': 'Philippine-made AR-15 variant, 5.56mm',
    'FN MAG 58': 'Belgian GPMG, 7.62mm',
    // Other common weapons
    'FN Minimi Light Machinegun': 'Belgian light machine gun, 5.56mm',
    'Standard Issue Rifle': 'Generic military rifle',
    'Pistol': 'Generic military sidearm',
    'KBAR': 'Combat knife, 7-inch blade',
    'Bayonet': 'Detachable blade for rifle mounting',
  };

  final Map<String, IconData> _weaponIcons = {
    'M16A4 Rifle': Icons.sports_score,
    'M203 Grenade Launcher': Icons.rocket_launch,
    'M4 Carbine': Icons.sports_score,
    'M320 Grenade Launcher': Icons.rocket_launch,
    'M320A1 Grenade Launcher': Icons.rocket_launch,
    'M249 SAW Light Machinegun': Icons.settings_input_antenna,
    'M40 Sniper Rifle': Icons.gps_fixed,
    'M24 Sniper Rifle': Icons.gps_fixed,
    'M2010 ESR Sniper Rifle': Icons.gps_fixed,
    'M13 Sniper Rifle': Icons.gps_fixed,
    'M110 SASS Sniper Rifle': Icons.gps_fixed,
    'Barrett M82 Sniper Rifle': Icons.gps_fixed,
    'M240 Machine Gun': Icons.settings_input_antenna,
    'M32 Grenade Launcher (GL)': Icons.rocket_launch,
    '870 Shotgun': Icons.spoke,
    'LAW': Icons.rocket,
    'AT-4': Icons.rocket,
    'M9 Pistol': Icons.flash_on,
    '1911 Pistol': Icons.flash_on,
    'Glock 17 Pistol': Icons.flash_on,
    'Makarov Pistol': Icons.flash_on,
    'AK-47 Rifle': Icons.sports_score,
    'AKM Rifle': Icons.sports_score,
    'AK-74 Rifle': Icons.sports_score,
    'AK-12 Rifle': Icons.sports_score,
    'VSS Vintorez': Icons.gps_fixed,
    'PKP Pecheneg': Icons.settings_input_antenna,
    'SV-98 Sniper Rifle': Icons.gps_fixed,
    'RPD Light Machine Gun': Icons.settings_input_antenna,
    // French weapons
    'FAMAS rifle': Icons.sports_score,
    'FAMAS rifle with GL': Icons.sports_score,
    'FRF2 Sniper Rifle': Icons.gps_fixed,
    'PGM Hecate II Sniper Rifle': Icons.gps_fixed,
    'FN MAG 58 Machine Gun': Icons.settings_input_antenna,
    // UK weapons
    'L85A2 Rifle': Icons.sports_score,
    'L85A2 Rifle with GL': Icons.sports_score,
    'L115A3 Sniper Rifle': Icons.gps_fixed,
    'L7A2 Machine Gun': Icons.settings_input_antenna,
    '2 inch mortar': Icons.rocket_launch,
    'Browning HP Pistol': Icons.flash_on,
    // Australian weapons
    'F88 Steyr Rifle': Icons.sports_score,
    'F88 Steyr Rifle with GL': Icons.sports_score,
    'SR-98 Sniper Rifle': Icons.gps_fixed,
    // Canadian weapons
    'C7A2': Icons.sports_score,
    'C7A2 with GL': Icons.sports_score,
    'McMillan TAC-50 (C15) Sniper Rifle': Icons.gps_fixed,
    'C14 Timberwolf MRSWS Sniper Rifle': Icons.gps_fixed,
    // German weapons
    'HKG36E': Icons.sports_score,
    'HKG36E with GL': Icons.sports_score,
    'G22A2 Sniper rifle': Icons.gps_fixed,
    'Rheinmetall MG3': Icons.settings_input_antenna,
    // Spanish weapons
    'Accuracy International AW308 Sniper': Icons.gps_fixed,
    // Norwegian weapons
    'HK416': Icons.sports_score,
    'HK416 with GL': Icons.sports_score,
    // Polish weapons
    'Wz 96 Beryl': Icons.sports_score,
    'Wz 96 Beryl with GL': Icons.sports_score,
    'TRG-42 Sniper Rifle': Icons.gps_fixed,
    'SVD Dragonov Sniper Rifle': Icons.gps_fixed,
    'PKM machinegun': Icons.settings_input_antenna,
    // Swedish weapons
    'AK5C Rifle': Icons.sports_score,
    'FN Minimi (KSP 90)': Icons.settings_input_antenna,
    'FN MAG GPMG': Icons.settings_input_antenna,
    'AS90 Sniper Rifle': Icons.gps_fixed,
    // Philippine weapons
    'M16A1 Rifle': Icons.sports_score,
    'M16A1 Rifle with M203 GL': Icons.sports_score,
    'HK416 Rifle': Icons.sports_score,
    'DSAR-15 Rifle': Icons.sports_score,
    'FN MAG 58': Icons.settings_input_antenna,
    // Other common weapons
    'FN Minimi Light Machinegun': Icons.settings_input_antenna,
    'Standard Issue Rifle': Icons.sports_score,
    'Pistol': Icons.flash_on,
    'KBAR': Icons.cut,
    'Bayonet': Icons.cut,
  };

  final Map<String, String> _equipmentDescriptions = {
    'Night Vision Goggles': 'See in darkness, low-light operations',
    'Rifle mounted IR pointer': 'Infrared laser for NVG targeting on rifles',
    'Pistol mounted IR pointer': 'Infrared laser for NVG targeting on pistols',
    'Rifle mounted flashlight': 'Tactical flashlight for rifles',
    'Pistol mounted flashlight': 'Tactical flashlight for pistols',
    'Infrared Beam': 'IR illuminator for night vision',
    'Frag grenade': 'M67 fragmentation grenade',
    'Gas grenade': 'Tear gas/CS dispersal',
    'Smoke grenade': 'Obscurant for concealment',
    'Concussion grenade': 'Stun without fragmentation',
    'Flashbang grenade': 'Distraction device, bright flash/loud bang',
    'Thermite grenade': 'Incendiary device, melts through metal',
    'Red star cluster signal flare': 'Emergency signal, red burst',
    'Illumination signal flare': 'Area illumination',
    'Green start cluster signal flare': 'Signal flare, green burst',
    'EOD demo kit': 'Explosives disposal tools and charges',
    'Hand held mine detector': 'Portable metal detector for mines',
    'Thor Backpack signal jammer': 'Radio-controlled IED jammer',
    'EOD robot and computer': 'Remote bomb disposal robot',
    'Canine Kit': 'Explosive detection dog gear',
    'Breacher Kit': 'Door-breaching explosives and tools',
    'Unit 1 Medical Kit': 'Advanced trauma medical supplies',
    'JTAC computer and radio': 'Joint Terminal Attack Controller system',
    'Civil Affairs Kit': 'Community engagement tools and supplies',
    'RIAB': 'Radio Station in a Box',
    'Signal Collection Kit': 'SIGINT intercept equipment',
    'Spy Kit': 'Covert surveillance and infiltration tools',
    'Inter Squad Radio': 'Short-range tactical radio',
    'Backpack Radio': 'Long-range communications system',
    'Hand held walkie talkie': 'Portable two-way radio',
  };

  final Map<String, IconData> _equipmentIcons = {
    'Night Vision Goggles': Icons.visibility,
    'Rifle mounted IR pointer': Icons.center_focus_strong,
    'Pistol mounted IR pointer': Icons.center_focus_weak,
    'Rifle mounted flashlight': Icons.flashlight_on,
    'Pistol mounted flashlight': Icons.light,
    'Infrared Beam': Icons.flashlight_on,
    'Frag grenade': Icons.trip_origin,
    'Gas grenade': Icons.cloud,
    'Smoke grenade': Icons.cloud_queue,
    'Concussion grenade': Icons.thunderstorm,
    'Flashbang grenade': Icons.flash_on,
    'Thermite grenade': Icons.local_fire_department,
    'Red star cluster signal flare': Icons.flare,
    'Illumination signal flare': Icons.wb_sunny,
    'Green start cluster signal flare': Icons.flare,
    'EOD demo kit': Icons.construction,
    'Hand held mine detector': Icons.radar,
    'Thor Backpack signal jammer': Icons.cell_tower,
    'EOD robot and computer': Icons.precision_manufacturing,
    'Canine Kit': Icons.pets,
    'Breacher Kit': Icons.meeting_room,
    'Unit 1 Medical Kit': Icons.medical_services,
    'JTAC computer and radio': Icons.computer,
    'Civil Affairs Kit': Icons.handshake,
    'RIAB': Icons.radio,
    'Signal Collection Kit': Icons.signal_cellular_alt,
    'Spy Kit': Icons.security,
    'Inter Squad Radio': Icons.radio,
    'Backpack Radio': Icons.router,
    'Hand held walkie talkie': Icons.phone_in_talk,
  };

  List<String> get _availableWeapons => _weaponDescriptions.keys.toList();
  List<String> get _availableEquipment => _equipmentDescriptions.keys.toList();

  @override
  void initState() {
    super.initState();
    _loadCharacter();
  }

  Future<void> _uploadEquipmentImage(String equipmentName) async {
    try {
      setState(() => _saving = true);

      final imageUrl = await StorageService.uploadEquipmentImage(
        widget.characterId,
        equipmentName,
      );

      if (imageUrl != null && mounted) {
        final box = Hive.box('characters');
        final data = box.get(widget.characterId);
        if (data != null) {
          final c = Character.fromJson(Map<String, dynamic>.from(data));
          c.customEquipmentImages[equipmentName] = imageUrl;
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
              SnackBar(content: Text('Image uploaded for $equipmentName')),
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
        final inventory = c.enlistment['inventory'];
        if (inventory is Map) {
          _selectedLoadout = inventory['loadout']?.toString();
          _loadoutWeapons = List<String>.from(
            inventory['loadoutWeapons'] ?? [],
          );
          _customWeapons = List<String>.from(inventory['customWeapons'] ?? []);
          _selectedEquipment = List<String>.from(inventory['equipment'] ?? []);
        }
        // Initialize loadout weapons if not set and we have a loadout
        if (_loadoutWeapons.isEmpty && _selectedLoadout != null) {
          _loadoutWeapons = _parseLoadoutWeapons(_selectedLoadout!);
        }

        // Load categorized inventory from new inventory field
        final invMap = c.inventory;
        _clothing = List<String>.from(invMap['clothing'] ?? []);
        _pouches = List<String>.from(invMap['pouches'] ?? []);
        _dayPack = List<String>.from(invMap['dayPack'] ?? []);
        _rucksack = List<String>.from(invMap['rucksack'] ?? []);
        _hands = List<String>.from(invMap['hands'] ?? []);
        _holster = List<String>.from(invMap['holster'] ?? []);
        if (invMap['customSlots'] is Map) {
          _customSlots = Map<String, List<String>>.from(
            (invMap['customSlots'] as Map).map(
              (k, v) => MapEntry(k.toString(), List<String>.from(v ?? [])),
            ),
          );
        }
      });
    }
  }

  List<String> _parseLoadoutWeapons(String loadout) {
    // Parse weapons from loadout string (e.g., "M4 carbine, combat knife, (2) frag grenades, LAW")
    final weapons = <String>[];
    final parts = loadout.split(',').map((s) => s.trim()).toList();

    for (final part in parts) {
      // Check if part matches any weapon in our list
      for (final weapon in _availableWeapons) {
        if (part.toLowerCase().contains(weapon.toLowerCase()) ||
            weapon.toLowerCase().contains(part.toLowerCase())) {
          if (!weapons.contains(weapon)) weapons.add(weapon);
        }
      }
      // Also check for common weapon names in loadout
      if (part.toLowerCase().contains('m4 carbine') &&
          !weapons.any((w) => w.contains('M4 Carbine'))) {
        weapons.add('M4 Carbine');
      }
      if (part.toLowerCase().contains('m9 pistol') &&
          !weapons.any((w) => w.contains('M9'))) {
        weapons.add('M9 Pistol');
      }
      if (part.toLowerCase().contains('combat knife') &&
          !weapons.any((w) => w.contains('KBAR'))) {
        weapons.add('KBAR');
      }
    }
    return weapons;
  }

  String _getSpecialtyKey(String? specialty) {
    if (specialty == null) return 'Rifleman';
    if (specialty.contains('Rifleman')) return 'Rifleman';
    if (specialty.contains('Sniper')) return 'Sniper';
    if (specialty.contains('Radio')) return 'Radio Operator';
    if (specialty.contains('Heavy Weapons')) return 'Heavy Weapons';
    if (specialty.contains('Signals')) return 'Signals/Cyber Intel';
    if (specialty.contains('Medical')) return 'Medical';
    if (specialty.contains('Civil Affairs')) return 'Civil Affairs';
    if (specialty.contains('JTAC')) return 'JTAC';
    if (specialty.contains('EOD')) return 'EOD';
    if (specialty.contains('Spy')) return 'Spy';
    return 'Rifleman';
  }

  List<String> _getAllItems() {
    // Combine all items: base inventory, weapons, equipment, loadout weapons, and custom weapons
    final allItems = <String>{
      ..._baseInventory,
      ..._availableWeapons,
      ..._availableEquipment,
      ..._loadoutWeapons,
      ..._customWeapons,
      ..._selectedEquipment,
    }.toList();
    return allItems;
  }

  Future<void> _assignItemToCategory(String category) async {
    final allItems = _getAllItems();
    final item = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add item to $category'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView(
            children: allItems.map((item) {
              final icon =
                  _weaponIcons[item] ??
                  _equipmentIcons[item] ??
                  Icons.inventory_2;
              final desc =
                  _weaponDescriptions[item] ??
                  _equipmentDescriptions[item] ??
                  item;
              return ListTile(
                leading: Icon(icon, size: 20),
                title: Text(item, style: const TextStyle(fontSize: 14)),
                subtitle: Text(desc, style: const TextStyle(fontSize: 11)),
                onTap: () => Navigator.pop(context, item),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (item != null) {
      setState(() {
        switch (category) {
          case 'Clothing':
            if (!_clothing.contains(item)) _clothing.add(item);
            break;
          case 'Pouches':
            if (!_pouches.contains(item)) _pouches.add(item);
            break;
          case 'Day Pack':
            if (!_dayPack.contains(item)) _dayPack.add(item);
            break;
          case 'Rucksack':
            if (!_rucksack.contains(item)) _rucksack.add(item);
            break;
          case 'Hands':
            if (!_hands.contains(item)) _hands.add(item);
            break;
          case 'Holster':
            if (!_holster.contains(item)) _holster.add(item);
            break;
        }
      });
    }
  }

  Widget _buildCategoryCard({
    required String title,
    required List<String> items,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      color: color,
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(
          '$title (${items.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text('Add item to $title'),
                  onPressed: () => _assignItemToCategory(title),
                ),
                const SizedBox(height: 8),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'No items assigned',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  )
                else
                  ...items.map((item) {
                    final itemIcon =
                        _weaponIcons[item] ??
                        _equipmentIcons[item] ??
                        Icons.inventory_2;
                    return ListTile(
                      dense: true,
                      leading: Icon(itemIcon, size: 20),
                      title: Text(item),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() => items.remove(item));
                        },
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_character == null) return;
    setState(() => _saving = true);
    try {
      final box = Hive.box('characters');
      final data = box.get(widget.characterId);
      if (data == null) throw Exception('Character not found');
      final c = Character.fromJson(Map<String, dynamic>.from(data));

      // Save ALL inventory data to character.inventory (consolidated location)
      c.inventory = {
        'loadout': _selectedLoadout,
        'loadoutWeapons': _loadoutWeapons,
        'customWeapons': _customWeapons,
        'selectedEquipment': _selectedEquipment,
        'clothing': _clothing,
        'pouches': _pouches,
        'dayPack': _dayPack,
        'rucksack': _rucksack,
        'hands': _hands,
        'holster': _holster,
        'customSlots': _customSlots,
      };

      // Also save to enlistment for backward compatibility
      c.enlistment['inventory'] = {
        'loadout': _selectedLoadout,
        'loadoutWeapons': _loadoutWeapons,
        'customWeapons': _customWeapons,
        'equipment': _selectedEquipment,
      };

      c.modifiedAt = DateTime.now();

      await box.put(widget.characterId, c.toJson());
      if (mounted) {
        // Show saved confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Inventory & equipment saved'),
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to Final Review Screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                FinalReviewScreen(characterId: widget.characterId),
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
        appBar: AppBar(title: const Text('Inventory & Equipment')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final specialty = (_character!.enlistment['specialty'] ?? '').toString();
    final specialtyKey = _getSpecialtyKey(specialty);
    final loadouts = _specialtyLoadouts[specialtyKey] ?? [];

    // Create preview character for live preview
    final previewCharacter = Character(
      id: _character!.id,
      name: _character!.name,
      age: _character!.age,
      homeLocation: _character!.homeLocation,
      nationality: _character!.nationality,
      height: _character!.height,
      weight: _character!.weight,
      weightUnit: _character!.weightUnit,
      languages: _character!.languages,
      motivation: _character!.motivation,
      background: _character!.background,
      trademark: _character!.trademark,
      personalConflict: _character!.personalConflict,
      attributes: _character!.attributes,
      skills: _character!.skills,
      enlistment: _character!.enlistment,
      specialtyHook: _character!.specialtyHook,
      inventory: {
        'loadout': _selectedLoadout,
        'loadoutWeapons': _loadoutWeapons,
        'customWeapons': _customWeapons,
        'selectedEquipment': _selectedEquipment,
        'clothing': _clothing,
        'pouches': _pouches,
        'dayPack': _dayPack,
        'rucksack': _rucksack,
        'hands': _hands,
        'holster': _holster,
      },
    );

    return CharacterCreationLayout(
      character: previewCharacter,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventory & Equipment'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      AbilitiesNarrativeScreen(characterId: widget.characterId),
                ),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Equipment Management: ${_character!.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Base Inventory
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Base Inventory',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Every player includes:',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 8),
                      ..._baseInventory.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Text(item),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Standard Issue Weapons from Nation's Locker (Multi-select)
              Card(
                color: Colors.amber[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Standard Issue Weapons (${_character!.nationality})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Select weapons from your nation\'s weapons locker (multi-select):',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            NationalityData.getWeaponsLocker(
                              _character!.nationality,
                            ).map((weapon) {
                              final isSelected = _customWeapons.contains(
                                weapon,
                              );
                              final icon =
                                  _weaponIcons[weapon] ?? Icons.military_tech;
                              final tooltip = NationalityData.getWeaponTooltip(
                                weapon,
                              );
                              final chip = FilterChip(
                                avatar: Icon(icon, size: 16),
                                label: Text(weapon),
                                selected: isSelected,
                                selectedColor: Colors.amber.shade200,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      if (!_customWeapons.contains(weapon)) {
                                        _customWeapons.add(weapon);
                                      }
                                    } else {
                                      _customWeapons.remove(weapon);
                                    }
                                  });
                                },
                              );
                              return tooltip != null
                                  ? Tooltip(message: tooltip, child: chip)
                                  : chip;
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Weapons Loadout
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weapons Loadout ($specialtyKey)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (loadouts.length > 1)
                        DropdownButtonFormField<String>(
                          initialValue: _selectedLoadout,
                          decoration: const InputDecoration(
                            labelText: 'Select Base Loadout',
                            border: OutlineInputBorder(),
                          ),
                          items: loadouts
                              .map(
                                (l) =>
                                    DropdownMenuItem(value: l, child: Text(l)),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _selectedLoadout = v;
                              if (v != null) {
                                _loadoutWeapons = _parseLoadoutWeapons(v);
                              }
                            });
                          },
                        )
                      else if (loadouts.length == 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Standard Loadout:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(loadouts.first),
                          ],
                        ),
                      if (_loadoutWeapons.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Loadout Weapons (tap to swap):',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _loadoutWeapons.map((weapon) {
                            final icon =
                                _weaponIcons[weapon] ?? Icons.military_tech;
                            return ActionChip(
                              avatar: Icon(icon, size: 16),
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(weapon),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.swap_horiz, size: 16),
                                ],
                              ),
                              onPressed: () async {
                                final replacement = await showDialog<String>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Replace $weapon'),
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: _availableWeapons.map((w) {
                                          final wIcon =
                                              _weaponIcons[w] ??
                                              Icons.military_tech;
                                          final desc =
                                              _weaponDescriptions[w] ?? '';
                                          return ListTile(
                                            leading: Icon(wIcon),
                                            title: Text(w),
                                            subtitle: Text(
                                              desc,
                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                            ),
                                            onTap: () =>
                                                Navigator.pop(context, w),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  ),
                                );
                                if (replacement != null) {
                                  setState(() {
                                    final index = _loadoutWeapons.indexOf(
                                      weapon,
                                    );
                                    _loadoutWeapons[index] = replacement;
                                  });
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Custom Weapons from All Nations
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'International Weapons Arsenal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mix and match weapons from all nations:',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 12),
                      // Show weapons grouped by nation
                      ...NationalityData.nationalities.map((nation) {
                        final weapons = NationalityData.getWeaponsLocker(
                          nation,
                        );
                        return ExpansionTile(
                          title: Text(
                            nation,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          initiallyExpanded: nation == _character!.nationality,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: weapons.map((weapon) {
                                  final isSelected = _customWeapons.contains(
                                    weapon,
                                  );
                                  final icon =
                                      _weaponIcons[weapon] ??
                                      Icons.military_tech;
                                  final tooltip =
                                      NationalityData.getWeaponTooltip(
                                        weapon,
                                      ) ??
                                      weapon;
                                  return Tooltip(
                                    message: tooltip,
                                    child: FilterChip(
                                      avatar: Icon(icon, size: 16),
                                      label: Text(
                                        weapon,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            if (!_customWeapons.contains(
                                              weapon,
                                            )) {
                                              _customWeapons.add(weapon);
                                            }
                                          } else {
                                            _customWeapons.remove(weapon);
                                          }
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        );
                      }),
                      if (_customWeapons.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Selected custom weapons:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        ..._customWeapons.map(
                          (w) => Padding(
                            padding: const EdgeInsets.only(left: 16, top: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_right, size: 16),
                                const SizedBox(width: 4),
                                Expanded(child: Text(w)),
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    size: 18,
                                  ),
                                  onPressed: () =>
                                      setState(() => _customWeapons.remove(w)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Equipment
              Card(
                color: Colors.purple[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Equipment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Select additional equipment:',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableEquipment.map((equip) {
                          final isSelected = _selectedEquipment.contains(equip);
                          final icon =
                              _equipmentIcons[equip] ?? Icons.inventory;
                          final desc = _equipmentDescriptions[equip] ?? '';
                          return Tooltip(
                            message: desc,
                            child: FilterChip(
                              avatar: Icon(icon, size: 16),
                              label: Text(equip),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedEquipment.add(equip);
                                  } else {
                                    _selectedEquipment.remove(equip);
                                  }
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                      if (_selectedEquipment.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Selected equipment:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        ..._selectedEquipment.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(left: 16, top: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_right, size: 16),
                                const SizedBox(width: 4),
                                Expanded(child: Text(e)),
                                if (_character?.customEquipmentImages
                                        .containsKey(e) ==
                                    true)
                                  const Icon(
                                    Icons.photo,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.camera_alt, size: 18),
                                  tooltip: 'Upload custom image',
                                  onPressed: _saving
                                      ? null
                                      : () => _uploadEquipmentImage(e),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    size: 18,
                                  ),
                                  onPressed: () => setState(
                                    () => _selectedEquipment.remove(e),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Next button
              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.arrow_forward),
                label: Text(_saving ? 'Saving...' : 'Next: Review'),
              ),
              const SizedBox(height: 8),
              // Back button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => AbilitiesNarrativeScreen(
                        characterId: widget.characterId,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back: Abilities'),
              ),
              const SizedBox(height: 8),
              // Save button
              OutlinedButton.icon(
                onPressed: _saving
                    ? null
                    : () async {
                        await _save();
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
      ), // Scaffold
    ); // CharacterCreationLayout
  }
}
