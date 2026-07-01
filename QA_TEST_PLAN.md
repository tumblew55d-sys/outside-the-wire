# QA Test Plan - 15 Character Stress Test

## Test Objective
Create 15 diverse characters to identify crashes, UI issues, data validation problems, and edge cases in the character creation system.

## Test Characters to Create

### Test 1: US Ranger → SOF Promotion Path
**Purpose**: Test Ranger school selection, SOF invitation acceptance, SOF promotion, and SOF school selection

- **Name**: Jake Morrison
- **Nickname**: Havoc
- **Age**: 28
- **Hometown**: Fort Benning, GA
- **Nationality**: United States
- **Background**: Infantry
- **Trademark**: Worn Ranger tab
- **Specialty**: Infantry → SOF
- **Career Roll**: 8 (2 deployments, sergeant promotion)
- **Deployment 1**: Ranger school, Commendation medal
- **Deployment 2**: Airborne school, Bronze Star
- **SOF Action**: JOIN SOF (verify promotion occurs)
- **SOF School**: Breacher
- **Expected Result**: Ranger bonuses preserved, SOF promotion applied, SOF school bonus added

### Test 2: UK Officer → EOD with Canine
**Purpose**: Test officer path, EOD specialty with canine companion

- **Name**: Oliver Blackwood
- **Nickname**: Bomber
- **Age**: 32
- **Nationality**: United Kingdom
- **Rank Type**: Officer
- **Career Roll**: 1 (2 deployments, officer promotion)
- **Deployment 1**: Small Boats school
- **Deployment 2**: Air Assault school
- **Special Invite**: EOD
- **Canine**: Belgian Malinois named "Rex"
- **Expected Result**: Officer promotion, EOD skills (+3 Explosives), canine saved

### Test 3: German Enlisted → JTAC
**Purpose**: Test non-US nationality, JTAC specialty

- **Name**: Klaus Schmidt
- **Age**: 26
- **Nationality**: Germany
- **Background**: Communications
- **Career Roll**: 2 (2 deployments, sergeant promotion, EOD/JTAC invite)
- **Special Invite**: JTAC
- **Expected Result**: JTAC skills (+3 Fires, +1 Radio Ops)

### Test 4: French Ranger → SOF → Agent
**Purpose**: Test full progression chain (Ranger → SOF → Agent)

- **Name**: Pierre Dubois
- **Nickname**: Ghost
- **Age**: 34
- **Nationality**: France
- **Background**: Intelligence
- **Career Roll**: 9 (2 deployments, sergeant promotion, EOD/JTAC invite)
- **Deployment 1**: Ranger school, Commendation
- **Deployment 2**: Small Boats, Silver Star
- **SOF Action**: JOIN SOF
- **SOF School**: Hostage Rescue
- **Agent Action**: JOIN AGENT
- **Expected Result**: All bonuses stacked (Ranger + SOF + Agent + schools)

### Test 5: Canadian Baseline
**Purpose**: Test minimal/baseline character creation

- **Name**: Connor MacLeod
- **Age**: 23
- **Nationality**: Canada
- **Background**: Infantry
- **Career Roll**: 5 (1 deployment, no promotion)
- **Deployment 1**: Air Assault school, No award
- **Expected Result**: Basic character with minimal bonuses

### Test 6: Australian Multiple Schools
**Purpose**: Test multiple different schools (no Ranger, no SOF)

- **Name**: Jack Harrison
- **Nickname**: Croc
- **Age**: 29
- **Nationality**: Australia
- **Background**: Recon
- **Career Roll**: 8 (2 deployments, sergeant promotion)
- **Deployment 1**: Small Boats, Achievement
- **Deployment 2**: Airborne, Commendation
- **Expected Result**: Multiple school bonuses applied correctly

### Test 7: US Wounded Veteran
**Purpose**: Test Purple Heart / wounded survival, high medals

- **Name**: Marcus Rodriguez
- **Nickname**: Steel
- **Age**: 35
- **Nationality**: United States
- **Background**: Infantry
- **Career Roll**: 8
- **Deployment 1**: Air Assault, Bronze Star, **Wounded**
- **Deployment 2**: Breacher, Silver Star, Survived
- **Expected Result**: Purple Heart awarded, high attribute bonuses from medals

### Test 8: Polish Officer Promotion
**Purpose**: Test officer promotion progression

- **Name**: Aleksander Kowalski
- **Nickname**: Aleks
- **Nationality**: Poland
- **Background**: Military Academy
- **Rank Type**: Officer
- **Career Roll**: 1 (officer promotion)
- **Expected Result**: Officer promoted from 2nd Lt → 1st Lt or similar

### Test 9: Italian Sergeant Progression
**Purpose**: Test enlisted sergeant promotion path

- **Name**: Giovanni Rossi
- **Nickname**: Gio
- **Age**: 27
- **Nationality**: Italy
- **Background**: Medic
- **Career Roll**: 8 (sergeant promotion)
- **Deployment 1**: Air Assault
- **Deployment 2**: Airborne
- **Expected Result**: Enlisted rank progression (E-1 → E-5 → E-6)

### Test 10: Japanese Minimal Character
**Purpose**: Test edge case - absolute minimum inputs

- **Name**: Takeshi Yamamoto
- **Age**: 22
- **Nationality**: Japan
- **No nickname**
- **No trademark**
- **Career Roll**: 5 (1 deployment, no promotion)
- **Minimal attribute allocation**
- **Expected Result**: Character created with minimal data, no crashes

### Test 11: Spanish Maxed Attributes
**Purpose**: Test maximum attribute allocation

- **Name**: Carlos Hernandez
- **Nickname**: Tank
- **Nationality**: Spain
- **Background**: Infantry
- **Maximize Strength attribute** (allocate all 22 points heavily to Strength)
- **Expected Result**: System handles high attribute values, displays correctly

### Test 12: Dutch Ranger Declines SOF
**Purpose**: Test Ranger who doesn't accept SOF invitation

- **Name**: Willem de Vries
- **Nickname**: Wil
- **Age**: 28
- **Nationality**: Netherlands
- **Career Roll**: 8
- **Deployment 1**: Ranger school
- **Deployment 2**: Air Assault
- **SOF Action**: **DO NOT JOIN** (decline invitation)
- **Expected Result**: Ranger bonuses preserved, no SOF bonuses, no crash

### Test 13: Swedish Multiple Deployments
**Purpose**: Test maximum deployment count (2 deployments)

- **Name**: Erik Andersson
- **Nickname**: Viking
- **Nationality**: Sweden
- **Career Roll**: 8 or 9 (2 deployments)
- **Full deployment data for both**
- **Expected Result**: All deployment bonuses applied, preview shows correctly

### Test 14: Belgian Breacher Specialist
**Purpose**: Test skill stacking (multiple Breacher schools if possible)

- **Name**: Luc Mercier
- **Nickname**: Boom
- **Nationality**: Belgium
- **Background**: Engineering
- **Career Roll**: 8
- **Deployment 1**: Breacher school (+2 Explosives)
- **Deployment 2**: Breacher school again if allowed (test duplicate prevention)
- **Expected Result**: System prevents duplicate schools OR stacks bonuses correctly

### Test 15: Norwegian Edge Cases
**Purpose**: Test UI limits - long strings, special characters, extreme values

- **Name**: Bjørn Håkonsson-Vestergaard (special characters æøå)
- **Nickname**: The-Mountain's-Shadow (hyphen, apostrophe)
- **Age**: 99 (extreme value)
- **Hometown**: "Tromsø, Arctic Norway, Land of Midnight Sun" (very long)
- **Motivation**: "[Very long string 200+ characters testing text field limits and special characters !@#$%^&*]"
- **Trademark**: "[Another long string with symbols]"
- **Specialty Hook**: "[Maximum length string testing overflow]"
- **Expected Result**: UI handles long strings without crash/overflow, special chars display

---

## Test Execution Checklist

For EACH character, verify:

### Character Creation Flow
- [ ] Basic info screen saves correctly
- [ ] Enlistment screen attribute allocation totals 22 points
- [ ] Specialty hooks display and save
- [ ] Career roll generates correct deployment count
- [ ] Deployments screen validates all required fields

### Deployment Testing
- [ ] School dropdowns show correct options
- [ ] Roll random buttons work for school/award/survival
- [ ] Duplicate school prevention works
- [ ] Awards display correctly
- [ ] Purple Heart auto-adds for wounded survival

### SOF Testing (where applicable)
- [ ] Ranger school enables SOF invitation card
- [ ] Join SOF button triggers promotion
- [ ] Pre-SOF schools become locked (disabled text fields)
- [ ] SOF school selection card appears
- [ ] SOF school dropdown shows 6 options
- [ ] Can select SOF school without crash
- [ ] Agent opportunity appears after joining SOF

### Abilities Screen
- [ ] Narrative generates correctly
- [ ] Includes age and hometown
- [ ] Includes trademark statement
- [ ] Preview attributes show all bonuses
- [ ] Preview skills show all bonuses
- [ ] No overflow errors on long text

### Inventory Screen
- [ ] Weapon selection works
- [ ] Equipment selection works
- [ ] Navigates to Final Review (not appearance)

### Final Review Screen
- [ ] All character data displays
- [ ] Nickname shows in quotes
- [ ] Specialty hook shows in purple box
- [ ] Equipment section displays weapons
- [ ] Attributes/abilities don't overflow
- [ ] Edit button works
- [ ] Return to Roster button works

### Dashboard/Roster
- [ ] Character appears in roster list
- [ ] Dossier preview loads without crash
- [ ] Nickname displays below name
- [ ] Specialty hook displays (purple box)
- [ ] NO tactical loadout section
- [ ] NO appearance section
- [ ] Canine displays for EOD characters

### PDF Export
- [ ] PDF generates without error
- [ ] Nickname included in name
- [ ] Specialty hook section present
- [ ] Equipment section present
- [ ] NO tactical loadout section
- [ ] NO appearance section

---

## Critical Issues to Watch For

### Known Risk Areas:
1. **SOF Dropdown Crash**: Pre-SOF schools not in SOF list → FIXED (schools now locked)
2. **Text Overflow**: Long ability names, nicknames, hooks
3. **Attribute Stacking**: Ranger + SOF + Officer promotions stacking correctly
4. **School Duplication**: System preventing or handling duplicate schools
5. **Null Values**: Empty nickname, trademark, specialty hook fields
6. **Edge Values**: Age 99, height 84", weight 250lbs
7. **Special Characters**: æøå, apostrophes, hyphens in names
8. **Deployment Validation**: Ensuring all fields required before save

### Expected Behavior:
- System should NEVER crash
- All bonuses should stack additively
- UI should handle overflow gracefully
- Validation should prevent invalid states
- Data should persist correctly in Hive database

---

## Success Criteria

✅ All 15 characters created without crashes
✅ All display correctly in roster
✅ PDF exports work for all characters
✅ Bonuses calculate correctly (verify math)
✅ UI handles edge cases without overflow
✅ Data persists after app restart

## Bug Report Template

If you find issues:

```
**Character**: [Name]
**Step**: [Which screen/action]
**Expected**: [What should happen]
**Actual**: [What actually happened]
**Reproducible**: [Yes/No - steps to reproduce]
**Screenshot**: [If applicable]
```

---

## Start Testing

Begin with Character 1 and work through sequentially. After all 15 are created, review the roster to verify they all display correctly.
