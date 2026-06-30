@TestOn('browser')
library;

import 'package:extensions/configuration.dart';
import 'package:extensions/dependency_injection.dart';
import 'package:extensions/hosting.dart';
import 'package:test/test.dart';

void main() {
  group('hosting on web', () {
    test('builds a default host without throwing', () {
      final builder = Host.createApplicationBuilder();
      final host = builder.build();

      expect(host, isNotNull);
    });

    test('default host exposes a resolvable Configuration', () {
      final host = Host.createApplicationBuilder().build();

      final configuration = host.services.getRequiredService<Configuration>();

      expect(configuration, isNotNull);
    });
  });
}
