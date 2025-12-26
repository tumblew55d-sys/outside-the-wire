// lib/services/storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';

class AppStorageService {
  static const String _keyCurrentChar = 'current_character_data';

  /// Save the specific screen data (Updates the master record)
  static Future<void> saveCharacter(CharacterProfile char) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = char.toJson();
    await prefs.setString(_keyCurrentChar, jsonString);
    print("DEBUG: Character Saved -> $jsonString"); // Console log for verifying
  }

  /// Load the character data
  static Future<CharacterProfile?> loadCharacter() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_keyCurrentChar);
    
    if (jsonString != null) {
      print("DEBUG: Character Loaded");
      return CharacterProfile.fromJson(jsonString);
    }
    return null; // No save found
  }
  
  /// Clear data (Reset)
  static Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentChar);
  }
}