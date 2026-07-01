// Platform-specific implementation for dart:io (mobile/desktop)
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PdfFileHandler {
  static Future<String> saveFile(List<int> bytes, String fileName) async {
    final directory = await getDownloadsDirectory() ?? 
                      await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
