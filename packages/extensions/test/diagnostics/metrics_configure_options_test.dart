import 'package:extensions/configuration.dart';
import 'package:extensions/src/diagnostics/configuration/metrics_configure_options.dart';
import 'package:extensions/src/diagnostics/meter_scope.dart';
import 'package:extensions/src/diagnostics/metrics_options.dart';
import 'package:extensions/src/system/enum.dart';
import 'package:test/test.dart';

void main() {
  group('MetricsConfigureOptions', () {
    test('loads rules from configuration sections', () {
      final config = (ConfigurationBuilder()
            ..addInMemoryCollection([
              const MapEntry('EnabledMetrics:Default', 'true'),
              const MapEntry('EnabledMetrics:MyMeter:MyInstrument', 'false'),
              const MapEntry('EnabledMetrics:BadMeter', 'maybe'),
              const MapEntry(
                'ListenerA:EnabledGlobalMetrics:MyMeter',
                'true',
              ),
              const MapEntry(
                'ListenerA:EnabledLocalMetrics:MyMeter:Default',
                'false',
              ),
            ]))
          .build();

      final options = MetricsOptions();
      MetricsConfigureOptions(config).configure(options);

      expect(options.rules, hasLength(4));

      final defaultRule = options.rules.firstWhere(
        (rule) =>
            rule.meterName == null &&
            rule.instrumentName == null &&
            rule.listenerName == null,
      );
      expect(defaultRule.enable, isTrue);
      expect(
        defaultRule.scopes.hasFlag(MeterScope.global) &&
            defaultRule.scopes.hasFlag(MeterScope.local),
        isTrue,
      );

      final instrumentRule = options.rules.firstWhere(
        (rule) =>
            rule.meterName == 'MyMeter' &&
            rule.instrumentName == 'MyInstrument',
      );
      expect(instrumentRule.enable, isFalse);
      expect(
        instrumentRule.scopes.hasFlag(MeterScope.global) &&
            instrumentRule.scopes.hasFlag(MeterScope.local),
        isTrue,
      );

      final listenerGlobalRule = options.rules.firstWhere(
        (rule) =>
            rule.listenerName == 'ListenerA' &&
            rule.meterName == 'MyMeter' &&
            rule.instrumentName == null &&
            rule.scopes.hasFlag(MeterScope.global),
      );
      expect(listenerGlobalRule.enable, isTrue);
      expect(listenerGlobalRule.scopes.hasFlag(MeterScope.local), isFalse);

      final listenerLocalRule = options.rules.firstWhere(
        (rule) =>
            rule.listenerName == 'ListenerA' &&
            rule.meterName == 'MyMeter' &&
            rule.instrumentName == null &&
            rule.scopes.hasFlag(MeterScope.local),
      );
      expect(listenerLocalRule.enable, isFalse);
      expect(listenerLocalRule.scopes.hasFlag(MeterScope.global), isFalse);
    });

    test('ignores invalid boolean values', () {
      final config = (ConfigurationBuilder()
            ..addInMemoryCollection([
              const MapEntry('EnabledMetrics:MyMeter', 'not-bool'),
            ]))
          .build();

      final options = MetricsOptions();
      MetricsConfigureOptions(config).configure(options);

      expect(options.rules, isEmpty);
    });
  });
}
