import 'package:extensions/src/options/options_service_collection_extensions.dart';

import '../../dependency_injection.dart';
import '../dependency_injection/service_collection.dart';
import '../options/configure_options.dart';
import '../options/options_monitor.dart';
import 'log_level.dart';
import 'logger_factory.dart';
import 'logger_filter_options.dart';
import 'logger_provider.dart';

/// An interface for configuring logging providers.
class LoggingBuilder {
  final ServiceCollection _services;

  // Private constructor to ensure that the builder is created internally.
  LoggingBuilder._(ServiceCollection services) : _services = services;

  /// Gets the [ServiceCollection] where Logging services are configured.
  ServiceCollection get services => _services;
}

typedef ConfigureLoggingBuilder = void Function(LoggingBuilder builder);

/// Extension methods for setting up logging services in a [ServiceCollection].
extension LoggingServiceCollectionExtensions on ServiceCollection {
  /// Adds logging services to the specified [ServiceCollection].
  ServiceCollection addLogging([ConfigureLoggingBuilder? configure1]) {
    // addOptions<LoggerFilterOptions>(
    //   () => LoggerFilterOptions(),
    // );

    configure<LoggerFilterOptions>(() => LoggerFilterOptions(), (options) {
      //options.minLevel = LogLevel.information;
    });

    tryAdd(ServiceDescriptor.singleton<LoggerFactory>(
      implementationFactory: (services) => LoggerFactory(
        services.getServices<LoggerProvider>(),
        services.getService<OptionsMonitor<LoggerFilterOptions>>(),
      ),
    ));

    tryAddIterable(
      ServiceDescriptor.singleton<ConfigureOptions<LoggerFilterOptions>>(
        instance: _DefaultLoggerLevelConfigureOptions(LogLevel.information),
      ),
    );

    if (configure1 != null) {
      configure1(LoggingBuilder._(this));
    }

    return this;
  }
}

class _DefaultLoggerLevelConfigureOptions
    extends ConfigureOptionsBase<LoggerFilterOptions> {
  _DefaultLoggerLevelConfigureOptions(
    LogLevel level,
  ) : super((options) => options.minLevel = level);
}
