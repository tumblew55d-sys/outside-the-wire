import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/character.dart';
import '../utils/body_type_descriptor.dart';
import 'screen_c_deployments.dart';
import 'screen_e_inventory.dart';

class AbilitiesNarrativeScreen extends StatefulWidget {
  final String characterId;
  const AbilitiesNarrativeScreen({super.key, required this.characterId});

  @override
  State<AbilitiesNarrativeScreen> createState() =>
      _AbilitiesNarrativeScreenState();
}

class _AbilitiesNarrativeScreenState extends State<AbilitiesNarrativeScreen> {
  Character? _character;
  bool _saving = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _narrativeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCharacter();
  }

  Future<void> _loadCharacter() async {
    final box = Hive.box('characters');
    final data = box.get(widget.characterId);
    if (data != null) {
      final c = Character.fromJson(Map<String, dynamic>.from(data));
      setState(() {
        _character = c;
        final existingNarrative = (c.enlistment['narrative'] ?? '').toString();
        _narrativeCtrl.text = existingNarrative;
      });

      // Auto-generate narrative if it's empty
      if (_narrativeCtrl.text.trim().isEmpty) {
        _generateNarrative();
      }
    }
  }

  int _val(Map<String, int> map, String key) => map[key] ?? 0;

  // Compute ability totals and whether earned
  Map<String, (int total, bool earned, String detail)> _computeAbilities(
    Character c,
  ) {
    final a = c
        .attributes; // 'Strength', 'Agility', 'Combat Wisdom', 'Combat Knowledge'
    final s = c.skills; // includes 'Combat', 'Training', and skill names

    // Prowess: never halved
    int prowessBase =
        _val(a, 'Strength') + _val(s, 'Combat') + _val(s, 'Training');
    bool prowessEarned = true;

    // Instincts: never halved
    int instinctsBase =
        _val(a, 'Combat Wisdom') + _val(s, 'Training') + _val(s, 'Combat');
    bool instinctsEarned = true;

    // Tactics: never halved
    int tacticsBase =
        _val(a, 'Combat Knowledge') + _val(s, 'Combat') + _val(s, 'Training');

    // Apply specialty bonuses
    final specialty = c.enlistment['specialty']?.toString() ?? '';
    if (specialty.contains('Rifleman')) {
      tacticsBase += 1; // Rifleman specialty bonus
    }

    bool tacticsEarned = true;

    // Skill-based abilities: not halved if the primary skill > 0 (background counts)
    int smallArmsBase =
        _val(s, 'Small Arms') + _val(a, 'Agility') + _val(s, 'Combat');
    bool smallArmsEarned = _val(s, 'Small Arms') > 0;

    int heavyWeaponsBase =
        _val(s, 'Heavy Weapons') + _val(a, 'Agility') + _val(s, 'Combat');
    bool heavyWeaponsEarned = _val(s, 'Heavy Weapons') > 0;

    int firstAidBase =
        _val(s, 'First Aid') + _val(s, 'Combat') + _val(a, 'Combat Wisdom');
    bool firstAidEarned = _val(s, 'First Aid') > 0;

    // "Communication" maps to 'Radio Ops' skill in data
    int commsBase =
        _val(s, 'Radio Ops') + _val(s, 'Combat') + _val(a, 'Combat Wisdom');
    bool commsEarned = _val(s, 'Radio Ops') > 0;

    int civilAffairsBase =
        _val(s, 'Civil Affairs') + _val(s, 'Combat') + _val(a, 'Combat Wisdom');
    bool civilAffairsEarned = _val(s, 'Civil Affairs') > 0;

    int firesBase =
        _val(s, 'Fires') + _val(s, 'Combat') + _val(a, 'Combat Wisdom');
    bool firesEarned = _val(s, 'Fires') > 0;

    int spyingBase =
        _val(s, 'Spying') + _val(s, 'Combat') + _val(a, 'Combat Wisdom');
    bool spyingEarned = _val(s, 'Spying') > 0;

    int explosivesBase =
        _val(s, 'Explosives') + _val(s, 'Combat') + _val(a, 'Combat Wisdom');
    bool explosivesEarned = _val(s, 'Explosives') > 0;

    int signalsBase =
        _val(s, 'Signals Intel') + _val(s, 'Combat') + _val(a, 'Combat Wisdom');
    bool signalsEarned = _val(s, 'Signals Intel') > 0;

    int penalize(int base, bool earned) => earned ? base : (base ~/ 2);

    return {
      'Prowess': (
        penalize(prowessBase, prowessEarned),
        prowessEarned,
        'Strength + Combat Experience + Training',
      ),
      'Instincts': (
        penalize(instinctsBase, instinctsEarned),
        instinctsEarned,
        'Wisdom + Training + Combat Experience',
      ),
      'Tactics': (
        penalize(tacticsBase, tacticsEarned),
        tacticsEarned,
        'Knowledge + Combat Experience + Training',
      ),
      'Small Arms': (
        penalize(smallArmsBase, smallArmsEarned),
        smallArmsEarned,
        'Small Arms + Agility + Combat Experience',
      ),
      'Heavy Weapons': (
        penalize(heavyWeaponsBase, heavyWeaponsEarned),
        heavyWeaponsEarned,
        'Heavy Weapons + Agility + Combat Experience',
      ),
      'First Aid': (
        penalize(firstAidBase, firstAidEarned),
        firstAidEarned,
        'First Aid + Combat Experience + Wisdom',
      ),
      'Communication': (
        penalize(commsBase, commsEarned),
        commsEarned,
        'Radio Ops + Combat Experience + Wisdom',
      ),
      'Civil Affairs': (
        penalize(civilAffairsBase, civilAffairsEarned),
        civilAffairsEarned,
        'Civil Affairs + Combat Experience + Wisdom',
      ),
      'Fires': (
        penalize(firesBase, firesEarned),
        firesEarned,
        'Fires + Combat Experience + Wisdom',
      ),
      'Spying': (
        penalize(spyingBase, spyingEarned),
        spyingEarned,
        'Spying + Combat Experience + Wisdom',
      ),
      'Explosives': (
        penalize(explosivesBase, explosivesEarned),
        explosivesEarned,
        'Explosives + Combat Experience + Wisdom',
      ),
      'Signals Intel': (
        penalize(signalsBase, signalsEarned),
        signalsEarned,
        'Signals Intel + Combat Experience + Wisdom',
      ),
    };
  }

  Future<void> _save() async {
    if (_character == null) return;
    setState(() => _saving = true);
    try {
      final box = Hive.box('characters');
      final data = box.get(widget.characterId);
      if (data == null) throw Exception('Character not found');
      final c = Character.fromJson(Map<String, dynamic>.from(data));

      final abilities = _computeAbilities(c).map((k, v) => MapEntry(k, v.$1));
      c.enlistment['abilities'] = abilities;
      c.enlistment['narrative'] = _narrativeCtrl.text;
      c.modifiedAt = DateTime.now();

      await box.put(widget.characterId, c.toJson());
      if (mounted) {
        // Show saved confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Abilities & narrative saved'),
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to Screen E (Inventory)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                InventoryEquipmentScreen(characterId: widget.characterId),
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

  void _generateNarrative() {
    if (_character == null) return;
    final c = _character!;
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

    // Helper function to get attribute descriptor using official descriptors
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

    // Add Personal Conflict
    if (c.personalConflict.isNotEmpty) {
      sb.write(
        'However, $name carries a personal burden: ${c.personalConflict} ',
      );
    }

    // Deployment-by-deployment narrative with promotions, awards, and specialty changes
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

        // Extract medal from award field (e.g., "Silver Star (+3 Knowledge)")
        if (award.isNotEmpty) {
          final awardName = award.split('(').first.trim();
          if (awardName.toLowerCase().contains('silver star')) {
            allAwards.add('the Silver Star');
          } else if (awardName.toLowerCase().contains('bronze star')) {
            allAwards.add('the Bronze Star');
          } else if (awardName.toLowerCase().contains('commendation')) {
            allAwards.add('a Commendation');
          } else if (awardName.toLowerCase().contains('achievement')) {
            allAwards.add('an Achievement Medal');
          }
        }

        // Extract Purple Heart from survival status
        if (survival.contains('Purple Heart')) {
          allAwards.add('the Purple Heart');
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

    // Add canine info at the end if EOD specialty exists
    if (specialty.contains('EOD') &&
        c.canineName.isNotEmpty &&
        deployments.isEmpty) {
      sb.write(
        '\n\n$name works with ${c.canineName}, a ${c.canineBreed} explosive detection dog.',
      );
    }

    if (langs.isNotEmpty) {
      sb.write('\n\nLanguages: $langs.');
    }

    final text = sb.toString();
    _narrativeCtrl.text = text.length > 1200 ? text.substring(0, 1200) : text;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_character == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Abilities & Narrative')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final computed = _computeAbilities(_character!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Abilities & Narrative'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    DeploymentsScreen(characterId: widget.characterId),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ability Scores: ${_character!.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Ability Scores',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Ability Rules',
                            icon: const Icon(Icons.info_outline),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Ability Rules'),
                                  content: const SingleChildScrollView(
                                    child: Text(
                                      '- Each ability is the sum of its listed parts.\n'
                                      '- Prowess, Instincts, and Tactics are NEVER halved.\n'
                                      '- Other abilities are HALVED if their primary skill is 0.\n'
                                      '  (Background skills count; if > 0, not halved.)\n\n'
                                      'Mappings:\n'
                                      '- Communication uses Radio Ops skill.\n'
                                      '- Combat Experience is the Combat skill.\n'
                                      '- Wisdom = Combat Wisdom attribute.\n'
                                      '- Knowledge = Combat Knowledge attribute.',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...computed.entries.map((e) {
                        final (total, earned, detail) = e.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(child: Text(e.key)),
                              Text(
                                '$total',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Math breakdown hidden per request
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Rules notes removed per request
              const Text(
                'Narrative',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _narrativeCtrl,
                maxLength: 1200,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText:
                      'Write a personal narrative (max 1200 characters)...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              // Auto-generate button
              OutlinedButton.icon(
                onPressed: _generateNarrative,
                icon: const Icon(Icons.edit),
                label: const Text('Generate Narrative'),
              ),
              const SizedBox(height: 12),
              // Next button
              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.arrow_forward),
                label: Text(_saving ? 'Saving...' : 'Next: Inventory'),
              ),
              const SizedBox(height: 8),
              // Back button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          DeploymentsScreen(characterId: widget.characterId),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back: Deployments'),
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
      ),
    );
  }
}
