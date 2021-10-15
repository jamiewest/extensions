import 'service_collection.dart';

/// Specifies the lifetime of a service in a [ServiceCollection].
enum ServiceLifetime {
  /// Specifies that a single instance of the service will be created.
  singleton,

  /// Specifies that a new instance of the service will be created
  /// for each scope.
  scoped,

  /// Specifies that a new instance of the service will be created
  /// every time it is requested.
  transient,
}
