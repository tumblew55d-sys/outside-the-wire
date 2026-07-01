import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/character.dart';
import '../services/firebase_service.dart';
import '../data/nationality_data.dart';
import 'screen_f_final_review.dart';

class CharacterCreateScreen extends StatefulWidget {
  const CharacterCreateScreen({super.key});

  @override
  State<CharacterCreateScreen> createState() => _CharacterCreateScreenState();
}

class _CharacterCreateScreenState extends State<CharacterCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController(text: '17');
  final _homeLocationController = TextEditingController();
  final _weightController = TextEditingController();
  final _languagesController = TextEditingController();

  String? _nationality;
  String? _height;
  String _weightUnit = 'lb';
  String? _motivation;
  String? _background;

  /// Helper method to safely get Hive box with retry logic for Safari/iOS
  /// Safari has stricter IndexedDB handling and may close connections unexpectedly
  Future<Box> _getSafeHiveBox(String boxName, {int retries = 3}) async {
    for (var attempt = 0; attempt < retries; attempt++) {
      try {
        // Check if box is already open
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          // Verify box is actually usable (Safari issue workaround)
          try {
            box.keys; // Test if box is accessible
            return box;
          } catch (e) {
            // Box is open but not accessible, close and reopen
            debugPrint('Hive box $boxName is open but not accessible: $e');
            await box.close();
          }
        }

        // Box is not open or needs reopening
        debugPrint('Opening Hive box $boxName (attempt ${attempt + 1})');
        return await Hive.openBox(boxName);
      } catch (e) {
        debugPrint(
          'Error opening Hive box $boxName (attempt ${attempt + 1}): $e',
        );

        // If this isn't the last attempt, wait before retrying
        if (attempt < retries - 1) {
          await Future.delayed(Duration(milliseconds: 100 * (attempt + 1)));
        } else {
          rethrow;
        }
      }
    }

    // Should never reach here, but fallback to regular open
    return Hive.box(boxName);
  }

  String? _trademark;
  String _personalConflict = '';
  final _customPersonalConflictController = TextEditingController();
  bool _showCustomPersonalConflict = false;
  bool _saving = false;

  // Auto-generate selection state
  bool _showAutoGenerateOptions = false;
  String? _selectedRankType; // 'Enlisted' or 'Officer'
  String? _selectedSpecialty;
  String? _selectedService; // 'Army', 'Marines', 'Navy'

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

  /// Parse background bonuses from selected background string
  Map<String, dynamic> _parseBackgroundBonus(String? background) {
    if (background == null || background.isEmpty) return {};

    // Extract bonus from parentheses, e.g., "Outdoor Hunter (Small Arms +1)" -> "Small Arms +1"
    final match = RegExp(r'\((.+?)\)').firstMatch(background);
    if (match == null) return {};

    final bonusText = match.group(1)!;
    // Parse "Attribute/Skill +1" format
    final parts = bonusText.split('+');
    if (parts.length != 2) return {};

    final statName = parts[0].trim();
    final bonusValue = int.tryParse(parts[1].trim()) ?? 0;

    // Determine if it's an attribute or skill
    final attributes = ['Strength', 'Agility', 'Wisdom', 'Knowledge'];
    if (attributes.contains(statName)) {
      return {
        'attributes': {statName: bonusValue},
      };
    } else {
      return {
        'skills': {statName: bonusValue},
      };
    }
  }

  Future<void> _saveCharacter() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final id = const Uuid().v4();

    // Parse weight
    final weightValue = double.tryParse(_weightController.text) ?? 0.0;

    // Parse background bonuses
    final bonuses = _parseBackgroundBonus(_background);
    final attributes = Map<String, int>.from(bonuses['attributes'] ?? {});
    final skills = Map<String, int>.from(bonuses['skills'] ?? {});

    final character = Character(
      id: id,
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text) ?? 17,
      homeLocation: _homeLocationController.text.trim(),
      nationality: _nationality ?? '',
      height: _height ?? '',
      weight: weightValue,
      weightUnit: _weightUnit,
      languages: _languagesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      motivation: _motivation ?? '',
      background: _background ?? '',
      trademark: _trademark ?? '',
      personalConflict: _showCustomPersonalConflict
          ? _customPersonalConflictController.text.trim()
          : _personalConflict,
      attributes: attributes,
      skills: skills,
    );

    try {
      final box = await _getSafeHiveBox('characters');
      debugPrint('Saving character $id: ${character.name}');
      await box.put(id, character.toJson());
      debugPrint('Character saved to Hive. Box now has ${box.length} entries');

      // Try cloud sync if Firebase is initialized
      try {
        await FirebaseService.saveCharacterToCloud(id, character.toJson());
      } catch (e) {
        // ignore cloud sync errors for local-first behavior
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Character saved — Continuing to Enlistment'),
          ),
        );
        // Navigate to Screen B instead of returning to dashboard
        Navigator.of(
          context,
        ).pushReplacementNamed('/enlistment', arguments: id);
      }
    } catch (e) {
      debugPrint('Error saving character: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Save failed: $e\n\nPlease try again or restart the app.',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _homeLocationController.dispose();
    _weightController.dispose();
    _languagesController.dispose();
    _customPersonalConflictController.dispose();
    super.dispose();
  }

  String _generateRandomName() {
    final random = Random();
    if (_nationality == null) {
      return 'Unknown';
    }
    final names = NationalityData.getNames(_nationality!);
    return names[random.nextInt(names.length)];
  }

  String _generateHometown(String nationality) {
    final random = Random();
    final Map<String, List<String>> hometowns = {
      'USA': [
        'Atlanta, Georgia',
        'Austin, Texas',
        'Boston, Massachusetts',
        'Charlotte, North Carolina',
        'Chicago, Illinois',
        'Denver, Colorado',
        'Houston, Texas',
        'Jacksonville, Florida',
        'Los Angeles, California',
        'Miami, Florida',
        'New York, New York',
        'Philadelphia, Pennsylvania',
        'Phoenix, Arizona',
        'Portland, Oregon',
        'San Diego, California',
        'Seattle, Washington',
        'Tampa, Florida',
        'Detroit, Michigan',
      ],
      'United Kingdom': [
        'London, England',
        'Manchester, England',
        'Birmingham, England',
        'Glasgow, Scotland',
        'Edinburgh, Scotland',
        'Cardiff, Wales',
        'Liverpool, England',
        'Bristol, England',
        'Leeds, England',
      ],
      'France': [
        'Paris, Île-de-France',
        'Marseille, Provence',
        'Lyon, Auvergne-Rhône-Alpes',
        'Toulouse, Occitanie',
        'Nice, Provence-Alpes-Côte d\'Azur',
        'Bordeaux, Nouvelle-Aquitaine',
      ],
      'German': [
        'Berlin, Berlin',
        'Hamburg, Hamburg',
        'Munich, Bavaria',
        'Cologne, North Rhine-Westphalia',
        'Frankfurt, Hesse',
        'Stuttgart, Baden-Württemberg',
      ],
      'Australian': [
        'Sydney, New South Wales',
        'Melbourne, Victoria',
        'Brisbane, Queensland',
        'Perth, Western Australia',
        'Adelaide, South Australia',
        'Canberra, ACT',
      ],
      'Canada': [
        'Toronto, Ontario',
        'Vancouver, British Columbia',
        'Montreal, Quebec',
        'Calgary, Alberta',
        'Edmonton, Alberta',
        'Ottawa, Ontario',
      ],
      'Poland': [
        'Warsaw, Masovian',
        'Kraków, Lesser Poland',
        'Wrocław, Lower Silesian',
        'Poznań, Greater Poland',
        'Gdańsk, Pomeranian',
        'Szczecin, West Pomeranian',
      ],
      'Polish': [
        'Warsaw, Masovian',
        'Kraków, Lesser Poland',
        'Wrocław, Lower Silesian',
        'Poznań, Greater Poland',
        'Gdańsk, Pomeranian',
        'Szczecin, West Pomeranian',
      ],
      'Norway': [
        'Oslo, Oslo',
        'Bergen, Vestland',
        'Trondheim, Trøndelag',
        'Stavanger, Rogaland',
        'Tromsø, Troms og Finnmark',
        'Drammen, Viken',
      ],
      'Sweden': [
        'Stockholm, Stockholm',
        'Gothenburg, Västra Götaland',
        'Malmö, Skåne',
        'Uppsala, Uppsala',
        'Linköping, Östergötland',
        'Örebro, Örebro',
      ],
      'Spain': [
        'Madrid, Community of Madrid',
        'Barcelona, Catalonia',
        'Valencia, Valencian Community',
        'Seville, Andalusia',
        'Zaragoza, Aragon',
        'Málaga, Andalusia',
        'Bilbao, Basque Country',
        'Alicante, Valencian Community',
      ],
      'The Philippines': [
        'Manila, Metro Manila',
        'Quezon City, Metro Manila',
        'Davao City, Davao del Sur',
        'Cebu City, Cebu',
        'Zamboanga City, Zamboanga del Sur',
        'Cagayan de Oro, Misamis Oriental',
        'Iloilo City, Iloilo',
        'Baguio, Benguet',
      ],
      'Dutch': [
        'Amsterdam, North Holland',
        'Rotterdam, South Holland',
        'The Hague, South Holland',
        'Utrecht, Utrecht',
        'Eindhoven, North Brabant',
        'Groningen, Groningen',
      ],
      'Brazil': [
        'Rio de Janeiro, Rio de Janeiro',
        'São Paulo, São Paulo',
        'Brasília, Federal District',
        'Manaus, Amazonas',
        'Salvador, Bahia',
        'Recife, Pernambuco',
        'Porto Alegre, Rio Grande do Sul',
        'Curitiba, Paraná',
        'Fortaleza, Ceará',
        'Belo Horizonte, Minas Gerais',
      ],
      'New Zealand': [
        'Auckland, Auckland',
        'Wellington, Wellington',
        'Christchurch, Canterbury',
        'Hamilton, Waikato',
        'Dunedin, Otago',
        'Tauranga, Bay of Plenty',
        'Napier, Hawke\'s Bay',
        'Palmerston North, Manawatū-Whanganui',
        'Invercargill, Southland',
        'Rotorua, Bay of Plenty',
      ],
      'Panama': [
        'Panama City, Panamá Province',
        'Colón, Colón Province',
        'David, Chiriquí Province',
        'Santiago, Veraguas Province',
        'Chitré, Herrera Province',
        'La Chorrera, Panamá Oeste',
        'Penonomé, Coclé Province',
        'Bocas del Toro, Bocas del Toro',
        'Aguadulce, Coclé Province',
        'Arraiján, Panamá Oeste',
      ],
    };

    final towns = hometowns[nationality] ?? ['Unknown City, Unknown State'];
    return towns[random.nextInt(towns.length)];
  }

  Future<void> _autoGenerateCompleteCharacter() async {
    if (_nationality == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select National Service first')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final random = Random();
      final id = const Uuid().v4();

      // Generate basic info
      final name = _generateRandomName();
      final baseAge = 17 + random.nextInt(3); // 17-19 at enlistment
      final homeLocation = _generateHometown(_nationality!);
      final heights = [
        'Compact (Short)',
        'Standard (Avg)',
        'Rangy (Tall)',
        'Towering (V. Tall)',
      ];
      final height = heights[random.nextInt(heights.length)];
      final weight = 140.0 + random.nextInt(80);

      final motivations = [
        'Duty & Service',
        'Survival & Self-Preservation',
        'Justice & Vengeance',
        'Career Ambition',
        'Humanitarian Idealism',
        'Thrill',
        'Challenge & Skill Mastery',
      ];
      final motivation = motivations[random.nextInt(motivations.length)];

      final backgrounds = [
        'Outdoor Hunter (Small Arms +1)',
        'High School / College Athlete (Strength +1)',
        'EMT / Medical Volunteer (First Aid +1)',
        'Mechanical / Electrical Worker (Explosives +1)',
        'Rural Farm Worker (Strength +1)',
        'Streetwise Urban Survivor (Wisdom +1)',
        'Computer Hobbyist / Hacker (Signals Intel +1)',
        'Volunteer Firefighter (First Aid +1)',
        'Amateur Radio Operator (Communication +1)',
        'Amateur Boxer / Martial Artist (Strength +1)',
        'Range Enthusiast / Competitive Shooter (Small Arms +1)',
        'Engineering Student (Explosives +1)',
      ];
      final background = backgrounds[random.nextInt(backgrounds.length)];

      final trademarks = [
        'Copenhagen can / tobacco tin',
        'Non-issued scarf / shemagh',
        'Photo of loved ones',
        'Lucky multitool or pocketknife',
        'Dog tags from someone else',
        'Ritualistic weapon check',
      ];
      final trademark = trademarks[random.nextInt(trademarks.length)];

      final conflicts = [
        'You believe your unit is being set up by higher command.',
        'You distrust your team leader after a past mistake.',
        'You\'re terrified of freezing under fire again.',
        'A comrade saved your life, you feel intense obligation.',
        'You\'re questioning the mission\'s legitimacy and your role in it.',
      ];
      final personalConflict = conflicts[random.nextInt(conflicts.length)];

      // Generate enlistment data using selected values
      final service =
          _selectedService ?? 'Army'; // Use selected service or default to Army

      // Use selected specialty (var instead of final to allow transitions)
      var specialty = _selectedSpecialty!;
      String?
      sofInitialSpecialty; // Track original specialty before SOF transition

      // Initialize skills map for specialty transitions
      final Map<String, int> skills = {};

      // Career Roll System (matching page 2 deployment screen)
      // Roll 1D10 for career outcome (determines deployments and promotions)
      final careerRoll = random.nextInt(10) + 1;
      int numDeployments;
      bool sergeantPromotion = false;
      bool officerPromotion = false;
      bool eodJtacInvite = false;
      int additionalAge = 0;

      // Process career roll (matching screen_c_deployments.dart logic)
      if (careerRoll == 1) {
        numDeployments = 2;
        officerPromotion = true;
      } else if (careerRoll == 2) {
        numDeployments = 2;
        sergeantPromotion = true;
        eodJtacInvite = true;
      } else if (careerRoll == 3 ||
          careerRoll == 4 ||
          careerRoll == 6 ||
          careerRoll == 7) {
        numDeployments = 1;
        sergeantPromotion = true;
      } else if (careerRoll == 5) {
        numDeployments = 1;
        // E-4 promotion (already handled by deployed soldier minimum rank below)
      } else if (careerRoll == 8) {
        numDeployments = 2;
        sergeantPromotion = true;
      } else {
        // careerRoll == 9 || careerRoll == 10
        numDeployments = 2;
        sergeantPromotion = true;
        eodJtacInvite = true;
      }

      // Override for advanced specialties (SOF/Agent have their own rules)
      if (specialty == 'SOF') {
        numDeployments = 3 + random.nextInt(2); // 3-4 deployments
        additionalAge = 2; // +2 years for SOF training
        sergeantPromotion = false; // SOF handles rank separately
        officerPromotion = false;
      } else if (specialty == 'Agent') {
        numDeployments = 4 + random.nextInt(2); // 4-5 deployments
        additionalAge = 5; // +2 years SOF + 3 years Agent training
        sergeantPromotion = false; // Agent handles rank separately
        officerPromotion = false;
      } else if (specialty == 'EOD' || specialty == 'JTAC') {
        // EOD/JTAC use career roll but add specialty training time
        additionalAge = 1; // +1 year specialty training
      }

      // Process EOD/JTAC specialty transition (from career roll 2, 9, or 10)
      if (eodJtacInvite &&
          specialty != 'SOF' &&
          specialty != 'Agent' &&
          specialty != 'EOD' &&
          specialty != 'JTAC') {
        // 50% chance to accept EOD, 50% chance to accept JTAC
        final acceptTransition = random.nextBool();
        if (acceptTransition) {
          specialty = random.nextBool() ? 'EOD' : 'JTAC';
          additionalAge = 1; // +1 year specialty training

          // Apply specialty-specific skill bonuses
          if (specialty == 'EOD') {
            skills['Explosives'] = (skills['Explosives'] ?? 0) + 3;
          } else {
            // JTAC
            skills['Fires'] = (skills['Fires'] ?? 0) + 3;
            skills['Radio Ops'] = (skills['Radio Ops'] ?? 0) + 1;
          }
        }
      }

      // Use selected rank type to determine rank (nationality-specific)
      // Apply promotions from career roll
      final String rank;
      if (specialty == 'SOF' || specialty == 'Agent') {
        // SOF/Agent always enlisted, higher rank required (E-6)
        final allEnlistedRanks = NationalityData.getEnlistedRanks(
          _nationality!,
        )['ranks']!;
        final rankIndex = allEnlistedRanks.length > 5
            ? 5
            : allEnlistedRanks.length - 1;
        rank = allEnlistedRanks[rankIndex];
      } else if (officerPromotion || _selectedRankType == 'Officer') {
        // Officer promotion or officer start
        final allOfficerRanks = NationalityData.getOfficerRanks(
          _nationality!,
        )['ranks']!;
        if (officerPromotion) {
          // Promoted to 2nd Lieutenant (O-1)
          rank = allOfficerRanks.isNotEmpty
              ? allOfficerRanks[0]
              : '2nd Lieutenant (O-1)';
        } else {
          // Officer start: minimum O-2 if deployed
          final officerRanks = NationalityData.getInitialOfficerRanks(
            _nationality!,
          )['ranks']!;
          if (numDeployments > 0 && officerRanks.length > 1) {
            rank = officerRanks[1 + random.nextInt(officerRanks.length - 1)];
          } else {
            rank = officerRanks[random.nextInt(officerRanks.length)];
          }
        }
      } else if (sergeantPromotion) {
        // Sergeant promotion (E-5)
        final allEnlistedRanks = NationalityData.getEnlistedRanks(
          _nationality!,
        )['ranks']!;
        final rankIndex = allEnlistedRanks.length > 4
            ? 4
            : allEnlistedRanks.length - 1;
        rank = allEnlistedRanks[rankIndex];
      } else {
        // Enlisted: minimum E-4 if deployed
        final enlistedRanks = NationalityData.getInitialEnlistedRanks(
          _nationality!,
        )['ranks']!;
        if (numDeployments > 0 && enlistedRanks.length > 2) {
          // Select from E-4 equivalent (last rank in initial enlisted list)
          rank = enlistedRanks[enlistedRanks.length - 1];
        } else {
          rank = enlistedRanks[random.nextInt(enlistedRanks.length)];
        }
      }

      // Generate attributes (base + background bonus)
      final bonuses = _parseBackgroundBonus(background);
      final attributes = {
        'Strength':
            3 + random.nextInt(8) + (bonuses['attributes']?['Strength'] ?? 0),
        'Agility':
            3 + random.nextInt(8) + (bonuses['attributes']?['Agility'] ?? 0),
        'Combat Wisdom':
            3 + random.nextInt(8) + (bonuses['attributes']?['Wisdom'] ?? 0),
        'Combat Knowledge':
            3 + random.nextInt(8) + (bonuses['attributes']?['Knowledge'] ?? 0),
      };

      // Initialize skills based on specialty (using skills map from line 328)
      skills.addAll({
        'Small Arms': 0,
        'Heavy Weapons': 0,
        'First Aid': 0,
        'Radio Ops': 0,
        'Civil Affairs': 0,
        'Spying': 0,
        'Fires': 0,
        'Signals Intel': 0,
        'Explosives': 0,
      });

      // Apply specialty-specific skill bonuses
      switch (specialty) {
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
        case 'EOD':
          skills['Explosives'] = 3;
          skills['Small Arms'] = 2;
          break;
        case 'JTAC':
          skills['Fires'] = 3;
          skills['Radio Ops'] = 2;
          skills['Small Arms'] = 1;
          break;
        case 'SOF':
          // SOF requires Ranger school + initial specialty + SOF school
          final sofInitialSpecialties = [
            'Rifleman',
            'Sniper',
            'Radio Operator',
            'Medical',
          ];
          final sofInitial =
              sofInitialSpecialties[random.nextInt(
                sofInitialSpecialties.length,
              )];

          // Apply initial specialty skills
          if (sofInitial == 'Rifleman') {
            skills['Small Arms'] = 3;
            skills['Heavy Weapons'] = 1;
            skills['First Aid'] = 1;
          } else if (sofInitial == 'Sniper') {
            skills['Small Arms'] = 4;
            skills['Radio Ops'] = 1;
            skills['First Aid'] = 1;
          } else if (sofInitial == 'Radio Operator') {
            skills['Radio Ops'] = 3;
            skills['Small Arms'] = 1;
            skills['First Aid'] = 1;
          } else if (sofInitial == 'Medical') {
            skills['First Aid'] = 3;
            skills['Small Arms'] = 1;
          }

          // Add Ranger school bonuses
          attributes['Strength'] = (attributes['Strength'] ?? 0) + 1;
          attributes['Combat Knowledge'] =
              (attributes['Combat Knowledge'] ?? 0) + 1;
          skills['Training'] = 1;

          // Boost highest skill by +1
          var highestSkill = '';
          var highestValue = 0;
          skills.forEach((key, value) {
            if (key != 'Combat' && key != 'Training' && value > highestValue) {
              highestValue = value;
              highestSkill = key;
            }
          });
          if (highestSkill.isNotEmpty) {
            skills[highestSkill] = highestValue + 1;
          }

          // SOF school bonus
          attributes['Strength'] = (attributes['Strength'] ?? 0) + 1;
          break;

        case 'Agent':
          // Agent requires SOF first, then Agent training
          final agentInitialSpecialties = [
            'Rifleman',
            'Sniper',
            'Radio Operator',
            'Medical',
          ];
          final agentInitial =
              agentInitialSpecialties[random.nextInt(
                agentInitialSpecialties.length,
              )];

          // Apply initial specialty skills
          if (agentInitial == 'Rifleman') {
            skills['Small Arms'] = 3;
            skills['Heavy Weapons'] = 1;
            skills['First Aid'] = 1;
          } else if (agentInitial == 'Sniper') {
            skills['Small Arms'] = 4;
            skills['Radio Ops'] = 1;
            skills['First Aid'] = 1;
          } else if (agentInitial == 'Radio Operator') {
            skills['Radio Ops'] = 3;
            skills['Small Arms'] = 1;
            skills['First Aid'] = 1;
          } else if (agentInitial == 'Medical') {
            skills['First Aid'] = 3;
            skills['Small Arms'] = 1;
          }

          // Add Ranger school bonuses
          attributes['Strength'] = (attributes['Strength'] ?? 0) + 1;
          attributes['Combat Knowledge'] =
              (attributes['Combat Knowledge'] ?? 0) + 1;
          skills['Training'] = 1;

          // Boost highest skill by +1
          var highestSkill = '';
          var highestValue = 0;
          skills.forEach((key, value) {
            if (key != 'Combat' && key != 'Training' && value > highestValue) {
              highestValue = value;
              highestSkill = key;
            }
          });
          if (highestSkill.isNotEmpty) {
            skills[highestSkill] = highestValue + 1;
          }

          // SOF school bonus
          attributes['Strength'] = (attributes['Strength'] ?? 0) + 1;

          // Agent training bonuses
          skills['Spying'] = (skills['Spying'] ?? 0) + 3;
          skills['Civil Affairs'] = (skills['Civil Affairs'] ?? 0) + 1;
          break;

        default:
          skills['Small Arms'] = 1;
      }

      // Apply background bonuses on top of specialty skills
      if (bonuses['skills'] != null) {
        bonuses['skills'].forEach((skill, bonus) {
          if (skills.containsKey(skill)) {
            skills[skill] = (skills[skill] ?? 0) + (bonus as int);
          }
        });
      }

      // Add experience
      if (skills['Combat'] == null) skills['Combat'] = 0;
      if (skills['Training'] == null) skills['Training'] = 0;

      // Generate deployment details with proper location rolling (matching page 2)
      String rollDeploymentLocation() {
        final locations = NationalityData.getDeploymentLocations(_nationality!);
        return locations[random.nextInt(locations.length)];
      }

      String rollAward() {
        final awardData = NationalityData.getDeploymentAwards(_nationality!);
        final awards = awardData['awards'] as List<String>;
        final awardRoll = random.nextInt(10) + 1;

        if (awardRoll >= 1 && awardRoll <= 7) {
          // Roll 1-7: Basic service medal (awards[1])
          return awards[1]; // Achievement Medal / Mentioned in Dispatches / etc
        } else if (awardRoll == 8 || awardRoll == 9) {
          // Roll 8-9: Bronze-tier award with +2 Knowledge (awards[3])
          return awards[3]; // Bronze Star / Military Cross / Médaille Militaire / etc
        } else {
          // Roll 10: Silver-tier award with +3 Knowledge (awards[4])
          return awards[4]; // Silver Star / DSO / Légion d'Honneur / etc
        }
      }

      String rollSurvival() {
        final awardData = NationalityData.getDeploymentAwards(_nationality!);
        final woundDecoration = awardData['wound'] as String;
        final survivalRoll = random.nextInt(10) + 1;

        if (survivalRoll >= 1 && survivalRoll <= 6) {
          return 'Uninjured';
        } else if (survivalRoll >= 7 && survivalRoll <= 9) {
          return 'Minor Injury';
        } else {
          return 'Major Injury ($woundDecoration +2 Wisdom)';
        }
      }

      // Generate schools (one per deployment, nationality-specific)
      final List<String> availableSchools;
      if (specialty == 'SOF' || specialty == 'Agent') {
        // Use SOF schools for SOF/Agent
        availableSchools = List<String>.from(
          NationalityData.getSOFSchools(_nationality!),
        );
      } else {
        // Use regular schools for other specialties
        availableSchools = List<String>.from(
          NationalityData.getSchools(_nationality!),
        );
      }

      final deployments = <Map<String, dynamic>>[];
      for (int i = 0; i < numDeployments; i++) {
        final location = rollDeploymentLocation();
        final award = rollAward();
        final survival = rollSurvival();

        // Select school (ensure no duplicates)
        String? school;
        if (availableSchools.isNotEmpty) {
          school = availableSchools[random.nextInt(availableSchools.length)];
          // Remove used school to avoid duplicates
          availableSchools.remove(school);
        }

        deployments.add({
          'location': location,
          'duration': '${6 + random.nextInt(7)} months',
          'award': award,
          'survival': survival,
          'school': school,
        });

        // Apply award bonuses (works for all nationalities)
        // Bronze-tier awards have "+2 Knowledge" in the string
        if (award.contains('+2 Knowledge')) {
          attributes['Combat Knowledge'] =
              (attributes['Combat Knowledge'] ?? 0) + 2;
        }
        // Silver-tier awards have "+3 Knowledge" in the string
        else if (award.contains('+3 Knowledge')) {
          attributes['Combat Knowledge'] =
              (attributes['Combat Knowledge'] ?? 0) + 3;
        }
        // Basic awards have "+1 Knowledge" in the string
        else if (award.contains('+1 Knowledge')) {
          attributes['Combat Knowledge'] =
              (attributes['Combat Knowledge'] ?? 0) + 1;
        }

        // Apply survival bonuses (works for all nationalities)
        // Major injury (Purple Heart / Wound Stripe / etc) gives +2 Wisdom
        if (survival.contains('+2 Wisdom')) {
          attributes['Combat Wisdom'] = (attributes['Combat Wisdom'] ?? 0) + 2;
        }

        // Apply school bonuses
        if (school != null) {
          // All schools give +1 Strength
          attributes['Strength'] = (attributes['Strength'] ?? 0) + 1;

          // Elite schools (Ranger equivalents) give +1 Knowledge and Training=1
          // Identified by "Knowledge +1" in school name
          if (school.contains('Knowledge +1')) {
            attributes['Combat Knowledge'] =
                (attributes['Combat Knowledge'] ?? 0) + 1;
            skills['Training'] = 1;
          }

          // Breacher equivalents give +2 Explosives
          // Identified by "Explosives +2" in school name
          if (school.contains('Explosives +2')) {
            skills['Explosives'] = (skills['Explosives'] ?? 0) + 2;
          }

          // Hostage Rescue schools give +1 Small Arms
          // Identified by "Small Arms +1" in school name
          if (school.contains('Small Arms +1')) {
            skills['Small Arms'] = (skills['Small Arms'] ?? 0) + 1;
          }
        }
      }

      // Add combat experience per deployment
      skills['Combat'] = (skills['Combat'] ?? 0) + numDeployments;

      // Apply promotion bonuses
      if (sergeantPromotion) {
        skills['Training'] = (skills['Training'] ?? 0) + 1;
      }

      if (officerPromotion) {
        // Officer promotion: +1 Strength, +1 Agility, +1 Knowledge, +1 Training
        attributes['Strength'] = (attributes['Strength'] ?? 0) + 1;
        attributes['Agility'] = (attributes['Agility'] ?? 0) + 1;
        attributes['Combat Knowledge'] =
            (attributes['Combat Knowledge'] ?? 0) + 1;
        skills['Training'] = (skills['Training'] ?? 0) + 1;
      }

      // Process SOF specialty transition (from Ranger school graduates)
      bool rangerGraduate = deployments.any(
        (d) => d['school']?.toString().contains('Ranger') ?? false,
      );
      if (rangerGraduate &&
          specialty != 'SOF' &&
          specialty != 'Agent' &&
          specialty != 'EOD' &&
          specialty != 'JTAC') {
        // 40% chance to accept SOF transition
        if (random.nextInt(100) < 40) {
          sofInitialSpecialty = specialty; // Remember original specialty
          specialty = 'SOF';
          additionalAge += 2; // +2 years SOF training
          numDeployments = 3 + random.nextInt(2); // Override to 3-4 deployments

          // Apply SOF bonuses: +1 Training, +1 to highest skill
          skills['Training'] = (skills['Training'] ?? 0) + 1;

          // Find highest skill and add +1
          if (skills.isNotEmpty) {
            final highestSkill = skills.entries
                .reduce((a, b) => (a.value > b.value) ? a : b)
                .key;
            skills[highestSkill] = skills[highestSkill]! + 1;
          }
        }
      }

      // Process Agent specialty transition (from SOF)
      if (specialty == 'SOF') {
        // 30% chance to accept Agent transition
        if (random.nextInt(100) < 30) {
          specialty = 'Agent';
          additionalAge += 3; // +3 years Agent training (on top of SOF time)
          numDeployments = 4 + random.nextInt(2); // Override to 4-5 deployments

          // Apply Agent bonuses: +1 Training, +3 Spying
          skills['Training'] = (skills['Training'] ?? 0) + 1;
          skills['Spying'] = (skills['Spying'] ?? 0) + 3;
        }
      }

      // Generate loadout weapons based on specialty (matching page 3 equipment screen)
      List<String> loadoutWeapons;

      // Get nationality-specific weapons
      final rifles = NationalityData.getRifles(_nationality!);
      final sniperRifles = NationalityData.getSniperRifles(_nationality!);
      final machineGuns = NationalityData.getMachineGuns(_nationality!);
      final lightMachineGuns = NationalityData.getLightMachineGuns(
        _nationality!,
      );
      final pistols = NationalityData.getPistols(_nationality!);
      final grenadeLaunchers = NationalityData.getGrenadeLaunchers(
        _nationality!,
      );

      switch (specialty) {
        case 'Rifleman':
          final riflemanLoadouts = <List<String>>[];

          // Loadout 1: Rifle with grenades and LAW
          if (rifles.isNotEmpty) {
            riflemanLoadouts.add([
              rifles[random.nextInt(rifles.length)],
              'combat knife',
              '(2) frag grenades',
              'LAW',
            ]);
          }

          // Loadout 2: Light Machine Gun (SAW/Minimi) with pistol
          if (lightMachineGuns.isNotEmpty && pistols.isNotEmpty) {
            riflemanLoadouts.add([
              lightMachineGuns[random.nextInt(lightMachineGuns.length)],
              pistols[random.nextInt(pistols.length)],
              'combat knife',
            ]);
          }

          // Loadout 3: Rifle with grenade launcher
          if (grenadeLaunchers.isNotEmpty) {
            final rifleWithGL = grenadeLaunchers
                .where((w) => w.contains('with'))
                .toList();
            if (rifleWithGL.isNotEmpty) {
              riflemanLoadouts.add([
                rifleWithGL[random.nextInt(rifleWithGL.length)],
                'combat knife',
              ]);
            }
          }

          loadoutWeapons = riflemanLoadouts.isNotEmpty
              ? riflemanLoadouts[random.nextInt(riflemanLoadouts.length)]
              : [rifles.isNotEmpty ? rifles[0] : 'Rifle', 'combat knife'];
          break;
        case 'Sniper':
          final sniperLoadouts = <List<String>>[];

          // Sniper loadouts: Sniper rifle + pistol + knife + smoke grenades
          if (sniperRifles.isNotEmpty && pistols.isNotEmpty) {
            for (var i = 0; i < 3 && i < sniperRifles.length; i++) {
              sniperLoadouts.add([
                sniperRifles[i],
                pistols[random.nextInt(pistols.length)],
                'combat knife',
                'smoke/CS grenades',
              ]);
            }
          }

          loadoutWeapons = sniperLoadouts.isNotEmpty
              ? sniperLoadouts[random.nextInt(sniperLoadouts.length)]
              : [
                  sniperRifles.isNotEmpty ? sniperRifles[0] : 'Sniper Rifle',
                  'Pistol',
                  'combat knife',
                ];
          break;
        case 'Radio Operator':
          loadoutWeapons = [
            rifles.isNotEmpty ? rifles[random.nextInt(rifles.length)] : 'Rifle',
            'combat knife',
            '(2) smoke grenades',
          ];
          break;
        case 'Heavy Weapons':
          final heavyLoadouts = <List<String>>[];

          // Loadout 1: GPMG (Machine Gun) with pistol
          if (machineGuns.isNotEmpty && pistols.isNotEmpty) {
            heavyLoadouts.add([
              machineGuns[random.nextInt(machineGuns.length)],
              pistols[random.nextInt(pistols.length)],
              'combat knife',
            ]);
          }

          // Loadout 2: Rifle with tripod/ammunition
          if (rifles.isNotEmpty) {
            heavyLoadouts.add([
              rifles[random.nextInt(rifles.length)],
              'combat knife',
              'tripod/ammunition',
            ]);
          }

          // Loadout 3: Grenade launcher with rifle
          if (grenadeLaunchers.isNotEmpty && rifles.isNotEmpty) {
            final standAloneGL = grenadeLaunchers
                .where((w) => !w.contains('with'))
                .toList();
            if (standAloneGL.isNotEmpty) {
              heavyLoadouts.add([
                standAloneGL[random.nextInt(standAloneGL.length)],
                rifles[random.nextInt(rifles.length)],
                'combat knife',
              ]);
            }
          }

          loadoutWeapons = heavyLoadouts.isNotEmpty
              ? heavyLoadouts[random.nextInt(heavyLoadouts.length)]
              : [
                  machineGuns.isNotEmpty ? machineGuns[0] : 'Machine Gun',
                  'combat knife',
                ];
          break;
        case 'Signals/Cyber Intel':
          loadoutWeapons = [
            rifles.isNotEmpty ? rifles[random.nextInt(rifles.length)] : 'Rifle',
            'combat knife',
            '(2) smoke grenades',
          ];
          break;
        case 'Medical':
          loadoutWeapons = [
            rifles.isNotEmpty ? rifles[random.nextInt(rifles.length)] : 'Rifle',
            'combat knife',
            '(2) smoke grenades',
          ];
          break;
        case 'Civil Affairs':
          loadoutWeapons = [
            rifles.isNotEmpty ? rifles[random.nextInt(rifles.length)] : 'Rifle',
            'combat knife',
            '(2) smoke grenades',
          ];
          break;
        case 'JTAC':
          final jtacLoadouts = <List<String>>[];

          // Loadout 1: Rifle with pistol
          if (rifles.isNotEmpty && pistols.isNotEmpty) {
            jtacLoadouts.add([
              rifles[random.nextInt(rifles.length)],
              pistols[random.nextInt(pistols.length)],
              'combat knife',
              '(2) smoke grenades',
            ]);
          }

          // Loadout 2: Rifle with GL and pistol
          if (grenadeLaunchers.isNotEmpty && pistols.isNotEmpty) {
            final rifleWithGL = grenadeLaunchers
                .where((w) => w.contains('with'))
                .toList();
            if (rifleWithGL.isNotEmpty) {
              jtacLoadouts.add([
                rifleWithGL[random.nextInt(rifleWithGL.length)],
                pistols[random.nextInt(pistols.length)],
                'combat knife',
                '(2) smoke grenades',
              ]);
            }
          }

          loadoutWeapons = jtacLoadouts.isNotEmpty
              ? jtacLoadouts[random.nextInt(jtacLoadouts.length)]
              : [
                  rifles.isNotEmpty ? rifles[0] : 'Rifle',
                  pistols.isNotEmpty ? pistols[0] : 'Pistol',
                  'combat knife',
                ];
          break;
        case 'EOD':
          loadoutWeapons = [
            rifles.isNotEmpty ? rifles[random.nextInt(rifles.length)] : 'Rifle',
            'combat knife',
            pistols.isNotEmpty
                ? pistols[random.nextInt(pistols.length)]
                : 'Pistol',
          ];
          break;
        case 'SOF':
          // SOF uses initial specialty for loadout
          final sofInitialSpecialties = [
            'Rifleman',
            'Sniper',
            'Radio Operator',
            'Medical',
          ];
          sofInitialSpecialty =
              sofInitialSpecialties[random.nextInt(
                sofInitialSpecialties.length,
              )];

          if (sofInitialSpecialty == 'Sniper') {
            loadoutWeapons = [
              sniperRifles.isNotEmpty
                  ? sniperRifles[random.nextInt(sniperRifles.length)]
                  : 'Sniper Rifle',
              pistols.isNotEmpty
                  ? pistols[random.nextInt(pistols.length)]
                  : 'Pistol',
              'combat knife',
              'smoke grenades',
            ];
          } else if (sofInitialSpecialty == 'Medical' ||
              sofInitialSpecialty == 'Radio Operator') {
            loadoutWeapons = [
              rifles.isNotEmpty
                  ? rifles[random.nextInt(rifles.length)]
                  : 'Rifle',
              'combat knife',
              '(2) smoke grenades',
            ];
          } else {
            loadoutWeapons = [
              rifles.isNotEmpty
                  ? rifles[random.nextInt(rifles.length)]
                  : 'Rifle',
              pistols.isNotEmpty
                  ? pistols[random.nextInt(pistols.length)]
                  : 'Pistol',
              '(2) frag grenades',
              'LAW',
            ];
          }
          break;
        case 'Agent':
          loadoutWeapons = ['Makarov Pistol'];
          break;
        default:
          loadoutWeapons = [
            rifles.isNotEmpty ? rifles[random.nextInt(rifles.length)] : 'Rifle',
            'combat knife',
          ];
      }

      // Generate specialty-specific equipment (matching page 3)
      final specialtyEquipment = <String>[];

      if (specialty == 'Medical') {
        specialtyEquipment.add('Unit 1 Medical Kit');
      } else if (specialty == 'JTAC') {
        specialtyEquipment.addAll([
          'JTAC computer and radio',
          'Backpack Radio',
        ]);
      } else if (specialty == 'Agent') {
        specialtyEquipment.add('Spy Kit');
      } else if (specialty == 'EOD') {
        specialtyEquipment.addAll([
          'EOD demo kit',
          'EOD robot and computer',
          'Thor Backpack signal jammer',
        ]);
      } else if (specialty == 'Civil Affairs') {
        specialtyEquipment.addAll(['Civil Affairs Kit', 'RIAB']);
      } else if (specialty == 'Signals/Cyber Intel') {
        specialtyEquipment.addAll([
          'Signal Collection Kit',
          'Inter Squad Radio',
        ]);
      } else if (specialty == 'SOF') {
        specialtyEquipment.addAll([
          'Night Vision Goggles',
          'Rifle mounted IR pointer',
          'Inter Squad Radio',
          'Flashbang grenade',
        ]);
      }

      // Add optional equipment (30% chance)
      if (random.nextInt(100) < 30) {
        final optional = [
          'Rifle mounted flashlight',
          'Hand held walkie talkie',
          'Frag grenade',
          'Smoke grenade',
        ];
        specialtyEquipment.add(optional[random.nextInt(optional.length)]);
      }

      // Base inventory items
      final baseInventory = [
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

      // Generate narrative
      // Generate comprehensive narrative matching manual flow (screen_d_abilities.dart)
      final narrativeBuffer = StringBuffer();

      // Basic intro with physical description
      narrativeBuffer.write(
        '$name, age ${baseAge + (numDeployments * 4) + additionalAge} from $homeLocation, ',
      );
      narrativeBuffer.write('is a $_nationality $service $specialty $rank. ');

      // Physical and mental attributes
      final attributeDescriptors = <String>[];
      final strength = attributes['Strength'] ?? 0;
      final agility = attributes['Agility'] ?? 0;
      final wisdom = attributes['Combat Wisdom'] ?? 0;
      final knowledge = attributes['Combat Knowledge'] ?? 0;

      String getStrengthDesc(int v) {
        if (v <= 3) return 'scrawny';
        if (v <= 6) return 'of average strength';
        if (v <= 8) return 'strong';
        return 'a beast';
      }

      String getAgilityDesc(int v) {
        if (v <= 3) return 'clumsy';
        if (v <= 6) return 'of average agility';
        if (v <= 8) return 'nimble';
        return 'ninja-like';
      }

      String getWisdomDesc(int v) {
        if (v <= 3) return 'slow-minded';
        if (v <= 6) return 'of average combat wisdom';
        if (v <= 8) return 'smart';
        return 'wicked smart';
      }

      String getKnowledgeDesc(int v) {
        if (v <= 3) return 'lacking combat instincts';
        if (v <= 6) return 'of average combat awareness';
        if (v <= 8) return 'possessing cat-like reflexes';
        return 'having killer instincts';
      }

      if (height.toLowerCase() != 'average') {
        attributeDescriptors.add(height.toLowerCase());
      }
      if (strength > 0) {
        attributeDescriptors.add(getStrengthDesc(strength.toInt()));
      }
      if (agility > 0) {
        attributeDescriptors.add(getAgilityDesc(agility.toInt()));
      }
      if (wisdom > 0) attributeDescriptors.add(getWisdomDesc(wisdom.toInt()));
      if (knowledge > 0) {
        attributeDescriptors.add(getKnowledgeDesc(knowledge.toInt()));
      }

      if (attributeDescriptors.isNotEmpty) {
        narrativeBuffer.write('$name is ');
        if (attributeDescriptors.length == 1) {
          narrativeBuffer.write('${attributeDescriptors[0]}. ');
        } else if (attributeDescriptors.length == 2) {
          narrativeBuffer.write(
            '${attributeDescriptors[0]} and ${attributeDescriptors[1]}. ',
          );
        } else {
          for (var i = 0; i < attributeDescriptors.length - 1; i++) {
            narrativeBuffer.write('${attributeDescriptors[i]}, ');
          }
          narrativeBuffer.write('and ${attributeDescriptors.last}. ');
        }
      }

      // Background and motivation
      narrativeBuffer.write(
        'With a background in ${background.split('(')[0].trim()}, ',
      );
      narrativeBuffer.write('$name is motivated by $motivation. ');
      if (trademark.isNotEmpty) {
        narrativeBuffer.write(
          '$name\'s trademark is ${trademark.toLowerCase()}. ',
        );
      }

      // Personal conflict
      if (personalConflict.isNotEmpty) {
        narrativeBuffer.write(
          'However, $name carries a personal burden: $personalConflict ',
        );
      }

      // Deployment history with schools and awards
      if (deployments.isNotEmpty) {
        narrativeBuffer.write('\n\nDeployment History: ');
        for (var i = 0; i < deployments.length; i++) {
          final dep = deployments[i];
          final location = dep['location'] ?? '';
          final school = dep['school'] ?? '';
          final promotionRank = dep['promotionRank'] ?? '';
          final award = dep['award'] ?? '';
          final survival = dep['survival'] ?? '';

          final awards = <String>[];
          if (award.isNotEmpty) {
            final awardName = award.split('(').first.trim();
            if (awardName.toLowerCase().contains('silver star')) {
              awards.add('the Silver Star');
            } else if (awardName.toLowerCase().contains('bronze star')) {
              awards.add('the Bronze Star');
            } else if (awardName.toLowerCase().contains('commendation')) {
              awards.add('a Commendation');
            } else if (awardName.toLowerCase().contains('achievement')) {
              awards.add('an Achievement Medal');
            }
          }
          if (survival.contains('Purple Heart')) {
            awards.add('the Purple Heart');
          }

          narrativeBuffer.write('$name deployed to $location');

          if (awards.isNotEmpty) {
            if (awards.length == 1) {
              narrativeBuffer.write(', earning ${awards.first}');
            } else {
              narrativeBuffer.write(
                ', earning ${awards.sublist(0, awards.length - 1).join(", ")} and ${awards.last}',
              );
            }
          }

          if (promotionRank.isNotEmpty) {
            narrativeBuffer.write(' and was promoted to $promotionRank');
          }

          narrativeBuffer.write('. ');

          if (school.isNotEmpty) {
            narrativeBuffer.write(
              'Following deployment, $name attended $school. ',
            );
          }
        }
      }

      // Equipment loadout summary (from page 3)
      narrativeBuffer.write('\n\nCombat Loadout: ');
      if (loadoutWeapons.isNotEmpty) {
        narrativeBuffer.write('Armed with ${loadoutWeapons.join(", ")}. ');
      }
      if (specialtyEquipment.isNotEmpty) {
        narrativeBuffer.write(
          'Specialty equipment includes ${specialtyEquipment.join(", ")}. ',
        );
      }
      narrativeBuffer.write(
        'Standard issue gear: ${baseInventory.take(5).join(", ")}, and other essential field equipment.',
      );

      // Languages
      narrativeBuffer.write('\n\nLanguages: English, $_nationality.');

      final narrative = narrativeBuffer.toString();

      // Generate specialty hook (matching page 2 character hook system)
      final specialtyHook = NationalityData.getRandomHook(specialty);

      // Calculate abilities (matching screen_d_abilities.dart logic)
      int val(Map<String, num> map, String key) => (map[key] ?? 0).toInt();

      final a = attributes;
      final s = skills;

      // Prowess, Instincts, Tactics: never halved
      final prowessBase =
          val(a, 'Strength') + val(s, 'Combat') + val(s, 'Training');
      final instinctsBase =
          val(a, 'Combat Wisdom') + val(s, 'Training') + val(s, 'Combat');
      var tacticsBase =
          val(a, 'Combat Knowledge') + val(s, 'Combat') + val(s, 'Training');

      // Apply specialty bonuses
      if (specialty.contains('Rifleman')) {
        tacticsBase += 1; // Rifleman specialty bonus
      }

      // Skill-based abilities: halved if primary skill is 0
      final smallArmsBase =
          val(s, 'Small Arms') + val(a, 'Agility') + val(s, 'Combat');
      final smallArmsEarned = val(s, 'Small Arms') > 0;

      final heavyWeaponsBase =
          val(s, 'Heavy Weapons') + val(a, 'Agility') + val(s, 'Combat');
      final heavyWeaponsEarned = val(s, 'Heavy Weapons') > 0;

      final firstAidBase =
          val(s, 'First Aid') + val(s, 'Combat') + val(a, 'Combat Wisdom');
      final firstAidEarned = val(s, 'First Aid') > 0;

      final commsBase =
          val(s, 'Radio Ops') + val(s, 'Combat') + val(a, 'Combat Wisdom');
      final commsEarned = val(s, 'Radio Ops') > 0;

      final civilAffairsBase =
          val(s, 'Civil Affairs') + val(s, 'Combat') + val(a, 'Combat Wisdom');
      final civilAffairsEarned = val(s, 'Civil Affairs') > 0;

      final firesBase =
          val(s, 'Fires') + val(s, 'Combat') + val(a, 'Combat Wisdom');
      final firesEarned = val(s, 'Fires') > 0;

      final spyingBase =
          val(s, 'Spying') + val(s, 'Combat') + val(a, 'Combat Wisdom');
      final spyingEarned = val(s, 'Spying') > 0;

      final explosivesBase =
          val(s, 'Explosives') + val(s, 'Combat') + val(a, 'Combat Wisdom');
      final explosivesEarned = val(s, 'Explosives') > 0;

      final signalsBase =
          val(s, 'Signals Intel') + val(s, 'Combat') + val(a, 'Combat Wisdom');
      final signalsEarned = val(s, 'Signals Intel') > 0;

      int penalize(int base, bool earned) => earned ? base : (base ~/ 2);

      final abilities = {
        'Prowess': prowessBase,
        'Instincts': instinctsBase,
        'Tactics': tacticsBase,
        'Small Arms': penalize(smallArmsBase, smallArmsEarned),
        'Heavy Weapons': penalize(heavyWeaponsBase, heavyWeaponsEarned),
        'First Aid': penalize(firstAidBase, firstAidEarned),
        'Communication': penalize(commsBase, commsEarned),
        'Civil Affairs': penalize(civilAffairsBase, civilAffairsEarned),
        'Fires': penalize(firesBase, firesEarned),
        'Spying': penalize(spyingBase, spyingEarned),
        'Explosives': penalize(explosivesBase, explosivesEarned),
        'Signals Intel': penalize(signalsBase, signalsEarned),
      };

      // Create complete character
      final character = Character(
        id: id,
        userId: '',
        name: name,
        nickname: '',
        age:
            baseAge +
            (numDeployments * 4) +
            additionalAge, // Base age + deployments + training
        homeLocation: homeLocation,
        nationality: _nationality!,
        height: height,
        weight: weight,
        weightUnit: 'lb',
        languages: ['English', _nationality!],
        motivation: motivation,
        background: background,
        trademark: trademark,
        personalConflict: personalConflict,
        attributes: Map<String, int>.from(attributes),
        skills: Map<String, int>.from(skills),
        enlistment: {
          'service': service,
          'rank': rank,
          'specialty': specialty,
          'deployments': deployments,
          'abilities': abilities,
          'narrative': narrative,
        },
        inventory: {
          'loadoutWeapons': loadoutWeapons,
          'customWeapons': <String>[],
          'selectedEquipment': [...baseInventory, ...specialtyEquipment],
          'clothing': <String>[],
          'pouches': <String>[],
          'dayPack': <String>[],
          'rucksack': <String>[],
          'hands': <String>[],
          'holster': <String>[],
        },
        characterHook: narrative,
        specialtyHook: specialtyHook,
        isSOF: specialty.contains('SOF') || specialty.contains('Special'),
      );

      // Save to Hive
      final box = await _getSafeHiveBox('characters');
      debugPrint('Auto-generating character $id: $name');
      await box.put(id, character.toJson());
      debugPrint('Character saved to Hive. Box now has ${box.length} entries');

      // Try cloud sync
      try {
        await FirebaseService.saveCharacterToCloud(id, character.toJson());
      } catch (e) {
        // Ignore cloud errors
        debugPrint('Cloud sync failed (expected in local-first mode): $e');
      }

      if (mounted) {
        // Navigate to final review screen (dossier)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => FinalReviewScreen(characterId: id),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error in auto-generate: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Generation failed: $e\n\nPlease try again or restart the app.',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _autoGenerateCharacter() {
    // This function is deprecated - use _autoGenerateCompleteCharacter instead
    // Keeping for backwards compatibility but showing selection UI
    setState(() {
      _showAutoGenerateOptions = true;
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Character')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _nationality,
                    decoration: const InputDecoration(
                      labelText: 'National Service',
                      helperText: 'Select your nation first',
                      border: OutlineInputBorder(),
                    ),
                    items: NationalityData.nationalities
                        .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                        .toList(),
                    onChanged: (v) => setState(() => _nationality = v),
                    validator: (v) =>
                        v == null ? 'Select national service' : null,
                  ),
                  const SizedBox(height: 16),
                  if (_nationality != null && !_showAutoGenerateOptions) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Skip Auto Build if you prefer to build your character manually using the step-by-step screens.',
                              style: TextStyle(color: Colors.blue.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showAutoGenerateOptions = true;
                        });
                      },
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Auto Generate Character'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                  if (_showAutoGenerateOptions) ...[
                    Card(
                      color: Colors.amber.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Auto Generate Options',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedRankType,
                              decoration: const InputDecoration(
                                labelText: 'Rank Type',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Enlisted',
                                  child: Text('Enlisted'),
                                ),
                                DropdownMenuItem(
                                  value: 'Officer',
                                  child: Text('Officer'),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedRankType = v),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedService,
                              decoration: const InputDecoration(
                                labelText: 'Service to Join',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Army',
                                  child: Text('Army'),
                                ),
                                DropdownMenuItem(
                                  value: 'Marines',
                                  child: Text('Marines'),
                                ),
                                DropdownMenuItem(
                                  value: 'Navy',
                                  child: Text('Navy'),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedService = v),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedSpecialty,
                              decoration: const InputDecoration(
                                labelText: 'Military Specialty',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Rifleman',
                                  child: Text('Rifleman'),
                                ),
                                DropdownMenuItem(
                                  value: 'Heavy Weapons',
                                  child: Text('Heavy Weapons Gunner'),
                                ),
                                DropdownMenuItem(
                                  value: 'Sniper',
                                  child: Text('Sniper'),
                                ),
                                DropdownMenuItem(
                                  value: 'Radio Operator',
                                  child: Text('Radio Operator'),
                                ),
                                DropdownMenuItem(
                                  value: 'Signals/Cyber Intel',
                                  child: Text('Signals/Cyber Intel'),
                                ),
                                DropdownMenuItem(
                                  value: 'Medical',
                                  child: Text('Medical'),
                                ),
                                DropdownMenuItem(
                                  value: 'Civil Affairs',
                                  child: Text('Civil Affairs'),
                                ),
                                DropdownMenuItem(
                                  value: 'EOD',
                                  child: Text('EOD'),
                                ),
                                DropdownMenuItem(
                                  value: 'JTAC',
                                  child: Text('JTAC'),
                                ),
                                DropdownMenuItem(
                                  value: 'SOF',
                                  child: Text('SOF'),
                                ),
                                DropdownMenuItem(
                                  value: 'Agent',
                                  child: Text('Agent'),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedSpecialty = v),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed:
                                  (_selectedRankType != null &&
                                      _selectedService != null &&
                                      _selectedSpecialty != null)
                                  ? _autoGenerateCompleteCharacter
                                  : null,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Generate Complete Character'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _showAutoGenerateOptions = false;
                                  _selectedRankType = null;
                                  _selectedService = null;
                                  _selectedSpecialty = null;
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_nationality != null) const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter a name'
                              : null,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.casino),
                        tooltip: 'Random Name',
                        onPressed: _nationality == null
                            ? null
                            : () {
                                setState(() {
                                  _nameController.text = _generateRandomName();
                                });
                              },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ageController,
                          decoration: const InputDecoration(
                            labelText: 'Age',
                            helperText:
                                '+4 years will be added after enlistment',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            if (n == null || n < 17) {
                              return 'Enter age 17 or higher';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.casino),
                        tooltip: 'Random Age',
                        onPressed: () {
                          final random = Random();
                          setState(() {
                            _ageController.text = (17 + random.nextInt(8))
                                .toString();
                          });
                        },
                      ),
                    ],
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
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _height,
                          decoration: const InputDecoration(
                            labelText: 'Height',
                          ),
                          items:
                              const [
                                    'Compact (Short)',
                                    'Standard (Avg)',
                                    'Rangy (Tall)',
                                    'Towering (V. Tall)',
                                  ]
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(() => _height = v),
                          validator: (v) => v == null ? 'Select height' : null,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.casino),
                        tooltip: 'Random Height',
                        onPressed: () {
                          final random = Random();
                          final heights = [
                            'Compact (Short)',
                            'Standard (Avg)',
                            'Rangy (Tall)',
                            'Towering (V. Tall)',
                          ];
                          setState(() {
                            _height = heights[random.nextInt(heights.length)];
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _weightController,
                          decoration: const InputDecoration(
                            labelText: 'Weight',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter weight'
                              : null,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.casino),
                        tooltip: 'Random Weight',
                        onPressed: () {
                          final random = Random();
                          setState(() {
                            _weightController.text = (140 + random.nextInt(80))
                                .toString();
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _weightUnit,
                          decoration: const InputDecoration(labelText: 'Unit'),
                          items: const ['lb', 'kg']
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _weightUnit = v ?? 'lb'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _languagesController,
                    decoration: const InputDecoration(
                      labelText: 'Languages',
                      helperText: 'Comma-separated (e.g., English, Spanish)',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter at least one language'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _motivation,
                          decoration: const InputDecoration(
                            labelText: 'Motivation',
                          ),
                          items:
                              const [
                                    'Duty & Service',
                                    'Survival & Self-Preservation',
                                    'Justice & Vengeance',
                                    'Career Ambition',
                                    'Humanitarian Idealism',
                                    'Thrill',
                                    'Challenge & Skill Mastery',
                                    'Custom (user defined)',
                                  ]
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(() => _motivation = v),
                          validator: (v) =>
                              v == null ? 'Select motivation' : null,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.casino),
                        tooltip: 'Random Motivation',
                        onPressed: () {
                          final random = Random();
                          final motivations = [
                            'Duty & Service',
                            'Survival & Self-Preservation',
                            'Justice & Vengeance',
                            'Career Ambition',
                            'Humanitarian Idealism',
                            'Thrill',
                            'Challenge & Skill Mastery',
                          ];
                          setState(() {
                            _motivation =
                                motivations[random.nextInt(motivations.length)];
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _background,
                          decoration: const InputDecoration(
                            labelText: 'Background',
                          ),
                          items: const [
                            'Outdoor Hunter (Small Arms +1)',
                            'High School / College Athlete (Strength +1)',
                            'EMT / Medical Volunteer (First Aid +1)',
                            'Mechanical / Electrical Worker (Explosives +1)',
                            'Rural Farm Worker (Strength +1)',
                            'Debate Team / Political Organizer (Civil Affairs +1)',
                            'Construction Worker (Strength +1)',
                            'Streetwise Urban Survivor (Wisdom +1)',
                            'Computer Hobbyist / Hacker (Signals Intel +1)',
                            'Volunteer Firefighter (First Aid +1)',
                            'Amateur Radio Operator (Communication +1)',
                            'NGO Volunteer / Aid Worker (Civil Affairs +1)',
                            'Amateur Boxer / Martial Artist (Strength +1)',
                            'Former Delivery Bicyclist / Motorcyclist (Agility +1)',
                            'Range Enthusiast / Competitive Shooter (Small Arms +1)',
                            'Engineering Student (Explosives +1)',
                            'Lifeguard (First Aid +1)',
                            'Security Guard / Mall Cop (Strength +1)',
                            'Eagle Scout / Outdoor Program (Knowledge +1)',
                            'Custom (user defined)',
                          ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setState(() => _background = v),
                          validator: (v) =>
                              v == null ? 'Select background' : null,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.casino),
                        tooltip: 'Random Background',
                        onPressed: () {
                          final random = Random();
                          final backgrounds = [
                            'Outdoor Hunter (Small Arms +1)',
                            'High School / College Athlete (Strength +1)',
                            'EMT / Medical Volunteer (First Aid +1)',
                            'Mechanical / Electrical Worker (Explosives +1)',
                            'Rural Farm Worker (Strength +1)',
                            'Streetwise Urban Survivor (Wisdom +1)',
                            'Computer Hobbyist / Hacker (Signals Intel +1)',
                            'Volunteer Firefighter (First Aid +1)',
                            'Amateur Radio Operator (Communication +1)',
                            'Amateur Boxer / Martial Artist (Strength +1)',
                            'Range Enthusiast / Competitive Shooter (Small Arms +1)',
                            'Engineering Student (Explosives +1)',
                          ];
                          setState(() {
                            _background =
                                backgrounds[random.nextInt(backgrounds.length)];
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _trademark,
                          decoration: const InputDecoration(
                            labelText: 'Trademark',
                          ),
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
                            'Sketches or writes in a small notebook',
                            'Always the first to volunteer for point or rear guard',
                            'Keeps a private "good luck ritual"',
                            'Custom (user defined)',
                          ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setState(() => _trademark = v),
                          validator: (v) =>
                              v == null ? 'Select trademark' : null,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.casino),
                        tooltip: 'Random Trademark',
                        onPressed: () {
                          final random = Random();
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
                            'Collects sand from deployments',
                            'Uses colorful slang or military sayings',
                          ];
                          setState(() {
                            _trademark =
                                trademarks[random.nextInt(trademarks.length)];
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Personal Conflict',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _showCustomPersonalConflict
                              ? 'Custom'
                              : (_personalConflict.isEmpty
                                    ? null
                                    : _personalConflict),
                          decoration: const InputDecoration(
                            labelText: 'Personal Conflict',
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
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.casino),
                        tooltip: 'Roll Random',
                        onPressed: _rollPersonalConflict,
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
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _saveCharacter,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(_saving ? 'Saving...' : 'Next: Enlistment'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
