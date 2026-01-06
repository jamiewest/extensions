import 'package:extensions/dependency_injection.dart';

/// An interface for configuring Flutter.
class FlutterBuilder {
  final ServiceCollection _services;

  // Private constructor to ensure that the builder is created internally.
  const FlutterBuilder(ServiceCollection services) : _services = services;

  /// Gets the [ServiceCollection] where flutter services are configured.
  ServiceCollection get services => _services;
}
