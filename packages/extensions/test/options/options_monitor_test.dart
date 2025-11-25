import 'package:extensions/src/dependency_injection/service_collection.dart';
import 'package:extensions/src/dependency_injection/service_collection_container_builder_extensions.dart';
import 'package:extensions/src/dependency_injection/service_collection_service_extensions.dart';
import 'package:extensions/src/dependency_injection/service_provider_service_extensions.dart';
import 'package:extensions/src/options/configure_named_options.dart';
import 'package:extensions/src/options/configure_options.dart';
import 'package:extensions/src/options/options.dart';
import 'package:extensions/src/options/options_factory.dart';
import 'package:extensions/src/options/options_monitor.dart';
import 'package:extensions/src/options/options_monitor_cache.dart';
import 'package:extensions/src/options/options_service_collection_extensions.dart';
import 'package:test/test.dart';

import 'fake_options.dart';
import 'fake_options_factory.dart';

void main() {
  OptionsMonitorTest().run();
}

class OptionsMonitorTest {
  void run() {
    group('OptionsMonitorTest', () {
      test('MonitorUsesFactory', () {
        var services = ServiceCollection()
            .addSingleton<OptionsFactory<FakeOptions>>(
              (sp) => FakeOptionsFactory(),
            )
            .configure<FakeOptions>(
              FakeOptions.new,
              (options) => options.message = 'Ignored',
            )
            .buildServiceProvider();

        var monitor =
            services.getRequiredService<OptionsMonitor<FakeOptions>>();
        expect(monitor.currentValue, equals(FakeOptionsFactory.options));
        expect(monitor.get('1'), equals(FakeOptionsFactory.options));
        expect(monitor.get('bsdfsdf'), equals(FakeOptionsFactory.options));
      });

      test('CanClearNamedOptions', () {
        var services = ServiceCollection()
          ..addOptions<FakeOptions>(FakeOptions.new)
          ..addSingleton<ConfigureOptions<FakeOptions>>(
            (sp) => _CountIncrement(this),
          );
        var sp = services.buildServiceProvider();

        var monitor = sp.getRequiredService<OptionsMonitor<FakeOptions>>();
        var cache = sp.getRequiredService<OptionsMonitorCache<FakeOptions>>();

        expect(monitor.get('#1').message, '1');
        expect(monitor.get('#2').message, '2');
        expect(monitor.get('#1').message, '1');
        expect(monitor.get('#2').message, '2');

        cache.clear();

        expect(monitor.get('#1').message, '3');
        expect(monitor.get('#2').message, '4');
        expect(monitor.get('#1').message, '3');
        expect(monitor.get('#2').message, '4');

        cache.clear();

        expect(monitor.get('#1').message, '5');
        expect(monitor.get('#2').message, '6');
        expect(monitor.get('#1').message, '5');
        expect(monitor.get('#2').message, '6');
      });
    });
  }

  int? setupInvokeCount;
}

class _CountIncrement implements ConfigureNamedOptions<FakeOptions> {
  final OptionsMonitorTest? _test;

  _CountIncrement(this._test);

  @override
  void configure(FakeOptions options) => configureNamed(
        Options.defaultName,
        options,
      );

  @override
  void configureNamed(String name, FakeOptions options) {
    _test!.setupInvokeCount = (_test.setupInvokeCount ?? 0) + 1;
    options.message += (_test.setupInvokeCount ?? 0).toString();
  }
}
