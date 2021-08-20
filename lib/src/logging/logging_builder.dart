import '../dependency_injection/service_collection.dart';

/// An interface for configuring logging providers.
class LoggingBuilder {
  final ServiceCollection _services;

  LoggingBuilder(ServiceCollection services) : _services = services;

  /// Gets the [ServiceCollection] where Logging services are configured.
  ServiceCollection get services => _services;
}
