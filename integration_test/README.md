# Integration Tests

This directory contains integration tests for the Patrol Character Generator application.

## Overview

Integration tests run against the full application stack including:
- Real Hive database instances
- Platform channel integration (path_provider, etc.)
- PDF generation services
- Firebase services (when configured)

Unlike unit tests, integration tests have access to platform-specific functionality and test the complete user workflow.

## Running Integration Tests

### Method 1: Local Testing (Recommended for Development)

Run integration tests in the current environment with platform integration:

```powershell
flutter test integration_test/edit_persistence_integration_test.dart
```

This method:
- ✅ Runs quickly (no device startup time)
- ✅ Has access to platform channels
- ✅ Works on Windows, macOS, and Linux
- ✅ Suitable for CI/CD pipelines

### Method 2: Device/Emulator Testing (Full E2E)

For complete end-to-end testing on a real device or emulator:

```powershell
# Start an emulator or connect a device first
flutter devices

# Run the integration test on the device
flutter drive `
  --driver=test_driver/integration_test_driver.dart `
  --target=integration_test/edit_persistence_integration_test.dart
```

This method:
- ✅ Tests on actual platform (Android/iOS/Web)
- ✅ Validates UI interactions
- ✅ Verifies platform-specific behavior
- ⚠️ Slower (requires device startup)

### Method 3: Web Testing

```powershell
flutter drive `
  --driver=test_driver/integration_test_driver.dart `
  --target=integration_test/edit_persistence_integration_test.dart `
  -d chrome
```

## Available Integration Tests

### edit_persistence_integration_test.dart

**Purpose:** Verifies that character weapon and equipment edits persist correctly across:
- Hive local storage
- Application state
- PDF export

**Test Cases:**
1. Create character and verify persistence
2. Edit weapons and verify persistence  
3. Multiple equipment edits persist correctly
4. PDF export uses latest persisted data

**Expected Results:**
- ✅ All edits saved to Hive
- ✅ Data reloads correctly after save
- ✅ PDF exports contain latest changes
- ✅ No data loss during navigation

## Writing New Integration Tests

### Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_application_4patrol/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('My Integration Test', () {
    setUpAll(() async {
      // Initialize services
    });

    tearDownAll(() async {
      // Clean up
    });

    testWidgets('Test scenario', (tester) async {
      // Your test code here
    });
  });
}
```

### Best Practices

1. **Use descriptive test names** that explain the scenario
2. **Clean up after tests** to avoid state pollution
3. **Use debugPrint()** for test output (visible in logs)
4. **Test real user workflows** not just individual functions
5. **Verify persistence** by reloading data after saves
6. **Handle async operations** properly with await

## Troubleshooting

### Issue: "No implementation found for method..."

**Solution:** Make sure you're using `flutter test integration_test/...` not `flutter test test/...`

### Issue: Tests timeout

**Solution:** 
- Increase timeout: `testWidgets('...', (tester) async { ... }, timeout: Timeout(Duration(minutes: 5)));`
- Check for infinite loops or blocked async operations

### Issue: Hive box already open

**Solution:**
```dart
setUpAll(() async {
  if (Hive.isBoxOpen('characters')) {
    await Hive.box('characters').close();
  }
  await Hive.openBox('characters');
});
```

### Issue: PDF generation fails in test

**Expected behavior** - PDF generation may not work in all test environments. Tests should handle gracefully:

```dart
try {
  final pdfPath = await PdfCharacterSheetService.exportCharacterSheet(char);
  expect(File(pdfPath).existsSync(), isTrue);
} catch (e) {
  debugPrint('PDF export skipped in test environment: $e');
  // Test continues - PDF functionality tested separately
}
```

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Run Integration Tests
  run: flutter test integration_test/
```

### Azure DevOps Example

```yaml
- script: flutter test integration_test/
  displayName: 'Run Integration Tests'
```

## Performance Considerations

Integration tests are slower than unit tests:
- Unit tests: ~100ms per test
- Integration tests: ~1-5s per test (with platform integration)
- Device tests: ~10-30s per test (with UI rendering)

**Recommendation:** 
- Use unit tests for business logic
- Use integration tests for critical user workflows
- Use device tests for platform-specific validation

## Migration from Unit Tests

If you have existing unit tests that fail with platform channel errors:

**Before (Unit Test):**
```dart
// test/my_test.dart
void main() {
  test('my test', () {
    // Fails: MissingPluginException
  });
}
```

**After (Integration Test):**
```dart
// integration_test/my_integration_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('my test', (tester) async {
    // Works: Platform channels available
  });
}
```

## Additional Resources

- [Flutter Integration Testing Docs](https://docs.flutter.dev/testing/integration-tests)
- [integration_test Package](https://pub.dev/packages/integration_test)
- [Testing Best Practices](https://docs.flutter.dev/testing/overview)
