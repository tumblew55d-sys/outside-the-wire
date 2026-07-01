import 'dart:convert';

class Character {
  final String id;
  String userId;
  String name;
  String nickname;
  int age;
  String homeLocation;
  String nationality;
  String height;
  double weight;
  String weightUnit;
  List<String> languages;
  String motivation;
  String background;
  String trademark;
  String characterHook;
  String specialtyHook;
  String personalConflict;
  bool isSOF;
  List<String> medals;
  String canineBreed;
  String canineName;
  Map<String, int> attributes;
  Map<String, int> skills;
  Map<String, dynamic> enlistment;
  Map<String, dynamic> inventory;
  String portraitUrl;
  Map<String, String> customEquipmentImages;
  DateTime modifiedAt;

  Character({
    required this.id,
    this.userId = '',
    this.name = '',
    this.nickname = '',
    this.age = 17,
    this.homeLocation = '',
    this.nationality = '',
    this.height = 'Standard (Avg)',
    this.weight = 0.0,
    this.weightUnit = 'kg',
    this.languages = const [],
    this.motivation = '',
    this.background = '',
    this.trademark = '',
    this.characterHook = '',
    this.specialtyHook = '',
    this.personalConflict = '',
    this.isSOF = false,
    this.medals = const [],
    this.canineBreed = '',
    this.canineName = '',
    this.attributes = const {},
    this.skills = const {},
    this.enlistment = const {},
    this.inventory = const {},
    this.portraitUrl = '',
    this.customEquipmentImages = const {},
    DateTime? modifiedAt,
  }) : modifiedAt = modifiedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'nickname': nickname,
    'age': age,
    'homeLocation': homeLocation,
    'nationality': nationality,
    'height': height,
    'weight': weight,
    'weightUnit': weightUnit,
    'languages': languages,
    'motivation': motivation,
    'background': background,
    'trademark': trademark,
    'characterHook': characterHook,
    'specialtyHook': specialtyHook,
    'personalConflict': personalConflict,
    'isSOF': isSOF,
    'medals': medals,
    'canineBreed': canineBreed,
    'canineName': canineName,
    'attributes': attributes,
    'skills': skills,
    'enlistment': enlistment,
    'inventory': inventory,
    'portraitUrl': portraitUrl,
    'customEquipmentImages': customEquipmentImages,
    'modifiedAt': modifiedAt.toUtc().toIso8601String(),
  };

  factory Character.fromJson(Map<String, dynamic> json) => Character(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    name: json['name'] ?? '',
    nickname: json['nickname'] ?? '',
    age: json['age'] ?? 17,
    homeLocation: json['homeLocation'] ?? '',
    nationality: json['nationality'] ?? '',
    height: json['height'] ?? 'Standard (Avg)',
    weight: (json['weight'] ?? 0).toDouble(),
    weightUnit: json['weightUnit'] ?? 'kg',
    languages: List<String>.from(json['languages'] ?? []),
    motivation: json['motivation'] ?? '',
    background: json['background'] ?? '',
    trademark: json['trademark'] ?? '',
    characterHook: json['characterHook'] ?? '',
    specialtyHook: json['specialtyHook'] ?? '',
    personalConflict: json['personalConflict'] ?? '',
    isSOF: json['isSOF'] ?? false,
    medals: List<String>.from(json['medals'] ?? []),
    canineBreed: json['canineBreed'] ?? '',
    canineName: json['canineName'] ?? '',
    attributes: Map<String, int>.from(json['attributes'] ?? {}),
    skills: Map<String, int>.from(json['skills'] ?? {}),
    enlistment: Map<String, dynamic>.from(json['enlistment'] ?? {}),
    inventory: Map<String, dynamic>.from(json['inventory'] ?? {}),
    portraitUrl: json['portraitUrl'] ?? '',
    customEquipmentImages: Map<String, String>.from(
      json['customEquipmentImages'] ?? {},
    ),
    modifiedAt: json['modifiedAt'] != null
        ? DateTime.parse(json['modifiedAt']).toLocal()
        : DateTime.now(),
  );

  @override
  String toString() => jsonEncode(toJson());
}
