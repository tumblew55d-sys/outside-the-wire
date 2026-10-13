// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
// Platform-specific implementation for dart:html (web)
import 'dart:html' as html;

class PdfFileHandler {
  static Future<String> saveFile(List<int> bytes, String fileName) async {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
    return fileName;
  }
}
