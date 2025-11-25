import '../../dependency_injection.dart';
import '../options/configure_options.dart';
import '../options/options_monitor.dart';
import 'default_logger_level_configure_options.dart';
import 'log_level.dart';
import 'logger_factory.dart';
import 'logger_filter_options.dart';
import 'logger_provider.dart';

typedef ConfigureLoggingBuilder = void Function(LoggingBuilder builder);

/// An interface for configuring logging providers.
class LoggingBuilder {
  final ServiceCollection _services;

  // Private constructor to ensure that the builder is created internally.
  LoggingBuilder._(ServiceCollection services) : _services = services;

  /// Gets the [ServiceCollection] where Logging services are configured.
  ServiceCollection get services => _services;
}

/// Extension methods for setting up logging services in a [ServiceCollection].
extension LoggingServiceCollectionExtensions on ServiceCollection {
  /// Adds logging services to the specified [ServiceCollection].
  ServiceCollection addLogging([ConfigureLoggingBuilder? configure]) {
    tryAdd(ServiceDescriptor.singleton<LoggerFactory>(
      (services) => LoggerFactory(
        (services.getServices<LoggerProvider>() as List)
            .map((item) => item as LoggerProvider)
            .toList(),
        services.getService<OptionsMonitor<LoggerFilterOptions>>(),
      ),
    ));

    tryAddIterable(
      ServiceDescriptor.singletonInstance<
          ConfigureOptions<LoggerFilterOptions>>(
        DefaultLoggerLevelConfigureOptions(LogLevel.information),
      ),
    );

    if (configure != null) {
      configure(LoggingBuilder._(this));
    }

    return this;
  }
}
