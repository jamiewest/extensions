import '../dependency_injection/service_collection_service_extensions.dart';
import '../dependency_injection/service_descriptor.dart';
import '../options/configure_options.dart';
import 'log_level.dart';
import 'logger_factory_options.dart';
import 'logger_filter_options.dart';
import 'logger_provider.dart';
import 'logging_builder.dart';

typedef ConfigureLoggerFactoryOptions = void Function(
  LoggerFactoryOptions options,
);

/// Extension methods for setting up logging services in a [LoggingBuilder].
extension LoggingBuilderExtensions on LoggingBuilder {
  /// Sets a minimum [LogLevel] requirement for log messages to be logged.
  LoggingBuilder setMinimumLevel(LogLevel level) {
    services.add(
      ServiceDescriptor.singleton<ConfigureOptions<LoggerFilterOptions>>(
        instance: _DefaultLoggerLevelConfigureOptions(level),
      ),
    );
    return this;
  }

  /// Adds the given [LoggerProvider] to the [LoggingBuilder]
  LoggingBuilder addProvider(LoggerProvider provider) {
    services.addSingleton<LoggerProvider>(implementationInstance: provider);
    return this;
  }

  /// Removes all [LoggerProvider]s from `builder`.
  LoggingBuilder clearProviders() {
    services.removeWhere((service) => service.runtimeType == LoggerProvider);
    return this;
  }

  /// configure the `builder` with the [LoggerFactoryOptions].
  LoggingBuilder configure(ConfigureLoggerFactoryOptions action) {
    // services.configure(action);
    return this;
  }
}

class _DefaultLoggerLevelConfigureOptions
    extends ConfigureOptions<LoggerFilterOptions> {
  _DefaultLoggerLevelConfigureOptions(LogLevel level)
      : super((options) => options.minLevel = level);
}
