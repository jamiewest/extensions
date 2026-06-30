@TestOn('browser')
library;

import 'package:extensions/dependency_injection.dart';
import 'package:extensions/http.dart';
import 'package:test/test.dart';

void main() {
  group('http on web', () {
    test('HTTP client factory services resolve', () {
      final provider =
          (ServiceCollection()..addHttpClient()).buildServiceProvider();

      final factory = provider.getRequiredService<HttpClientFactory>();

      expect(factory, isNotNull);
    });
  });
}
