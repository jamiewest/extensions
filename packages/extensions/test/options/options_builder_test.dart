import 'package:extensions/configuration.dart';
import 'package:extensions/dependency_injection.dart';
import 'package:extensions/options.dart';
import 'package:test/test.dart';

import 'fake_options.dart';

void main() {
  group('OptionsBuilderTest', () {
    test('CanSupportDefaultName', () {
      var services = ServiceCollection();
      var dic = <String, String>{'Message': '!'};

      var config =
          ConfigurationBuilder().addInMemoryCollection(dic.entries).build();

      var builder = services.addOptions<FakeOptions>(FakeOptions.new);

      builder
          .configure(
            (options) =>
                options.message = '${options.message}${config['Message']}',
          )
          .postConfigure((options) => options.message = '${options.message}]')
          .configure((options) => options.message = '${options.message}[')
          .configure(
              (options) => options.message = '${options.message}Default');

      var sp = services.buildServiceProvider();
      var factory = sp.getRequiredService<OptionsFactory<FakeOptions>>();
      expect(factory.create(Options.defaultName).message, equals('![Default]'));
    });
  });

  test('CanSupportNamedOptions', () {
    var services = ServiceCollection();
    var dic = <String, String>{'Message': '!'};

    var config =
        ConfigurationBuilder().addInMemoryCollection(dic.entries).build();

    var builder1 = services.addOptions<FakeOptions>(
      FakeOptions.new,
      name: '1',
    );

    var builder2 = services.addOptions<FakeOptions>(
      FakeOptions.new,
      name: '2',
    );

    builder1
        .configure((options) => options.message = config['Message']!)
        .postConfigure((options) => options.message = '${options.message}]')
        .configure((options) => options.message = '${options.message}[')
        .configure((options) => options.message = '${options.message}one');

    builder2
        .configure((options) => options.message = config['Message']!)
        .postConfigure((options) => options.message = '${options.message}>')
        .configure((options) => options.message = '${options.message}<')
        .configure((options) => options.message = '${options.message}two');

    var sp = services.buildServiceProvider();
    var factory = sp.getRequiredService<OptionsFactory<FakeOptions>>();

    expect(factory.create('1').message, equals('![one]'));
    expect(factory.create('2').message, equals('!<two>'));
  });

  test('CanMixConfigureCallsOutsideBuilderInOrder', () {
    // var services = ServiceCollection();
    // var builder = services.addOptions<FakeOptions>(
    //   FakeOptions.new,
    //   name: '1',
    // );
  });
}
