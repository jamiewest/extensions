import 'package:extensions/src/diagnostics/default_meter_factory.dart';
import 'package:extensions/src/diagnostics/system/meter_options.dart';
import 'package:extensions/src/system/exceptions/argument_null_exception.dart';
import 'package:extensions/src/system/exceptions/object_disposed_exception.dart';
import 'package:test/test.dart';

void main() {
  group('DefaultMeterFactory', () {
    test('returns cached meter for same name and version', () {
      final factory = DefaultMeterFactory();
      final first = factory.create(MeterOptions('meter')..version = '1.0');
      final second = factory.create(MeterOptions('meter')..version = '1.0');

      expect(identical(first, second), isTrue);
    });

    test('returns different meter for different version', () {
      final factory = DefaultMeterFactory();
      final first = factory.create(MeterOptions('meter')..version = '1.0');
      final second = factory.create(MeterOptions('meter')..version = '2.0');

      expect(identical(first, second), isFalse);
    });

    test('sets meter scope to factory when not provided', () {
      final factory = DefaultMeterFactory();
      final meter = factory.create(MeterOptions('meter'));

      expect(identical(meter.scope, factory), isTrue);
    });

    test('throws when options scope is not the factory', () {
      final factory = DefaultMeterFactory();
      final options = MeterOptions('meter')..scope = Object();

      expect(() => factory.create(options), throwsArgumentError);
    });

    test('throws after disposal', () {
      final factory = DefaultMeterFactory();
      factory.dispose();

      expect(
        () => factory.create(MeterOptions('meter')),
        throwsA(isA<ObjectDisposedException>()),
      );
    });
  });

  group('MeterOptions', () {
    test('throws when name set to null', () {
      final options = MeterOptions('initial');
      expect(
        () => options.name = null,
        throwsA(isA<ArgumentNullException>()),
      );
    });
  });
}
