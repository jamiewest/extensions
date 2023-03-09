import 'package:extensions/dependency_injection.dart';
import 'package:extensions/options.dart';
import 'package:test/test.dart';

import 'fake_options.dart';

void main() {
  group('OptionsFactoryTest', () {
    test('CreateSupportsNames', () {
      var services = ServiceCollection()
        ..configure<FakeOptions>(
          FakeOptions.new,
          (options) => options.message = 'one',
          name: '1',
        )
        ..configure<FakeOptions>(
          FakeOptions.new,
          (options) => options.message = 'two',
          name: '2',
        );

      var sp = services.buildServiceProvider();
      var factory = sp.getRequiredService<OptionsFactory<FakeOptions>>();
      expect(factory.create('1').message, equals('one'));
      expect(factory.create('2').message, equals('two'));
    });

    test('NamesAreCaseSensitive', () {
      var services = ServiceCollection()
        ..configure<FakeOptions>(
          FakeOptions.new,
          (options) => options.message = 'UP',
          name: 'UP',
        )
        ..configure<FakeOptions>(
          FakeOptions.new,
          (options) => options.message = 'up',
          name: 'up',
        );

      var sp = services.buildServiceProvider();
      var factory = sp.getRequiredService<OptionsFactory<FakeOptions>>();
      expect(factory.create('UP').message, equals('UP'));
      expect(factory.create('up').message, equals('up'));
    });

    test('CanConfigureAllOptions', () {
      var services = ServiceCollection()
        ..configureAll<FakeOptions>(
          FakeOptions.new,
          (options) => options.message = 'Default',
        );

      var sp = services.buildServiceProvider();
      var factory = sp.getRequiredService<OptionsFactory<FakeOptions>>();
      expect(factory.create('1').message, equals('Default'));
      expect(factory.create(Options.defaultName).message, equals('Default'));
      expect(factory.create('2').message, equals('Default'));
    });
  });
}
