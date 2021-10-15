import 'service_provider.dart';
import 'service_scope.dart';

/// A factory for creating instances of [ServiceScope],
/// which is used to create services within a scope.
abstract class ServiceScopeFactory {
  /// Create an [ServiceScope] which contains an [ServiceProvider]
  /// used to resolve dependencies from a newly created scope.
  ServiceScope createScope();
}
