import 'package:extensions/src/dependency_injection/service_collection.dart';
import 'package:extensions/src/dependency_injection/service_collection_container_builder_extensions.dart';
import 'package:extensions/src/dependency_injection/service_collection_service_extensions.dart';
import 'package:extensions/src/dependency_injection/service_provider_service_extensions.dart';
import 'package:extensions/src/options/configure_named_options.dart';
import 'package:extensions/src/options/configure_options.dart';
import 'package:extensions/src/options/options.dart';
import 'package:extensions/src/options/options_cache.dart';
import 'package:extensions/src/options/options_change_token_source.dart';
import 'package:extensions/src/options/options_factory.dart';
import 'package:extensions/src/options/options_monitor.dart';
import 'package:extensions/src/options/options_monitor_cache.dart';
import 'package:extensions/src/options/options_service_collection_extensions.dart';
import 'package:extensions/src/primitives/change_token.dart';
import 'package:test/test.dart';

import 'fake_change_token.dart';
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

      test('all registered onChange listeners are notified', () {
        var token = FakeChangeToken();
        var monitor = OptionsMonitor<FakeOptions>(
          FakeOptionsFactory(),
          [_FakeChangeTokenSource(token)],
          OptionsCache<FakeOptions>(FakeOptions.new),
        );

        var firstCount = 0;
        var secondCount = 0;
        monitor.onChange((FakeOptions options, [String? name]) => firstCount++);
        monitor
            .onChange((FakeOptions options, [String? name]) => secondCount++);

        token.invokeChangeCallback();

        expect(firstCount, 1);
        expect(secondCount, 1);
      });

      test('disposing one listener leaves the others active', () {
        var token = FakeChangeToken();
        var monitor = OptionsMonitor<FakeOptions>(
          FakeOptionsFactory(),
          [_FakeChangeTokenSource(token)],
          OptionsCache<FakeOptions>(FakeOptions.new),
        );

        var firstCount = 0;
        var secondCount = 0;
        var firstRegistration = monitor
            .onChange((FakeOptions options, [String? n]) => firstCount++);
        monitor.onChange((FakeOptions options, [String? n]) => secondCount++);

        firstRegistration?.dispose();
        token.invokeChangeCallback();

        expect(firstCount, 0);
        expect(secondCount, 1);
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

class _FakeChangeTokenSource implements OptionsChangeTokenSource<FakeOptions> {
  _FakeChangeTokenSource(this._token);

  final FakeChangeToken _token;

  @override
  ChangeToken getChangeToken() => _token;

  @override
  String get name => Options.defaultName;
}
