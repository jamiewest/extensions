import '../../dependency_injection.dart';
import '../dependency_injection/service_collection.dart';
import 'logger_factory.dart';
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
  ServiceCollection addLogging([ConfigureLoggingBuilder? configure]) {
    tryAdd(ServiceDescriptor.singleton<LoggerFactory>(
      implementationFactory: (services) => LoggerFactory(
        services.getServices<LoggerProvider>(),
      ),
    ));
    if (configure != null) {
      configure(LoggingBuilder._(this));
    }

    return this;
  }
}
