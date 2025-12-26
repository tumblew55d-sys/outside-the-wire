import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/inventory.dart';
import '../theme/tactical_theme.dart';
import '../services/storage_service.dart';

class InspectionScreen extends StatefulWidget {
  const InspectionScreen({super.key});

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  CharacterProfile _char = CharacterProfile();
  bool _loading = true;

  // APPEARANCE OPTIONS (Data Lists)
  final List<String> _skinTones = ["Pale", "Tan", "Dark", "Olive", "Weathered"];
  final List<String> _hairStyles = ["Buzz Cut", "Shaved", "Crew Cut", "High & Tight", "Messy"];
  final List<String> _eyeColors = ["Brown", "Blue", "Green", "Hazel", "Grey", "Steely"];
  final List<String> _scars = ["None", "Eye Scar", "Cheek Gash", "Burn Mark", "Lip Split"];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final loaded = await AppStorageService.loadCharacter();
    if (!mounted) return;
    setState(() {
      _char = loaded ?? CharacterProfile();
      // Ensure inventory has base kit if empty
      if (_char.inventory.isEmpty) {
        _char.inventory = InventoryManager.getBaseKit();
        _char.inventory.addAll(InventoryManager.getMOSLoadout(_char.militarySpecialty));
      }
      _loading = false;
    });
  }

  Future<void> _saveAppearance() async {
    await AppStorageService.saveCharacter(_char);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("VISUAL ID UPDATED"),
      backgroundColor: TacticalTheme.oliveDrab,
      duration: Duration(milliseconds: 700),
    ));
  }

  void _showInspectionLog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 400,
          child: _char.inspections.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No inspections recorded')))
              : ListView.builder(
                  itemCount: _char.inspections.length,
                  itemBuilder: (context, idx) {
                    final rec = _char.inspections[idx];
                    return Dismissible(
                      key: ValueKey(rec.timestamp.toIso8601String()),
                      onDismissed: (_) async {
                        setState(() {
                          _char.inspections.removeAt(idx);
                        });
                        await AppStorageService.saveCharacter(_char);
                      },
                      background: Container(color: Colors.red, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 16), child: const Icon(Icons.delete, color: Colors.white)),
                      child: ListTile(
                        title: Text('${rec.station} — ${rec.result}'),
                        subtitle: Text('${rec.inspector} • ${rec.timestamp.toLocal().toString().split('.').first}\n${rec.notes}'),
                        isThreeLine: rec.notes.isNotEmpty,
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      backgroundColor: TacticalTheme.gunmetal,
      appBar: AppBar(title: const Text('Inspection Station'), backgroundColor: TacticalTheme.oliveDrab),
      body: Row(
        children: [
          // LEFT PANEL: CONTROLS
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black26,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader("VISUAL IDENTIFICATION"),
                    const SizedBox(height: 20),

                    _buildDropdown("DERMAL TONE", _char.skinTone, _skinTones, (v) => setState(() => _char.skinTone = v!)),
                    _buildDropdown("HAIR PATTERN", _char.hairStyle, _hairStyles, (v) => setState(() => _char.hairStyle = v!)),
                    _buildDropdown("OCULAR ID", _char.eyeColor, _eyeColors, (v) => setState(() => _char.eyeColor = v!)),
                    _buildDropdown("DISTINGUISHING MARKS", _char.scar, _scars, (v) => setState(() => _char.scar = v!)),

                    const SizedBox(height: 10),
                    _buildEquipmentSummary(),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveAppearance,
                        style: ElevatedButton.styleFrom(backgroundColor: TacticalTheme.safetyOrange),
                        icon: const Icon(Icons.save, color: Colors.black),
                        label: const Text("CONFIRM VISUALS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showInspectionLog,
                        icon: const Icon(Icons.list),
                        label: const Text('Show Inspection Log'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // RIGHT PANEL: THE PAPER DOLL (VISUALIZER)
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: TacticalTheme.desertTan.withOpacity(0.5))),
                gradient: LinearGradient(
                  colors: [Colors.black, TacticalTheme.gunmetal],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. GRID BACKGROUND
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: Image.asset("assets/images/textures/grid_bg.png", repeat: ImageRepeat.repeat, errorBuilder: (_,__,___)=>const SizedBox()), 
                    ),
                  ),

                  // 2. THE PAPER DOLL LAYERS
                  _buildDollLayer("body_base", color: _getSkinColor(_char.skinTone)), // Dynamic Skin
                  _buildDollLayer("uniform_camo"), // Always on
                  
                  // Dynamic Equipment Layers (Check Inventory)
                  if (_hasItem("Load Bearing Vest")) _buildDollLayer("vest_standard"),
                  if (_hasItem("Rucksack")) _buildDollLayer("rucksack_large"),
                  if (_hasItem("Kevlar Helmet")) _buildDollLayer("helmet_kevlar"),
                  
                  // Weapon Layer (Find the first weapon)
                  _buildWeaponLayer(),

                  // 3. OVERLAY: SCANLINES (The 80s Tech Effect)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.green.withOpacity(0.05)],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // 4. TEXT OVERLAY
                  Positioned(
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      color: Colors.black87,
                      child: Text("SUBJ: ${_char.name.isEmpty ? 'UNKNOWN' : _char.name.toUpperCase()}", style: TacticalTheme.digitalReadout),
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

  // ============================
  // DOLL LOGIC
  // ============================

  bool _hasItem(String name) {
    return _char.inventory.any((item) => item.name == name);
  }

  Color _getSkinColor(String tone) {
    switch (tone) {
      case "Pale": return const Color(0xFFFFDBAC);
      case "Tan": return const Color(0xFFE0AC69);
      case "Olive": return const Color(0xFF8D5524);
      case "Dark": return const Color(0xFF523620);
      case "Weathered": return const Color(0xFF8D6E63);
      default: return const Color(0xFFFFDBAC);
    }
  }

  Widget _buildDollLayer(String assetName, {Color? color}) {
    return IgnorePointer(
      child: SizedBox(
        height: 500,
        width: 300,
        child: Image.asset(
          "assets/images/paper_doll/$assetName.png",
          color: color,
          colorBlendMode: color != null ? BlendMode.modulate : null,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(); 
          },
        ),
      ),
    );
  }

  Widget _buildWeaponLayer() {
    try {
      final weapon = _char.inventory.firstWhere((i) => i.category == "Weapon");
      String assetName = "weapon_rifle";
      if (weapon.name.contains("Pistol")) assetName = "weapon_pistol";
      if (weapon.name.contains("Sniper")) assetName = "weapon_sniper";
      if (weapon.name.contains("M249") || weapon.name.contains("M240")) assetName = "weapon_lmg";

      return _buildDollLayer(assetName);
    } catch (e) {
      return const SizedBox();
    }
  }

  // ============================
  // UI COMPONENTS
  // ============================
  
  Widget _buildEquipmentSummary() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("VISUALIZED ASSETS:", style: TextStyle(color: TacticalTheme.safetyOrange, fontSize: 10)),
          if (_hasItem("Kevlar Helmet")) const Text("- HEADGEAR: STANDARD KEVLAR", style: TextStyle(color: Colors.white70, fontSize: 10)),
          if (_hasItem("Load Bearing Vest")) const Text("- TORSO: LBV-88 VEST", style: TextStyle(color: Colors.white70, fontSize: 10)),
          if (_hasItem("Rucksack")) const Text("- BACK: ALICE PACK (LARGE)", style: TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) => Text(title, style: TacticalTheme.headerStencil);

  Widget _buildDropdown(String label, String current, List<String> items, Function(String?) onChange) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: TacticalTheme.desertTan, fontSize: 10)),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Colors.white10,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: items.contains(current) ? current : items.first,
                dropdownColor: TacticalTheme.gunmetal,
                isExpanded: true,
                style: TacticalTheme.dataMono.copyWith(color: Colors.white),
                items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: onChange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
