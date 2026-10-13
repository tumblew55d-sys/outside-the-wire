import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Test double for path_provider, which has no native implementation under
/// `flutter test`. All directories point at one temp folder.
class FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  FakePathProvider(this.root);

  final Directory root;

  /// Installs the fake and returns the temp directory it uses.
  static Directory install() {
    final dir = Directory.systemTemp.createTempSync('fake_path_provider_');
    PathProviderPlatform.instance = FakePathProvider(dir);
    return dir;
  }

  @override
  Future<String?> getTemporaryPath() async => root.path;

  @override
  Future<String?> getApplicationDocumentsPath() async => root.path;

  @override
  Future<String?> getApplicationSupportPath() async => root.path;

  @override
  Future<String?> getDownloadsPath() async => root.path;

  @override
  Future<String?> getExternalStoragePath() async => root.path;
}
