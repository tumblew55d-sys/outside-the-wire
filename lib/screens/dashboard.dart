import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/character.dart';
import '../services/pdf_export_service.dart';
import '../utils/responsive_utils.dart';
import 'screen_a_basic_info.dart';
import 'screen_b_enlistment.dart';
import 'screen_c_deployments.dart';
import 'screen_d_abilities.dart';
import 'screen_e_inventory.dart';

class DashboardScreen extends StatefulWidget {
  final List<Character> sampleRoster;
  const DashboardScreen({super.key, required this.sampleRoster});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Character> _characters = [];
  List<Character> _filteredCharacters = [];
  Character? _selectedCharacter;
  bool _hasLoadedOnce = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCharacters();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterCharacters();
    });
  }

  void _filterCharacters() {
    if (_searchQuery.isEmpty) {
      _filteredCharacters = _characters;
    } else {
      _filteredCharacters = _characters.where((c) {
        return c.name.toLowerCase().contains(_searchQuery) ||
            c.nickname.toLowerCase().contains(_searchQuery) ||
            c.nationality.toLowerCase().contains(_searchQuery) ||
            (c.enlistment['rank']?.toString().toLowerCase().contains(
                  _searchQuery,
                ) ??
                false);
      }).toList();
    }
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload characters when dashboard updates
    _loadCharacters();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload characters after returning from other screens
    // Use a longer delay to ensure navigation is complete and data is fully committed to Hive
    if (_hasLoadedOnce) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _loadCharacters();
        }
      });
    }
    _hasLoadedOnce = true;
  }

  Future<void> _loadCharacters() async {
    final box = Hive.box('characters');
    final loaded = <Character>[];

    for (final key in box.keys) {
      try {
        final json = box.get(key);
        if (json is Map) {
          debugPrint('=== Dashboard Loading Character $key ===');
          debugPrint('Raw JSON attributes: ${json['attributes']}');
          debugPrint('Raw JSON skills: ${json['skills']}');
          debugPrint(
            'Raw JSON enlistment keys: ${(json['enlistment'] as Map?)?.keys}',
          );

          final character = Character.fromJson(Map<String, dynamic>.from(json));
          debugPrint('Loaded character name: ${character.name}');
          debugPrint('Loaded character attributes: ${character.attributes}');
          debugPrint('Loaded character skills: ${character.skills}');
          debugPrint(
            'Loaded character enlistment keys: ${character.enlistment.keys}',
          );
          debugPrint('Loaded character rank: ${character.enlistment['rank']}');

          loaded.add(character);
        }
      } catch (e) {
        debugPrint('Error loading character $key: $e');
      }
    }

    setState(() {
      _characters = loaded.isEmpty ? widget.sampleRoster : loaded;
      _filterCharacters();

      // CRITICAL: Update selected character reference to the newly loaded object
      // This ensures the dossier preview and PDF export use fresh data
      if (_selectedCharacter != null) {
        final selectedId = _selectedCharacter!.id;
        _selectedCharacter = _characters.firstWhere(
          (c) => c.id == selectedId,
          orElse: () => _selectedCharacter!,
        );
        debugPrint('Updated selected character reference for ID: $selectedId');
      }
    });
    debugPrint('Loaded ${_characters.length} characters from Hive');
  }

  Widget _buildCompactLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header quote
        Text(
          '"Every step outside the wire is our story"',
          style: TextStyle(
            fontSize: ResponsiveUtils.getBodyFontSize(context),
            fontStyle: FontStyle.italic,
            color: Colors.grey.shade700,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context)),
        // Tabs for roster/dossier
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  labelColor: Theme.of(context).colorScheme.primary,
                  tabs: const [
                    Tab(text: 'Roster', icon: Icon(Icons.people)),
                    Tab(text: 'Dossier', icon: Icon(Icons.folder_open)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [_buildRosterList(), _buildDossierPanel()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRosterList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUtils.getSpacing(context)),
        // Search field
        Padding(
          padding: ResponsiveUtils.getScreenPadding(context),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, nationality, or rank...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getSpacing(context),
                vertical: ResponsiveUtils.getSpacing(context) * 0.75,
              ),
            ),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context)),
        // New Teammate button
        Card(
          child: InkWell(
            onTap: () async {
              await Navigator.of(context).pushNamed('/createCharacter');
              _loadCharacters();
            },
            child: Padding(
              padding: ResponsiveUtils.getCardPadding(context),
              child: Row(
                children: [
                  Icon(
                    Icons.person_add,
                    size: ResponsiveUtils.getIconSize(context) * 1.5,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: ResponsiveUtils.getSpacing(context)),
                  Text(
                    'NEW TEAMMATE',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getBodyFontSize(context),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context)),
        Expanded(
          child: _filteredCharacters.isEmpty && _searchQuery.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: ResponsiveUtils.getSpacing(context)),
                      Text(
                        'No characters found matching "$_searchQuery"',
                        style: TextStyle(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredCharacters.length,
                  itemBuilder: (context, index) =>
                      _buildCharacterCard(_filteredCharacters[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildDossierPanel() {
    return Container(
      padding: ResponsiveUtils.getCardPadding(context),
      child: _selectedCharacter == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
                SizedBox(height: ResponsiveUtils.getSpacing(context)),
                Text(
                  'Select a character from the roster',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getBodyFontSize(context),
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : _buildDossierDetails(_selectedCharacter!),
    );
  }

  Widget _buildCharacterCard(Character c) {
    final hasEnlistment =
        c.enlistment.isNotEmpty && c.enlistment['service'] != null;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCharacter = c;
        });
      },
      onLongPress: () => _showCharacterEditMenu(c, hasEnlistment),
      child: Card(
        margin: EdgeInsets.symmetric(
          vertical: ResponsiveUtils.getSpacing(context) / 2,
        ),
        child: ListTile(
          leading: Icon(
            Icons.folder,
            color: Colors.brown,
            size: ResponsiveUtils.getIconSize(context),
          ),
          title: Text(
            c.name.isNotEmpty ? c.name : 'New Recruit',
            style: TextStyle(
              fontSize: ResponsiveUtils.getBodyFontSize(context),
            ),
          ),
          subtitle: Text(
            '${c.enlistment['service'] ?? 'No service'} • ${c.enlistment['rank'] ?? ''}',
            style: TextStyle(
              fontSize: ResponsiveUtils.getBodyFontSize(context) - 2,
            ),
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              size: ResponsiveUtils.getIconSize(context),
            ),
            onSelected: (value) => _handleCharacterMenuAction(value, c),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'export', child: Text('Export PDF')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCharacterEditMenu(Character c, bool hasEnlistment) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(c.name),
        content: const Text('Edit character:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'basic_info'),
            child: const Text('Basic Info'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'enlistment'),
            child: const Text('Enlistment'),
          ),
          TextButton(
            onPressed: hasEnlistment
                ? () => Navigator.pop(context, 'deployments')
                : null,
            child: const Text('Deployments'),
          ),
          TextButton(
            onPressed: hasEnlistment
                ? () => Navigator.pop(context, 'abilities')
                : null,
            child: const Text('Abilities & Narrative'),
          ),
          TextButton(
            onPressed: hasEnlistment
                ? () => Navigator.pop(context, 'inventory')
                : null,
            child: const Text('Inventory & Equipment'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (choice == 'basic_info') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BasicInfoEditScreen(characterId: c.id),
        ),
      );
    } else if (choice == 'enlistment') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnlistmentScreen(characterId: c.id),
        ),
      );
    } else if (choice == 'deployments') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeploymentsScreen(characterId: c.id),
        ),
      );
    } else if (choice == 'abilities') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AbilitiesNarrativeScreen(characterId: c.id),
        ),
      );
    } else if (choice == 'inventory') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InventoryEquipmentScreen(characterId: c.id),
        ),
      );
    }
    _loadCharacters();
  }

  Future<void> _handleCharacterMenuAction(String action, Character c) async {
    if (action == 'edit') {
      final hasEnlistment =
          c.enlistment.isNotEmpty && c.enlistment['service'] != null;
      await _showCharacterEditMenu(c, hasEnlistment);
    } else if (action == 'export') {
      await _exportPDF(c);
    } else if (action == 'delete') {
      // Show confirmation dialog before deleting
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Character'),
          content: Text(
            'Are you sure you want to delete ${c.name}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final box = Hive.box('characters');
        await box.delete(c.id);
        setState(() {
          _characters.removeWhere((char) => char.id == c.id);
          if (_selectedCharacter?.id == c.id) {
            _selectedCharacter = null;
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${c.name} deleted')));
        }
      }
    }
  }

  Future<void> _exportPDF(Character c) async {
    // CRITICAL: Reload character from Hive to ensure we have the latest edits
    // Before PDF export, get fresh data in case user edited the character
    final box = Hive.box('characters');
    final freshData = box.get(c.id);

    if (freshData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Character ${c.name} not found in database'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Use fresh character data for PDF export
    final freshCharacter = Character.fromJson(
      Map<String, dynamic>.from(freshData),
    );

    debugPrint('=== Dashboard PDF Export - Fresh Data Load ===');
    debugPrint('Character ID: ${c.id}');
    debugPrint('Weapons: ${freshCharacter.inventory['loadoutWeapons']}');
    debugPrint('Equipment: ${freshCharacter.inventory['selectedEquipment']}');
    debugPrint('Custom Weapons: ${freshCharacter.inventory['customWeapons']}');

    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                SizedBox(width: ResponsiveUtils.getSpacing(context) * 2),
                const Expanded(child: Text('Generating PDF...')),
              ],
            ),
          ),
        ),
      );
    }

    try {
      final filePath = await PdfExportService.exportCharacterToPdf(
        freshCharacter,
      );

      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              kIsWeb
                  ? 'PDF downloaded: $filePath'
                  : 'PDF saved to Downloads: ${filePath.split(Platform.pathSeparator).last}',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (route) => false);
          },
          tooltip: 'Back to Home',
        ),
        title: Row(
          children: [
            if (!ResponsiveUtils.isPhone(context))
              Text(
                'Kazmo Studios',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getBodyFontSize(context) - 2,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            Expanded(
              child: Center(
                child: Text(
                  'Outside the Wire',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getTitleFontSize(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!ResponsiveUtils.isPhone(context))
              Text(
                'v Dec 2025',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getBodyFontSize(context) - 4,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              debugPrint('Sync button pressed - reloading characters');
              _loadCharacters();
            },
            icon: Icon(Icons.sync, size: ResponsiveUtils.getIconSize(context)),
            tooltip: 'Refresh Roster',
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.isPhone(context) ? 4 : 8,
            ),
            child: Row(
              children: [
                if (!ResponsiveUtils.isPhone(context))
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? 'Guest',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getBodyFontSize(context) - 2,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/auth');
                  },
                  icon: Icon(
                    Icons.account_circle,
                    size: ResponsiveUtils.getIconSize(context),
                  ),
                  tooltip: 'Account',
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/images/landing_background.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image fails to load
                  return Container(color: Colors.brown[200]);
                },
              ),
            ),
          ),
          Padding(
            padding: ResponsiveUtils.getScreenPadding(context),
            child: ResponsiveUtils.useCompactLayout(context)
                ? _buildCompactLayout()
                : Row(
                    children: [
                      // Roster stack
                      Expanded(
                        flex: ResponsiveUtils.getDashboardRosterFlex(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '"Every step outside the wire is our story"',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getBodyFontSize(
                                  context,
                                ),
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(
                              height: ResponsiveUtils.getSpacing(context),
                            ),
                            Text(
                              'Roster',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getTitleFontSize(
                                  context,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // New Teammate button
                            Card(
                              child: InkWell(
                                onTap: () async {
                                  await Navigator.of(
                                    context,
                                  ).pushNamed('/createCharacter');
                                  _loadCharacters();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person_add,
                                        size: 32,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        'NEW TEAMMATE',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _characters.length,
                                itemBuilder: (context, index) {
                                  final c = _characters[index];
                                  final hasEnlistment =
                                      c.enlistment.isNotEmpty &&
                                      c.enlistment['service'] != null;

                                  return GestureDetector(
                                    onTap: () {
                                      // Select character to display in dossier
                                      setState(() {
                                        _selectedCharacter = c;
                                      });
                                    },
                                    onDoubleTap: () async {
                                      // Double-click to open edit menu
                                      final choice = await showDialog<String>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(c.name),
                                          content: const Text(
                                            'Edit character:',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                context,
                                                'basic_info',
                                              ),
                                              child: const Text('Basic Info'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                context,
                                                'enlistment',
                                              ),
                                              child: const Text('Enlistment'),
                                            ),
                                            TextButton(
                                              onPressed: hasEnlistment
                                                  ? () => Navigator.pop(
                                                      context,
                                                      'deployments',
                                                    )
                                                  : null,
                                              child: const Text('Deployments'),
                                            ),
                                            TextButton(
                                              onPressed: hasEnlistment
                                                  ? () => Navigator.pop(
                                                      context,
                                                      'abilities',
                                                    )
                                                  : null,
                                              child: const Text(
                                                'Abilities & Narrative',
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: hasEnlistment
                                                  ? () => Navigator.pop(
                                                      context,
                                                      'inventory',
                                                    )
                                                  : null,
                                              child: const Text(
                                                'Inventory & Equipment',
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (choice == 'basic_info') {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                BasicInfoEditScreen(
                                                  characterId: c.id,
                                                ),
                                          ),
                                        );
                                      } else if (choice == 'enlistment') {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EnlistmentScreen(
                                                  characterId: c.id,
                                                ),
                                          ),
                                        );
                                      } else if (choice == 'deployments') {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DeploymentsScreen(
                                                  characterId: c.id,
                                                ),
                                          ),
                                        );
                                      } else if (choice == 'abilities') {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AbilitiesNarrativeScreen(
                                                  characterId: c.id,
                                                ),
                                          ),
                                        );
                                      } else if (choice == 'inventory') {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                InventoryEquipmentScreen(
                                                  characterId: c.id,
                                                ),
                                          ),
                                        );
                                      }
                                      _loadCharacters();
                                    },
                                    child: Card(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: ListTile(
                                        leading: const Icon(
                                          Icons.folder,
                                          color: Colors.brown,
                                        ),
                                        title: Text(
                                          c.name.isNotEmpty
                                              ? c.name
                                              : 'New Recruit',
                                        ),
                                        subtitle: Text(
                                          '${c.enlistment['service'] ?? 'No service'} • ${c.enlistment['rank'] ?? ''}',
                                        ),
                                        trailing: PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert),
                                          onSelected: (value) async {
                                            if (value == 'save') {
                                              // Save character (already auto-saved, show confirmation)
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Character saved locally',
                                                  ),
                                                ),
                                              );
                                            } else if (value == 'edit') {
                                              // Navigate to enlistment screen for editing
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EnlistmentScreen(
                                                        characterId: c.id,
                                                      ),
                                                ),
                                              );
                                              _loadCharacters();
                                            } else if (value == 'export') {
                                              // Export to PDF
                                              try {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Exporting PDF...',
                                                    ),
                                                  ),
                                                );

                                                // CRITICAL: Reload from Hive to get latest edits
                                                final box = Hive.box(
                                                  'characters',
                                                );
                                                final freshData = box.get(c.id);
                                                if (freshData == null) {
                                                  throw Exception(
                                                    'Character not found',
                                                  );
                                                }
                                                final freshChar =
                                                    Character.fromJson(
                                                      Map<String, dynamic>.from(
                                                        freshData,
                                                      ),
                                                    );

                                                final filePath =
                                                    await PdfExportService.exportCharacterToPdf(
                                                      freshChar,
                                                    );

                                                if (mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        kIsWeb
                                                            ? 'PDF downloaded: $filePath'
                                                            : 'PDF saved to Downloads: ${filePath.split(Platform.pathSeparator).last}',
                                                      ),
                                                      duration: const Duration(
                                                        seconds: 5,
                                                      ),
                                                      action: kIsWeb
                                                          ? null
                                                          : SnackBarAction(
                                                              label:
                                                                  'Open Folder',
                                                              onPressed: () async {
                                                                final file =
                                                                    File(
                                                                      filePath,
                                                                    );
                                                                final directory =
                                                                    file
                                                                        .parent
                                                                        .path;
                                                                await Process.run(
                                                                  'explorer',
                                                                  [directory],
                                                                );
                                                              },
                                                            ),
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'PDF export failed: $e',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            } else if (value == 'delete') {
                                              // Confirm and delete character
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text(
                                                    'Delete Character?',
                                                  ),
                                                  content: Text(
                                                    'Are you sure you want to delete ${c.name}? This cannot be undone.',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      style:
                                                          TextButton.styleFrom(
                                                            foregroundColor:
                                                                Colors.red,
                                                          ),
                                                      child: const Text(
                                                        'Delete',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                final box = Hive.box(
                                                  'characters',
                                                );
                                                await box.delete(c.id);
                                                _loadCharacters();
                                                if (mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        '${c.name} deleted',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'save',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.save, size: 20),
                                                  SizedBox(width: 12),
                                                  Text('Save'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit, size: 20),
                                                  SizedBox(width: 12),
                                                  Text('Edit'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'export',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.picture_as_pdf,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text('Export to PDF'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.delete,
                                                    size: 20,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Dossier preview
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: _selectedCharacter == null
                              ? const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dossier Preview',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Click on a character folder to view full details.',
                                    ),
                                  ],
                                )
                              : _buildDossierDetails(_selectedCharacter!),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDossierDetails(Character c) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name
          Text(
            c.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (c.nickname.isNotEmpty)
            Text(
              '"${c.nickname}"',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
          const Divider(),
          const SizedBox(height: 12),

          // Narrative (if available)
          if (c.enlistment['narrative'] != null &&
              c.enlistment['narrative'].toString().isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber.shade200, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_stories,
                        color: Colors.amber.shade900,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'NARRATIVE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    c.enlistment['narrative'].toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Specialty Hook
          if (c.specialtyHook.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.military_tech,
                    color: Colors.purple.shade700,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SPECIALTY HOOK',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c.specialtyHook,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Key Stats
          _buildInfoRow('Service', '${c.enlistment['service'] ?? 'N/A'}'),
          _buildInfoRow('Rank', '${c.enlistment['rank'] ?? 'N/A'}'),
          _buildInfoRow('Specialty', '${c.enlistment['specialty'] ?? 'N/A'}'),
          if (c.isSOF) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.military_tech,
                    color: Colors.red.shade700,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SPECIAL OPERATIONS FORCES (SOF)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Canine Companion
          if (c.canineName.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.pets, color: Colors.orange.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CANINE COMPANION',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${c.canineName} (${c.canineBreed})',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Attributes Summary
          if (c.attributes.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Attributes',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: c.attributes.entries.map((e) {
                return Container(
                  constraints: const BoxConstraints(
                    minWidth: 80,
                    maxWidth: 140,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          e.key,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${e.value}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          // Abilities Summary
          if (c.enlistment['abilities'] != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Abilities',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: (c.enlistment['abilities'] as Map).entries.map((e) {
                return Container(
                  constraints: const BoxConstraints(
                    minWidth: 80,
                    maxWidth: 140,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          e.key.toString(),
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${e.value}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          // Equipment Summary
          if (c.enlistment['inventory'] != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Equipment',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            if ((c.enlistment['inventory'] as Map)['loadoutWeapons'] != null &&
                ((c.enlistment['inventory'] as Map)['loadoutWeapons'] as List)
                    .isNotEmpty) ...[
              _buildInfoRow(
                'Weapons',
                ((c.enlistment['inventory'] as Map)['loadoutWeapons'] as List)
                    .join(', '),
              ),
            ],
            if ((c.enlistment['inventory'] as Map)['customWeapons'] != null &&
                ((c.enlistment['inventory'] as Map)['customWeapons'] as List)
                    .isNotEmpty) ...[
              _buildInfoRow(
                'Custom Weapons',
                ((c.enlistment['inventory'] as Map)['customWeapons'] as List)
                    .join(', '),
              ),
            ],
            if ((c.enlistment['inventory'] as Map)['equipment'] != null &&
                ((c.enlistment['inventory'] as Map)['equipment'] as List)
                    .isNotEmpty) ...[
              _buildInfoRow(
                'Equipment',
                ((c.enlistment['inventory'] as Map)['equipment'] as List).join(
                  ', ',
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
