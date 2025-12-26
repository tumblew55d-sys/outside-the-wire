// lib/models/character.dart

import 'dart:convert';
import 'inventory.dart';

enum AttributeType { strength, agility, wisdom, knowledge }

// Deployment Record helper class
class DeploymentRecord {
  String location;
  String award;
  String school;
  String survivalStatus;
  String skillIncreased;

  DeploymentRecord({
    this.location = "Unknown",
    this.award = "None",
    this.school = "None",
    this.survivalStatus = "Survived",
    this.skillIncreased = "None",
  });

  Map<String, dynamic> toMap() => {
    'location': location,
    'award': award,
    'school': school,
    'survivalStatus': survivalStatus,
    'skillIncreased': skillIncreased,
  };

  factory DeploymentRecord.fromMap(Map<String, dynamic> map) {
    return DeploymentRecord(
      location: map['location'] ?? "Unknown",
      award: map['award'] ?? "None",
      school: map['school'] ?? "None",
      survivalStatus: map['survivalStatus'] ?? "Survived",
      skillIncreased: map['skillIncreased'] ?? "None",
    );
  }
}

// Inspection Record for Section 7 (Inspection Station)
class InspectionRecord {
  String inspector;
  String station;
  String result; // e.g., 'Pass', 'Fail', 'Conditional'
  String notes;
  DateTime timestamp;

  InspectionRecord({
    this.inspector = 'Unknown',
    this.station = 'Main Gate',
    this.result = 'Pending',
    this.notes = '',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'inspector': inspector,
        'station': station,
        'result': result,
        'notes': notes,
        'timestamp': timestamp.toIso8601String(),
      };

  factory InspectionRecord.fromMap(Map<String, dynamic> map) {
    return InspectionRecord(
      inspector: map['inspector'] ?? 'Unknown',
      station: map['station'] ?? 'Main Gate',
      result: map['result'] ?? 'Pending',
      notes: map['notes'] ?? '',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : null,
    );
  }
}

class CharacterProfile {
  String name = '';
  String serviceBranch = 'Army';
  bool isOfficer = false;
  String rankTitle = 'Private';
  String militarySpecialty = 'Rifleman';

  // Appearance fields (used by Inspection / paper-doll)
  String skinTone = 'Pale';
  String hairStyle = 'Buzz Cut';
  String eyeColor = 'Brown';
  String scar = 'None';

  // Attributes (from earlier screens)
  Map<AttributeType, int> attributes = {
    AttributeType.strength: 4,
    AttributeType.agility: 4,
    AttributeType.wisdom: 4,
    AttributeType.knowledge: 4,
  };

  Map<String, int> skills = {
    'Small Arms': 0,
    'Heavy Weapons': 0,
    'First Aid': 0,
    'Radio Ops': 0,
    'Civil Affairs': 0,
    'Spying': 0,
    'Fires': 0,
    'Signals Intel': 0,
    'Explosives': 0,
    'Combat Experience': 0,
    'Training': 0,
  };

  // Deployment & service history
  List<DeploymentRecord> history = [];
  // Inspection station records (Section 7)
  List<InspectionRecord> inspections = [];
  // Inventory for paper-doll and equipment summary
  List<InventoryItem> inventory = [];
  bool hasCompletedService = false;
  bool isKIA = false;
  
  // Special invites (unlocked via logic)
  bool inviteEOD_JTAC = false;
  bool inviteSOF = false;

  CharacterProfile() {
    setMOS(militarySpecialty);
  }

  void setMOS(String mos) {
    militarySpecialty = mos;
    skills.updateAll((key, val) => 0);
    switch (mos) {
      case 'Rifleman':
        skills['Small Arms'] = 3;
        skills['Heavy Weapons'] = 1;
        skills['First Aid'] = 1;
        break;
      case 'Heavy Weapons':
        skills['Heavy Weapons'] = 3;
        skills['Small Arms'] = 1;
        skills['First Aid'] = 1;
        break;
      case 'Sniper':
        skills['Small Arms'] = 4;
        skills['Radio Ops'] = 1;
        skills['First Aid'] = 1;
        break;
      case 'Radio Operator':
        skills['Radio Ops'] = 3;
        skills['Small Arms'] = 1;
        skills['First Aid'] = 1;
        break;
      case 'Signals/Cyber Intel':
        skills['Signals Intel'] = 3;
        skills['Small Arms'] = 1;
        skills['Radio Ops'] = 1;
        break;
      case 'Medical':
        skills['First Aid'] = 3;
        skills['Small Arms'] = 1;
        break;
      case 'Civil Affairs':
        skills['Civil Affairs'] = 3;
        skills['Small Arms'] = 1;
        skills['First Aid'] = 1;
        break;
      default:
        skills['Small Arms'] = 1;
    }
  }

  void setOfficerStatus(bool officer) {
    isOfficer = officer;
    if (officer) {
      rankTitle = 'Lieutenant';
    } else {
      rankTitle = 'Private';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'serviceBranch': serviceBranch,
      'isOfficer': isOfficer,
      'rankTitle': rankTitle,
      'militarySpecialty': militarySpecialty,
      'skinTone': skinTone,
      'hairStyle': hairStyle,
      'eyeColor': eyeColor,
      'scar': scar,
      'skills': skills,
      'attributes': attributes.map((key, value) => MapEntry(key.toString(), value)),
      'history': history.map((e) => e.toMap()).toList(),
      'inspections': inspections.map((e) => e.toMap()).toList(),
      'inventory': inventory.map((i) => i.toMap()).toList(),
      'hasCompletedService': hasCompletedService,
      'isKIA': isKIA,
      'inviteEOD_JTAC': inviteEOD_JTAC,
      'inviteSOF': inviteSOF,
    };
  }

  factory CharacterProfile.fromMap(Map<String, dynamic> map) {
    final c = CharacterProfile();
    c.name = map['name'] ?? '';
    c.serviceBranch = map['serviceBranch'] ?? 'Army';
    c.isOfficer = map['isOfficer'] ?? false;
    c.rankTitle = map['rankTitle'] ?? 'Private';
    c.militarySpecialty = map['militarySpecialty'] ?? 'Rifleman';
    if (map['skills'] != null) {
      final s = Map<String, dynamic>.from(map['skills']);
      c.skills = s.map((k, v) => MapEntry(k, v as int));
    }
    if (map['attributes'] != null) {
      final attrMap = Map<String, dynamic>.from(map['attributes']);
      c.attributes = attrMap.map((key, value) {
        final type = AttributeType.values.firstWhere((e) => e.toString() == key, orElse: () => AttributeType.strength);
        return MapEntry(type, value as int);
      });
    }
    if (map['history'] != null) {
      c.history = (map['history'] as List).map((e) => DeploymentRecord.fromMap(e as Map<String, dynamic>)).toList();
    }
    if (map['inspections'] != null) {
      c.inspections = (map['inspections'] as List).map((e) => InspectionRecord.fromMap(e as Map<String, dynamic>)).toList();
    }
    if (map['inventory'] != null) {
      c.inventory = (map['inventory'] as List).map((e) => InventoryItem.fromMap(Map<String, dynamic>.from(e))).toList();
    }
    c.hasCompletedService = map['hasCompletedService'] ?? false;
    c.isKIA = map['isKIA'] ?? false;
    c.inviteEOD_JTAC = map['inviteEOD_JTAC'] ?? false;
    c.inviteSOF = map['inviteSOF'] ?? false;
    c.skinTone = map['skinTone'] ?? c.skinTone;
    c.hairStyle = map['hairStyle'] ?? c.hairStyle;
    c.eyeColor = map['eyeColor'] ?? c.eyeColor;
    c.scar = map['scar'] ?? c.scar;
    return c;
  }

  String toJson() => json.encode(toMap());
  factory CharacterProfile.fromJson(String source) => CharacterProfile.fromMap(json.decode(source) as Map<String, dynamic>);
}
