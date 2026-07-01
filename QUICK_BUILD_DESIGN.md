# Quick Build Character System Design

## Overview
Add a "Quick Build" option alongside manual character creation at the specialty selection point in EnlistmentScreen. This allows rapid generation of complete, playable characters with appropriate gear and backstory.

## Decision Point Location
**Screen B: EnlistmentScreen** - After user selects their military specialty, offer two paths:
1. **Manual Build** (existing) - Continue to deployments, abilities, inventory screens
2. **Quick Build** (new) - Auto-generate complete character based on specialty

## UI Implementation
### EnlistmentScreen Addition
After specialty dropdown, add prominent buttons:
```
┌─────────────────────────────────────────────┐
│ Military Specialty: [Rifleman ▼]           │
│                                             │
│ ┌─────────────────┐  ┌──────────────────┐  │
│ │  MANUAL BUILD   │  │  QUICK BUILD     │  │
│ │  (Continue)     │  │  (Auto-Generate) │  │
│ └─────────────────┘  └──────────────────┘  │
└─────────────────────────────────────────────┘
```

### Quick Build Dialog
When Quick Build clicked, show dialog:
```
┌────────────────────────────────────────────────┐
│         Select MOS for Quick Build             │
│                                                │
│  Basic Infantry:                               │
│    • Rifleman                                  │
│    • Heavy Weapons                             │
│    • Sniper                                    │
│                                                │
│  Support:                                      │
│    • Radio Operator                            │
│    • Signals/Cyber Intel                       │
│    • Medical                                   │
│    • Civil Affairs                             │
│                                                │
│  Advanced (Auto-generated path):               │
│    • EOD (via random initial specialty)        │
│    • JTAC (via random initial specialty)       │
│    • SOF (via random initial specialty)        │
│    • Agent (via SOF path)                      │
│                                                │
│              [GENERATE]  [CANCEL]              │
└────────────────────────────────────────────────┘
```

## Quick Build Logic by Specialty

### Basic Specialties (Direct Path)
**Rifleman, Heavy Weapons, Sniper, Radio Operator, Signals/Cyber Intel, Medical, Civil Affairs**

1. **Attributes**: Roll 1D10 for each attribute (auto-assign optimally)
2. **Skills**: Apply standard specialty bonuses from EnlistmentScreen
3. **Deployments**: Generate 1-2 random deployments with appropriate schools
4. **Weapons**: Assign specialty-appropriate loadout
5. **Equipment**: Assign base inventory + specialty kit

### Advanced Specialties (Prerequisites Required)

#### EOD - Explosives Ordnance Disposal
**Prerequisites**: Must have initial specialty first, then invited to EOD school
1. **Initial Specialty**: Random selection from [Rifleman, Heavy Weapons, Radio Operator]
2. **Deployments**: 1 deployment, roll for EOD invitation
3. **Skills**: Initial specialty bonuses + Explosives +3
4. **Weapons**: M4 carbine, combat knife, M9 Pistol
5. **Equipment**: EOD demo kit, EOD robot and computer, Thor Backpack signal jammer
6. **Optional**: 50% chance for Canine Kit + random breed/name

#### JTAC - Joint Terminal Attack Controller
**Prerequisites**: Must have initial specialty first, then invited to JTAC school
1. **Initial Specialty**: Random selection from [Rifleman, Radio Operator]
2. **Deployments**: 1 deployment, roll for JTAC invitation
3. **Skills**: Initial specialty bonuses + Fires +3, Radio Ops +1
4. **Weapons**: M4 carbine, M9 pistol, combat knife, (2) smoke grenades OR M4 with M320A1, M9 pistol, combat knife, (2) smoke grenades
5. **Equipment**: JTAC computer and radio, Backpack Radio

#### SOF - Special Operations Forces
**Prerequisites**: Must have initial specialty first, then invited to SOF, requires Ranger graduation
1. **Initial Specialty**: Random selection from [Rifleman, Sniper, Radio Operator, Medical]
2. **Deployments**: 2 deployments minimum (first includes Ranger school, second has SOF invitation)
3. **Schools**: 
   - Deployment 1: Ranger school (Strength +1, Combat Knowledge +1)
   - SOF School: Random from [Airborne, Air Assault, Small Boats, Hostage Rescue, Breacher, Mountain Warfare]
4. **Skills**: Initial specialty bonuses + Training +1 + highest skill +1 + SOF school bonuses
5. **Weapons**: Role-appropriate (Rifleman: M4 + grenades, Sniper: M110 SASS/M24/M40A4, Radio Op: M4 + smoke grenades, Medical: M4 + smoke grenades)
6. **Equipment**: Advanced kit (Night Vision Goggles, Rifle mounted IR pointer, Inter Squad Radio)
7. **Promotion**: Automatic promotion when joining SOF

##### SOF School Bonuses:
- **Breacher**: Explosives +1
- **Hostage Rescue**: Small Arms +1
- **Airborne/Air Assault/Small Boats**: Strength +1 (physical schools)
- **Mountain Warfare/Underground/Jungle**: No skill bonuses (already applied from deployment schools)

#### Agent - Intelligence Operative
**Prerequisites**: Must be SOF first, then invited to Agent program
1. **Initial Path**: Generate SOF character first (see SOF above)
2. **Deployments**: 3 deployments minimum (SOF path + Agent invitation)
3. **Skills**: SOF bonuses + Spying +3, Civil Affairs +1
4. **Weapons**: Makarov Pistol (covert operations weapon)
5. **Equipment**: Spy Kit, concealment gear

## Weapon Assignment Rules

### By Specialty:
- **Rifleman**: M4 carbine, combat knife, (2) frag grenades, LAW
- **Heavy Weapons**: M240 GPMG, M9 pistol, combat knife OR M4 carbine with tripod/ammo
- **Sniper**: M40A4 sniper rifle OR M110 SASS OR M24 sniper rifle, M9 pistol, combat knife, smoke grenades
- **Radio Operator**: M4 carbine, combat knife, (2) smoke grenades
- **Signals/Cyber Intel**: M4 carbine, combat knife, (2) smoke grenades
- **Medical**: M4 carbine, combat knife, (2) smoke grenades
- **Civil Affairs**: M4 carbine, combat knife, (2) smoke grenades
- **EOD**: M4 carbine, combat knife, M9 Pistol
- **JTAC**: M4 carbine OR M4 with M320A1, M9 pistol, combat knife, (2) smoke grenades
- **SOF**: Based on underlying specialty + advanced weapons (preference for suppressed/specialized variants)
- **Agent**: Makarov Pistol (covert weapon)

### Weapon Categories:
- **Rifles**: M16A4, M4 Carbine
- **Sniper Rifles**: M40A4, M24, M110 SASS, M2010 ESR, Barrett M82
- **Machine Guns**: M249 SAW, M240 GPMG
- **Grenade Launchers**: M203, M320, M320A1, M32 GL
- **Pistols**: M9, 1911, Glock 17, Makarov (Agent only)
- **Melee**: KBAR, Bayonet

## Equipment Assignment Rules

### Base Inventory (All Characters):
- Deployer camouflage uniforms
- Kevlar helmet
- Day patrol pack
- Personal medical kit
- Load bearing vest (with attachments)
- Flashlight
- Compass
- Sleeping bag
- Rucksack
- Gas mask
- Combat jacket

### Specialty-Specific Kits:
- **Medical**: Unit 1 Medical Kit
- **JTAC**: JTAC computer and radio, Backpack Radio
- **Agent**: Spy Kit
- **EOD**: EOD demo kit, EOD robot and computer, Thor Backpack signal jammer, (optional: Canine Kit)
- **Civil Affairs**: Civil Affairs Kit, RIAB (Radio Station in a Box)
- **Signals/Cyber Intel**: Signal Collection Kit, Inter Squad Radio
- **SOF**: Night Vision Goggles, Rifle mounted IR pointer, Inter Squad Radio, specialty grenades (flashbangs, concussion)
- **Heavy Weapons**: Additional ammunition, tripod
- **Sniper**: Rangefinder (if available), additional optics

### Optional Equipment (Random 20-40% chance):
- Night Vision Goggles (non-SOF)
- Rifle mounted flashlight
- Hand held walkie talkie
- Additional grenades (frag, smoke, gas)

## Deployment Generation

### Number of Deployments:
- **Basic Specialties**: 1-2 deployments
- **EOD/JTAC**: 1 deployment (invitation deployment)
- **SOF**: 2 deployments (Ranger + SOF invitation)
- **Agent**: 3 deployments (Ranger + SOF + Agent invitation)

### Deployment Details:
Each deployment includes:
- **Location**: Random from available theaters
- **Result**: Random roll (1D10) - success, wounded, decorated
- **School**: Specialty-appropriate (if applicable)
- **Award**: Based on result roll (none, Commendation Medal, Bronze Star, Silver Star, Purple Heart)

### School Assignment Priority:
1. **First deployment for SOF track**: Ranger school (mandatory)
2. **Specialty-specific**: JTAC school, EOD school, Agent school
3. **Physical schools**: Airborne, Air Assault, Small Boats (for SOF)
4. **Specialty schools**: Breacher, Hostage Rescue, Mountain Warfare (for SOF)

## Character Hook Generation
- Roll 1D10 for specialty-appropriate hook from NationalityData
- Auto-assign to character

## Implementation Classes

### QuickBuildService (lib/services/quick_build_service.dart)
```dart
class QuickBuildService {
  // Main entry point
  static Future<Character> generateQuickCharacter(
    String characterId,
    String specialty,
    Character baseCharacter,
  );
  
  // Attribute generation
  static Map<String, int> _rollAttributes();
  
  // Deployment generation
  static List<DeploymentData> _generateDeployments(String specialty);
  
  // Weapon assignment
  static List<String> _assignWeapons(String specialty, String? subSpecialty);
  
  // Equipment assignment
  static List<String> _assignEquipment(String specialty);
  
  // Advanced specialty handlers
  static Future<Character> _buildEODCharacter(...);
  static Future<Character> _buildJTACCharacter(...);
  static Future<Character> _buildSOFCharacter(...);
  static Future<Character> _buildAgentCharacter(...);
}
```

## Testing Checklist
- [ ] Rifleman quick build
- [ ] Heavy Weapons quick build
- [ ] Sniper quick build
- [ ] Radio Operator quick build
- [ ] Signals/Cyber Intel quick build
- [ ] Medical quick build
- [ ] Civil Affairs quick build
- [ ] EOD quick build (verify initial specialty + EOD invitation)
- [ ] JTAC quick build (verify initial specialty + JTAC invitation)
- [ ] SOF quick build - Airborne school
- [ ] SOF quick build - Air Assault school
- [ ] SOF quick build - Small Boats school
- [ ] SOF quick build - Breacher school
- [ ] SOF quick build - Hostage Rescue school
- [ ] SOF quick build - Mountain Warfare school
- [ ] Agent quick build (verify SOF → Agent progression)
- [ ] Verify weapons match specialty
- [ ] Verify equipment kits assigned correctly
- [ ] Verify attributes rolled and assigned
- [ ] Verify skills calculated correctly
- [ ] Verify deployments generated properly
- [ ] Verify character saves and loads correctly
- [ ] Verify PDF export works with quick build characters

## Notes
- Quick build should skip Screen C (Deployments), Screen D (Abilities), and Screen E (Inventory) - directly generate final character
- User can still manually edit character afterwards from dashboard
- Quick build characters should be marked with metadata: `quickBuild: true` in Character model
- Quick build should take ~2 seconds max to generate
- Show progress indicator during generation
- Display summary of generated character before finalizing
