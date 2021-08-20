import 'service_provider.dart';

/// Optional service used to determine if the specified type is available from
/// the [ServiceProvider].
abstract class ServiceProviderIsService {
  /// Determines if the specified service type is available from the
  /// [ServiceProvider].
  bool isService({required Type serviceType});
}
