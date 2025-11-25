import 'package:extensions/logging.dart';
import 'package:test/test.dart';

void main() {
  group('NullLoggerTest', () {
    test('IsEnabled_AlwaysFalse', () {
      // Arrange
      var logger = NullLogger.instance;

      // Act & Assert
      expect(logger.isEnabled(LogLevel.debug), equals(false));
      expect(logger.isEnabled(LogLevel.trace), equals(false));
      expect(logger.isEnabled(LogLevel.information), equals(false));
      expect(logger.isEnabled(LogLevel.warning), equals(false));
      expect(logger.isEnabled(LogLevel.error), equals(false));
      expect(logger.isEnabled(LogLevel.critical), equals(false));
    });

    test('Write_Does_Nothing', () {
      // Arrange
      var logger = NullLogger.instance;
      var isCalled = false;

      // Act
      logger.log(
        logLevel: LogLevel.trace,
        eventId: EventId.empty(),
        state: null,
        error: null,
        formatter: (ex, message) {
          isCalled = true;
          return '';
        },
      );

      // Assert
      expect(isCalled, equals(false));
    });
  });
}
