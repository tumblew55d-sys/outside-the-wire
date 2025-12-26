import 'dart:math';
import 'package:flutter/material.dart';
import '../services/storage_service.dart' as storage;
import '../models/character.dart';
import '../theme/tactical_theme.dart';

class DeploymentScreen extends StatefulWidget {
  const DeploymentScreen({super.key});

  @override
  State<DeploymentScreen> createState() => _DeploymentScreenState();
}

class _DeploymentScreenState extends State<DeploymentScreen> {
  CharacterProfile _char = CharacterProfile();
  
  int _phase = 0;
  int _deploymentsRemaining = 0;
  int _currentDeploymentIndex = 1;
  String _careerRollResultText = "";
  
  int? _forcedCareerRoll;
  String _manualAward = "Random";
  String _manualSchool = "Random";
  String _manualSurvival = "Random";

  String _tempLocation = "Iraq";
  String _tempSkill = "Small Arms";
  
  final List<String> _locations = ["Philippines", "Iraq", "Afghanistan", "Syria", "Africa"];
  final List<String> _skillOptions = ["Small Arms", "Heavy Weapons", "First Aid", "Radio Ops", "Civil Affairs", "Spying", "Fires", "Signals Intel", "Explosives"];

  final Map<int, String> _careerPaths = {
    0: "STANDARD RNG PROTOCOL",
    1: "OFFICER TRACK (Roll 1)",
    2: "SGT + EOD/JTAC (Roll 2,9,10)",
    8: "SGT + 2 TOURS (Roll 8)",
    3: "SGT + 1 TOUR (Roll 3,4,6,7)",
    5: "GRUNT + 1 TOUR (Roll 5)",
  };

  final List<String> _awardOptions = ["Random", "None", "Achievement", "Commendation", "Bronze Star", "Silver Star"];
  final List<String> _schoolOptions = ["Random", "None", "Small Boats", "Air Assault", "Airborne", "Breacher", "Ranger"];
  final List<String> _survivalOptions = ["Random", "Survived", "Wounded (Purple Heart)", "KILLED IN ACTION"];

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
        if (_char.hasCompletedService) _phase = 2;
      });
    }
  }

  void _executeCareerRoll() {
    int roll;
    if (_forcedCareerRoll != null && _forcedCareerRoll != 0) {
      roll = _forcedCareerRoll!;
    } else {
      roll = Random().nextInt(10) + 1;
    }

    String resultText = "Log: $roll // ";
    int deployments = 1;
    bool promoSgt = false;
    bool promoOfficer = false;
    bool inviteSpec = false;

    if (roll == 1) {
      resultText += "OFFICER TRACK INITIALIZED";
      deployments = 2;
      promoOfficer = true;
    } else if ([2, 9, 10].contains(roll)) {
      resultText += "NCO TRACK + SPEC OPS INVITE";
      deployments = 2;
      promoSgt = true;
      inviteSpec = true;
    } else if (roll == 8) {
      resultText += "NCO TRACK (EXTENDED)";
      deployments = 2;
      promoSgt = true;
    } else if ([3, 4, 6, 7].contains(roll)) {
      resultText += "NCO TRACK (STANDARD)";
      deployments = 1;
      promoSgt = true;
    } else {
      resultText += "STANDARD ENLISTMENT";
      deployments = 1;
    }

    if (promoOfficer) {
      _applyPromotion(isOfficerEvent: true);
      _char.attributes[AttributeType.strength] = (_char.attributes[AttributeType.strength] ?? 0) + 1;
      _char.attributes[AttributeType.agility] = (_char.attributes[AttributeType.agility] ?? 0) + 1;
      _char.attributes[AttributeType.knowledge] = (_char.attributes[AttributeType.knowledge] ?? 0) + 1;
    } else if (promoSgt) {
      _applyPromotion(isOfficerEvent: false);
    }
    
    if (promoOfficer || promoSgt) {
      _char.skills["Training"] = (_char.skills["Training"] ?? 0) + 1;
    }

    setState(() {
      _deploymentsRemaining = deployments;
      _careerRollResultText = resultText;
      _char.inviteEOD_JTAC = inviteSpec;
      _phase = 1; 
    });
  }

  void _applyPromotion({required bool isOfficerEvent}) {
    if (isOfficerEvent && !_char.isOfficer) {
      _char.isOfficer = true;
      _char.rankTitle = "2nd Lieutenant"; 
    } else if (!_char.isOfficer && _char.rankTitle == "Private") {
       _char.rankTitle = "Sergeant";
    }
  }

  void _resolveMission() {
    String award = "None";
    if (_manualAward != "Random") {
      award = _manualAward;
      if (award == "Silver Star") _char.attributes[AttributeType.knowledge] = (_char.attributes[AttributeType.knowledge] ?? 0) + 3;
      if (award == "Bronze Star") _char.attributes[AttributeType.knowledge] = (_char.attributes[AttributeType.knowledge] ?? 0) + 2;
      if (award == "Commendation") _char.attributes[AttributeType.knowledge] = (_char.attributes[AttributeType.knowledge] ?? 0) + 1;
    } else {
      int roll = Random().nextInt(10) + 1;
      if (roll == 10) { award = "Silver Star"; _char.attributes[AttributeType.knowledge] = (_char.attributes[AttributeType.knowledge] ?? 0) + 3; }
      else if (roll == 9) { award = "Bronze Star"; _char.attributes[AttributeType.knowledge] = (_char.attributes[AttributeType.knowledge] ?? 0) + 2; }
      else if (roll >= 7) { award = "Commendation"; _char.attributes[AttributeType.knowledge] = (_char.attributes[AttributeType.knowledge] ?? 0) + 1; }
      else if (roll >= 4) { award = "Achievement"; }
    }

    String school = "None";
    if (_manualSchool != "Random") {
      school = _manualSchool;
      if (school == "Ranger") {
        _char.inviteSOF = true;
        _char.attributes[AttributeType.knowledge] = (_char.attributes[AttributeType.knowledge] ?? 0) + 1;
      }
      if (school == "Breacher") _char.skills["Explosives"] = (_char.skills["Explosives"] ?? 0) + 2;
    } else {
      int roll = Random().nextInt(10) + 1;
      if (roll >= 9) { 
        school = "Ranger"; 
        _char.inviteSOF = true; 
        _char.attributes[AttributeType.knowledge] = (_char.attributes[AttributeType.knowledge] ?? 0) + 1;
      } 
      else if (roll >= 7) { school = "Breacher"; _char.skills["Explosives"] = (_char.skills["Explosives"] ?? 0) + 2; }
      else if (roll >= 5) school = "Airborne";
      else if (roll >= 3) school = "Air Assault";
      else if (roll >= 1) school = "Small Boats";
    }

    String status = "Survived";
    if (_manualSurvival != "Random") {
      status = _manualSurvival;
      if (status.contains("KILLED")) _char.isKIA = true;
    } else {
      int roll = Random().nextInt(10) + 1;
      if (roll == 1) { status = "KILLED IN ACTION"; _char.isKIA = true; }
      else if (roll >= 8) { status = "Wounded (Purple Heart)"; }
    }

    _char.skills[_tempSkill] = (_char.skills[_tempSkill] ?? 0) + 1;
    _char.skills["Combat Experience"] = (_char.skills["Combat Experience"] ?? 0) + 1;

    _char.history.add(DeploymentRecord(
      location: _tempLocation,
      award: award,
      school: school,
      survivalStatus: status,
      skillIncreased: _tempSkill,
    ));

    setState(() {
      _deploymentsRemaining--;
      _manualAward = "Random";
      _manualSchool = "Random";
      _manualSurvival = "Random";

      if (_char.isKIA || _deploymentsRemaining <= 0) {
        _char.hasCompletedService = true;
        _phase = 2; 
        storage.AppStorageService.saveCharacter(_char);
      } else {
        _currentDeploymentIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalTheme.gunmetal,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
             _buildHeader("SECTION 6: SERVICE RECORD"),
             const SizedBox(height: 20),
             
             if (_phase == 0) _buildIntroPhase(),
             if (_phase == 1) _buildMissionPhase(),
             if (_phase == 2) _buildDebriefPhase(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroPhase() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: TacticalTheme.desertTan), color: Colors.black12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("CAREER PATH PROTOCOL", style: TextStyle(color: TacticalTheme.safetyOrange, fontSize: 10)),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _forcedCareerRoll ?? 0,
                    dropdownColor: TacticalTheme.gunmetal,
                    isExpanded: true,
                    style: TacticalTheme.dataMono.copyWith(color: Colors.white),
                    items: _careerPaths.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                    onChanged: (val) => setState(() => _forcedCareerRoll = val),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          GestureDetector(
            onTap: _executeCareerRoll,
            child: Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(color: TacticalTheme.safetyOrange, width: 3),
                boxShadow: [BoxShadow(color: TacticalTheme.safetyOrange.withOpacity(0.3), blurRadius: 20)],
              ),
              child: Center(
                child: Text(
                  _forcedCareerRoll == 0 ? "EXECUTE\n1D10" : "CONFIRM\nOVERRIDE", 
                  textAlign: TextAlign.center, 
                  style: TacticalTheme.headerStencil.copyWith(color: Colors.white)
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionPhase() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalTheme.oliveDrab.withOpacity(0.2),
        border: Border.all(color: TacticalTheme.desertTan),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("DEPLOYMENT #$_currentDeploymentIndex", style: TacticalTheme.headerStencil),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), color: TacticalTheme.safetyOrange, child: const Text("ACTIVE", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold))),
            ],
          ),
          Text(_careerRollResultText, style: const TextStyle(color: TacticalTheme.crtGreen, fontSize: 12)),
          const Divider(color: TacticalTheme.desertTan),
          const SizedBox(height: 10),
          
          _buildLabel("THEATER"),
          _buildDropdown(_locations, _tempLocation, (val) => setState(() => _tempLocation = val)),
          const SizedBox(height: 10),

          _buildLabel("FIELD EXP GAINED"),
          _buildDropdown(_skillOptions, _tempSkill, (val) => setState(() => _tempSkill = val)),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("MANUAL OVERRIDES (OPTIONAL)", style: TextStyle(color: Colors.white54, fontSize: 10)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel("AWARD"), _buildDropdown(_awardOptions, _manualAward, (v)=>setState(()=>_manualAward=v))])),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel("SCHOOL"), _buildDropdown(_schoolOptions, _manualSchool, (v)=>setState(()=>_manualSchool=v))])),
                  ],
                ),
                const SizedBox(height: 8),
                _buildLabel("SURVIVAL OUTCOME"),
                _buildDropdown(_survivalOptions, _manualSurvival, (v)=>setState(()=>_manualSurvival=v)),
              ],
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _resolveMission,
              style: ElevatedButton.styleFrom(backgroundColor: TacticalTheme.safetyOrange, padding: const EdgeInsets.symmetric(vertical: 15)),
              icon: const Icon(Icons.flash_on, color: Colors.black),
              label: const Text("RESOLVE TOUR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDebriefPhase() {
    return Column(
      children: [
        if (_char.isKIA) 
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.red[900],
            child: const Row(children: [Icon(Icons.warning, color: Colors.white), SizedBox(width: 10), Text("STATUS: KILLED IN ACTION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
          ),
        
        const SizedBox(height: 10),
        ..._char.history.map((record) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("THEATER: ${record.location.toUpperCase()}", style: TacticalTheme.dataMono.copyWith(color: TacticalTheme.desertTan)),
              Text("OUTCOME: ${record.survivalStatus}", style: TextStyle(color: record.survivalStatus.contains("KILLED") ? Colors.red : Colors.white)),
              if (record.award != "None") Text("AWARD: ${record.award}", style: const TextStyle(color: TacticalTheme.crtGreen)),
              if (record.school != "None") Text("SCHOOL: ${record.school}", style: const TextStyle(color: Colors.blueAccent)),
            ],
          ),
        )),
        
        const SizedBox(height: 20),
        const Text("SERVICE RECORD FINALIZED", style: TextStyle(color: Colors.grey)),
      ],
    );
  }
  
  Widget _buildHeader(String title) => Container(padding: const EdgeInsets.all(8), color: TacticalTheme.oliveDrab, width: double.infinity, child: Text(title, style: TacticalTheme.headerStencil.copyWith(fontSize: 16, color: Colors.black)));
  Widget _buildLabel(String txt) => Text(txt, style: TextStyle(color: TacticalTheme.desertTan.withOpacity(0.6), fontSize: 10));
  Widget _buildDropdown(List<String> items, String current, Function(String) onChange) {
    return Container(
      color: Colors.white10,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(current) ? current : items.first,
          dropdownColor: TacticalTheme.gunmetal,
          isExpanded: true,
          style: TacticalTheme.dataMono.copyWith(color: Colors.white),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => onChange(val!),
        ),
      ),
    );
  }
}
