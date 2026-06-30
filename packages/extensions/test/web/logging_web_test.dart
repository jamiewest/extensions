@TestOn('browser')
library;

import 'package:extensions/dependency_injection.dart';
import 'package:extensions/logging.dart';
import 'package:test/test.dart';

void main() {
  group('logging on web', () {
    test('debug and simple console logging resolve and log', () {
      final provider = (ServiceCollection()
            ..addLogging((logging) {
              logging
                ..setMinimumLevel(LogLevel.debug)
                ..addSimpleConsole()
                ..addDebug();
            }))
          .buildServiceProvider();

      final factory = provider.getRequiredService<LoggerFactory>();
      final logger = factory.createLogger('WebSmokeTest');

      expect(logger, isNotNull);
      expect(() => logger.logInformation('hello from web'), returnsNormally);
    });
  });
}
