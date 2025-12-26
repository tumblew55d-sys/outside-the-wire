import 'character.dart';

class InventoryItem {
  final String name;
  final String category; // Weapon, Gear, Uniform
  final bool isBaseIssue; // Cannot be removed easily

  InventoryItem({required this.name, required this.category, this.isBaseIssue = false});

  // Serialization
  Map<String, dynamic> toMap() => {'name': name, 'category': category, 'isBaseIssue': isBaseIssue};
  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      name: map['name'] ?? "Unknown",
      category: map['category'] ?? "Gear",
      isBaseIssue: map['isBaseIssue'] ?? false,
    );
  }
}

class InventoryManager {
  // ==========================
  // MASTER SUPPLY LIST (The Cage)
  // ==========================
  static final List<String> allWeapons = [
    "M16A4 Rifle", "M4 Carbine", "M4 w/ M203", "M4 w/ M320A1", "M249 SAW",
    "M240 GPMG", "M40A4 Sniper", "M24 Sniper", "M2010 ESR", "M110 SASS",
    "Barrett M82", "M32 GL", "870 Shotgun", "LAW", "AT-4", 
    "M9 Pistol", "1911 Pistol", "Glock 17", "Makarov Pistol", "Combat Knife"
  ];

  static final List<String> allGear = [
    "Night Vision Goggles", "IR Pointer", "Frag Grenade", "Smoke Grenade", 
    "Flashbang", "Thermite Grenade", "Signal Flare (Red)", "Signal Flare (Green)",
    "Breacher Kit", "EOD Demo Kit", "Thor Jammer", "EOD Robot", "Canine Kit",
    "Unit 1 Med Kit", "JTAC Radio", "Sat Phone", "Backpack Radio"
  ];

  // ==========================
  // LOADOUT LOGIC
  // ==========================
  
  /// Adds the "Standard Issue" kit every soldier gets (Rule 1)
  static List<InventoryItem> getBaseKit() {
    return [
      InventoryItem(name: "Camouflage Uniform", category: "Uniform", isBaseIssue: true),
      InventoryItem(name: "Kevlar Helmet", category: "Uniform", isBaseIssue: true),
      InventoryItem(name: "Combat Jacket", category: "Uniform", isBaseIssue: true),
      InventoryItem(name: "Load Bearing Vest", category: "Gear", isBaseIssue: true),
      InventoryItem(name: "Rucksack", category: "Gear", isBaseIssue: true),
      InventoryItem(name: "IFAK (Medical)", category: "Gear", isBaseIssue: true),
      InventoryItem(name: "Gas Mask", category: "Gear", isBaseIssue: true),
      InventoryItem(name: "Flashlight", category: "Gear", isBaseIssue: true),
    ];
  }

  /// Auto-Equips weapons based on MOS (Rule 2)
  static List<InventoryItem> getMOSLoadout(String mos) {
    List<InventoryItem> kit = [];
    
    // Helper to add weapons quickly
    void add(String name) => kit.add(InventoryItem(name: name, category: "Weapon"));

    switch (mos) {
      case "Rifleman":
        add("M4 Carbine"); add("Combat Knife"); add("Frag Grenade (x2)"); add("LAW");
        break;
      case "Sniper":
        add("M40A4 Sniper Rifle"); add("M9 Pistol"); add("Smoke Grenade");
        break;
      case "Heavy Weapons":
        add("M240 GPMG"); add("M9 Pistol"); add("Combat Knife");
        break;
      case "Radio Operator":
        add("M4 Carbine"); add("Backpack Radio"); add("Smoke Grenade (x2)");
        break;
      case "Medical":
        add("M4 Carbine"); add("Unit 1 Med Kit"); add("Smoke Grenade (x2)");
        break;
      case "Civil Affairs":
        add("M4 Carbine"); add("Civil Affairs Kit");
        break;
      case "Signals/Cyber Intel":
        add("M4 Carbine"); add("Signal Collection Kit");
        break;
      default:
        add("M4 Carbine"); // Fallback
    }
    return kit;
  }
}