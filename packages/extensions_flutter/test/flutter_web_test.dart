@TestOn('browser')
library;

import 'package:extensions/file_providers.dart';
import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:file/memory.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('extensions_flutter on web', () {
    test('builds a default host and resolves the root widget', () {
      final builder = Host.createApplicationBuilder();
      builder.services.addFlutter(
        (flutter) => flutter.runApp(
          (_) => const Text('Root', textDirection: TextDirection.ltr),
        ),
      );

      final host = builder.build();
      final widget = host.services.getRequiredService<Widget>();

      expect(widget, isA<ServiceProviderScope>());
    });

    test('reads JSON config from a memory-backed file provider on web', () {
      final fs = MemoryFileSystem();
      fs.file('/app/appsettings.json')
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('{"AllowedHosts":"*"}');

      final config = (ConfigurationBuilder()
            ..setFileProvider(PhysicalFileProvider('/app', fileSystem: fs))
            ..addJsonFile('appsettings.json'))
          .build();

      expect(config['AllowedHosts'], '*');
    });
  });
}
