import 'dart:async';
import 'dart:io' as io;

import 'package:extensions/file_providers.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late io.Directory tempDir;

  setUp(() {
    // Canonicalize so paths reported by the event watcher (which may resolve
    // symlinks such as macOS's /var -> /private/var) match the provider root.
    tempDir = io.Directory.systemTemp.createTempSync('watch_test_');
    tempDir = io.Directory(tempDir.resolveSymbolicLinksSync());
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('PhysicalFileProvider event-based watch (default options)', () {
    test('invokes change callback when a watched file is modified', () async {
      final filePath = p.join(tempDir.path, 'watched.txt');
      io.File(filePath).writeAsStringSync('v1');

      // Default options use the event-based watcher on the VM.
      final provider = PhysicalFileProvider(tempDir.path);
      addTearDown(provider.dispose);

      final token = provider.watch('watched.txt');
      final changed = Completer<void>();
      token.registerChangeCallback((_) {
        if (!changed.isCompleted) changed.complete();
      }, null);

      // Give the underlying watcher time to become ready before mutating.
      await Future<void>.delayed(const Duration(milliseconds: 800));

      // Write on an interval wider than the watcher's 200ms debounce so each
      // change is allowed to settle and emit, riding over watcher warm-up.
      var version = 2;
      Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (changed.isCompleted) {
          timer.cancel();
          return;
        }
        io.File(filePath).writeAsStringSync('v${version++}');
      });

      await changed.future.timeout(const Duration(seconds: 15));
      expect(token.hasChanged, isTrue);
    });
  });
}
