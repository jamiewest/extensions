import 'package:extensions/logging.dart';
import 'package:test/test.dart';

void main() {
  group('NullLoggerFactoryTest', () {
    test('Create_GivesSameLogger', () {
      // Arrange
      var factory = NullLoggerFactory.instance;

      // Act
      var logger1 = factory.createLogger('Logger1');
      var logger2 = factory.createLogger('Logger2');

      // Assert
      expect(identical(logger1, logger2), equals(true));
    });
  });
}
