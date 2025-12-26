// lib/models/inventory.dart

class InventoryItem {
  final String name;
  final String category;
  final bool isBaseIssue;

  InventoryItem({required this.name, required this.category, this.isBaseIssue = false});

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'isBaseIssue': isBaseIssue,
      };

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      name: map['name'] ?? 'Unknown',
      category: map['category'] ?? 'Gear',
      isBaseIssue: map['isBaseIssue'] ?? false,
    );
  }
}

class InventoryManager {
  static List<InventoryItem> getBaseKit() {
    return [
      InventoryItem(name: 'Camouflage Uniform', category: 'Uniform', isBaseIssue: true),
      InventoryItem(name: 'Kevlar Helmet', category: 'Uniform', isBaseIssue: true),
      InventoryItem(name: 'Combat Jacket', category: 'Uniform', isBaseIssue: true),
      InventoryItem(name: 'Load Bearing Vest', category: 'Gear', isBaseIssue: true),
      InventoryItem(name: 'Rucksack', category: 'Gear', isBaseIssue: true),
      InventoryItem(name: 'IFAK (Medical)', category: 'Gear', isBaseIssue: true),
      InventoryItem(name: 'Gas Mask', category: 'Gear', isBaseIssue: true),
      InventoryItem(name: 'Flashlight', category: 'Gear', isBaseIssue: true),
    ];
  }

  static List<InventoryItem> getMOSLoadout(String mos) {
    List<InventoryItem> kit = [];
    void add(String name) => kit.add(InventoryItem(name: name, category: 'Weapon'));

    switch (mos) {
      case 'Rifleman':
        add('M4 Carbine');
        add('Combat Knife');
        break;
      case 'Sniper':
        add('M40A4 Sniper Rifle');
        add('M9 Pistol');
        break;
      default:
        add('M4 Carbine');
    }
    return kit;
  }
}
