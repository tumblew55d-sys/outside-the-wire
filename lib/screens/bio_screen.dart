import 'package:flutter/material.dart';
import '../theme/tactical_theme.dart';
import '../models/character.dart';
import '../services/storage_service.dart' as storage;

class BioScreen extends StatefulWidget {
  const BioScreen({super.key});

  @override
  State<BioScreen> createState() => _BioScreenState();
}

class _BioScreenState extends State<BioScreen> {
  CharacterProfile _char = CharacterProfile();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loaded = await storage.AppStorageService.loadCharacter();
    if (loaded != null) {
      setState(() => _char = loaded);
    }
  }

  Future<void> _handleSave() async {
    await storage.AppStorageService.saveCharacter(_char);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PERSONNEL RECORD UPDATED [SAVED]")),
      );
    }
  }

  Future<void> _handleLoad() async {
    final loaded = await storage.AppStorageService.loadCharacter();
    if (loaded != null) {
      setState(() {
        _char = loaded;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PERSONNEL RECORD RETRIEVED [LOADED]")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalTheme.gunmetal,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("SECTION 1: PERSONNEL ID"),
            const SizedBox(height: 10),
            _buildTacticalInput("FULL NAME", (val) => setState(() => _char.name = val), initial: _char.name),
            const SizedBox(height: 12),
            _buildSectionHeader("SECTION 2: BACKGROUND DATA"),
            const SizedBox(height: 10),
            _buildDropdown("SERVICE BRANCH", _char.serviceBranch, ["Army", "Navy", "Marines", "Air Force"], (val) => setState(() => _char.serviceBranch = val ?? _char.serviceBranch)),
            const SizedBox(height: 10),
            _buildDropdown("MILITARY SPECIALTY", _char.militarySpecialty, _char.skills.keys.toList(), (val) {
              if (val != null) setState(() => _char.setMOS(val));
            }),
            const SizedBox(height: 20),
            _buildSectionHeader("SECTION 3: ATTRIBUTES EVAL"),
            const SizedBox(height: 8),
            ...AttributeType.values.map((t) => _buildAttributeRow(t)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: _handleSave, child: const Text('SAVE'))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(onPressed: _handleLoad, child: const Text('LOAD'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    color: TacticalTheme.oliveDrab,
    child: Text(title, style: TacticalTheme.headerStencil.copyWith(fontSize: 16, color: Colors.black)),
  );

  Widget _buildTacticalInput(String label, Function(String) onChanged, {String initial = ''}) {
    return TextField(
      controller: TextEditingController(text: initial),
      style: TacticalTheme.dataMono.copyWith(color: Colors.white),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: TacticalTheme.desertTan.withOpacity(0.6)),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: TacticalTheme.desertTan.withOpacity(0.6), fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.white10, border: Border.all(color: TacticalTheme.oliveDrab)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeRow(AttributeType type) {
    int score = _char.attributes[type] ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(color: TacticalTheme.desertTan.withOpacity(0.3)), color: Colors.black26),
      child: Row(
        children: [
          Expanded(child: Text(type.toString().split('.').last.toUpperCase(), style: TacticalTheme.dataMono.copyWith(color: TacticalTheme.desertTan))),
          IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.white), onPressed: () => setState(() { if (score>0) _char.attributes[type]=score-1; })),
          Text('$score', style: TacticalTheme.digitalReadout),
          IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.white), onPressed: () => setState(() { _char.attributes[type]=score+1; })),
        ],
      ),
    );
  }
}
