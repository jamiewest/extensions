import 'service_collection.dart';
import 'service_provider.dart';
import 'service_provider_factory.dart';
import 'service_provider_options.dart';

/// Default implementation of [ServiceProviderFactory<TContainerBuilder>].
class DefaultServiceProviderFactory
    implements ServiceProviderFactory<ServiceCollection> {
  final ServiceProviderOptions _options;

  /// Initializes a new instance of the [DefaultServiceProviderFactory] class
  /// with the specified options or default options if none is provided.
  DefaultServiceProviderFactory({ServiceProviderOptions? options})
      : _options = options ??= ServiceProviderOptions();

  @override
  ServiceCollection createBuilder({
    required ServiceCollection services,
  }) =>
      services;

  @override
  ServiceProvider createServiceProvider({
    required ServiceCollection containerBuilder,
  }) =>
      containerBuilder.buildServiceProvider(_options);
}
