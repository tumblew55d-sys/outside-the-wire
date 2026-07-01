import 'dart:math';
import '../models/character.dart';
import '../data/nationality_data.dart';
import '../utils/body_type_descriptor.dart';

class DeploymentData {
  String? location;
  String? award;
  String? school;
  String? survival;
  String? promotionRank;
  String? newSpecialty;
  List<String> awards = [];

  DeploymentData({
    this.location,
    this.award,
    this.school,
    this.survival,
    this.promotionRank,
    this.newSpecialty,
    List<String>? awards,
  }) : awards = awards ?? [];

  Map<String, dynamic> toJson() => {
    'location': location,
    'award': award,
    'school': school,
    'survival': survival,
    'promotionRank': promotionRank,
    'newSpecialty': newSpecialty,
    'awards': awards,
  };

  factory DeploymentData.fromJson(Map<String, dynamic> json) => DeploymentData(
    location: json['location'],
    award: json['award'],
    school: json['school'],
    survival: json['survival'],
    promotionRank: json['promotionRank'],
    newSpecialty: json['newSpecialty'],
    awards: List<String>.from(json['awards'] ?? []),
  );
}

class QuickBuildService {
  static final Random _random = Random();

  /// Main entry point for quick character generation
  static Future<Character> generateQuickCharacter(
    String characterId,
    String specialty,
    Character baseCharacter,
  ) async {
    // Determine if this is an advanced specialty requiring prerequisites
    if (specialty == 'EOD') {
      return await _buildEODCharacter(characterId, baseCharacter);
    } else if (specialty == 'JTAC') {
      return await _buildJTACCharacter(characterId, baseCharacter);
    } else if (specialty == 'SOF') {
      return await _buildSOFCharacter(characterId, baseCharacter);
    } else if (specialty == 'Agent') {
      return await _buildAgentCharacter(characterId, baseCharacter);
    } else {
      return await _buildBasicCharacter(characterId, specialty, baseCharacter);
    }
  }

  /// Build a basic specialty character (Rifleman, Heavy Weapons, etc.)
  static Future<Character> _buildBasicCharacter(
    String characterId,
    String specialty,
    Character baseCharacter,
  ) async {
    final character = baseCharacter;

    // Roll attributes
    final attributes = _rollAttributes();
    character.attributes = attributes;

    // Apply specialty skills
    final skills = _applySpecialtySkills(specialty, character.skills);
    character.skills = skills;

    // CRITICAL: Save base values BEFORE any deployment/school/award bonuses
    final baseAttributes = Map<String, int>.from(attributes);
    final baseSkills = Map<String, int>.from(skills);

    // Generate character hook
    final hook = _generateHook(specialty);
    character.specialtyHook = hook;

    // Generate 1-2 deployments
    final deployments = _generateBasicDeployments(
      1 + _random.nextInt(2),
      character.nationality,
    );

    // Add 4 years per deployment to character age
    character.age += (deployments.length * 4);

    // Apply deployment bonuses
    for (var deployment in deployments) {
      // Each deployment adds combat experience
      skills['Combat'] = (skills['Combat'] ?? 0) + 1;

      // Apply school bonuses if any
      if (deployment.school != null) {
        // All schools give Strength +1
        attributes['Strength'] = (attributes['Strength'] ?? 0) + 1;

        // Elite schools (Ranger equivalent) give Knowledge +1
        if (deployment.school!.contains('Knowledge +1')) {
          attributes['Combat Knowledge'] =
              (attributes['Combat Knowledge'] ?? 0) + 1;
        }
      }

      // Apply award bonuses
      if (deployment.award != null) {
        if (deployment.award!.contains('+1 Knowledge')) {
          attributes['Combat Knowledge'] =
              (attributes['Combat Knowledge'] ?? 0) + 1;
        } else if (deployment.award!.contains('+2 Knowledge')) {
          attributes['Combat Knowledge'] =
              (attributes['Combat Knowledge'] ?? 0) + 2;
        } else if (deployment.award!.contains('+3 Knowledge')) {
          attributes['Combat Knowledge'] =
              (attributes['Combat Knowledge'] ?? 0) + 3;
        }
      }
    }

    character.attributes = attributes;
    character.skills = skills;

    // Assign weapons
    final weapons = _assignWeapons(specialty, null);

    // Assign equipment
    final equipment = _assignEquipment(specialty, false);

    // Build enlistment data
    character.enlistment = {
      'service': 'Army',
      'rankType': 'Enlisted',
      'rank': _getInitialRank(character.nationality, false),
      'specialty': specialty,
      'experience': {'Combat': deployments.length, 'Training': 0},
      'baseAttributes': baseAttributes, // Use saved base values
      'baseSkills': baseSkills, // Use saved base values
      'deployments': deployments.map((d) => d.toJson()).toList(),
    };

    // Build inventory data
    character.inventory = {
      'loadoutWeapons': weapons,
      'customWeapons': <String>[],
      'selectedEquipment': equipment,
      'clothing': <String>[],
      'pouches': <String>[],
      'dayPack': <String>[],
      'rucksack': <String>[],
      'hands': <String>[],
      'holster': <String>[],
    };

    // Add abilities and narrative
    _addAbilitiesAndNarrative(character);

    // Auto-promote to Corporal (E-4) if below Sergeant (E-5)
    _applyAutoPromotion(character);

    character.modifiedAt = DateTime.now();

    // Debug output
    print('Quick Build - Basic Character Generated:');
    print('  Name: ${character.name}');
    print('  Specialty: $specialty');
    print('  Attributes: ${character.attributes}');
    print('  Skills: ${character.skills}');
    print('  Deployments: ${deployments.length}');
    print('  Enlistment: ${character.enlistment}');

    return character;
  }

  /// Build EOD character with random initial specialty
  static Future<Character> _buildEODCharacter(
    String characterId,
    Character baseCharacter,
  ) async {
    // Random initial specialty
    final initialSpecialties = ['Rifleman', 'Heavy Weapons', 'Radio Operator'];
    final initialSpecialty =
        initialSpecialties[_random.nextInt(initialSpecialties.length)];

    final character = baseCharacter;

    // Roll attributes
    final attributes = _rollAttributes();
    character.attributes = attributes;

    // Apply initial specialty + EOD skills
    var skills = _applySpecialtySkills(initialSpecialty, character.skills);
    skills['Explosives'] = (skills['Explosives'] ?? 0) + 3;
    character.skills = skills;

    // CRITICAL: Save base values BEFORE deployment bonuses
    final baseAttributes = Map<String, int>.from(attributes);
    final baseSkills = Map<String, int>.from(skills);

    // Generate hook for EOD
    character.specialtyHook = _generateHook('EOD');

    // Generate 1 deployment with EOD invitation
    final deployments = _generateBasicDeployments(1, character.nationality);

    // Add 4 years per deployment + 1 year for EOD training
    character.age += (deployments.length * 4) + 1;

    // Apply deployment bonuses
    for (var deployment in deployments) {
      skills['Combat'] = (skills['Combat'] ?? 0) + 1;

      // Apply school and award bonuses
      if (deployment.school != null) {
        // All schools give Strength +1
        attributes['Strength'] = (attributes['Strength'] ?? 0) + 1;

        // Elite schools (Ranger equivalent) give Knowledge +1
        if (deployment.school!.contains('Knowledge +1')) {
          attributes['Combat Knowledge'] =
              (attributes['Combat Knowledge'] ?? 0) + 1;
        }
      }

      if (deployment.award != null) {
        if (deployment.award!.contains('+1 Knowledge')) {
          attributes['Combat Knowledge'] =
              (attributes['Combat Knowledge'] ?? 0) + 1;
        } else if (deployment.award!.contains('+2 Knowledge')) {
          attributes['Combat Knowledge'] =
              (attributes['Combat Knowledge'] ?? 0) + 2;
        } else if (deployment.award!.contains('+3 Knowledge')) {
          attributes['Combat Knowledge'] =
              (attributes['Combat Knowledge'] ?? 0) + 3;
        }
      }
    }

    character.attributes = attributes;
    character.skills = skills;

    // Randomly assign canine companion
    final hasCanine = _random.nextBool();
    if (hasCanine) {
      character.canineBreed = _getRandomCanineBreed();
      character.canineName = _getRandomCanineName();
    }

    // Assign weapons
    final weapons = _assignWeapons('EOD', null);

    // Assign equipment (with optional canine kit)
    final equipment = _assignEquipment('EOD', hasCanine);

    character.enlistment = {
      'service': 'Army',
      'rankType': 'Enlisted',
      'rank': _getInitialRank(character.nationality, false),
      'specialty': 'EOD',
      'experience': {'Combat': deployments.length, 'Training': 0},
      'baseAttributes': baseAttributes, // Use saved base values
      'baseSkills': baseSkills, // Use saved base values
      'deployments': deployments.map((d) => d.toJson()).toList(),
    };

    character.inventory = {
      'loadoutWeapons': weapons,
      'customWeapons': <String>[],
      'selectedEquipment': equipment,
      'clothing': <String>[],
      'pouches': <String>[],
      'dayPack': <String>[],
      'rucksack': <String>[],
      'hands': <String>[],
      'holster': <String>[],
    };

    // Auto-promote to Sergeant (E-5) - EOD requires E-5 or higher (BEFORE narrative generation)
    _applyAutoPromotionToSergeant(character);

    // Add abilities and narrative (AFTER promotion so rank is correct)
    _addAbilitiesAndNarrative(character);

    character.modifiedAt = DateTime.now();
    return character;
  }

  /// Build JTAC character with random initial specialty
  static Future<Character> _buildJTACCharacter(
    String characterId,
    Character baseCharacter,
  ) async {
    final initialSpecialties = ['Rifleman', 'Radio Operator'];
    final initialSpecialty =
        initialSpecialties[_random.nextInt(initialSpecialties.length)];

    final character = baseCharacter;

    final attributes = _rollAttributes();
    character.attributes = attributes;

    var skills = _applySpecialtySkills(initialSpecialty, character.skills);
    skills['Fires'] = (skills['Fires'] ?? 0) + 3;
    skills['Radio Ops'] = (skills['Radio Ops'] ?? 0) + 1;
    character.skills = skills;

    // CRITICAL: Save base values BEFORE deployment bonuses
    final baseAttributes = Map<String, int>.from(attributes);
    final baseSkills = Map<String, int>.from(skills);

    character.specialtyHook = _generateHook('JTAC');

    final deployments = _generateBasicDeployments(1, character.nationality);

    // Add 4 years per deployment + 1 year JTAC training
    character.age += (deployments.length * 4) + 1;

    // Apply deployment bonuses
    for (var deployment in deployments) {
      skills['Combat'] = (skills['Combat'] ?? 0) + 1;

      if (deployment.school != null) {
        // All schools give Strength +1
        attributes['Strength'] = (attributes['Strength'] ?? 0) + 1;

        // Elite schools (Ranger equivalent) give Knowledge +1
        if (deployment.school!.contains('Knowledge +1')) {
          attributes['Combat Knowledge'] =
              (attributes['Combat Knowledge'] ?? 0) + 1;
        }
      }

      if (deployment.award != null) {
        if (deployment.award!.contains('+1 Knowledge')) {
          attributes['Combat Knowledge'] =
              (attributes['Combat Knowledge'] ?? 0) + 1;
        } else if (deployment.award!.contains('+2 Knowledge')) {
          attributes['Combat Knowledge'] =
              (attributes['Combat Knowledge'] ?? 0) + 2;
        } else if (deployment.award!.contains('+3 Knowledge')) {
          attributes['Combat Knowledge'] =
              (attributes['Combat Knowledge'] ?? 0) + 3;
        }
      }
    }

    character.attributes = attributes;
    character.skills = skills;

    final weapons = _assignWeapons('JTAC', null);
    final equipment = _assignEquipment('JTAC', false);

    character.enlistment = {
      'service': 'Army',
      'rankType': 'Enlisted',
      'rank': _getInitialRank(character.nationality, false),
      'specialty': 'JTAC',
      'experience': {'Combat': deployments.length, 'Training': 0},
      'baseAttributes': baseAttributes, // Use saved base values
      'baseSkills': baseSkills, // Use saved base values
      'deployments': deployments.map((d) => d.toJson()).toList(),
    };

    character.inventory = {
      'loadoutWeapons': weapons,
      'customWeapons': <String>[],
      'selectedEquipment': equipment,
      'clothing': <String>[],
      'pouches': <String>[],
      'dayPack': <String>[],
      'rucksack': <String>[],
      'hands': <String>[],
      'holster': <String>[],
    };

    // Auto-promote to Sergeant (E-5) - JTAC requires E-5 or higher (BEFORE narrative generation)
    _applyAutoPromotionToSergeant(character);

    // Add abilities and narrative (AFTER promotion so rank is correct)
    _addAbilitiesAndNarrative(character);

    character.modifiedAt = DateTime.now();
    return character;
  }

  /// Build SOF character with random initial specialty + Ranger + SOF school
  static Future<Character> _buildSOFCharacter(
    String characterId,
    Character baseCharacter,
  ) async {
    final initialSpecialties = [
      'Rifleman',
      'Sniper',
      'Radio Operator',
      'Medical',
    ];
    final initialSpecialty =
        initialSpecialties[_random.nextInt(initialSpecialties.length)];

    final character = baseCharacter;

    var attributes = _rollAttributes();
    // CRITICAL: Save base attributes BEFORE any bonuses
    final baseAttributes = Map<String, int>.from(attributes);
    
    character.attributes = attributes;

    // Apply Ranger school bonuses
    attributes['Strength'] = (attributes['Strength'] ?? 0) + 1;
    attributes['Combat Knowledge'] = (attributes['Combat Knowledge'] ?? 0) + 1;

    var skills = _applySpecialtySkills(initialSpecialty, character.skills);
    // CRITICAL: Save base skills AFTER initial specialty but BEFORE Training bonus
    final baseSkills = Map<String, int>.from(skills);
    
    skills['Training'] = (skills['Training'] ?? 0) + 1;

    // Find highest skill and add +1
    var highestSkill = '';
    var highestValue = 0;
    skills.forEach((key, value) {
      if (value > highestValue) {
        highestValue = value;
        highestSkill = key;
      }
    });
    if (highestSkill.isNotEmpty) {
      skills[highestSkill] = highestValue + 1;
    }

    // Random SOF school (nationality-specific)
    final sofSchools = NationalityData.getSOFSchools(character.nationality);
    final sofSchool = sofSchools[_random.nextInt(sofSchools.length)];

    // Apply SOF school bonuses (check for patterns in school name)
    if (sofSchool.contains('Explosives +2')) {
      skills['Explosives'] = (skills['Explosives'] ?? 0) + 2;
    } else if (sofSchool.contains('Small Arms +1')) {
      skills['Small Arms'] = (skills['Small Arms'] ?? 0) + 1;
    } else if (sofSchools.indexOf(sofSchool) < 3) {
      // First 3 schools are physical (Small Boats, Air Assault, Airborne equivalents)
      attributes['Strength'] = (attributes['Strength'] ?? 0) + 1;
    }

    // Generate 3-4 deployments (Ranger school + additional combat deployments)
    final numDeployments = 3 + _random.nextInt(2); // 3 or 4 deployments
    final deployments = _generateSOFDeployments(
      sofSchool,
      numDeployments,
      character.nationality,
    );

    // Add 4 years per deployment + 2 years SOF training
    character.age += (numDeployments * 4) + 2;

    // Apply deployment bonuses to attributes and skills
    // Each deployment adds combat experience
    for (var deployment in deployments) {
      skills['Combat'] = (skills['Combat'] ?? 0) + 1;

      // School bonuses (Elite school in first deployment)
      if (deployment.school != null) {
        // All schools give Strength +1
        attributes['Strength'] = (attributes['Strength'] ?? 0) + 1;

        if (deployment.school!.contains('Knowledge +1')) {
          // Ranger bonuses already applied above, but ensure they're in final values
          attributes['Strength'] = (attributes['Strength'] ?? 0);
          attributes['Combat Knowledge'] =
              (attributes['Combat Knowledge'] ?? 0);
        }
      }
    }

    character.attributes = attributes;
    character.skills = skills;
    character.isSOF = true;
    character.specialtyHook = _generateHook('SOF');

    // Get SOF rank (Staff Sergeant E-6 or equivalent)
    final sofRank = _getSOFRank(character.nationality, false);

    final weapons = _assignWeapons('SOF', initialSpecialty);
    final equipment = _assignEquipment('SOF', false);

    character.enlistment = {
      'service': 'Army',
      'rankType': 'Enlisted',
      'rank': sofRank,
      'specialty': 'SOF $initialSpecialty',
      'experience': {'Combat': deployments.length, 'Training': 1},
      'baseAttributes': baseAttributes, // Use saved base values
      'baseSkills': baseSkills, // Use saved base values
      'deployments': deployments.map((d) => d.toJson()).toList(),
      'sofSchool': sofSchool,
    };

    character.inventory = {
      'loadoutWeapons': weapons,
      'customWeapons': <String>[],
      'selectedEquipment': equipment,
      'clothing': <String>[],
      'pouches': <String>[],
      'dayPack': <String>[],
      'rucksack': <String>[],
      'hands': <String>[],
      'holster': <String>[],
    };

    // Add abilities and narrative
    _addAbilitiesAndNarrative(character);

    // Auto-promote to Corporal (E-4) if below Sergeant (E-5)
    _applyAutoPromotion(character);

    character.modifiedAt = DateTime.now();

    // Debug output
    print('Quick Build - SOF Character Generated:');
    print('  Name: ${character.name}');
    print('  Initial Specialty: $initialSpecialty');
    print('  SOF School: $sofSchool');
    print('  Rank: $sofRank');
    print('  Attributes: ${character.attributes}');
    print('  Skills: ${character.skills}');
    print('  Deployments: ${deployments.length}');
    print('  isSOF: ${character.isSOF}');

    return character;
  }

  /// Build Agent character (SOF -> Agent progression)
  static Future<Character> _buildAgentCharacter(
    String characterId,
    Character baseCharacter,
  ) async {
    // First build as SOF
    var character = await _buildSOFCharacter(characterId, baseCharacter);

    // Add 3 years for Agent training
    character.age += 3;

    // Add Agent-specific bonuses
    var skills = Map<String, int>.from(character.skills);
    skills['Spying'] = (skills['Spying'] ?? 0) + 3;
    skills['Civil Affairs'] = (skills['Civil Affairs'] ?? 0) + 1;
    skills['Training'] = (skills['Training'] ?? 0) + 1; // Agent school adds Training +1

    character.specialtyHook = _generateHook('Agent');

    // Add third deployment for Agent invitation
    final deployments = List<DeploymentData>.from(
      (character.enlistment['deployments'] as List).map(
        (d) => DeploymentData.fromJson(d),
      ),
    );
    deployments.add(_generateAgentDeployment());
    
    // Update Combat skill to reflect new deployment count
    skills['Combat'] = deployments.length;
    character.skills = skills;

    // Replace weapons with covert loadout
    final weapons = _assignWeapons('Agent', null);
    final equipment = _assignEquipment('Agent', false);

    // Preserve Training from SOF and add Agent bonus
    final currentTraining = (character.enlistment['experience'] as Map?)?['Training'] ?? 1;
    character.enlistment = {
      ...character.enlistment,
      'specialty': 'Agent',
      'experience': {'Combat': deployments.length, 'Training': currentTraining + 1},
      'deployments': deployments.map((d) => d.toJson()).toList(),
    };

    character.inventory = {
      'loadoutWeapons': weapons,
      'customWeapons': <String>[],
      'selectedEquipment': equipment,
      'clothing': <String>[],
      'pouches': <String>[],
      'dayPack': <String>[],
      'rucksack': <String>[],
      'hands': <String>[],
      'holster': <String>[],
    };

    // Add abilities and narrative (Agent already has them from SOF build, but regenerate with Agent specialty)
    _addAbilitiesAndNarrative(character);

    // Auto-promote to Corporal (E-4) if below Sergeant (E-5)
    _applyAutoPromotion(character);

    character.modifiedAt = DateTime.now();
    return character;
  }

  /// Roll 1D10 for each attribute and assign optimally
  static Map<String, int> _rollAttributes() {
    final rolls = List.generate(4, (_) => 3 + _random.nextInt(8));
    rolls.sort((a, b) => b.compareTo(a)); // Sort descending

    // Assign highest to most important attributes
    return {
      'Strength': rolls[0],
      'Agility': rolls[1],
      'Combat Wisdom': rolls[2],
      'Combat Knowledge': rolls[3],
    };
  }

  /// Apply specialty skill bonuses
  static Map<String, int> _applySpecialtySkills(
    String specialty,
    Map<String, int> baseSkills,
  ) {
    final skills = Map<String, int>.from(baseSkills);

    if (specialty.contains('Rifleman')) {
      skills['Small Arms'] = (skills['Small Arms'] ?? 0) + 3;
      skills['Heavy Weapons'] = (skills['Heavy Weapons'] ?? 0) + 1;
      skills['First Aid'] = (skills['First Aid'] ?? 0) + 1;
    } else if (specialty.contains('Heavy Weapons')) {
      skills['Heavy Weapons'] = (skills['Heavy Weapons'] ?? 0) + 3;
      skills['Small Arms'] = (skills['Small Arms'] ?? 0) + 1;
      skills['First Aid'] = (skills['First Aid'] ?? 0) + 1;
    } else if (specialty.contains('Sniper')) {
      skills['Small Arms'] = (skills['Small Arms'] ?? 0) + 4;
      skills['Radio Ops'] = (skills['Radio Ops'] ?? 0) + 1;
      skills['First Aid'] = (skills['First Aid'] ?? 0) + 1;
    } else if (specialty.contains('Radio Operator')) {
      skills['Radio Ops'] = (skills['Radio Ops'] ?? 0) + 3;
      skills['Small Arms'] = (skills['Small Arms'] ?? 0) + 1;
      skills['First Aid'] = (skills['First Aid'] ?? 0) + 1;
    } else if (specialty.contains('Signals/Cyber Intel')) {
      skills['Signals Intel'] = (skills['Signals Intel'] ?? 0) + 3;
      skills['Small Arms'] = (skills['Small Arms'] ?? 0) + 1;
      skills['Radio Ops'] = (skills['Radio Ops'] ?? 0) + 1;
    } else if (specialty.contains('Medical')) {
      skills['First Aid'] = (skills['First Aid'] ?? 0) + 3;
      skills['Small Arms'] = (skills['Small Arms'] ?? 0) + 1;
    } else if (specialty.contains('Civil Affairs')) {
      skills['Civil Affairs'] = (skills['Civil Affairs'] ?? 0) + 3;
      skills['Small Arms'] = (skills['Small Arms'] ?? 0) + 1;
      skills['First Aid'] = (skills['First Aid'] ?? 0) + 1;
    }

    return skills;
  }

  /// Generate character hook
  static String _generateHook(String specialty) {
    final specialtyName = specialty.split(' ').first;
    return NationalityData.getRandomHook(specialtyName);
  }

  /// Generate random personal conflict
  static String _generatePersonalConflict() {
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
    return conflicts[_random.nextInt(conflicts.length)];
  }

  /// Generate basic deployments
  static List<DeploymentData> _generateBasicDeployments(
    int count,
    String nationality,
  ) {
    final locations = [
      'Afghanistan',
      'Iraq',
      'Syria',
      'Philippines',
      'Yemen',
      'Somalia',
      'Sahel',
      'Nigeria',
      'Libya',
    ];
    final deployments = <DeploymentData>[];
    final awards =
        NationalityData.getDeploymentAwards(nationality)['awards']
            as List<String>;

    for (var i = 0; i < count; i++) {
      final location = locations[_random.nextInt(locations.length)];
      final result = 1 + _random.nextInt(10);

      String? award;
      if (result <= 3) {
        award = awards[0]; // None
      } else if (result <= 6) {
        award = awards[1]; // Achievement
      } else if (result <= 8) {
        award = awards[2]; // Commendation +1
      } else if (result == 9) {
        award = awards[3]; // Bronze Star +2
      } else {
        award = awards[4]; // Silver Star +3
      }

      deployments.add(
        DeploymentData(
          location: location,
          school: null,
          award: award,
          survival: 'Survived',
        ),
      );
    }

    return deployments;
  }

  /// Generate SOF deployments with Ranger school
  static List<DeploymentData> _generateSOFDeployments(
    String sofSchool,
    int numDeployments,
    String nationality,
  ) {
    final locations = [
      'Afghanistan',
      'Iraq',
      'Syria',
      'Philippines',
      'Yemen',
      'Somalia',
      'Sahel',
      'Nigeria',
      'Libya',
    ];
    final deployments = <DeploymentData>[];
    final awards =
        NationalityData.getDeploymentAwards(nationality)['awards']
            as List<String>;
    final schools = NationalityData.getSchools(nationality);

    // First deployment with Ranger equivalent school (elite training)
    deployments.add(
      DeploymentData(
        location: locations[_random.nextInt(locations.length)],
        school: schools[4], // Ranger equivalent (Knowledge +1)
        award: null,
        survival: 'Survived unscathed',
      ),
    );

    // Additional deployments (combat experience)
    for (var i = 1; i < numDeployments; i++) {
      final roll = 1 + _random.nextInt(10);
      String? award;
      if (roll <= 3) {
        award = awards[0]; // None
      } else if (roll <= 6) {
        award = awards[1]; // Achievement
      } else if (roll <= 8) {
        award = awards[2]; // Commendation +1
      } else if (roll == 9) {
        award = awards[3]; // Bronze Star +2
      } else {
        award = awards[4]; // Silver Star +3
      }

      deployments.add(
        DeploymentData(
          location: locations[_random.nextInt(locations.length)],
          school: null,
          award: award,
          survival: 'Survived unscathed',
        ),
      );
    }

    return deployments;
  }

  /// Generate Agent deployment
  static DeploymentData _generateAgentDeployment() {
    final locations = ['Classified', 'Overseas', 'Undisclosed'];
    return DeploymentData(
      location: locations[_random.nextInt(locations.length)],
      school: null,
      award: null,
      survival: 'Survived',
    );
  }

  /// Assign weapons based on specialty
  static List<String> _assignWeapons(String specialty, String? subSpecialty) {
    if (specialty == 'Rifleman') {
      return ['M4 carbine', 'combat knife', '(2) frag grenades', 'LAW'];
    } else if (specialty == 'Heavy Weapons') {
      return _random.nextBool()
          ? ['M240 GPMG', 'M9 pistol', 'combat knife']
          : ['M4 carbine', 'combat knife', 'tripod/ammunition'];
    } else if (specialty == 'Sniper') {
      final sniperRifles = [
        'M40A4 sniper rifle',
        'M110 SASS',
        'M24 sniper rifle',
      ];
      return [
        sniperRifles[_random.nextInt(sniperRifles.length)],
        'M9 pistol',
        'combat knife',
        'smoke/CS grenades',
      ];
    } else if (specialty == 'Radio Operator' ||
        specialty == 'Signals/Cyber Intel') {
      return ['M4 carbine', 'combat knife', '(2) smoke grenades'];
    } else if (specialty == 'Medical' || specialty == 'Civil Affairs') {
      return ['M4 carbine', 'combat knife', '(2) smoke grenades'];
    } else if (specialty == 'EOD') {
      return ['M4 carbine', 'combat knife', 'M9 Pistol'];
    } else if (specialty == 'JTAC') {
      return _random.nextBool()
          ? ['M4 carbine', 'M9 pistol', 'combat knife', '(2) smoke grenades']
          : [
              'M4 carbine with M320A1',
              'M9 pistol',
              'combat knife',
              '(2) smoke grenades',
            ];
    } else if (specialty == 'SOF') {
      // SOF weapons based on sub-specialty
      if (subSpecialty == 'Sniper') {
        return ['M110 SASS', 'M9 pistol', 'combat knife', 'smoke grenades'];
      } else if (subSpecialty == 'Medical' ||
          subSpecialty == 'Radio Operator') {
        return ['M4 carbine', 'combat knife', '(2) smoke grenades'];
      } else {
        return ['M4 carbine', 'M9 pistol', '(2) frag grenades', 'LAW'];
      }
    } else if (specialty == 'Agent') {
      return ['Makarov Pistol'];
    }

    // Default
    return ['M4 carbine', 'combat knife'];
  }

  /// Assign equipment based on specialty
  static List<String> _assignEquipment(String specialty, bool hasCanine) {
    final equipment = <String>[];

    if (specialty == 'Medical') {
      equipment.add('Unit 1 Medical Kit');
    } else if (specialty == 'JTAC') {
      equipment.addAll(['JTAC computer and radio', 'Backpack Radio']);
    } else if (specialty == 'Agent') {
      equipment.add('Spy Kit');
    } else if (specialty == 'EOD') {
      equipment.addAll([
        'EOD demo kit',
        'EOD robot and computer',
        'Thor Backpack signal jammer',
      ]);
      if (hasCanine) {
        equipment.add('Canine Kit');
      }
    } else if (specialty == 'Civil Affairs') {
      equipment.addAll(['Civil Affairs Kit', 'RIAB']);
    } else if (specialty == 'Signals/Cyber Intel') {
      equipment.addAll(['Signal Collection Kit', 'Inter Squad Radio']);
    } else if (specialty == 'SOF') {
      equipment.addAll([
        'Night Vision Goggles',
        'Rifle mounted IR pointer',
        'Inter Squad Radio',
        'Flashbang grenade',
      ]);
    }

    // Random optional equipment (20-40% chance)
    if (_random.nextInt(100) < 30) {
      final optional = [
        'Rifle mounted flashlight',
        'Hand held walkie talkie',
        'Frag grenade',
        'Smoke grenade',
      ];
      equipment.add(optional[_random.nextInt(optional.length)]);
    }

    return equipment;
  }

  /// Get initial rank based on nationality
  static String _getInitialRank(String nationality, bool isOfficer) {
    if (isOfficer) {
      return NationalityData.getInitialOfficerRanks(
        nationality,
      )['ranks']!.first;
    } else {
      return NationalityData.getInitialEnlistedRanks(
        nationality,
      )['ranks']!.first;
    }
  }

  /// Auto-promote character to Corporal (E-4) if below Sergeant (E-5)
  static void _applyAutoPromotion(Character character) {
    final rankType = character.enlistment['rankType']?.toString() ?? 'Enlisted';
    final service = character.enlistment['service']?.toString() ?? 'Army';

    if (rankType == 'Enlisted') {
      final currentRank = character.enlistment['rank']?.toString() ?? '';
      final promotedRank = NationalityData.autoPromoteToCorporal(
        currentRank,
        character.nationality,
        service,
      );
      if (promotedRank != currentRank) {
        character.enlistment['rank'] = promotedRank;
        // Add Training +1 for promotion
        character.skills['Training'] = (character.skills['Training'] ?? 0) + 1;
        print(
          'Auto-promoted ${character.name} from $currentRank to $promotedRank (Training +1)',
        );
      }
    }
  }

  /// Auto-promote to Sergeant (E-5) for EOD/JTAC specialties that require E-5 minimum
  static void _applyAutoPromotionToSergeant(Character character) {
    final rankType = character.enlistment['rankType']?.toString() ?? 'Enlisted';
    final service = character.enlistment['service']?.toString() ?? 'Army';

    if (rankType == 'Enlisted') {
      final currentRank = character.enlistment['rank']?.toString() ?? '';
      final promotedRank = NationalityData.autoPromoteToSergeant(
        currentRank,
        character.nationality,
        service,
      );
      if (promotedRank != currentRank) {
        character.enlistment['rank'] = promotedRank;
        // Add Training +1 for promotion
        character.skills['Training'] = (character.skills['Training'] ?? 0) + 1;
        print(
          'Auto-promoted ${character.name} from $currentRank to $promotedRank (required for ${character.enlistment['specialty']}, Training +1)',
        );
      }
    }
  }

  /// Get promoted rank (single promotion)
  // Helper method for future rank progression feature
  // ignore: unused_element
  static String _getPromotedRank(String nationality, bool isOfficer) {
    final ranks = isOfficer
        ? NationalityData.getInitialOfficerRanks(nationality)['ranks']!
        : NationalityData.getInitialEnlistedRanks(nationality)['ranks']!;

    // Return second rank (promoted from first)
    return ranks.length > 1 ? ranks[1] : ranks[0];
  }

  /// Get SOF rank (promoted to E-6 Staff Sergeant or equivalent)
  static String _getSOFRank(String nationality, bool isOfficer) {
    final ranks = isOfficer
        ? NationalityData.getInitialOfficerRanks(nationality)['ranks']!
        : NationalityData.getInitialEnlistedRanks(nationality)['ranks']!;

    // For SOF, promote to E-6 equivalent (index 5 for US ranks: E-1 to E-6)
    // Private, Private 2, PFC, Specialist, Sergeant, Staff Sergeant
    final sofRankIndex = 5; // Staff Sergeant (E-6)
    return ranks.length > sofRankIndex ? ranks[sofRankIndex] : ranks.last;
  }

  /// Get random canine breed
  static String _getRandomCanineBreed() {
    final breeds = [
      'German Shepherd',
      'Belgian Malinois',
      'Labrador Retriever',
      'Dutch Shepherd',
      'Rottweiler',
    ];
    return breeds[_random.nextInt(breeds.length)];
  }

  /// Get random canine name
  static String _getRandomCanineName() {
    final names = [
      'Rex',
      'Max',
      'Duke',
      'Bear',
      'Apollo',
      'Zeus',
      'Titan',
      'Ace',
      'Rocky',
      'Buddy',
    ];
    return names[_random.nextInt(names.length)];
  }

  /// Calculate abilities from attributes and skills (matches screen_d_abilities.dart logic)
  static Map<String, int> _calculateAbilities(Character character) {
    final a = character.attributes;
    final s = character.skills;

    int val(Map<String, int> map, String key) => map[key] ?? 0;
    int penalize(int base, bool earned) => earned ? base : (base ~/ 2);

    // Calculate base Tactics
    var tacticsBase =
        val(a, 'Combat Knowledge') + val(s, 'Combat') + val(s, 'Training');

    // Apply specialty bonuses
    final specialty = character.enlistment['specialty']?.toString() ?? '';
    if (specialty.contains('Rifleman')) {
      tacticsBase += 1; // Rifleman specialty bonus
    }

    return {
      'Prowess': val(a, 'Strength') + val(s, 'Combat') + val(s, 'Training'),
      'Instincts':
          val(a, 'Combat Wisdom') + val(s, 'Training') + val(s, 'Combat'),
      'Tactics': tacticsBase,
      'Small Arms': penalize(
        val(s, 'Small Arms') + val(a, 'Agility') + val(s, 'Combat'),
        val(s, 'Small Arms') > 0,
      ),
      'Heavy Weapons': penalize(
        val(s, 'Heavy Weapons') + val(a, 'Agility') + val(s, 'Combat'),
        val(s, 'Heavy Weapons') > 0,
      ),
      'First Aid': penalize(
        val(s, 'First Aid') + val(s, 'Combat') + val(a, 'Combat Wisdom'),
        val(s, 'First Aid') > 0,
      ),
      'Communication': penalize(
        val(s, 'Radio Ops') + val(s, 'Combat') + val(a, 'Combat Wisdom'),
        val(s, 'Radio Ops') > 0,
      ),
      'Civil Affairs': penalize(
        val(s, 'Civil Affairs') + val(s, 'Combat') + val(a, 'Combat Wisdom'),
        val(s, 'Civil Affairs') > 0,
      ),
      'Fires': penalize(
        val(s, 'Fires') + val(s, 'Combat') + val(a, 'Combat Wisdom'),
        val(s, 'Fires') > 0,
      ),
      'Spying': penalize(
        val(s, 'Spying') + val(s, 'Combat') + val(a, 'Combat Wisdom'),
        val(s, 'Spying') > 0,
      ),
      'Explosives': penalize(
        val(s, 'Explosives') + val(s, 'Combat') + val(a, 'Combat Wisdom'),
        val(s, 'Explosives') > 0,
      ),
      'Signals Intel': penalize(
        val(s, 'Signals Intel') + val(s, 'Combat') + val(a, 'Combat Wisdom'),
        val(s, 'Signals Intel') > 0,
      ),
    };
  }

  /// Generate narrative text (matches screen_d_abilities.dart logic)
  static String _generateNarrative(Character character) {
    final c = character;
    final name = c.name.isNotEmpty ? c.name : 'This recruit';
    final nat = c.nationality.isNotEmpty ? c.nationality : '';
    final service = (c.enlistment['service'] ?? '').toString();
    final rank = (c.enlistment['rank'] ?? '').toString();
    final specialty = (c.enlistment['specialty'] ?? '').toString();
    final motivation = c.motivation;
    final trademark = c.trademark;
    final age = c.age;
    final hometown = c.homeLocation;

    // deployments summary
    final rawDeployments = c.enlistment['deployments'];
    final deployments = rawDeployments is List
        ? rawDeployments
              .whereType<Map>()
              .map((m) => Map<String, dynamic>.from(m))
              .toList()
        : <Map<String, dynamic>>[];

    final langs = c.languages.isNotEmpty ? c.languages.join(', ') : '';

    // Helper functions for official attribute descriptors
    String getStrengthDescriptor(int value) {
      if (value <= 3) return 'scrawny';
      if (value <= 6) return 'of average strength';
      if (value <= 8) return 'strong';
      return 'a beast';
    }

    String getAgilityDescriptor(int value) {
      if (value <= 3) return 'clumsy';
      if (value <= 6) return 'of average agility';
      if (value <= 8) return 'nimble';
      return 'ninja-like';
    }

    String getWisdomDescriptor(int value) {
      if (value <= 3) return 'slow-minded';
      if (value <= 6) return 'of average combat wisdom';
      if (value <= 8) return 'smart';
      return 'wicked smart';
    }

    String getKnowledgeDescriptor(int value) {
      if (value <= 3) return 'lacking combat instincts';
      if (value <= 6) return 'of average combat awareness';
      if (value <= 8) return 'possessing cat-like reflexes';
      return 'having killer instincts';
    }

    // Get body type archetype
    final weightInLbs = c.weightUnit == 'kg' ? c.weight * 2.20462 : c.weight;
    final bodyTypeArchetype = BodyTypeDescriptor.getArchetypeName(
      c.height,
      weightInLbs,
    );

    final sb = StringBuffer();
    sb.write(name);
    if (age > 0 && hometown.isNotEmpty) {
      sb.write(', age $age from $hometown,');
    } else if (age > 0) {
      sb.write(', age $age,');
    } else if (hometown.isNotEmpty) {
      sb.write(' from $hometown');
    }
    sb.write(' is a ');
    if (nat.isNotEmpty) sb.write('$nat ');
    sb.write('$service ');
    if (specialty.isNotEmpty) sb.write('$specialty ');
    sb.write('$rank. ');

    // Add body type archetype
    sb.write('Physically, $name has the build of "$bodyTypeArchetype". ');

    // Physical and mental description
    if (c.attributes.isNotEmpty) {
      final str = c.attributes['Strength'] ?? 0;
      final agi = c.attributes['Agility'] ?? 0;
      final wis = c.attributes['Combat Wisdom'] ?? 0;
      final know = c.attributes['Combat Knowledge'] ?? 0;

      final descriptors = <String>[];
      if (str > 0) {
        descriptors.add(getStrengthDescriptor(str));
      }
      if (agi > 0) {
        descriptors.add(getAgilityDescriptor(agi));
      }
      if (wis > 0) {
        descriptors.add(getWisdomDescriptor(wis));
      }
      if (know > 0) {
        descriptors.add(getKnowledgeDescriptor(know));
      }

      if (descriptors.isNotEmpty) {
        sb.write('$name is ');
        if (descriptors.length == 1) {
          sb.write('${descriptors[0]}. ');
        } else if (descriptors.length == 2) {
          sb.write('${descriptors[0]} and ${descriptors[1]}. ');
        } else {
          for (var i = 0; i < descriptors.length - 1; i++) {
            sb.write('${descriptors[i]}, ');
          }
          sb.write('and ${descriptors.last}. ');
        }
      }
    }

    // Link motivation and trademark naturally
    if (motivation.isNotEmpty && trademark.isNotEmpty) {
      sb.write(
        'Motivated by $motivation, $name\'s trademark is ${trademark.toLowerCase()}. ',
      );
    } else if (motivation.isNotEmpty) {
      sb.write('$name is motivated by $motivation. ');
    } else if (trademark.isNotEmpty) {
      sb.write('$name\'s trademark is ${trademark.toLowerCase()}. ');
    }

    // Add Personal Conflict (generate if empty)
    if (c.personalConflict.isEmpty) {
      c.personalConflict = _generatePersonalConflict();
    }
    if (c.personalConflict.isNotEmpty) {
      sb.write(
        'However, $name carries a personal burden: ${c.personalConflict} ',
      );
    }

    // Deployment-by-deployment narrative
    if (deployments.isNotEmpty) {
      sb.write('\n\nDeployment History: ');
      for (var i = 0; i < deployments.length; i++) {
        final d = deployments[i];
        final location = d['location']?.toString() ?? '';
        final school = d['school']?.toString() ?? '';
        final promotionRank = d['promotionRank']?.toString() ?? '';
        final newSpecialty = d['newSpecialty']?.toString() ?? '';
        final survival = d['survival']?.toString() ?? '';
        final award = d['award']?.toString() ?? '';
        final rawAwards = d['awards'];
        final awards = rawAwards is List
            ? rawAwards.whereType<String>().toList()
            : <String>[];

        // Extract medals from both 'award' field and survival status
        final allAwards = List<String>.from(awards);

        // Extract medal from award field (e.g., "Croix de Guerre (+1 Knowledge)")
        if (award.isNotEmpty && award != 'None') {
          final awardName = award.split('(').first.trim();
          // Determine article based on first character
          final firstChar = awardName[0].toLowerCase();
          final article = ['a', 'e', 'i', 'o', 'u'].contains(firstChar)
              ? 'an'
              : 'the';
          allAwards.add('$article $awardName');
        }

        // Extract wound decoration from survival status
        final woundDecorations = [
          'Purple Heart',
          'Wound Stripe',
          'Blessure de Guerre',
          'Sacrifice Medal',
          'Wound Medal',
          'Wound Badge',
          'Verwundetenabzeichen',
          'Medalla de Sufrimientos por la Patria',
          'Wounded Personnel Medal',
          'Medal for Wounds and Contusions',
          'Sårad i Strid',
        ];
        for (final decoration in woundDecorations) {
          if (survival.contains(decoration)) {
            allAwards.add('the $decoration');
            break;
          }
        }

        if (location.isEmpty) continue;

        sb.write('$name deployed to $location');

        // Add awards earned during this deployment
        if (allAwards.isNotEmpty) {
          if (allAwards.length == 1) {
            sb.write(', earning ${allAwards.first}');
          } else {
            sb.write(
              ', earning ${allAwards.sublist(0, allAwards.length - 1).join(", ")} and ${allAwards.last}',
            );
          }
        }

        // Add promotion during this deployment
        if (promotionRank.isNotEmpty) {
          sb.write(' and was promoted to $promotionRank');
        }

        sb.write('. ');

        // Add school attendance
        if (school.isNotEmpty) {
          sb.write('Following deployment, $name attended $school. ');
        }

        // Add specialty change
        if (newSpecialty.isNotEmpty) {
          sb.write('$name became a $newSpecialty. ');

          // Add canine companion for EOD
          if (newSpecialty == 'EOD' && c.canineName.isNotEmpty) {
            sb.write(
              '$name was partnered with ${c.canineName}, a ${c.canineBreed} explosive detection dog. ',
            );
          }
        }
      }
    }

    // Add re-enlistment information
    final reenlistmentCount = c.enlistment['reenlistmentCount'] ?? 0;
    if (reenlistmentCount > 0) {
      if (reenlistmentCount == 1) {
        sb.write(
          '\n\n$name re-enlisted for an additional tour of duty, demonstrating continued dedication to service.',
        );
      } else {
        sb.write(
          '\n\n$name re-enlisted $reenlistmentCount times, showing exceptional commitment and career longevity.',
        );
      }
    }

    // Languages
    if (langs.isNotEmpty) {
      sb.write('\n\nLanguages: $langs.');
    }

    return sb.toString();
  }

  /// Add abilities and narrative to character (call before returning from build methods)
  static void _addAbilitiesAndNarrative(Character character) {
    final abilities = _calculateAbilities(character);
    final narrative = _generateNarrative(character);

    character.enlistment['abilities'] = abilities;
    character.enlistment['narrative'] = narrative;
  }
}
