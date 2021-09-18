import '../../dependency_injection.dart';
import '../options/options.dart';
import '../options/options_monitor.dart';
import '../shared/disposable.dart';
import 'log_level.dart';
import 'logger.dart';
import 'logger_factory_options.dart';
import 'logger_filter_options.dart';
import 'logger_information.dart';
import 'logger_provider.dart';
import 'logging_builder.dart'
    show LoggingServiceCollectionExtensions, ConfigureLoggingBuilder;

class _Logger extends Logger with LoggerMixin {}

/// Represents a type used to configure the logging system and
/// create instances of [Logger] from the registered [LoggerProvider]s.
class LoggerFactory implements Disposable {
  final Map<String, Logger> _loggers;
  final List<_ProviderRegistration> _providerRegistrations;
  // LoggerFactoryScopeProvider _scopeProvider;
  bool _isDisposed = false;
  late Disposable _changeTokenRegistration;
  LoggerFilterOptions? _filterOptions;
  LoggerFactoryOptions? _factoryOptions;

  LoggerFactory([
    Iterable<LoggerProvider>? providers,
    OptionsMonitor<LoggerFilterOptions>? filterOption,
    Options<LoggerFactoryOptions>? options,
  ])  : _loggers = <String, Logger>{},
        _providerRegistrations = <_ProviderRegistration>[] {
    _factoryOptions = options == null || options.value == null
        ? LoggerFactoryOptions()
        : options.value;

    if (providers != null) {
      for (var provider in providers) {
        _addProviderRegistration(provider, false);
      }
    }

    if (filterOption != null) {
      _changeTokenRegistration =
          filterOption.onChange((a, [b]) => _refreshFilters(a));
      _refreshFilters(filterOption.currentValue);
    }
  }

  void _refreshFilters(LoggerFilterOptions filterOptions) {
    _filterOptions = filterOptions;
    for (var registeredLogger in _loggers.entries) {
      var logger = registeredLogger.value;
    }
  }

  //factory LoggerFactory() => LoggerFactory._(List<LoggerProvider>.empty());

  /// Creates a new [Logger] instance.
  Logger createLogger(String categoryName) {
    var logger = _Logger();
    if (_loggers.containsKey(categoryName)) {
      return _loggers[categoryName] as Logger;
    } else {
      logger.loggers = _createLoggers(categoryName).toList();

      var messageLoggers = <MessageLogger>[];

      for (var loggerInformation in logger.loggers!) {
        messageLoggers.add(
          MessageLogger(
            loggerInformation.logger,
            loggerInformation.category,
            loggerInformation.providerType.toString(),
            LogLevel.trace,
            (a, b, c) => true,
          ),
        );
      }

      logger.messageLoggers = messageLoggers;

      _loggers[categoryName] = logger;
    }

    return logger;
  }

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
    // TODO: implement dispose
  }

  /// TODO: Check if loggerFactory could be null.s
  static LoggerFactory create(ConfigureLoggingBuilder configure) {
    var serviceCollection = ServiceCollection()..addLogging();
    var serviceProvider = serviceCollection.buildServiceProvider();
    var loggerfactory = serviceProvider.getService<LoggerFactory>();
    return _DisposingLoggerFactory(loggerfactory, serviceProvider,
        serviceProvider.getServices<LoggerProvider>());
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
  final ServiceProvider _serviceProvider;

  _DisposingLoggerFactory(
    LoggerFactory loggerFactory,
    ServiceProvider serviceProvider,
    Iterable<LoggerProvider> providerRegistrations,
  )   : _loggerFactory = loggerFactory,
        _serviceProvider = serviceProvider,
        super(providerRegistrations);

  @override
  void dispose() => _serviceProvider.dispose();

  @override
  Logger createLogger(String categoryName) =>
      _loggerFactory.createLogger(categoryName);

  @override
  void addProvider(LoggerProvider loggerProvider) =>
      _loggerFactory.addProvider(loggerProvider);
}
