//import 'package:extensions/hosting.dart' hide equals;

import 'package:extensions/src/common/enum.dart';
import 'package:extensions/src/dependency_injection/service_collection.dart';
import 'package:extensions/src/dependency_injection/service_collection_container_builder_extensions.dart';
import 'package:extensions/src/dependency_injection/service_provider_service_extensions.dart';
import 'package:extensions/src/diagnostics/meter_scope.dart';
import 'package:extensions/src/diagnostics/metrics_builder.dart';
import 'package:extensions/src/diagnostics/metrics_builder_extensions.dart';
import 'package:extensions/src/diagnostics/metrics_options.dart';
import 'package:extensions/src/options/options.dart';
import 'package:extensions/src/options/options_service_collection_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('MetricsBuilderExtensionsRulesTests', () {
    test('BuilderEnableMetricsAddsRule', () {
      void builderEnableMetricsAddsRule(String? meterName) {
        var services = ServiceCollection();
        services.addOptions<MetricsOptions>(() => MetricsOptions());
        var builder = _FakeBuilder(services);

        builder.enableMetrics(meterName: meterName);

        var container = services.buildServiceProvider();
        var options = container.getRequiredService<Options<MetricsOptions>>();
        var instance = options.value;
        var rule = instance!.rules.first;
        expect(rule.meterName, equals(meterName));
        expect(rule.instrumentName, isNull);
        expect(rule.ListenerName, isNull);
        expect(
          rule.scopes.hasFlag(MeterScope.local) ||
              rule.scopes.hasFlag(MeterScope.global),
          isTrue,
        );
        expect(rule.enable, isTrue);
      }

      builderEnableMetricsAddsRule(null);
      builderEnableMetricsAddsRule('');
      builderEnableMetricsAddsRule('*');
      builderEnableMetricsAddsRule('foo');
    });

    test('BuilderEnableMetricsWithAllParamsAddsRule', () {
      var services = ServiceCollection();
      services.addOptions<MetricsOptions>(() => MetricsOptions());
      var builder = _FakeBuilder(services);

      builder.enableMetrics(
        meterName: 'meter',
        instrumentName: 'instance',
        listenerName: 'listener',
        scopes: MeterScope.local.value,
      );

      var container = services.buildServiceProvider();
      var options = container.getRequiredService<Options<MetricsOptions>>();
      var instance = options.value;
      var rule = instance!.rules.first;
      expect(rule.meterName, equals('meter'));
      expect(rule.instrumentName, equals('instance'));
      expect(rule.ListenerName, equals('listener'));
      expect(
        rule.scopes.hasFlag(MeterScope.local),
        isTrue,
      );
      expect(rule.enable, isTrue);
    });

    test('OptionsEnableMetricsAddsRule', () {
      void optionsEnableMetricsAddsRule(String? meterName) {
        var services = ServiceCollection();
        services.configure<MetricsOptions>(
          () => MetricsOptions(),
          (options) => options.enableMetrics(
            meterName: meterName,
          ),
        );
        var builder = _FakeBuilder(services);

        builder.enableMetrics(meterName: meterName);

        var container = services.buildServiceProvider();
        var options = container.getRequiredService<Options<MetricsOptions>>();
        var instance = options.value;
        var rule = instance!.rules.first;
        expect(rule.meterName, equals(meterName));
        expect(rule.instrumentName, isNull);
        expect(rule.ListenerName, isNull);
        expect(
          rule.scopes.hasFlag(MeterScope.global) ||
              rule.scopes.hasFlag(MeterScope.global),
          isTrue,
        );
        expect(rule.enable, isTrue);
      }

      optionsEnableMetricsAddsRule(null);
      optionsEnableMetricsAddsRule('');
      optionsEnableMetricsAddsRule('*');
      optionsEnableMetricsAddsRule('foo');
    });

    test('OptionsEnableMetricsAllParamsAddsRule', () {
      var services = ServiceCollection();
      services.configure<MetricsOptions>(
        () => MetricsOptions(),
        (options) => options.enableMetrics(
          meterName: 'meter',
          instrumentName: 'instrument',
          listenerName: 'listener',
          scopes: MeterScope.global.value,
        ),
      );

      var container = services.buildServiceProvider();
      var options = container.getRequiredService<Options<MetricsOptions>>();
      var instance = options.value;
      var rule = instance!.rules.first;
      expect(rule.meterName, equals('meter'));
      expect(rule.instrumentName, equals('instrument'));
      expect(rule.ListenerName, equals('listener'));
      expect(
        rule.scopes.hasFlag(MeterScope.global),
        isTrue,
      );
      expect(rule.enable, isTrue);
    });

    test('BuilderDisableMetricsAddsRule', () {
      void builderDisableMetricsAddsRule(String? meterName) {
        var services = ServiceCollection();
        services.addOptions<MetricsOptions>(() => MetricsOptions());
        var builder = _FakeBuilder(services);

        builder.disableMetrics(meterName: meterName);

        var container = services.buildServiceProvider();
        var options = container.getRequiredService<Options<MetricsOptions>>();
        var instance = options.value;
        var rule = instance!.rules.first;
        expect(rule.meterName, equals(meterName));
        expect(rule.instrumentName, isNull);
        expect(rule.ListenerName, isNull);
        expect(
          rule.scopes.hasFlag(MeterScope.global) ||
              rule.scopes.hasFlag(MeterScope.global),
          isTrue,
        );
        expect(rule.enable, isFalse);
      }

      builderDisableMetricsAddsRule(null);
      builderDisableMetricsAddsRule('');
      builderDisableMetricsAddsRule('*');
      builderDisableMetricsAddsRule('foo');
    });

    test('BuilderDisableMetricsWithAllParamsAddsRule', () {
      var services = ServiceCollection();
      services.addOptions<MetricsOptions>(() => MetricsOptions());
      var builder = _FakeBuilder(services);

      builder.disableMetrics(
        meterName: 'meter',
        instrumentName: 'instance',
        listenerName: 'listener',
        scopes: MeterScope.local.value,
      );

      var container = services.buildServiceProvider();
      var options = container.getRequiredService<Options<MetricsOptions>>();
      var instance = options.value;
      var rule = instance!.rules.first;
      expect(rule.meterName, equals('meter'));
      expect(rule.instrumentName, equals('instance'));
      expect(rule.ListenerName, equals('listener'));
      expect(
        rule.scopes.hasFlag(MeterScope.local),
        isTrue,
      );
      expect(rule.enable, isFalse);
    });

    test('OptionsDisableMetricsAddsRule', () {
      void optionsDisableMetricsAddsRule(String? meterName) {
        var services = ServiceCollection();
        services.configure<MetricsOptions>(
          () => MetricsOptions(),
          (options) => options.disableMetrics(
            meterName: meterName,
          ),
        );
        var builder = _FakeBuilder(services);

        builder.enableMetrics(meterName: meterName);

        var container = services.buildServiceProvider();
        var options = container.getRequiredService<Options<MetricsOptions>>();
        var instance = options.value;
        var rule = instance!.rules.first;
        expect(rule.meterName, equals(meterName));
        expect(rule.instrumentName, isNull);
        expect(rule.ListenerName, isNull);
        expect(
          rule.scopes.hasFlag(MeterScope.global) ||
              rule.scopes.hasFlag(MeterScope.global),
          isTrue,
        );
        expect(rule.enable, isFalse);
      }

      optionsDisableMetricsAddsRule(null);
      optionsDisableMetricsAddsRule('');
      optionsDisableMetricsAddsRule('*');
      optionsDisableMetricsAddsRule('foo');
    });

    test('OptionsDisableMetricsAllParamsAddsRule', () {
      var services = ServiceCollection();
      services.configure<MetricsOptions>(
        () => MetricsOptions(),
        (options) => options.disableMetrics(
          meterName: 'meter',
          instrumentName: 'instrument',
          listenerName: 'listener',
          scopes: MeterScope.global.value,
        ),
      );

      var container = services.buildServiceProvider();
      var options = container.getRequiredService<Options<MetricsOptions>>();
      var instance = options.value;
      var rule = instance!.rules.first;
      expect(rule.meterName, equals('meter'));
      expect(rule.instrumentName, equals('instrument'));
      expect(rule.ListenerName, equals('listener'));
      expect(
        rule.scopes.hasFlag(MeterScope.global),
        isTrue,
      );
      expect(rule.enable, isFalse);
    });
  });
}

class _FakeBuilder implements MetricsBuilder {
  final ServiceCollection _services;

  const _FakeBuilder(ServiceCollection services) : _services = services;

  @override
  ServiceCollection get services => _services;
}
