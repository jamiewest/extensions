import 'package:extensions/annotations.dart';

import '../../dependency_injection/service_provider.dart';
import '../empty_service_provider.dart';
import 'realtime_client.dart';

/// A factory that creates a [RealtimeClient] from a [ServiceProvider].
typedef InnerRealtimeClientFactory = RealtimeClient Function(
    ServiceProvider services);

/// A factory that creates middleware by wrapping an inner [RealtimeClient].
typedef RealtimeClientFactory = RealtimeClient Function(
    RealtimeClient innerClient);

/// A factory that creates middleware by wrapping an inner [RealtimeClient] and
/// receiving the active [ServiceProvider].
typedef RealtimeClientFactoryWithServices = RealtimeClient Function(
  RealtimeClient innerClient,
  ServiceProvider services,
);

/// Builds a pipeline of real-time client middleware.
///
/// The pipeline is composed by calling [use] or [useWithServices] one or more
/// times, then calling [build] to produce the final [RealtimeClient].
/// Middleware factories are applied in reverse order so that the first call
/// adds the outermost wrapper.
///
/// This is an experimental feature.
@Source(
  name: 'RealtimeClientBuilder.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class RealtimeClientBuilder {
  late final InnerRealtimeClientFactory _innerClientFactory;

  List<RealtimeClientFactoryWithServices>? _clientFactories;

  RealtimeClientBuilder._(InnerRealtimeClientFactory innerClientFactory)
      : _innerClientFactory = innerClientFactory;

  /// Creates a new [RealtimeClientBuilder] wrapping [innerClient].
  RealtimeClientBuilder(RealtimeClient innerClient) {
    _innerClientFactory = (_) => innerClient;
  }

  /// Creates a new [RealtimeClientBuilder] from a factory function.
  factory RealtimeClientBuilder.fromFactory(
    InnerRealtimeClientFactory innerClientFactory,
  ) =>
      RealtimeClientBuilder._(innerClientFactory);

  /// Adds a middleware factory to the pipeline.
  RealtimeClientBuilder use(RealtimeClientFactory clientFactory) {
    ArgumentError.checkNotNull(clientFactory, 'clientFactory');
    return useWithServices((innerClient, _) => clientFactory(innerClient));
  }

  /// Adds a middleware factory to the pipeline that receives the active
  /// [ServiceProvider].
  RealtimeClientBuilder useWithServices(
      RealtimeClientFactoryWithServices clientFactory) {
    ArgumentError.checkNotNull(clientFactory, 'clientFactory');

    (_clientFactories ??= <RealtimeClientFactoryWithServices>[])
        .add(clientFactory);
    return this;
  }

  /// Builds the pipeline and returns the outermost [RealtimeClient].
  RealtimeClient build([ServiceProvider? services]) {
    services ??= EmptyServiceProvider.instance;

    var client = _innerClientFactory(services);

    final factories = _clientFactories;
    if (factories != null) {
      for (var i = factories.length - 1; i >= 0; i--) {
        client = factories[i](client, services);
      }
    }

    return client;
  }
}
