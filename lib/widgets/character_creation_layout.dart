import 'package:flutter/material.dart';
import '../models/character.dart';
import 'character_sheet_preview.dart';

/// Split-screen layout for character creation with live preview
class CharacterCreationLayout extends StatelessWidget {
  final Character character;
  final Widget child;
  final bool showPreview;
  final Function(String item, bool isChecked)? onEquipmentChanged;

  const CharacterCreationLayout({
    super.key,
    required this.character,
    required this.child,
    this.showPreview = true,
    this.onEquipmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    debugPrint(
      'CharacterCreationLayout: screenWidth=$screenWidth, isWideScreen=$isWideScreen, showPreview=$showPreview',
    );

    if (!showPreview || !isWideScreen) {
      // On narrow screens, show only the creation form
      return child;
    }

    // Split screen layout for wide screens
    return Row(
      children: [
        // Left side: Character creation form
        Expanded(flex: 3, child: child),
        // Divider
        VerticalDivider(width: 1, thickness: 1, color: Colors.grey.shade300),
        // Right side: Live preview
        Expanded(
          flex: 2,
          child: Material(
            color: Colors.grey.shade100,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.preview,
                        size: 20,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Live Preview',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const Spacer(),
                      Chip(
                        label: const Text(
                          'Updates as you type',
                          style: TextStyle(fontSize: 10),
                        ),
                        backgroundColor: Colors.blue.shade50,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CharacterSheetPreview(
                      character: character,
                      onEquipmentChanged: onEquipmentChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
