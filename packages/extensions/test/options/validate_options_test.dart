import 'package:extensions/dependency_injection.dart';
import 'package:extensions/options.dart';
import 'package:test/test.dart';

import 'fake_options.dart';

void main() {
  group('ValidateOptions', () {
    test('validates the instance whose name matches', () {
      var validate = ValidateOptions0<FakeOptions>(
        'A',
        (options) => false,
        'failed',
      );

      var result = validate.validate('A', FakeOptions());

      expect(result.failed, isTrue);
    });

    test('returns success when the matching instance passes validation', () {
      var validate = ValidateOptions0<FakeOptions>(
        'A',
        (options) => true,
        'failed',
      );

      var result = validate.validate('A', FakeOptions());

      expect(result.succeeded, isTrue);
    });

    test('skips instances whose name does not match', () {
      var validate = ValidateOptions0<FakeOptions>(
        'A',
        (options) => false,
        'failed',
      );

      var result = validate.validate('B', FakeOptions());

      expect(result.skipped, isTrue);
      expect(result.failed, isFalse);
    });

    test('a null configured name validates every named instance', () {
      var validate = ValidateOptions0<FakeOptions>(
        null,
        (options) => false,
        'failed',
      );

      expect(validate.validate('A', FakeOptions()).failed, isTrue);
      expect(validate.validate('B', FakeOptions()).failed, isTrue);
      expect(
        validate.validate(Options.defaultName, FakeOptions()).failed,
        isTrue,
      );
    });
  });

  group('OptionsFactory validation', () {
    test('a named validator only fails its own named instance', () {
      var services = ServiceCollection();
      services.addOptions<FakeOptions>(FakeOptions.new, name: '1').validate(
            (options) => false,
            'failed for 1',
          );

      var sp = services.buildServiceProvider();
      var factory = sp.getRequiredService<OptionsFactory<FakeOptions>>();

      expect(() => factory.create('1'), throwsA(isA<Exception>()));
      expect(() => factory.create('2'), returnsNormally);
    });
  });
}
