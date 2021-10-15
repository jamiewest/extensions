import 'service_collection.dart';
import 'service_provider.dart';

/// Provides an extension point for creating a container
/// specific builder and an [ServiceProvider].
abstract class ServiceProviderFactory<TContainerBuilder> {
  /// Creates a container builder from an [ServiceCollection].
  TContainerBuilder createBuilder({
    required ServiceCollection services,
  });

  /// Creates an [ServiceProvider] from the container builder.
  ServiceProvider createServiceProvider({
    required TContainerBuilder containerBuilder,
  });
}
