import '../../configuration/configuration.dart';
import '../../options/configure_options.dart';
import '../log_level.dart';
import '../logger_filter_options.dart';
import '../logger_filter_rule.dart';

/// Loads logging configuration from [Configuration].
class LoggingConfiguration implements ConfigureOptions<LoggerFilterOptions> {
  final Configuration _configuration;

  /// Creates a new [LoggingConfiguration] that reads from the given
  /// [Configuration].
  LoggingConfiguration(Configuration configuration)
      : _configuration = configuration;

  @override
  void configure(LoggerFilterOptions options) {
    _loadRules(options, _configuration);
  }

  void _loadRules(LoggerFilterOptions options, Configuration configuration) {
    // Load global minimum level from "Logging:LogLevel:Default"
    var defaultLevel = _getLogLevel(
      configuration,
      'Logging:LogLevel:Default',
    );
    if (defaultLevel != null) {
      options.minLevel = defaultLevel;
    }

    // Load capture scopes setting
    var captureScopes = configuration['Logging:IncludeScopes'];
    if (captureScopes != null) {
      options.captureScopes = captureScopes.toLowerCase() == 'true';
    }

    // Load provider-specific settings
    // Format: Logging:<ProviderName>:LogLevel:<CategoryName>
    var loggingSection = configuration.getSection('Logging');
    var children = loggingSection.getChildren();

    for (var providerSection in children) {
      var providerName = providerSection.key;

      // Skip non-provider sections
      if (providerName == 'LogLevel' || providerName == 'IncludeScopes') {
        continue;
      }

      // Load provider-specific log levels
      var logLevelSection = providerSection.getSection('LogLevel');
      var logLevelChildren = logLevelSection.getChildren();

      for (var categorySection in logLevelChildren) {
        var category = categorySection.key;
        var level = _parseLogLevel(categorySection.value);

        if (level != null) {
          var categoryName = category == 'Default' ? null : category;

          options.rules.add(
            LoggerFilterRule(
              providerName,
              categoryName,
              level,
              null,
            ),
          );
        }
      }
    }

    // Also load category-specific settings from the global LogLevel section
    var globalLogLevelSection = loggingSection.getSection('LogLevel');
    var globalLogLevelChildren = globalLogLevelSection.getChildren();

    for (var categorySection in globalLogLevelChildren) {
      var category = categorySection.key;

      // Skip Default as we already handled it
      if (category == 'Default') {
        continue;
      }

      var level = _parseLogLevel(categorySection.value);
      if (level != null) {
        options.rules.add(
          LoggerFilterRule(
            null,
            category,
            level,
            null,
          ),
        );
      }
    }
  }

  LogLevel? _getLogLevel(Configuration configuration, String key) {
    var value = configuration[key];
    return _parseLogLevel(value);
  }

  LogLevel? _parseLogLevel(String? value) {
    if (value == null) {
      return null;
    }

    switch (value.toLowerCase()) {
      case 'trace':
        return LogLevel.trace;
      case 'debug':
        return LogLevel.debug;
      case 'information':
        return LogLevel.information;
      case 'warning':
        return LogLevel.warning;
      case 'error':
        return LogLevel.error;
      case 'critical':
        return LogLevel.critical;
      case 'none':
        return LogLevel.none;
      default:
        return null;
    }
  }
}
