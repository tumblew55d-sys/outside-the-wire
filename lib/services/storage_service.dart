import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final ImagePicker _imagePicker = ImagePicker();

  /// Upload character portrait photo to Firebase Storage
  /// Returns the download URL of the uploaded image
  static Future<String?> uploadPortrait(String characterId) async {
    try {
      // Pick image from gallery or camera
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Create storage reference
      final storageRef = _storage.ref().child('portraits/$characterId.jpg');

      // Upload file
      final Uint8List imageData = await image.readAsBytes();
      final uploadTask = await storageRef.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading portrait: $e');
      return null;
    }
  }

  /// Upload character portrait from camera
  static Future<String?> uploadPortraitFromCamera(String characterId) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return null;

      final storageRef = _storage.ref().child('portraits/$characterId.jpg');
      final Uint8List imageData = await image.readAsBytes();
      final uploadTask = await storageRef.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading portrait from camera: $e');
      return null;
    }
  }

  /// Upload custom equipment image
  /// Returns the download URL of the uploaded image
  static Future<String?> uploadEquipmentImage(
    String characterId,
    String equipmentName,
  ) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image == null) return null;

      // Sanitize equipment name for file path
      final sanitizedName = equipmentName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final storageRef = _storage.ref().child('equipment/$characterId/$sanitizedName.jpg');

      final Uint8List imageData = await image.readAsBytes();
      final uploadTask = await storageRef.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading equipment image: $e');
      return null;
    }
  }

  /// Upload PDF character sheet to Firebase Storage
  /// Returns the download URL of the uploaded PDF
  static Future<String?> uploadPdfSheet(
    String characterId,
    Uint8List pdfData,
    String characterName,
  ) async {
    try {
      // Sanitize character name for filename
      final sanitizedName = characterName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${sanitizedName}_$timestamp.pdf';

      final storageRef = _storage.ref().child('character_sheets/$characterId/$filename');

      final uploadTask = await storageRef.putData(
        pdfData,
        SettableMetadata(contentType: 'application/pdf'),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading PDF: $e');
      return null;
    }
  }

  /// Delete portrait image
  static Future<bool> deletePortrait(String characterId) async {
    try {
      final storageRef = _storage.ref().child('portraits/$characterId.jpg');
      await storageRef.delete();
      return true;
    } catch (e) {
      print('Error deleting portrait: $e');
      return false;
    }
  }

  /// Delete equipment image
  static Future<bool> deleteEquipmentImage(
    String characterId,
    String equipmentName,
  ) async {
    try {
      final sanitizedName = equipmentName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final storageRef = _storage.ref().child('equipment/$characterId/$sanitizedName.jpg');
      await storageRef.delete();
      return true;
    } catch (e) {
      print('Error deleting equipment image: $e');
      return false;
    }
  }

  /// Get all PDF sheets for a character
  static Future<List<String>> getCharacterPdfUrls(String characterId) async {
    try {
      final storageRef = _storage.ref().child('character_sheets/$characterId');
      final listResult = await storageRef.listAll();
      
      final urls = <String>[];
      for (var item in listResult.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }
      
      return urls;
    } catch (e) {
      print('Error getting PDF URLs: $e');
      return [];
    }
  }

  /// Show image source selection dialog (Gallery or Camera)
  static Future<ImageSource?> showImageSourceDialog(BuildContext context) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }
}
