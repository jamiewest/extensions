import 'package:extensions/logging.dart';
import 'package:test/test.dart';

void main() {
  group('LoggerFactoryTest', () {
    test('CreateLogger_ThrowsAfterDisposed', () {
      var factory = LoggerFactory()..dispose();
      expect(() => factory.createLogger('d'), throwsException);
    });
  });
}
