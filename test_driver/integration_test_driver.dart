import 'package:integration_test/integration_test_driver.dart';

/// Test driver for integration tests.
/// 
/// This file is used when running integration tests on a real device or emulator.
/// 
/// Usage:
///   flutter drive \
///     --driver=test_driver/integration_test_driver.dart \
///     --target=integration_test/edit_persistence_integration_test.dart
Future<void> main() => integrationDriver();
