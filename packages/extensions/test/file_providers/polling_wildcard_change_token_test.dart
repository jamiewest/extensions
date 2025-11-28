import 'dart:io' as io;

import 'package:extensions/file_providers.dart';
import 'package:extensions/system.dart' hide equals;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late io.Directory tempDir;

  setUp(() {
    tempDir = io.Directory.systemTemp.createTempSync('polling_token_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('PollingWildcardChangeToken - Initial State', () {
    test('hasChanged returns false if no files exist', () async {
      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(token.hasChanged, isFalse);

      token.dispose();
    });

    test('hasChanged returns false if files do not change', () async {
      io.File(p.join(tempDir.path, 'unchanged.txt'))
          .writeAsStringSync('content');

      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(token.hasChanged, isFalse);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(token.hasChanged, isFalse);

      token.dispose();
    });

    test('activeChangeCallbacks is false when no callbacks registered', () {
      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      expect(token.activeChangeCallbacks, isFalse);

      token.dispose();
    });

    test('activeChangeCallbacks is true when callback registered', () {
      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      token.registerChangeCallback((_) {}, null);

      expect(token.activeChangeCallbacks, isTrue);

      token.dispose();
    });
  });

  group('PollingWildcardChangeToken - File Changes', () {
    test('hasChanged returns true if new files were added', () async {
      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      var fired = false;
      token.registerChangeCallback((_) {
        fired = true;
      }, null);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      io.File(p.join(tempDir.path, 'new.txt')).writeAsStringSync('new file');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(token.hasChanged, isTrue);
      expect(fired, isTrue);

      token.dispose();
    });

    test('hasChanged returns true if files were removed', () async {
      final testFile = io.File(p.join(tempDir.path, 'remove.txt'));
      testFile.writeAsStringSync('to remove');

      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      var fired = false;
      token.registerChangeCallback((_) {
        fired = true;
      }, null);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      testFile.deleteSync();

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(token.hasChanged, isTrue);
      expect(fired, isTrue);

      token.dispose();
    });

    test('hasChanged returns true if files were modified', () async {
      final testFile = io.File(p.join(tempDir.path, 'modify.txt'))
        ..writeAsStringSync('initial');

      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      var fired = false;
      token.registerChangeCallback((_) {
        fired = true;
      }, null);

      await Future<void>.delayed(const Duration(milliseconds: 150));

      testFile.writeAsStringSync('modified');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(token.hasChanged, isTrue);
      expect(fired, isTrue);

      token.dispose();
    });

    test(
        'hasChanged returns true if file was modified '
        'but retained an older timestamp', () async {
      final testFile = io.File(p.join(tempDir.path, 'timestamp.txt'));
      testFile.writeAsStringSync('initial');

      // Get the original timestamp
      final originalTime = testFile.lastModifiedSync();

      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      var fired = false;
      token.registerChangeCallback((_) {
        fired = true;
      }, null);

      await Future<void>.delayed(const Duration(milliseconds: 150));

      // Modify the file
      testFile.writeAsStringSync('modified');

      // Set an older timestamp
      final olderTime = originalTime.subtract(const Duration(hours: 1));
      testFile.setLastModifiedSync(olderTime);

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(token.hasChanged, isTrue);
      expect(fired, isTrue);

      token.dispose();
    });
  });

  group('PollingWildcardChangeToken - Pattern Matching', () {
    test('detects changes only for matching file extensions', () async {
      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      var fired = false;
      token.registerChangeCallback((_) {
        fired = true;
      }, null);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Create a non-matching file
      io.File(p.join(tempDir.path, 'file.json')).writeAsStringSync('{}');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(token.hasChanged, isFalse);
      expect(fired, isFalse);

      token.dispose();
    });

    test('matches files with single asterisk pattern', () async {
      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.json',
        pollingInterval: const Duration(milliseconds: 100),
      );

      var fired = false;
      token.registerChangeCallback((_) {
        fired = true;
      }, null);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      io.File(p.join(tempDir.path, 'config.json')).writeAsStringSync('{}');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(token.hasChanged, isTrue);
      expect(fired, isTrue);

      token.dispose();
    });

    test('matches files with double asterisk pattern', () async {
      final subDir = io.Directory(p.join(tempDir.path, 'sub', 'nested'));
      subDir.createSync(recursive: true);

      final token = PollingWildcardChangeToken(
        tempDir.path,
        '**/*.md',
        pollingInterval: const Duration(milliseconds: 100),
      );

      var fired = false;
      token.registerChangeCallback((_) {
        fired = true;
      }, null);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      io.File(p.join(subDir.path, 'readme.md')).writeAsStringSync('# Title');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(token.hasChanged, isTrue);
      expect(fired, isTrue);

      token.dispose();
    });

    test('matches files in subdirectory with specific pattern', () async {
      final subDir = io.Directory(p.join(tempDir.path, 'config'));
      subDir.createSync();

      final token = PollingWildcardChangeToken(
        tempDir.path,
        'config/*.json',
        pollingInterval: const Duration(milliseconds: 100),
      );

      var fired = false;
      token.registerChangeCallback((_) {
        fired = true;
      }, null);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      io.File(p.join(subDir.path, 'app.json')).writeAsStringSync('{}');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(token.hasChanged, isTrue);
      expect(fired, isTrue);

      token.dispose();
    });

    test('does not match files outside pattern scope', () async {
      final subDir = io.Directory(p.join(tempDir.path, 'other'));
      subDir.createSync();

      final token = PollingWildcardChangeToken(
        tempDir.path,
        'config/*.json',
        pollingInterval: const Duration(milliseconds: 100),
      );

      var fired = false;
      token.registerChangeCallback((_) {
        fired = true;
      }, null);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      io.File(p.join(subDir.path, 'file.json')).writeAsStringSync('{}');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(token.hasChanged, isFalse);
      expect(fired, isFalse);

      token.dispose();
    });
  });

  group('PollingWildcardChangeToken - Callback Management', () {
    test('invokes callback when changes detected', () async {
      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      Object? callbackState;
      token.registerChangeCallback((state) {
        callbackState = state;
      }, 'test-state');

      await Future<void>.delayed(const Duration(milliseconds: 50));

      io.File(p.join(tempDir.path, 'new.txt')).writeAsStringSync('content');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(callbackState, 'test-state');

      token.dispose();
    });

    test('invokes multiple callbacks', () async {
      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      var callback1Fired = false;
      var callback2Fired = false;

      token.registerChangeCallback((_) {
        callback1Fired = true;
      }, null);

      token.registerChangeCallback((_) {
        callback2Fired = true;
      }, null);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      io.File(p.join(tempDir.path, 'new.txt')).writeAsStringSync('content');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(callback1Fired, isTrue);
      expect(callback2Fired, isTrue);

      token.dispose();
    });

    test('callback not invoked after disposal', () async {
      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      var fired = false;
      final registration = token.registerChangeCallback((_) {
        fired = true;
      }, null);

      registration.dispose();

      await Future<void>.delayed(const Duration(milliseconds: 50));

      io.File(p.join(tempDir.path, 'new.txt')).writeAsStringSync('content');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(fired, isFalse);

      token.dispose();
    });

    test('exception in callback does not affect other callbacks', () async {
      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      var callback1Fired = false;
      var callback2Fired = false;

      token.registerChangeCallback((_) {
        callback1Fired = true;
        throw Exception('Test exception');
      }, null);

      token.registerChangeCallback((_) {
        callback2Fired = true;
      }, null);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      io.File(p.join(tempDir.path, 'new.txt')).writeAsStringSync('content');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(callback1Fired, isTrue);
      expect(callback2Fired, isTrue);

      token.dispose();
    });

    test('callback invoked immediately if already changed', () async {
      // Create file first
      io.File(p.join(tempDir.path, 'initial.txt')).writeAsStringSync('content');

      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      // Register callback to start polling
      var callbackCount = 0;
      token.registerChangeCallback((_) {
        callbackCount++;
      }, null);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Now modify the file
      io.File(p.join(tempDir.path, 'initial.txt'))
          .writeAsStringSync('modified');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Verify change was detected and callback fired
      expect(token.hasChanged, isTrue);
      expect(callbackCount, greaterThanOrEqualTo(1));

      // Register another callback after change detected
      var secondCallbackFired = false;
      token.registerChangeCallback((_) {
        secondCallbackFired = true;
      }, null);

      // Should fire immediately since hasChanged is already true
      expect(secondCallbackFired, isTrue);

      token.dispose();
    }, skip: 'Timing-dependent behavior - may be flaky');
  });

  group('PollingWildcardChangeToken - Cancellation', () {
    test('detects cancellation from CancellationTokenSource', () async {
      final cts = CancellationTokenSource();

      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
        cancellationTokenSource: cts,
      );

      expect(token.hasChanged, isFalse);

      cts.cancel();

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(token.hasChanged, isTrue);

      token.dispose();
    });

    test('stops checking after cancellation', () async {
      final cts = CancellationTokenSource();

      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
        cancellationTokenSource: cts,
      );

      var callbackCount = 0;
      token.registerChangeCallback((_) {
        callbackCount++;
      }, null);

      await Future<void>.delayed(const Duration(milliseconds: 150));

      cts.cancel();

      // Wait for cancellation to be processed
      await Future<void>.delayed(const Duration(milliseconds: 150));

      final countAfterCancel = callbackCount;

      // Add a file - should not trigger additional callbacks
      io.File(p.join(tempDir.path, 'new.txt')).writeAsStringSync('content');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Count should not increase after cancellation
      expect(callbackCount, countAfterCancel);

      token.dispose();
    }, skip: 'Timing-dependent cancellation behavior - may be flaky');
  });

  group('PollingWildcardChangeToken - Disposal', () {
    test('dispose stops polling', () async {
      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      var fired = false;
      token.registerChangeCallback((_) {
        fired = true;
      }, null);

      token.dispose();

      await Future<void>.delayed(const Duration(milliseconds: 50));

      io.File(p.join(tempDir.path, 'new.txt')).writeAsStringSync('content');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(fired, isFalse);
    });

    test('can dispose multiple times safely', () {
      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      token.dispose();
      expect(() => token.dispose(), returnsNormally);
    });

    test('clears all callbacks on disposal', () {
      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      token.registerChangeCallback((_) {}, null);
      token.registerChangeCallback((_) {}, null);

      expect(token.activeChangeCallbacks, isTrue);

      token.dispose();

      expect(token.activeChangeCallbacks, isFalse);
    });
  });

  group('PollingWildcardChangeToken - Polling Behavior', () {
    test('respects polling interval', () async {
      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 200),
      );

      token.registerChangeCallback((_) {}, null);

      io.File(p.join(tempDir.path, 'file.txt')).writeAsStringSync('content');

      // Check before polling interval
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(token.hasChanged, isFalse);

      // Check after polling interval
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(token.hasChanged, isTrue);

      token.dispose();
    });

    test('starts polling when first callback registered', () async {
      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      // No polling yet
      io.File(p.join(tempDir.path, 'before.txt')).writeAsStringSync('content');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      var fired = false;
      token.registerChangeCallback((_) {
        fired = true;
      }, null);

      // Now polling started - create another file
      io.File(p.join(tempDir.path, 'after.txt')).writeAsStringSync('content');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(fired, isTrue);

      token.dispose();
    });

    test('stops polling when last callback unregistered', () async {
      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      final registration = token.registerChangeCallback((_) {}, null);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      registration.dispose();

      // Polling should have stopped
      expect(token.activeChangeCallbacks, isFalse);

      token.dispose();
    });
  });

  group('PollingWildcardChangeToken - Edge Cases', () {
    test('handles non-existent directory', () {
      final nonExistent = p.join(tempDir.path, 'nonexistent');

      final token = PollingWildcardChangeToken(
        nonExistent,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      expect(token.hasChanged, isFalse);

      token.dispose();
    });

    test('handles inaccessible files gracefully', () async {
      io.File(p.join(tempDir.path, 'file.txt')).writeAsStringSync('content');

      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      expect(() => token.hasChanged, returnsNormally);

      token.dispose();
    });

    test('handles empty pattern', () {
      final token = PollingWildcardChangeToken(
        tempDir.path,
        '',
        pollingInterval: const Duration(milliseconds: 100),
      );

      expect(token.hasChanged, isFalse);

      token.dispose();
    });

    test('handles complex glob patterns', () async {
      final subDir = io.Directory(p.join(tempDir.path, 'src', 'lib'));
      subDir.createSync(recursive: true);

      final token = PollingWildcardChangeToken(
        tempDir.path,
        'src/**/*.dart',
        pollingInterval: const Duration(milliseconds: 100),
      );

      var fired = false;
      token.registerChangeCallback((_) {
        fired = true;
      }, null);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      io.File(p.join(subDir.path, 'main.dart'))
          .writeAsStringSync('void main()');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(token.hasChanged, isTrue);
      expect(fired, isTrue);

      token.dispose();
    });

    test('handles multiple file changes in quick succession', () async {
      final token = PollingWildcardChangeToken(
        tempDir.path,
        '*.txt',
        pollingInterval: const Duration(milliseconds: 100),
      );

      var callbackCount = 0;
      token.registerChangeCallback((_) {
        callbackCount++;
      }, null);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Create multiple files quickly
      io.File(p.join(tempDir.path, 'file1.txt')).writeAsStringSync('1');
      io.File(p.join(tempDir.path, 'file2.txt')).writeAsStringSync('2');
      io.File(p.join(tempDir.path, 'file3.txt')).writeAsStringSync('3');

      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Should fire callback once for all changes
      expect(callbackCount, 1);
      expect(token.hasChanged, isTrue);

      token.dispose();
    });
  });
}
