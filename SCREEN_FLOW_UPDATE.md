# Screen Flow Improvements

## Changes Implemented

### 1. **Landing Page: "New Teammate" Button**
Replaced the floating action button (+) with a prominent "NEW TEAMMATE" button card at the top of the roster.

**File:** `lib/screens/dashboard.dart`
- Removed `floatingActionButton` widget
- Added new Card with InkWell at top of roster list
- Styled with person_add icon and primary color theme
- Navigates to `/createCharacter` route

### 2. **Automatic Screen Flow (A → B → C → D → E → F)**
Implemented seamless navigation between all character creation screens:

**Character Create (Screen A)** → **Enlistment (Screen B)** → **Deployments (Screen C)** → **Abilities (Screen D)** → **Inventory (Screen E)** → **Appearance (Screen F)** → **Dashboard**

#### Screen Transitions:
- **character_create.dart**: Auto-navigates to Screen B after saving character (line 106)
- **screen_b_enlistment.dart**: Auto-navigates to Screen C after saving enlistment (line 235)
- **screen_c_deployments.dart**: Auto-navigates to Screen D after saving deployments (line 448)
- **screen_d_abilities.dart**: Auto-navigates to Screen E after saving abilities (line 119)
- **screen_e_inventory.dart**: Auto-navigates to Screen F after saving inventory (line 285)
- **screen_f_appearance.dart**: Returns to Dashboard (roster) after completing (line 113)

### 3. **Next/Back/Save Navigation Buttons**
Each screen now has three buttons:

#### **Next Button** (ElevatedButton - Primary)
- **Icon:** arrow_forward (Screens A-E) or check_circle (Screen F)
- **Label:** "Next: [Screen Name]" or "Finish Character" (Screen F)
- **Action:** Saves current screen and navigates to next screen
- **Auto-save:** Data is saved before navigation

#### **Back Button** (OutlinedButton - Secondary)
- **Icon:** arrow_back
- **Label:** "Back: [Previous Screen Name]"
- **Action:** Navigates to previous screen without saving
- **Note:** Uses pushReplacement to maintain clean navigation stack

#### **Save & Return Button** (OutlinedButton - Tertiary)
- **Icon:** save
- **Label:** "Save & Return to Roster"
- **Action:** Saves current screen and returns to Dashboard
- **Use Case:** User wants to save progress and come back later

### 4. **Route Configuration**
Added `onGenerateRoute` to handle dynamic routes with character ID arguments.

**File:** `lib/main.dart` (lines 131-167)
- `/enlistment` → EnlistmentScreen
- `/deployments` → DeploymentsScreen
- `/abilities` → AbilitiesNarrativeScreen
- `/inventory` → InventoryEquipmentScreen
- `/appearance` → AppearanceScreen

### 5. **Imports Added**
Each screen now imports its neighboring screens for navigation:

- **screen_b_enlistment.dart**: Imports `screen_c_deployments.dart`
- **screen_c_deployments.dart**: Imports `screen_b_enlistment.dart`, `screen_d_abilities.dart`
- **screen_d_abilities.dart**: Imports `screen_c_deployments.dart`, `screen_e_inventory.dart`
- **screen_e_inventory.dart**: Imports `screen_d_abilities.dart`, `screen_f_appearance.dart`
- **screen_f_appearance.dart**: Imports `screen_e_inventory.dart`

## User Experience Improvements

### Before:
1. User clicked FAB (+) to create character
2. User filled Screen A → clicked "Save" → returned to Dashboard
3. User manually navigated to Screen B from Dashboard
4. Repeated for each screen (6 manual navigation steps)
5. "Cancel" button abandoned progress

### After:
1. User clicks "NEW TEAMMATE" button card (more discoverable)
2. User fills Screen A → clicks "Next: Enlistment" (auto-saves)
3. User fills Screen B → clicks "Next: Deployments" (auto-saves)
4. User fills Screen C → clicks "Next: Abilities" (auto-saves)
5. User fills Screen D → clicks "Next: Inventory" (auto-saves)
6. User fills Screen E → clicks "Next: Appearance" (auto-saves)
7. User fills Screen F → clicks "Finish Character" → Returns to Dashboard
8. At any point, user can click "Back" to review/edit previous screen
9. At any point, user can click "Save & Return to Roster" to save progress

### Benefits:
- **Reduced friction:** One continuous flow instead of 6 separate sessions
- **Auto-save:** Data persists at each step (no lost work)
- **Clear navigation:** Users know what comes next
- **Flexibility:** Can still save and return, or go back to previous screens
- **Visual clarity:** "NEW TEAMMATE" button more obvious than FAB

## Technical Notes

### Navigation Pattern:
- Uses `pushReplacement` for Next/Back buttons to prevent stack buildup
- Uses `popUntil((route) => route.isFirst)` for "Save & Return" to clear entire stack
- Character ID passed as route argument via `Navigator.of(context).pushReplacementNamed('/route', arguments: id)`

### Save Behavior:
- Each screen's save method now triggers navigation instead of just popping
- Screen F is the only screen that returns to Dashboard (end of flow)
- All screens auto-save before navigating to next screen

### State Management:
- Hive box stores character data after each screen save
- Previous screen bonus stacking bug already fixed (see BUGFIX_CALCULATION_STACKING.md)
- Base values stored in Screen B for deployment bonus recalculation

## Testing Checklist

- [x] "NEW TEAMMATE" button visible and functional on Dashboard
- [x] Screen A → B navigation works
- [x] Screen B → C navigation works
- [x] Screen C → D navigation works
- [x] Screen D → E navigation works
- [x] Screen E → F navigation works
- [x] Screen F returns to Dashboard
- [x] Back buttons work on all screens
- [x] Save & Return buttons work on all screens
- [x] Data persists between screen transitions
- [x] No navigation stack overflow issues
- [x] No compilation errors

## Files Modified

1. `lib/main.dart` - Added onGenerateRoute, added screen imports
2. `lib/screens/dashboard.dart` - Replaced FAB with "NEW TEAMMATE" button
3. `lib/screens/character_create.dart` - Navigate to Screen B, changed button text
4. `lib/screens/screen_b_enlistment.dart` - Added Next/Back/Save buttons, navigate to Screen C
5. `lib/screens/screen_c_deployments.dart` - Added Next/Back/Save buttons, navigate to Screen D
6. `lib/screens/screen_d_abilities.dart` - Added Next/Back/Save buttons, navigate to Screen E
7. `lib/screens/screen_e_inventory.dart` - Added Next/Back/Save buttons, navigate to Screen F
8. `lib/screens/screen_f_appearance.dart` - Added Finish/Back/Save buttons, return to Dashboard

## Future Enhancements (Optional)

- Add progress indicator showing "Step X of 6"
- Add breadcrumb navigation at top of each screen
- Add "Skip to Roster" button for advanced users
- Add confirmation dialog if user tries to leave flow without finishing
- Add keyboard shortcuts (Enter = Next, Esc = Back)
