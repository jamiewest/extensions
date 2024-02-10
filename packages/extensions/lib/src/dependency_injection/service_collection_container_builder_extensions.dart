import 'service_collection.dart';
import 'service_lookup/service_lookup.dart';
import 'service_provider.dart';
import 'service_provider_options.dart';

/// Extension methods for building a [ServiceProvider] from a
/// [ServiceCollection].
extension ServiceCollectionContainerBuilderExtensions on ServiceCollection {
  /// Creates a [ServiceProvider] containing services from the
  /// provided [ServiceCollection].
  ServiceProvider buildServiceProvider([ServiceProviderOptions? options]) =>
      DefaultServiceProvider(
        this,
        options ??= ServiceProviderOptions(),
      );
}
