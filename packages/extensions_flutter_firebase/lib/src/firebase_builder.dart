import 'package:extensions_flutter/extensions_flutter.dart';

class FirebaseBuilder {
  final ServiceCollection _services;

  // Private constructor to ensure that the builder is created internally.
  FirebaseBuilder(ServiceCollection services) : _services = services;

  /// Gets the [ServiceCollection] where Flutter services are configured.
  ServiceCollection get services => _services;
}
