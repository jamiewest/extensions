import 'package:extensions/hosting.dart';

/// An interface for configuring Flutter.
class FlutterBuilder {
  final ServiceCollection _services;

  // Creates a [FlutterBuilder].
  FlutterBuilder(ServiceCollection services) : _services = services;

  /// Gets the [ServiceCollection] where Flutter services are configured.
  ServiceCollection get services => _services;
}
