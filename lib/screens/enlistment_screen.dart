import 'package:flutter/material.dart';
import '../services/storage_service.dart' as storage;
import '../models/character.dart';
import '../models/rank_ladder.dart';
import '../theme/tactical_theme.dart';

class EnlistmentScreen extends StatefulWidget {
  const EnlistmentScreen({super.key});

  @override
  State<EnlistmentScreen> createState() => _EnlistmentScreenState();
}

class _EnlistmentScreenState extends State<EnlistmentScreen> {
  CharacterProfile _char = CharacterProfile();
  
  ServiceType _selectedService = ServiceType.army;
  bool _isOfficer = false;

  final List<String> _mosList = [
    "Rifleman",
    "Heavy Weapons",
    "Sniper",
    "Radio Operator",
    "Signals/Cyber Intel",
    "Civil Affairs",
    "Medical"
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loaded = await storage.AppStorageService.loadCharacter();
    if (loaded != null) {
      setState(() {
        _char = loaded;
      });
    } else {
      _char.setMOS("Rifleman");
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
            _buildHeader("SECTION 4: ENLISTMENT ORDER"),
            
            _buildLabel("SELECT SERVICE BRANCH"),
            _buildServiceDropdown(),
            
            const SizedBox(height: 20),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("COMMISSION STATUS"),
                      _buildOfficerToggle(),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("ASSIGNED RANK"),
                      _buildRankDisplay(),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(color: TacticalTheme.oliveDrab),
            const SizedBox(height: 10),

            _buildHeader("SECTION 5: MILITARY SPECIALTY (MOS)"),
            _buildLabel("PRIMARY SPECIALTY"),
            _buildMOSDropdown(),

            const SizedBox(height: 20),

            _buildLabel("QUALIFIED SKILLS & RATINGS"),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                border: Border.all(color: TacticalTheme.desertTan.withOpacity(0.3)),
              ),
              child: Column(
                children: _char.skills.entries.map((entry) {
                  if (entry.value == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key.toUpperCase(), style: TacticalTheme.dataMono.copyWith(color: TacticalTheme.desertTan)),
                        Text("${entry.value}", style: TacticalTheme.digitalReadout),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 40),
            
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveEnlistment,
                icon: const Icon(Icons.save_alt, color: Colors.black),
                label: const Text("CONFIRM ENLISTMENT"),
                style: ElevatedButton.styleFrom(backgroundColor: TacticalTheme.desertTan),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEnlistment() async {
    await storage.AppStorageService.saveCharacter(_char);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ENLISTMENT PROCESSED [SAVED]"), backgroundColor: TacticalTheme.oliveDrab),
      );
    }
  }

  Widget _buildHeader(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: TacticalTheme.oliveDrab,
      child: Text(title, style: TacticalTheme.headerStencil.copyWith(fontSize: 16, color: Colors.black)),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(text, style: TextStyle(color: TacticalTheme.desertTan.withOpacity(0.6), fontSize: 12)),
    );
  }

  Widget _buildServiceDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white10, border: Border.all(color: TacticalTheme.oliveDrab)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ServiceType>(
          value: _selectedService,
          dropdownColor: TacticalTheme.gunmetal,
          isExpanded: true,
          style: TacticalTheme.dataMono.copyWith(color: Colors.white),
          items: ServiceType.values.map((s) {
            return DropdownMenuItem(value: s, child: Text(s.toString().split('.').last.toUpperCase()));
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedService = val!;
              _char.serviceBranch = val.toString().split('.').last;
            });
          },
        ),
      ),
    );
  }

  Widget _buildOfficerToggle() {
    return Row(
      children: [
        _buildToggleButton("ENLISTED", !_isOfficer),
        const SizedBox(width: 10),
        _buildToggleButton("OFFICER", _isOfficer),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isOfficer = label == "OFFICER";
            _char.setOfficerStatus(_isOfficer);
            RankDefinition r = RankLadder.getInitialRank(_selectedService, _isOfficer);
            _char.rankTitle = r.title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? TacticalTheme.safetyOrange : Colors.transparent,
            border: Border.all(color: isActive ? TacticalTheme.safetyOrange : TacticalTheme.desertTan),
          ),
          alignment: Alignment.center,
          child: Text(
            label, 
            style: TextStyle(
              color: isActive ? Colors.black : TacticalTheme.desertTan, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.black,
      child: Row(
        children: [
          const Icon(Icons.shield, color: TacticalTheme.oliveDrab, size: 16),
          const SizedBox(width: 10),
          Text(_char.rankTitle.toUpperCase(), style: TacticalTheme.digitalReadout),
        ],
      ),
    );
  }

  Widget _buildMOSDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white10, border: Border.all(color: TacticalTheme.oliveDrab)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _char.militarySpecialty,
          dropdownColor: TacticalTheme.gunmetal,
          isExpanded: true,
          style: TacticalTheme.dataMono.copyWith(color: Colors.white),
          items: _mosList.map((mos) {
            return DropdownMenuItem(value: mos, child: Text(mos.toUpperCase()));
          }).toList(),
          onChanged: (val) {
            setState(() {
              _char.setMOS(val!);
            });
          },
        ),
      ),
    );
  }
}
