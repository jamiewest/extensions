import '../../dependency_injection.dart';
import '../dependency_injection/service_lookup/service_lookup.dart';
import '../options/options_monitor.dart';
import '../system/disposable.dart';
import '../system/exceptions/object_disposed_exception.dart';
import 'log_level.dart';
import 'logger.dart';
import 'logger_filter_options.dart';
import 'logger_information.dart';
import 'logger_mixin.dart';
import 'logger_provider.dart';
import 'logger_rule_selector.dart';
import 'logging_builder.dart'
    show ConfigureLoggingBuilder, LoggingServiceCollectionExtensions;

class StaticFilterOptionsMonitor
    implements OptionsMonitor<LoggerFilterOptions> {
  final LoggerFilterOptions _currentValue;

  StaticFilterOptionsMonitor(LoggerFilterOptions currentValue)
      : _currentValue = currentValue;

  @override
  Disposable? onChange(OnChangeListener<LoggerFilterOptions> listener) => null;

  @override
  LoggerFilterOptions get(String? name) => currentValue;

  @override
  LoggerFilterOptions get currentValue => _currentValue;

  @override
  void dispose() {}
}

class _Logger extends Logger with LoggerMixin {}

/// Represents a type used to configure the logging system and
/// create instances of [Logger] from the registered [LoggerProvider]s.
class LoggerFactory implements Disposable {
  final Map<String, Logger> _loggers = <String, Logger>{};
  final List<_ProviderRegistration> _providerRegistrations =
      <_ProviderRegistration>[];
  bool _disposed = false;
  Disposable? _changeTokenRegistration;
  LoggerFilterOptions? _filterOptions;
  //LoggerFactoryScopeProvider _scopeProvider;

  /// Creates a new [LoggerFactory] instance.
  LoggerFactory([
    Iterable<LoggerProvider>? providers,
    OptionsMonitor<LoggerFilterOptions>? filterOption,
  ]) {
    if (providers != null) {
      for (var provider in providers) {
        _addProviderRegistration(provider, false);
      }
    }

    if (filterOption == null) {
      _filterOptions =
          StaticFilterOptionsMonitor(LoggerFilterOptions()).currentValue;
    }

    if (filterOption != null) {
      _changeTokenRegistration =
          filterOption.onChange((a, [b]) => _refreshFilters(a));
      _refreshFilters(filterOption.currentValue);
    }
  }

  /// Creates new instance of [LoggerFactory] configured using provided
  /// [configure] delegate.
  static LoggerFactory create(ConfigureLoggingBuilder configure) {
    var serviceCollection = ServiceCollection()..addLogging(configure);
    var serviceProvider = serviceCollection.buildServiceProvider();
    var loggerFactory = serviceProvider.getRequiredService<LoggerFactory>();

    return _DisposingLoggerFactory(
      loggerFactory,
      serviceProvider as DefaultServiceProvider,
      (serviceProvider.getServices<LoggerProvider>() as List)
          .map((item) => item as LoggerProvider)
          .toList(),
    );
  }

  void _refreshFilters(LoggerFilterOptions filterOptions) {
    _filterOptions = filterOptions;
    for (var registeredLogger in _loggers.entries) {
      var logger = registeredLogger.value as _Logger;
      var (messageLoggers, scopeLoggers) = _applyFilters(logger.loggers!);
      logger
        ..messageLoggers = messageLoggers
        ..scopeLoggers = scopeLoggers;
    }
  }

  /// Creates a new [Logger] instance with the given [categoryName].
  Logger createLogger(String categoryName) {
    if (_checkDisposed()) {
      throw ObjectDisposedException(objectName: 'LoggerFactory');
    }

    var logger = _Logger();
    if (_loggers.containsKey(categoryName)) {
      return _loggers[categoryName] as Logger;
    } else {
      logger.loggers = _createLoggers(categoryName).toList();

      var (messageLoggers, scopeLoggers) = _applyFilters(logger.loggers!);
      logger
        ..messageLoggers = messageLoggers
        ..scopeLoggers = scopeLoggers;

      _loggers[categoryName] = logger;
    }

    return logger;
  }

  bool _checkDisposed() => _disposed;

  Iterable<LoggerInformation> _createLoggers(String categoryName) {
    var loggers = List.generate(
      _providerRegistrations.length,
      (index) => LoggerInformation(
        _providerRegistrations[index].provider,
        categoryName,
      ),
    );

    return loggers;
  }

  (List<MessageLogger>, List<ScopeLogger>) _applyFilters(
    List<LoggerInformation> loggers,
  ) {
    var messageLoggers = <MessageLogger>[];
    var scopeLoggers = _filterOptions!.captureScopes ? <ScopeLogger>[] : null;

    for (var loggerInformation in loggers) {
      var result = LoggerRuleSelector.select(
        _filterOptions!,
        loggerInformation.providerType,
        loggerInformation.category,
      );

      var minLevel = result.$1;
      if (minLevel != null) {
        if (minLevel.value > LogLevel.critical.value) {
          continue;
        }
      }

      var filter = result.$2;

      messageLoggers.add(
        MessageLogger(
          loggerInformation.logger,
          loggerInformation.category,
          loggerInformation.providerType.toString(),
          result.$1,
          filter,
        ),
      );

      if (!loggerInformation.externalScope) {
        scopeLoggers?.add(
          ScopeLogger(
            loggerInformation.logger,
            null,
          ),
        );
      }
    }

    // if (_scopeProvider != null) {

    // }

    return (
      messageLoggers,
      scopeLoggers ?? <ScopeLogger>[],
    );
  }

  /// Adds an [LoggerProvider] to the logging system.
  void addProvider(LoggerProvider provider) {
    _addProviderRegistration(provider, true);

    for (var existingLogger in _loggers.entries) {
      var logger = existingLogger.value as _Logger;
      var loggerInformation = logger.loggers;

      var newLoggerIndex = loggerInformation!.length;
      loggerInformation[newLoggerIndex] = LoggerInformation(
        provider,
        existingLogger.key,
      );
      logger.loggers = loggerInformation;

      var (messageLoggers, scopeLoggers) = _applyFilters(logger.loggers!);
      logger
        ..messageLoggers = messageLoggers
        ..scopeLoggers = scopeLoggers;
    }
  }

  void _addProviderRegistration(LoggerProvider provider, bool dispose) {
    _providerRegistrations.add(_ProviderRegistration(provider, dispose));

    // if (provider is SupportExternalScope) {
    //   if (_scopeProvider == null) {
    //     _scopeProvider = LoggerFactoryScopeProvider();

    //     (provider as SupportExternalScope).setScopeProvider(_scopeProvider);
    //   }
    // }
  }

  @override
  void dispose() {
    if (!_disposed) {
      _disposed = true;

      _changeTokenRegistration?.dispose();

      for (var registration in _providerRegistrations) {
        try {
          if (registration.shouldDispose) {
            registration.provider.dispose();
          }
          // ignore: empty_catches
        } catch (e) {
          // Swallow exceptions on dispose
        }
      }
    }
  }
}

class _ProviderRegistration {
  _ProviderRegistration(
    this.provider,
    this.shouldDispose,
  );

  final LoggerProvider provider;
  final bool shouldDispose;
}

class _DisposingLoggerFactory extends LoggerFactory {
  final LoggerFactory _loggerFactory;
  final DefaultServiceProvider _serviceProvider;

  _DisposingLoggerFactory(
    LoggerFactory loggerFactory,
    DefaultServiceProvider serviceProvider,
    Iterable<LoggerProvider> super.providerRegistrations,
  )   : _loggerFactory = loggerFactory,
        _serviceProvider = serviceProvider;

  @override
  void dispose() => _serviceProvider.dispose();

  @override
  Logger createLogger(String categoryName) =>
      _loggerFactory.createLogger(categoryName);

  @override
  void addProvider(LoggerProvider loggerProvider) =>
      _loggerFactory.addProvider(loggerProvider);
}
