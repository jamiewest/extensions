import 'dart:io' as io;

import 'package:extensions/primitives.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'mocks/mock_physical_files_watcher.dart';

void main() {
  late io.Directory tempDir;
  late MockPhysicalFilesWatcher watcher;

  setUp(() {
    tempDir = io.Directory.systemTemp.createTempSync('watcher_test_');
    watcher = MockPhysicalFilesWatcher(tempDir.path);
  });

  tearDown(() {
    watcher.dispose();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('PhysicalFilesWatcher - Token Creation', () {
    test('creates change token for file filter', () {
      final token = watcher.createFileChangeToken('test.txt');

      expect(token, isA<IChangeToken>());
      expect(token.activeChangeCallbacks, isFalse);
    });

    test('creates change token for wildcard pattern', () {
      final token = watcher.createFileChangeToken('*.txt');

      expect(token, isA<IChangeToken>());
      expect(token.activeChangeCallbacks, isFalse);
    });

    test('creates change token for double asterisk pattern', () {
      final token = watcher.createFileChangeToken('**/*.json');

      expect(token, isA<IChangeToken>());
    });

    test('multiple tokens can be created', () {
      final token1 = watcher.createFileChangeToken('*.txt');
      final token2 = watcher.createFileChangeToken('*.json');

      expect(token1, isA<IChangeToken>());
      expect(token2, isA<IChangeToken>());
    });
  });

  group('PhysicalFilesWatcher - Change Detection', () {
    test('token fires when change triggered', () {
      final token = watcher.createFileChangeToken('*.txt');

      var callbackFired = false;
      token.registerChangeCallback((_) {
        callbackFired = true;
      }, null);

      expect(token.hasChanged, isFalse);

      watcher.triggerChange('*.txt');

      expect(callbackFired, isTrue);
      expect(token.hasChanged, isTrue);
    });

    test('token does not fire for different pattern', () {
      final txtToken = watcher.createFileChangeToken('*.txt');
      final jsonToken = watcher.createFileChangeToken('*.json');

      var txtFired = false;
      var jsonFired = false;

      txtToken.registerChangeCallback((_) {
        txtFired = true;
      }, null);

      jsonToken.registerChangeCallback((_) {
        jsonFired = true;
      }, null);

      watcher.triggerChange('*.txt');

      expect(txtFired, isTrue);
      expect(jsonFired, isFalse);
    });

    test('multiple callbacks fire for same token', () {
      final token = watcher.createFileChangeToken('*.txt');

      var callback1Fired = false;
      var callback2Fired = false;

      token.registerChangeCallback((_) {
        callback1Fired = true;
      }, null);

      token.registerChangeCallback((_) {
        callback2Fired = true;
      }, null);

      watcher.triggerChange('*.txt');

      expect(callback1Fired, isTrue);
      expect(callback2Fired, isTrue);
    });

    test('callback receives correct state parameter', () {
      final token = watcher.createFileChangeToken('*.txt');

      Object? receivedState;
      token.registerChangeCallback((state) {
        receivedState = state;
      }, 'test-state');

      watcher.triggerChange('*.txt');

      expect(receivedState, equals('test-state'));
    });
  });

  group('PhysicalFilesWatcher - File Path Matching', () {
    test('triggerChangeForFile matches wildcard patterns', () {
      final token = watcher.createFileChangeToken('*.txt');

      var fired = false;
      token.registerChangeCallback((_) {
        fired = true;
      }, null);

      watcher.triggerChangeForFile('test.txt');

      expect(fired, isTrue);
    });

    test('triggerChangeForFile does not match wrong extension', () {
      final token = watcher.createFileChangeToken('*.txt');

      var fired = false;
      token.registerChangeCallback((_) {
        fired = true;
      }, null);

      watcher.triggerChangeForFile('test.json');

      expect(fired, isFalse);
    });

    test('triggerChangeForFile matches all patterns', () {
      final token = watcher.createFileChangeToken('**/*');

      var fired = false;
      token.registerChangeCallback((_) {
        fired = true;
      }, null);

      watcher.triggerChangeForFile('anything.xyz');

      expect(fired, isTrue);
    });
  });

  group('PhysicalFilesWatcher - Callback Registration', () {
    test('activeChangeCallbacks is true when callback registered', () {
      final token = watcher.createFileChangeToken('*.txt');

      expect(token.activeChangeCallbacks, isFalse);

      token.registerChangeCallback((_) {}, null);

      expect(token.activeChangeCallbacks, isTrue);
    });

    test('disposed callback does not fire', () {
      final token = watcher.createFileChangeToken('*.txt');

      var fired = false;
      final registration = token.registerChangeCallback((_) {
        fired = true;
      }, null);

      registration.dispose();

      watcher.triggerChange('*.txt');

      expect(fired, isFalse);
    });

    test('callback registered after change fires immediately', () {
      final token = watcher.createFileChangeToken('*.txt');

      watcher.triggerChange('*.txt');

      var fired = false;
      token.registerChangeCallback((_) {
        fired = true;
      }, null);

      // Should fire immediately since token already changed
      expect(fired, isTrue);
    });

    test('exception in one callback does not affect others', () {
      final token = watcher.createFileChangeToken('*.txt');

      var callback1Fired = false;
      var callback2Fired = false;

      token.registerChangeCallback((_) {
        callback1Fired = true;
        throw Exception('Test exception');
      }, null);

      token.registerChangeCallback((_) {
        callback2Fired = true;
      }, null);

      watcher.triggerChange('*.txt');

      expect(callback1Fired, isTrue);
      expect(callback2Fired, isTrue);
    });
  });

  group('PhysicalFilesWatcher - Multiple Tokens', () {
    test('same filter creates multiple independent tokens', () {
      final token1 = watcher.createFileChangeToken('*.txt');
      final token2 = watcher.createFileChangeToken('*.txt');

      var token1Fired = false;
      var token2Fired = false;

      token1.registerChangeCallback((_) {
        token1Fired = true;
      }, null);

      token2.registerChangeCallback((_) {
        token2Fired = true;
      }, null);

      watcher.triggerChange('*.txt');

      expect(token1Fired, isTrue);
      expect(token2Fired, isTrue);
    });

    test('different patterns fire independently', () {
      final txtToken = watcher.createFileChangeToken('*.txt');
      final mdToken = watcher.createFileChangeToken('*.md');

      var txtFired = false;
      var mdFired = false;

      txtToken.registerChangeCallback((_) {
        txtFired = true;
      }, null);

      mdToken.registerChangeCallback((_) {
        mdFired = true;
      }, null);

      watcher.triggerChange('*.txt');

      expect(txtFired, isTrue);
      expect(mdFired, isFalse);

      watcher.triggerChange('*.md');

      expect(mdFired, isTrue);
    });
  });

  group('PhysicalFilesWatcher - Token State', () {
    test('hasChanged is false before trigger', () {
      final token = watcher.createFileChangeToken('*.txt');

      expect(token.hasChanged, isFalse);
    });

    test('hasChanged is true after trigger', () {
      final token = watcher.createFileChangeToken('*.txt');

      watcher.triggerChange('*.txt');

      expect(token.hasChanged, isTrue);
    });

    test('token only fires once', () {
      final token = watcher.createFileChangeToken('*.txt');

      var fireCount = 0;
      token.registerChangeCallback((_) {
        fireCount++;
      }, null);

      watcher.triggerChange('*.txt');
      watcher.triggerChange('*.txt');
      watcher.triggerChange('*.txt');

      expect(fireCount, equals(1));
    });
  });

  group('PhysicalFilesWatcher - Disposal', () {
    test('dispose clears all tokens', () {
      final token = watcher.createFileChangeToken('*.txt');

      var fired = false;
      token.registerChangeCallback((_) {
        fired = true;
      }, null);

      watcher.dispose();

      // After disposal, triggering should not cause errors
      // but the token may not fire since watcher is disposed
      expect(() => watcher.triggerChange('*.txt'), returnsNormally);
    });

    test('can dispose multiple times safely', () {
      watcher.dispose();
      expect(() => watcher.dispose(), returnsNormally);
    });
  });

  group('PhysicalFilesWatcher - Edge Cases', () {
    test('handles empty filter', () {
      final token = watcher.createFileChangeToken('');

      expect(token, isA<IChangeToken>());
    });

    test('handles complex patterns', () {
      final patterns = [
        '*.txt',
        '**/*.json',
        'config/*.xml',
        'src/**/*.dart',
      ];

      for (final pattern in patterns) {
        final token = watcher.createFileChangeToken(pattern);
        expect(token, isA<IChangeToken>());
      }
    });

    test('handles special characters in filter', () {
      final token = watcher.createFileChangeToken('file-name_123.txt');

      expect(token, isA<IChangeToken>());
    });
  });
}
