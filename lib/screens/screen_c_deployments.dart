import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/character.dart';
import '../data/nationality_data.dart';
import '../widgets/character_creation_layout.dart';
import 'screen_b_enlistment.dart';
import 'screen_c2_reenlistment.dart';

class DeploymentsScreen extends StatefulWidget {
  final String characterId;

  const DeploymentsScreen({super.key, required this.characterId});

  @override
  State<DeploymentsScreen> createState() => _DeploymentsScreenState();
}

class _DeploymentsScreenState extends State<DeploymentsScreen> {
  final _formKey = GlobalKey<FormState>();

  Character? _character;
  int? _careerRoll;
  int _numDeployments = 0;
  bool _sergeantPromotion = false;
  bool _officerPromotion = false;
  bool _eodJtacInvite = false;
  String? _specialtyChoice; // 'EOD', 'JTAC', 'SOF', 'Agent'

  final List<DeploymentData> _deployments = [];
  int _unusedSkillPoints = 0;
  bool _rangerGraduate = false;
  bool _sofMember = false;
  String? _sofSchool; // Separate SOF school selection
  bool _sofPromotion = false; // Track if SOF promotion occurred
  bool _agentPromotion = false; // Track if Agent promotion occurred
  bool _saving = false;

  // Track starting age to prevent multiple career rolls from stacking age
  int _startingAge = 0;

  // Canine companion for EOD
  String _canineBreed = '';
  String _canineName = '';
  final _canineNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCharacter();
  }

  // Get list of all schools already selected
  Set<String> _getSelectedSchools() {
    return _deployments
        .where((d) => d.school != null)
        .map((d) => _normalizeSchoolName(d.school!))
        .toSet();
  }

  // Normalize school names to base form for comparison
  String _normalizeSchoolName(String school) {
    if (school.contains('Small Boats')) return 'Small Boats';
    if (school.contains('Air Assault')) return 'Air Assault';
    if (school.contains('Airborne')) return 'Airborne';
    if (school.contains('Breacher')) return 'Breacher';
    if (school.contains('Ranger')) return 'Ranger';
    if (school.contains('Underground') ||
        school.contains('Jungle') ||
        school.contains('Mountain')) {
      return 'Specialty Warfare';
    }
    if (school.contains('Hostage Rescue')) return 'Hostage Rescue';
    return school;
  }

  // Check if a school has already been selected
  bool _isSchoolDuplicate(String school) {
    final normalized = _normalizeSchoolName(school);
    final selected = _getSelectedSchools();
    return selected.contains(normalized);
  }

  // Calculate preview attributes with all current bonuses
  Map<String, int> _getPreviewAttributes() {
    if (_character == null) return {};

    final preview = Map<String, int>.from(_character!.attributes);

    // Officer promotion bonuses
    if (_officerPromotion) {
      preview['Strength'] = (preview['Strength'] ?? 0) + 1;
      preview['Agility'] = (preview['Agility'] ?? 0) + 1;
      preview['Combat Knowledge'] = (preview['Combat Knowledge'] ?? 0) + 1;
    }

    // Deployment school bonuses
    for (var deployment in _deployments) {
      if (deployment.school != null) {
        // All schools give Strength +1
        preview['Strength'] = (preview['Strength'] ?? 0) + 1;

        // Elite schools (Ranger equivalent) give Knowledge +1
        if (deployment.school!.contains('Knowledge +1')) {
          preview['Combat Knowledge'] = (preview['Combat Knowledge'] ?? 0) + 1;
        }
      }

      // Award bonuses
      if (deployment.award != null) {
        if (deployment.award!.contains('+1 Knowledge')) {
          preview['Combat Knowledge'] = (preview['Combat Knowledge'] ?? 0) + 1;
        } else if (deployment.award!.contains('+2 Knowledge')) {
          preview['Combat Knowledge'] = (preview['Combat Knowledge'] ?? 0) + 2;
        } else if (deployment.award!.contains('+3 Knowledge')) {
          preview['Combat Knowledge'] = (preview['Combat Knowledge'] ?? 0) + 3;
        }
      }
    }

    // SOF school bonuses (first 3 schools are physical: Small Boats, Air Assault, Airborne equivalents)
    if (_sofSchool != null) {
      final sofSchools = NationalityData.getSOFSchools(_character!.nationality);
      // Check if it's one of the first 3 physical schools
      if (sofSchools.length >= 3 &&
          (sofSchools[0] == _sofSchool ||
              sofSchools[1] == _sofSchool ||
              sofSchools[2] == _sofSchool)) {
        preview['Strength'] = (preview['Strength'] ?? 0) + 1;
      }
    }

    return preview;
  }

  // Calculate preview skills with all current bonuses
  Map<String, int> _getPreviewSkills() {
    if (_character == null) return {};

    final preview = Map<String, int>.from(_character!.skills);

    // Promotion training bonus
    if (_officerPromotion || _sergeantPromotion) {
      preview['Training'] = (preview['Training'] ?? 0) + 1;
    }

    // Specialty bonuses
    if (_specialtyChoice == 'EOD') {
      preview['Explosives'] = (preview['Explosives'] ?? 0) + 3;
    } else if (_specialtyChoice == 'JTAC') {
      preview['Fires'] = (preview['Fires'] ?? 0) + 3;
      preview['Radio Ops'] = (preview['Radio Ops'] ?? 0) + 1;
    } else if (_specialtyChoice == 'SOF') {
      preview['Training'] = (preview['Training'] ?? 0) + 1;
      // +1 to highest skill
      var highestSkill = '';
      var highestValue = 0;
      _character!.skills.forEach((key, value) {
        if (value > highestValue) {
          highestValue = value;
          highestSkill = key;
        }
      });
      if (highestSkill.isNotEmpty) {
        preview[highestSkill] = (preview[highestSkill] ?? 0) + 1;
      }
    } else if (_specialtyChoice == 'Agent') {
      preview['Training'] = (preview['Training'] ?? 0) + 1;
      preview['Spying'] = (preview['Spying'] ?? 0) + 3;
    }

    // Combat experience per deployment
    preview['Combat'] = (preview['Combat'] ?? 0) + _deployments.length;

    // School skill bonuses
    for (var deployment in _deployments) {
      if (deployment.school != null) {
        if (deployment.school!.contains('Breacher')) {
          preview['Explosives'] = (preview['Explosives'] ?? 0) + 2;
        }
        if (deployment.school!.contains('Hostage Rescue')) {
          preview['Small Arms'] = (preview['Small Arms'] ?? 0) + 1;
        }
      }
    }

    // SOF school skill bonuses
    if (_sofSchool != null) {
      if (_sofSchool!.contains('Breacher')) {
        preview['Explosives'] = (preview['Explosives'] ?? 0) + 2;
      }
      if (_sofSchool!.contains('Hostage Rescue')) {
        preview['Small Arms'] = (preview['Small Arms'] ?? 0) + 1;
      }
    }

    return preview;
  }

  Future<void> _loadCharacter() async {
    final box = Hive.box('characters');
    final data = box.get(widget.characterId);
    if (data != null) {
      setState(() {
        _character = Character.fromJson(Map<String, dynamic>.from(data));

        // Store starting age to prevent multiple career rolls from stacking age
        _startingAge = _character!.age;

        // Store base values from Screen B (before any deployment bonuses)
        // If not already stored, save current values as base
        if (_character!.enlistment['baseAttributes'] == null) {
          _character!.enlistment['baseAttributes'] = Map<String, int>.from(
            _character!.attributes,
          );
        }
        if (_character!.enlistment['baseSkills'] == null) {
          _character!.enlistment['baseSkills'] = Map<String, int>.from(
            _character!.skills,
          );
        }
      });
    }
  }

  void _rollCareer() {
    final random = Random();
    final roll = random.nextInt(10) + 1;
    setState(() {
      _careerRoll = roll;
      _processCareerRoll(roll);
    });
  }

  void _selectCareerRoll(int roll) {
    setState(() {
      _careerRoll = roll;
      _processCareerRoll(roll);
    });
  }

  void _processCareerRoll(int roll) {
    switch (roll) {
      case 1:
        _numDeployments = 2;
        _officerPromotion = true;
        _sergeantPromotion = false;
        _eodJtacInvite = false;
        break;
      case 2:
        _numDeployments = 2;
        _sergeantPromotion = true;
        _officerPromotion = false;
        _eodJtacInvite = true;
        break;
      case 3:
      case 4:
      case 6:
      case 7:
        _numDeployments = 1;
        _sergeantPromotion = true;
        _officerPromotion = false;
        _eodJtacInvite = false;
        break;
      case 5:
        _numDeployments = 1;
        _sergeantPromotion = false;
        _officerPromotion = false;
        _eodJtacInvite = false;
        break;
      case 8:
        _numDeployments = 2;
        _sergeantPromotion = true;
        _officerPromotion = false;
        _eodJtacInvite = false;
        break;
      case 9:
      case 10:
        _numDeployments = 2;
        _sergeantPromotion = true;
        _officerPromotion = false;
        _eodJtacInvite = true;
        break;
    }

    // Initialize deployments
    _deployments.clear();
    for (int i = 0; i < _numDeployments; i++) {
      _deployments.add(DeploymentData());
    }
    _unusedSkillPoints = _numDeployments;

    // Reset to starting age, then add 4 years per deployment
    // This prevents age from stacking if user re-rolls career multiple times
    if (_character != null) {
      _character!.age = _startingAge + (_numDeployments * 4);
    }
  }

  String _getPromotedRank() {
    if (_character == null) return '';

    final currentRank = _character!.enlistment['rank'] ?? '';
    final rankType =
        _character!.enlistment['rankType']?.toString() ?? 'Enlisted';
    final service = _character!.enlistment['service']?.toString() ?? 'Army';
    final nationality = _character!.nationality;
    final isOfficer = rankType == 'Officer';

    // Get appropriate rank list based on service and rank type
    List<String> ranks;
    if (isOfficer) {
      if (service == 'Navy') {
        ranks = NationalityData.getNavyOfficerRanks(nationality)['ranks']!;
      } else {
        ranks = NationalityData.getOfficerRanks(nationality)['ranks']!;
      }
    } else {
      if (service == 'Navy') {
        ranks = NationalityData.getNavyEnlistedRanks(nationality)['ranks']!;
      } else {
        ranks = NationalityData.getEnlistedRanks(nationality)['ranks']!;
      }
    }

    final currentIndex = ranks.indexOf(currentRank);
    if (currentIndex == -1) return currentRank; // Rank not found in list

    // Agent promotion takes highest precedence (E-6+)
    if (_agentPromotion) {
      if (isOfficer) {
        // Promote officer by one rank (to O-2 if O-1, to O-3 if O-2, etc.)
        if (currentIndex < ranks.length - 1) {
          return ranks[currentIndex + 1];
        }
        return currentRank; // Already at highest rank
      } else {
        // Enlisted Agent promotion to E-6 (index 5) or higher
        final targetIndex = currentIndex < 5 ? 5 : currentIndex + 1;
        if (targetIndex < ranks.length) {
          return ranks[targetIndex];
        }
        return ranks.length > 5 ? ranks[5] : currentRank;
      }
    }

    // SOF promotion takes precedence (E-5+)
    if (_sofPromotion) {
      if (isOfficer) {
        // Promote officer by one rank (to O-2 if O-1, to O-3 if O-2, etc.)
        if (currentIndex < ranks.length - 1) {
          return ranks[currentIndex + 1];
        }
        return currentRank; // Already at highest rank
      } else {
        // Enlisted SOF promotion to E-5 (index 4) or higher
        final targetIndex = currentIndex < 4 ? 4 : currentIndex + 1;
        if (targetIndex < ranks.length) {
          return ranks[targetIndex];
        }
        return ranks.length > 4 ? ranks[4] : currentRank;
      }
    }

    if (_officerPromotion && !isOfficer) {
      // Battlefield commission to O-1 (first officer rank)
      final officerRanks = service == 'Navy'
          ? NationalityData.getNavyOfficerRanks(nationality)['ranks']!
          : NationalityData.getOfficerRanks(nationality)['ranks']!;
      return officerRanks.first;
    } else if (_sergeantPromotion && isOfficer) {
      // Officer promotion to O-2 (index 1: second officer rank)
      if (currentIndex == 0 && ranks.length > 1) {
        return ranks[1]; // O-1 to O-2
      } else if (currentIndex > 0 && currentIndex < ranks.length - 1) {
        return ranks[currentIndex + 1]; // Promote by one rank
      }
      return currentRank;
    } else if (_sergeantPromotion) {
      // Enlisted promotion to E-5 (index 4) or next rank if already E-5+
      final targetIndex = currentIndex < 4 ? 4 : currentIndex + 1;
      if (targetIndex < ranks.length) {
        return ranks[targetIndex];
      }
      return ranks.length > 4 ? ranks[4] : currentRank;
    }
    return currentRank;
  }

  Future<void> _saveDeployments() async {
    if (!_formKey.currentState!.validate()) return;
    if (_unusedSkillPoints > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please allocate all $_unusedSkillPoints skill points'),
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

      // Reset to base values from Screen B before applying deployment bonuses
      // This prevents double-counting when user revisits this screen
      final baseAttributes = character.enlistment['baseAttributes'];
      final baseSkills = character.enlistment['baseSkills'];

      if (baseAttributes != null && baseAttributes is Map) {
        character.attributes = Map<String, int>.from(
          baseAttributes.map(
            (key, value) => MapEntry(key.toString(), value as int),
          ),
        );
      }

      if (baseSkills != null && baseSkills is Map) {
        character.skills = Map<String, int>.from(
          baseSkills.map(
            (key, value) => MapEntry(key.toString(), value as int),
          ),
        );
      }

      // Apply promotions
      if (_officerPromotion ||
          _sergeantPromotion ||
          _sofPromotion ||
          _agentPromotion) {
        character.enlistment['rank'] = _getPromotedRank();

        if (_officerPromotion || _sergeantPromotion) {
          character.skills['Training'] =
              (character.skills['Training'] ?? 0) + 1;
        }

        if (_officerPromotion) {
          character.attributes['Strength'] =
              (character.attributes['Strength'] ?? 0) + 1;
          character.attributes['Agility'] =
              (character.attributes['Agility'] ?? 0) + 1;
          character.attributes['Combat Knowledge'] =
              (character.attributes['Combat Knowledge'] ?? 0) + 1;
        }
      }

      // Apply specialty bonuses
      if (_specialtyChoice == 'EOD') {
        character.skills['Explosives'] =
            (character.skills['Explosives'] ?? 0) + 3;
      } else if (_specialtyChoice == 'JTAC') {
        character.skills['Fires'] = (character.skills['Fires'] ?? 0) + 3;
        character.skills['Radio Ops'] =
            (character.skills['Radio Ops'] ?? 0) + 1;
      } else if (_specialtyChoice == 'SOF') {
        character.skills['Training'] = (character.skills['Training'] ?? 0) + 1;
        // Add +1 to highest skill
        var highestSkill = '';
        var highestValue = 0;
        character.skills.forEach((key, value) {
          if (value > highestValue) {
            highestValue = value;
            highestSkill = key;
          }
        });
        if (highestSkill.isNotEmpty) {
          character.skills[highestSkill] = highestValue + 1;
        }
      } else if (_specialtyChoice == 'Agent') {
        character.skills['Training'] = (character.skills['Training'] ?? 0) + 1;
        character.skills['Spying'] = (character.skills['Spying'] ?? 0) + 3;
      }

      // Apply deployment bonuses
      for (var deployment in _deployments) {
        // Combat experience per deployment
        character.skills['Combat'] = (character.skills['Combat'] ?? 0) + 1;

        // School bonuses
        if (deployment.school != null) {
          // All schools give Strength +1
          character.attributes['Strength'] =
              (character.attributes['Strength'] ?? 0) + 1;

          // Breacher schools give Explosives +2 (check for pattern in school name)
          if (deployment.school!.contains('Explosives +2')) {
            character.skills['Explosives'] =
                (character.skills['Explosives'] ?? 0) + 2;
          }

          // Elite schools (Ranger equivalent) give Knowledge +1
          if (deployment.school!.contains('Knowledge +1')) {
            character.attributes['Combat Knowledge'] =
                (character.attributes['Combat Knowledge'] ?? 0) + 1;
          }
        }

        // Award bonuses
        if (deployment.award != null) {
          if (deployment.award!.contains('+1 Knowledge')) {
            character.attributes['Combat Knowledge'] =
                (character.attributes['Combat Knowledge'] ?? 0) + 1;
          } else if (deployment.award!.contains('+2 Knowledge')) {
            character.attributes['Combat Knowledge'] =
                (character.attributes['Combat Knowledge'] ?? 0) + 2;
          } else if (deployment.award!.contains('+3 Knowledge')) {
            character.attributes['Combat Knowledge'] =
                (character.attributes['Combat Knowledge'] ?? 0) + 3;
          }
        }

        // Wound decoration for wounded
        if (deployment.survival != null &&
            deployment.survival!.contains('wounded')) {
          final woundAward =
              NationalityData.getDeploymentAwards(
                    character.nationality,
                  )['wound']
                  as String;
          deployment.awards.add(woundAward);
        }
      }

      // Apply SOF school bonuses separately (this is the additional school after joining SOF)
      if (_sofSchool != null) {
        final sofSchools = NationalityData.getSOFSchools(character.nationality);
        // First 3 schools are physical (Small Boats, Air Assault, Airborne equivalents)
        if (sofSchools.length >= 3 &&
            (sofSchools[0] == _sofSchool ||
                sofSchools[1] == _sofSchool ||
                sofSchools[2] == _sofSchool)) {
          character.attributes['Strength'] =
              (character.attributes['Strength'] ?? 0) + 1;
        }
        // Check for skill bonuses in school name
        if (_sofSchool!.contains('Explosives +2')) {
          character.skills['Explosives'] =
              (character.skills['Explosives'] ?? 0) + 2;
        }
        if (_sofSchool!.contains('Small Arms +1')) {
          character.skills['Small Arms'] =
              (character.skills['Small Arms'] ?? 0) + 1;
        }
      }

      // Store deployment history
      final existingDeployments = character.enlistment['deployments'];
      final deploymentList = <Map<String, dynamic>>[];

      // Add existing deployments if any
      if (existingDeployments != null && existingDeployments is List) {
        for (var item in existingDeployments) {
          if (item is Map) {
            deploymentList.add(Map<String, dynamic>.from(item));
          }
        }
      }

      // Add new deployments
      for (var i = 0; i < _deployments.length; i++) {
        final deployment = _deployments[i];

        // Set promotion rank if earned during this career
        if ((_sergeantPromotion || _officerPromotion) && i == 0) {
          // Promotion happens during first deployment
          deployment.promotionRank = _getPromotedRank();
        }

        // Set new specialty if gained after this deployment
        if (_specialtyChoice != null && i == _deployments.length - 1) {
          // Specialty gained after last deployment
          deployment.newSpecialty = _specialtyChoice;
        }

        deploymentList.add(deployment.toJson());
      }

      character.enlistment['deployments'] = deploymentList;

      // Auto-promote to Corporal (E-4) if below Sergeant (E-5) and Enlisted
      final rankType =
          character.enlistment['rankType']?.toString() ?? 'Enlisted';
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
          debugPrint('Auto-promoted from $currentRank to $promotedRank');
        }
      }

      // Save canine companion info for EOD
      if (_specialtyChoice == 'EOD' && _canineName.isNotEmpty) {
        character.canineBreed = _canineBreed;
        character.canineName = _canineName;
      }

      character.modifiedAt = DateTime.now();

      await box.put(widget.characterId, character.toJson());
      debugPrint('Deployments saved for character ${widget.characterId}');

      if (mounted) {
        // Show saved confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Deployments saved'),
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to Re-enlistment Screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                ReenlistmentScreen(characterId: widget.characterId),
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

  Widget _buildDeploymentCard(int index) {
    final deployment = _deployments[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deployment ${index + 1}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            // Location
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: deployment.location,
                    decoration: const InputDecoration(labelText: 'Location'),
                    items:
                        const [
                              'Afghanistan',
                              'Iraq',
                              'Syria',
                              'Philippines',
                              'Yemen',
                              'Somalia',
                              'Sahel',
                              'Nigeria',
                              'Libya',
                            ]
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => deployment.location = v),
                    validator: (v) => v == null ? 'Select location' : null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.casino),
                  tooltip: 'Roll random (1D10)',
                  onPressed: () {
                    final random = Random();
                    final roll = random.nextInt(10) + 1;
                    setState(() {
                      if (roll == 1) {
                        deployment.location = 'Philippines';
                      } else if (roll >= 2 && roll <= 5) {
                        deployment.location = 'Iraq';
                      } else if (roll >= 6 && roll <= 8) {
                        deployment.location = 'Afghanistan';
                      } else if (roll == 9) {
                        deployment.location = 'Syria';
                      } else {
                        // Roll == 10: Africa (random sub-location)
                        final africaLocations = [
                          'Yemen',
                          'Somalia',
                          'Sahel',
                          'Nigeria',
                          'Libya',
                        ];
                        deployment.location =
                            africaLocations[random.nextInt(
                              africaLocations.length,
                            )];
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Award
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: deployment.award,
                    decoration: const InputDecoration(labelText: 'Award'),
                    items:
                        (NationalityData.getDeploymentAwards(
                                  _character!.nationality,
                                )['awards']
                                as List<String>)
                            .map((s) {
                              final tooltip = NationalityData.getAwardTooltip(
                                s,
                              );
                              return DropdownMenuItem(
                                value: s,
                                child: tooltip != null
                                    ? Tooltip(message: tooltip, child: Text(s))
                                    : Text(s),
                              );
                            })
                            .toList(),
                    onChanged: (v) => setState(() => deployment.award = v),
                    validator: (v) => v == null ? 'Select award' : null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.casino),
                  tooltip: 'Roll random',
                  onPressed: () {
                    final random = Random();
                    final roll = random.nextInt(10) + 1;
                    final awards =
                        NationalityData.getDeploymentAwards(
                              _character!.nationality,
                            )['awards']
                            as List<String>;
                    setState(() {
                      if (roll <= 3) {
                        deployment.award = awards[0]; // None
                      } else if (roll <= 6)
                        deployment.award = awards[1]; // Achievement
                      else if (roll <= 8)
                        deployment.award = awards[2]; // Commendation +1
                      else if (roll == 9)
                        deployment.award = awards[3]; // Bronze Star +2
                      else
                        deployment.award = awards[4]; // Silver Star +3
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // School - if SOF member, show as text field (locked), otherwise dropdown
            if (_sofMember && deployment.school != null)
              // Show locked school as text (can't change after joining SOF)
              TextFormField(
                initialValue: deployment.school,
                decoration: const InputDecoration(
                  labelText: 'Pre-SOF School (locked)',
                  enabled: false,
                ),
                enabled: false,
              )
            else
              // Normal dropdown before joining SOF
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: deployment.school,
                      decoration: const InputDecoration(labelText: 'School'),
                      items: NationalityData.getSchools(_character!.nationality)
                          .map((s) {
                            final tooltip = NationalityData.getSchoolTooltip(s);
                            return DropdownMenuItem(
                              value: s,
                              child: tooltip != null
                                  ? Tooltip(message: tooltip, child: Text(s))
                                  : Text(s),
                            );
                          })
                          .toList(),
                      onChanged: (v) {
                        if (v != null && _isSchoolDuplicate(v)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${_normalizeSchoolName(v)} already selected. Choose a different school.',
                              ),
                            ),
                          );
                          return;
                        }
                        setState(() {
                          deployment.school = v;
                          if (v != null &&
                              (v.contains('Ranger') ||
                                  v.contains('Knowledge +1'))) {
                            _rangerGraduate = true;
                          }
                        });
                      },
                      validator: (v) => v == null ? 'Select school' : null,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.casino),
                    tooltip: 'Roll random',
                    onPressed: () {
                      final random = Random();
                      String? selectedSchool;
                      int attempts = 0;
                      final maxAttempts = 20;
                      final schools = NationalityData.getSchools(
                        _character!.nationality,
                      );

                      // Keep rolling until we get a non-duplicate school
                      while (attempts < maxAttempts) {
                        final roll = random.nextInt(10) + 1;
                        String tempSchool;

                        if (roll <= 2) {
                          tempSchool = schools[0]; // Small Boats equivalent
                        } else if (roll <= 4)
                          tempSchool = schools[1]; // Air Assault equivalent
                        else if (roll <= 6)
                          tempSchool = schools[2]; // Airborne equivalent
                        else if (roll <= 8)
                          tempSchool = schools[3]; // Breacher equivalent
                        else
                          tempSchool = schools[4]; // Ranger equivalent

                        if (!_isSchoolDuplicate(tempSchool)) {
                          selectedSchool = tempSchool;
                          break;
                        }
                        attempts++;
                      }

                      if (selectedSchool != null) {
                        final chosenSchool = selectedSchool;
                        setState(() {
                          deployment.school = chosenSchool;
                          if (chosenSchool.contains('Ranger') ||
                              chosenSchool.contains('Knowledge +1')) {
                            _rangerGraduate = true;
                          }
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'All schools already selected. Please choose manually.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            const SizedBox(height: 12),

            // Survival
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: deployment.survival,
                    decoration: const InputDecoration(labelText: 'Survival'),
                    items: () {
                      final woundAward =
                          NationalityData.getDeploymentAwards(
                                _character!.nationality,
                              )['wound']
                              as String;
                      return [
                            'Killed',
                            'Survived unscathed',
                            'Wounded ($woundAward)',
                          ]
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList();
                    }(),
                    onChanged: (v) => setState(() => deployment.survival = v),
                    validator: (v) => v == null ? 'Select survival' : null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.casino),
                  tooltip: 'Roll random',
                  onPressed: () {
                    final random = Random();
                    final roll = random.nextInt(10) + 1;
                    final woundAward =
                        NationalityData.getDeploymentAwards(
                              _character!.nationality,
                            )['wound']
                            as String;
                    setState(() {
                      if (roll == 1) {
                        deployment.survival = 'Killed';
                      } else if (roll <= 7)
                        deployment.survival = 'Survived unscathed';
                      else
                        deployment.survival = 'Wounded ($woundAward)';
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_character == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Deployments')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
      enlistment: {
        ..._character!.enlistment,
        'deployments': _deployments.map((d) => d.toJson()).toList(),
        'careerRoll': _careerRoll,
        'numDeployments': _numDeployments,
      },
      specialtyHook: _character!.specialtyHook,
    );

    return CharacterCreationLayout(
      character: previewCharacter,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Career & Deployments'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      EnlistmentScreen(characterId: widget.characterId),
                ),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Career Path: ${_character!.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Career Roll Section
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Career Roll (1D10)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _rollCareer,
                                icon: const Icon(Icons.casino),
                                label: const Text('Roll Random'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                initialValue: _careerRoll,
                                decoration: const InputDecoration(
                                  labelText: 'Or Select',
                                ),
                                items: List.generate(10, (i) => i + 1)
                                    .map(
                                      (n) => DropdownMenuItem(
                                        value: n,
                                        child: Text('$n'),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) _selectCareerRoll(v);
                                },
                              ),
                            ),
                          ],
                        ),
                        if (_careerRoll != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Roll: $_careerRoll',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('$_numDeployments deployment(s)'),
                          if (_sergeantPromotion)
                            const Text('✓ Sergeant Promotion'),
                          if (_officerPromotion)
                            const Text('✓ Officer Promotion'),
                          if (_eodJtacInvite) const Text('✓ EOD/JTAC Invite'),
                        ],
                      ],
                    ),
                  ),
                ),

                if (_careerRoll != null) ...[
                  const SizedBox(height: 20),

                  // Promotion Details
                  if (_sergeantPromotion || _officerPromotion) ...[
                    Card(
                      color: Colors.green[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Promotion',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('New Rank: ${_getPromotedRank()}'),
                            const Text('Training +1'),
                            if (_officerPromotion)
                              const Text(
                                'Strength +1, Agility +1, Knowledge +1',
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Special Invites
                  if (_eodJtacInvite) ...[
                    Card(
                      color: Colors.orange[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Special Invitation',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue:
                                  (_specialtyChoice == 'SOF' ||
                                      _specialtyChoice == 'Agent')
                                  ? null
                                  : _specialtyChoice,
                              decoration: const InputDecoration(
                                labelText: 'Join EOD or JTAC?',
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('None'),
                                ),
                                const DropdownMenuItem(
                                  value: 'EOD',
                                  child: Text('EOD (Explosives +3)'),
                                ),
                                const DropdownMenuItem(
                                  value: 'JTAC',
                                  child: Text('JTAC (Fires +3, Radio Ops +1)'),
                                ),
                              ],
                              onChanged: (v) {
                                setState(() {
                                  _specialtyChoice = v;
                                  // Clear canine info if not EOD
                                  if (v != 'EOD') {
                                    _canineBreed = '';
                                    _canineName = '';
                                    _canineNameController.clear();
                                  }
                                  // Add 1 year for JTAC or EOD training
                                  if ((v == 'JTAC' || v == 'EOD') &&
                                      _character != null) {
                                    _character!.age += 1;
                                  }
                                });
                              },
                            ),

                            // Canine Companion Selection (only for EOD)
                            if (_specialtyChoice == 'EOD') ...[
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.pets,
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Canine Companion',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                initialValue: _canineBreed.isEmpty
                                    ? null
                                    : _canineBreed,
                                decoration: const InputDecoration(
                                  labelText: 'Breed',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Belgian Malinois',
                                    child: Text('Belgian Malinois'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'German Shepherd',
                                    child: Text('German Shepherd'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Custom',
                                    child: Text('Custom Breed'),
                                  ),
                                ],
                                onChanged: (v) {
                                  setState(() => _canineBreed = v ?? '');
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _canineNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Canine Name',
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter your canine\'s name',
                                ),
                                onChanged: (v) {
                                  setState(() => _canineName = v);
                                },
                              ),
                              if (_canineBreed == 'Custom') ...[
                                const SizedBox(height: 12),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Custom Breed Name',
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter custom breed',
                                  ),
                                  onChanged: (v) {
                                    if (v.isNotEmpty) {
                                      setState(() => _canineBreed = v);
                                    }
                                  },
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Deployments
                  Text(
                    'Deployments ($_numDeployments)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),

                  ..._deployments.asMap().entries.map(
                    (entry) => _buildDeploymentCard(entry.key),
                  ),

                  // Join SOF (appears after school selection in deployments)
                  if (_rangerGraduate && !_sofMember) ...[
                    Card(
                      color: Colors.purple[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ranger Graduate - SOF Opportunity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _sofMember = true;
                                  _specialtyChoice = 'SOF';
                                  _sofPromotion =
                                      true; // SOF members get promoted
                                  // Add 2 years for SOF training
                                  if (_character != null) {
                                    _character!.age += 2;
                                  }
                                  // Don't clear deployment schools - keep them including Ranger
                                });
                              },
                              child: const Text(
                                'Join SOF (Training +1, +1 to highest skill, Promotion)',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // SOF School Selection - appears after joining SOF
                  if (_sofMember) ...[
                    Card(
                      color: Colors.purple[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.military_tech,
                                  color: Colors.purple.shade700,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'SOF School Selection',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Select one additional SOF school. Your previous schools (including Ranger) are retained.',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: _sofSchool,
                              decoration: const InputDecoration(
                                labelText: 'SOF School',
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  NationalityData.getSOFSchools(
                                    _character!.nationality,
                                  ).map((s) {
                                    final tooltip =
                                        NationalityData.getSchoolTooltip(s);
                                    return DropdownMenuItem(
                                      value: s,
                                      child: tooltip != null
                                          ? Tooltip(
                                              message: tooltip,
                                              child: Text(s),
                                            )
                                          : Text(s),
                                    );
                                  }).toList(),
                              onChanged: (v) => setState(() => _sofSchool = v),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (_sofMember && _specialtyChoice != 'Agent') ...[
                    Card(
                      color: Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SOF Member - Agent Opportunity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _specialtyChoice = 'Agent';
                                  _agentPromotion =
                                      true; // Agents get promoted to E-6+
                                  // Add 3 years for Agent training
                                  if (_character != null) {
                                    _character!.age += 3;
                                  }
                                });
                              },
                              child: const Text(
                                'Join Agent Program (Training +1, Spying +3, Promotion)',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Skill Points Allocation
                  Card(
                    color: Colors.amber[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unused Skill Points: $_unusedSkillPoints',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Allocate +1 to any skill per deployment'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children:
                                [
                                      'Small Arms',
                                      'Heavy Weapons',
                                      'First Aid',
                                      'Radio Ops',
                                      'Civil Affairs',
                                      'Spying',
                                      'Fires',
                                      'Signals Intel',
                                      'Explosives',
                                    ]
                                    .map(
                                      (skill) => ElevatedButton(
                                        onPressed: _unusedSkillPoints > 0
                                            ? () {
                                                setState(() {
                                                  _character!.skills[skill] =
                                                      (_character!
                                                              .skills[skill] ??
                                                          0) +
                                                      1;
                                                  _unusedSkillPoints--;
                                                });
                                              }
                                            : null,
                                        child: Text('$skill +1'),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Dossier Preview
                  Card(
                    color: Colors.grey[100],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Character Dossier Preview',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '(Shows bonuses from current selections)',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          const Text(
                            'Attributes:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...() {
                            final previewAttrs = _getPreviewAttributes();
                            final originalAttrs = _character!.attributes;
                            return [
                              'Strength',
                              'Agility',
                              'Knowledge',
                              'Combat Knowledge',
                            ].map((attr) {
                              final original = originalAttrs[attr] ?? 0;
                              final preview = previewAttrs[attr] ?? 0;
                              final bonus = preview - original;
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  top: 4,
                                ),
                                child: Text(
                                  '$attr: $preview${bonus > 0 ? " ($original + $bonus)" : ""}',
                                  style: TextStyle(
                                    color: bonus > 0 ? Colors.green[700] : null,
                                    fontWeight: bonus > 0
                                        ? FontWeight.bold
                                        : null,
                                  ),
                                ),
                              );
                            });
                          }(),
                          const SizedBox(height: 12),
                          const Text(
                            'Skills:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...() {
                            final previewSkills = _getPreviewSkills();
                            final originalSkills = _character!.skills;
                            final allSkills = <String>{
                              ...originalSkills.keys,
                              ...previewSkills.keys,
                            };
                            return allSkills
                                .where(
                                  (skill) => (previewSkills[skill] ?? 0) > 0,
                                )
                                .map((skill) {
                                  final original = originalSkills[skill] ?? 0;
                                  final preview = previewSkills[skill] ?? 0;
                                  final bonus = preview - original;
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      top: 4,
                                    ),
                                    child: Text(
                                      '$skill: $preview${bonus > 0 ? " ($original + $bonus)" : ""}',
                                      style: TextStyle(
                                        color: bonus > 0
                                            ? Colors.green[700]
                                            : null,
                                        fontWeight: bonus > 0
                                            ? FontWeight.bold
                                            : null,
                                      ),
                                    ),
                                  );
                                });
                          }(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Next button
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _saveDeployments,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(_saving ? 'Saving...' : 'Next: Re-enlistment'),
                  ),
                  const SizedBox(height: 8),
                  // Back button
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>
                              EnlistmentScreen(characterId: widget.characterId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back: Enlistment'),
                  ),
                  const SizedBox(height: 8),
                  // Save button
                  OutlinedButton.icon(
                    onPressed: _saving
                        ? null
                        : () async {
                            await _saveDeployments();
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
              ],
            ),
          ),
        ),
      ), // Scaffold
    ); // CharacterCreationLayout
  }
}

class DeploymentData {
  String? location;
  String? award;
  String? school;
  String? survival;
  String? promotionRank; // Rank earned during this deployment
  String?
  newSpecialty; // Specialty gained after this deployment (JTAC, EOD, SOF, Agent)
  List<String> awards = [];

  Map<String, dynamic> toJson() => {
    'location': location,
    'award': award,
    'school': school,
    'survival': survival,
    'promotionRank': promotionRank,
    'newSpecialty': newSpecialty,
    'awards': awards,
  };
}
