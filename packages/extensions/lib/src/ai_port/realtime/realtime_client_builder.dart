import '../../../../../lib/func_typedefs.dart';
import '../abstractions/realtime/realtime_client.dart';
import '../empty_service_provider.dart';

/// A builder for creating pipelines of [RealtimeClient].
class RealtimeClientBuilder {
  /// Initializes a new instance of the [RealtimeClientBuilder] class.
  ///
  /// [innerClient] The inner [RealtimeClient] that represents the underlying
  /// backend.
  RealtimeClientBuilder({RealtimeClient? innerClient = null, Func<ServiceProvider, RealtimeClient>? innerClientFactory = null, }) : _innerClientFactory = _ => innerClient {
    _ = Throw.ifNull(innerClient);
  }

  final Func<ServiceProvider, RealtimeClient> _innerClientFactory;

  /// The registered client factory instances.
  List<Func2<RealtimeClient, ServiceProvider, RealtimeClient>>? _clientFactories;

  /// Builds an [RealtimeClient] that represents the entire pipeline. Calls to
  /// this instance will pass through each of the pipeline stages in turn.
  ///
  /// Returns: An instance of [RealtimeClient] that represents the entire
  /// pipeline.
  ///
  /// [services] The [ServiceProvider] that should provide services to the
  /// [RealtimeClient] instances. If `null`, an empty [ServiceProvider] will be
  /// used.
  RealtimeClient build({ServiceProvider? services}) {
    services ??= EmptyServiceProvider.instance;
    var client = _innerClientFactory(services);
    if (_clientFactories != null) {
      for (var i = _clientFactories.count - 1; i >= 0; i--) {
        client = _clientFactories[i](client, services);
        if (client == null) {
          Throw.invalidOperationException(
                        'The ${nameof(RealtimeClientBuilder)} entry at index ${i} returned null. ' +
                        'Ensure that the callbacks passed to ${nameof(Use)} return non-null ${nameof(IRealtimeClient)} instances.');
        }
      }
    }
    return client;
  }

  /// Adds a factory for an intermediate realtime client to the realtime client
  /// pipeline.
  ///
  /// Returns: The updated [RealtimeClientBuilder] instance.
  ///
  /// [clientFactory] The client factory function.
  RealtimeClientBuilder use({Func<RealtimeClient, RealtimeClient>? clientFactory}) {
    _ = Throw.ifNull(clientFactory);
    return use((innerClient, _) => clientFactory(innerClient));
  }
}
