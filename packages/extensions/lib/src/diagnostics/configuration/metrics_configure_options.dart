import '../../configuration/configuration.dart';
import '../../configuration/configuration_section.dart';
import '../../options/configure_options.dart';
import '../instrument_rule.dart';
import '../meter_scope.dart';
import '../metrics_options.dart';

class MetricsConfigureOptions implements ConfigureOptions<MetricsOptions> {
  static const String enabledMetricsKey = 'EnabledMetrics';
  static const String enabledGlobalMetricsKey = 'EnabledGlobalMetrics';
  static const String enabledLocalMetricsKey = 'EnabledLocalMetrics';
  static const String defaultKey = 'Default';

  final Configuration _configuration;

  MetricsConfigureOptions(this._configuration);

  @override
  void configure(MetricsOptions options) => _loadConfig(options);

  void _loadConfig(MetricsOptions options) {
    // Process each section in configuration
    for (final section in _configuration.getChildren()) {
      final listenerName = section.key;

      // Check for default configuration keys (apply to all listeners)
      if (listenerName == enabledMetricsKey ||
          listenerName == enabledGlobalMetricsKey ||
          listenerName == enabledLocalMetricsKey) {
        _loadRules(
          section,
          null,
          _getScopeFromKey(listenerName),
          options,
        );
      } else {
        // Process listener-specific configuration
        final metricsSection = section.getSection(enabledMetricsKey);
        final globalMetricsSection =
            section.getSection(enabledGlobalMetricsKey);
        final localMetricsSection = section.getSection(enabledLocalMetricsKey);

        if (_sectionExists(metricsSection)) {
          _loadRules(
            metricsSection,
            listenerName,
            MeterScope.global.value | MeterScope.local.value,
            options,
          );
        }

        if (_sectionExists(globalMetricsSection)) {
          _loadRules(
            globalMetricsSection,
            listenerName,
            MeterScope.global.value,
            options,
          );
        }

        if (_sectionExists(localMetricsSection)) {
          _loadRules(
            localMetricsSection,
            listenerName,
            MeterScope.local.value,
            options,
          );
        }
      }
    }
  }

  bool _sectionExists(IConfigurationSection section) =>
      section.value != null || section.getChildren().isNotEmpty;

  int _getScopeFromKey(String key) {
    if (key == enabledGlobalMetricsKey) {
      return MeterScope.global.value;
    } else if (key == enabledLocalMetricsKey) {
      return MeterScope.local.value;
    } else {
      return MeterScope.global.value | MeterScope.local.value;
    }
  }

  void _loadRules(
    Configuration meterSection,
    String? listenerName,
    int scopes,
    MetricsOptions options,
  ) {
    // Process each meter configuration
    for (final meterConfig in meterSection.getChildren()) {
      final meterName =
          meterConfig.key.toLowerCase() == defaultKey.toLowerCase()
              ? null
              : meterConfig.key;

      // Check if meter config is a simple boolean
      final meterValue = meterConfig.value;
      if (meterValue != null) {
        final enable = _parseBoolean(meterValue);
        if (enable != null) {
          options.rules.add(
            InstrumentRule(
              meterName: meterName,
              instrumentName: null,
              listenerName: listenerName,
              scopes: scopes,
              enable: enable,
            ),
          );
          continue;
        }
      }

      // Process instrument configurations within meter
      for (final instrumentConfig in meterConfig.getChildren()) {
        final instrumentName =
            instrumentConfig.key.toLowerCase() == defaultKey.toLowerCase()
                ? null
                : instrumentConfig.key;

        final instrumentValue = instrumentConfig.value;
        if (instrumentValue != null) {
          final enable = _parseBoolean(instrumentValue);
          if (enable != null) {
            options.rules.add(
              InstrumentRule(
                meterName: meterName,
                instrumentName: instrumentName,
                listenerName: listenerName,
                scopes: scopes,
                enable: enable,
              ),
            );
          }
        }
      }
    }
  }

  bool? _parseBoolean(String value) {
    final lowerValue = value.toLowerCase();
    if (lowerValue == 'true') return true;
    if (lowerValue == 'false') return false;
    return null;
  }
}
