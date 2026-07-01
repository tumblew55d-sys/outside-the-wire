# Bugfix: Calculation Stacking Issue

## Problem
User reported John's attributes (especially Strength) and Small Arms skill were "very high" after multiple edits.

## Root Cause
**Deployment bonuses were being applied multiple times** whenever the user visited Screen C (Deployments) and saved, even if the deployments had already been processed.

### The Stacking Mechanism:
1. User completes Screen B (Enlistment) → specialty bonuses applied → character saved
2. User completes Screen C (Deployments) → deployment bonuses applied **ON TOP OF** existing values → character saved
3. User returns to Screen C to edit → **deployment bonuses applied AGAIN** on top of already-boosted values
4. Result: Each visit to Screen C **doubled/tripled** deployment bonuses

### Example Scenario:
- **Screen B**: Character has Small Arms 5 (after specialty bonus)
- **Screen C (First Visit)**: 2 Combat deployments → Small Arms 5 + 2 Combat skill = 7
- **Screen C (Second Visit - Edit)**: Same 2 deployments → Small Arms 7 + 2 Combat skill = **9** (WRONG!)
- **Screen C (Third Visit)**: Same 2 deployments → Small Arms 9 + 2 = **11** (EVEN MORE WRONG!)

Similarly for attributes:
- **Screen B**: Strength 6 (base)
- **Screen C (First Visit)**: Officer promotion (+1) + Ranger school (+1) → Strength 8
- **Screen C (Second Visit)**: Same bonuses applied again → Strength 10 (WRONG!)

## Solution
**Store base values from Screen B and reset to them before applying deployment bonuses.**

### Changes Made:

#### 1. Screen B (Enlistment) - `screen_b_enlistment.dart`
Added base value storage in the `character.enlistment` map:
```dart
character.enlistment = {
  'service': _service ?? '',
  'rankType': _rankType ?? '',
  'rank': _rankType == 'Officer' ? _officerRank : _enlistedRank,
  'specialty': _militarySpecialty ?? '',
  'experience': _experience,
  // Store base values for Screen C to reset from
  'baseAttributes': Map<String, int>.from(finalAttributes),
  'baseSkills': Map<String, int>.from(finalSkills),
};
```

#### 2. Screen C (Deployments) - `screen_c_deployments.dart`

**A. Initialize base values on first load:**
```dart
Future<void> _loadCharacter() async {
  final box = Hive.box('characters');
  final data = box.get(widget.characterId);
  if (data != null) {
    setState(() {
      _character = Character.fromJson(Map<String, dynamic>.from(data));
      
      // Store base values from Screen B (before any deployment bonuses)
      // If not already stored, save current values as base
      if (_character!.enlistment['baseAttributes'] == null) {
        _character!.enlistment['baseAttributes'] = Map<String, int>.from(_character!.attributes);
      }
      if (_character!.enlistment['baseSkills'] == null) {
        _character!.enlistment['baseSkills'] = Map<String, int>.from(_character!.skills);
      }
    });
  }
}
```

**B. Reset to base values before applying bonuses:**
```dart
// Reset to base values from Screen B before applying deployment bonuses
// This prevents double-counting when user revisits this screen
final baseAttributes = character.enlistment['baseAttributes'];
final baseSkills = character.enlistment['baseSkills'];

if (baseAttributes != null && baseAttributes is Map) {
  character.attributes = Map<String, int>.from(
    baseAttributes.map((key, value) => MapEntry(key.toString(), value as int))
  );
}

if (baseSkills != null && baseSkills is Map) {
  character.skills = Map<String, int>.from(
    baseSkills.map((key, value) => MapEntry(key.toString(), value as int))
  );
}

// NOW apply promotions, specialty bonuses, deployment bonuses
// (existing code continues...)
```

## How It Works Now

### Flow:
1. **Screen B**: Calculate final attributes/skills (background + specialty + officer bonuses) → **store as baseAttributes/baseSkills** → save
2. **Screen C (Any Visit)**:
   - Load character
   - **Reset to base values** from Screen B
   - Apply deployment bonuses fresh (promotions, specialty choices, school/award bonuses)
   - Save

### Example with Fix:
- **Screen B**: Character has Small Arms 5, Strength 6 → **saved as base**
- **Screen C (First Visit)**: Reset to base (5, 6) → Apply officer (+1 Str) + Ranger school (+1 Str, +1 Combat Knowledge) → Strength 8, Combat Knowledge +1
- **Screen C (Second Visit - Edit)**: **Reset to base (5, 6)** → Apply same bonuses → Strength 8 (CORRECT!)
- **Screen C (Any Subsequent Visit)**: **Always reset to base first** → Consistent results

## Impact
- **Existing Characters**: On next edit, will reset to correct base values and recalculate properly
- **New Characters**: Will never experience stacking bug
- **John's Character**: Next time you edit John's deployments, his stats will reset to the correct base values from Screen B

## Testing Recommendations
1. Load John's character
2. Edit deployments (Screen C) → check attributes/skills
3. Save and return to dashboard
4. Edit deployments again → **verify attributes/skills remain stable** (not increasing)
5. Create new character → complete all screens → edit deployments multiple times → verify no stacking

## Related Code
- `lib/screens/screen_b_enlistment.dart` (lines 215-227)
- `lib/screens/screen_c_deployments.dart` (lines 163-178, 285-310)
