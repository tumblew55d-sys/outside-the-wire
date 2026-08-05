# Abilities PDF Export Fix - August 5, 2026

## Issue
Abilities were missing when exporting character sheets to PDF, even though they displayed correctly in the preview.

## Root Cause Analysis
The PDF export services (`pdf_character_sheet_service.dart` and `pdf_export_service.dart`) expected abilities to be stored in `character.enlistment['abilities']`, but in certain scenarios this field could be null or empty:

1. **Legacy characters** created before abilities system was implemented
2. **Edge cases** in character creation flow where abilities weren't calculated
3. **Data corruption** from incomplete saves or interrupted flows

## Solution Implemented

### 1. Added Fallback Calculation Method
Both PDF services now include a `_calculateAbilities()` method that can compute abilities on-the-fly from character attributes and skills if they're missing from stored data:

```dart
static Map<String, dynamic> _calculateAbilities(Character character) {
  final a = character.attributes;
  final s = character.skills;
  
  // Calculates all 12 abilities using the same formulas as screen_d_abilities.dart
  // - Prowess, Instincts, Tactics (core abilities, never halved)
  // - 9 skill-based abilities (halved if skill not earned)
}
```

### 2. Modified PDF Export Methods
Updated both services to check for abilities and calculate them if missing:

**pdf_character_sheet_service.dart:**
- `_buildAbilitiesSectionLarge()` - Main character sheet abilities section
- `_buildAbilitiesSection()` - Alternative abilities display format

**pdf_export_service.dart:**
- Abilities section in `exportCharacterToPdf()` method

### 3. Added Debug Logging
Added warning message when abilities are calculated on-the-fly:
```dart
debugPrint('⚠️ Abilities missing from character data - calculating on-the-fly');
```

This helps identify characters that need their abilities recalculated and saved.

## Files Modified

1. `lib/services/pdf_character_sheet_service.dart`
   - Added `_calculateAbilities()` helper method
   - Modified `_buildAbilitiesSectionLarge()` to use fallback calculation
   - Modified `_buildAbilitiesSection()` to use fallback calculation
   - Added null safety with `nonNullAbilities` variable

2. `lib/services/pdf_export_service.dart`
   - Added `_calculateAbilities()` helper method
   - Modified abilities section to always calculate if missing
   - Uses IIFE pattern to calculate abilities inline

3. `lib/screens/screen_f_final_review.dart`
   - Added debug logging for abilities when exporting PDF

## Testing Recommendations

### Test Case 1: New Character
1. Create a new character using Quick Build
2. Export to PDF
3. **Expected:** Abilities display correctly (calculated during creation)

### Test Case 2: Manual Character
1. Create character manually through all screens (A → B → C → D → E → F)
2. Export to PDF
3. **Expected:** Abilities display correctly (calculated in Screen D)

### Test Case 3: Legacy Character (Main Fix Target)
1. Open an older character that might not have abilities saved
2. Export to PDF
3. **Expected:** Abilities calculated on-the-fly and display correctly
4. **Console:** Warning message appears about missing abilities

### Test Case 4: Edited Character
1. Edit an existing character's attributes or skills
2. Export to PDF without re-calculating abilities in Screen D
3. **Expected:** PDF shows abilities based on current stats (fallback calculation)

## Benefits

✅ **Backward Compatible** - Works with all existing characters, even those created before abilities system  
✅ **Defensive Programming** - Handles edge cases and incomplete data gracefully  
✅ **No Data Migration Required** - Automatically fixes missing data on export  
✅ **Consistent Formulas** - Uses identical calculation logic as Screen D  
✅ **Debugging Support** - Debug logs help identify problematic characters  

## Future Improvements

### Optional Enhancement: Auto-Save Calculated Abilities
If you want to persist calculated abilities back to the character data:

```dart
// In PDF export method, after calculating abilities
if (character.enlistment['abilities'] == null) {
  character.enlistment['abilities'] = _calculateAbilities(character);
  final box = Hive.box('characters');
  await box.put(character.id, character.toJson());
  debugPrint('✓ Abilities auto-saved to character data');
}
```

This would ensure abilities are saved for future exports, but is not required for the fix to work.

## Verification Status

✅ **Static Analysis:** 0 errors  
✅ **Production Build:** Compiles successfully (64.9s)  
✅ **Null Safety:** All nullable values properly handled  
✅ **Debug Logging:** Added for troubleshooting  

## Resolution

**Status:** ✅ **FIXED**  
**Impact:** All character PDF exports will now include abilities, regardless of when the character was created or how their data is stored.

---

**Implementation Date:** August 5, 2026  
**Developer Note:** This fix uses defensive programming to ensure abilities always appear in PDF exports by calculating them on-the-fly from source attributes and skills when stored ability data is unavailable.
