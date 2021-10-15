import 'service_provider.dart';

/// Optional contract used by
/// [ServiceProviderServiceExtensions.getRequiredService()] resolve services if
/// supported by [ServiceProvider].
abstract class SupportRequiredService {
  /// Gets service of type [serviceType] from the [ServiceProvider]
  /// implementing this interface.
  ///
  /// Throws an exception if the [ServiceProvider] cannot create the object.
  Object getRequiredService({required Type serviceType});
}
