import '../../../../../lib/func_typedefs.dart';
import '../abstractions/files/hosted_file_client.dart';
import '../empty_service_provider.dart';

/// A builder for creating pipelines of [HostedFileClient].
class HostedFileClientBuilder {
  /// Initializes a new instance of the [HostedFileClientBuilder] class.
  ///
  /// [innerClient] The inner [HostedFileClient] that represents the underlying
  /// backend.
  HostedFileClientBuilder({HostedFileClient? innerClient = null, Func<ServiceProvider, HostedFileClient>? innerClientFactory = null, }) : _innerClientFactory = _ => innerClient {
    _ = Throw.ifNull(innerClient);
  }

  final Func<ServiceProvider, HostedFileClient> _innerClientFactory;

  /// The registered client factory instances.
  List<Func2<HostedFileClient, ServiceProvider, HostedFileClient>>? _clientFactories;

  /// Builds an [HostedFileClient] that represents the entire pipeline. Calls to
  /// this instance will pass through each of the pipeline stages in turn.
  ///
  /// Returns: An instance of [HostedFileClient] that represents the entire
  /// pipeline.
  ///
  /// [services] The [ServiceProvider] that should provide services to the
  /// [HostedFileClient] instances. If `null`, an empty [ServiceProvider] will
  /// be used.
  HostedFileClient build({ServiceProvider? services}) {
    services ??= EmptyServiceProvider.instance;
    var fileClient = _innerClientFactory(services);
    if (_clientFactories != null) {
      for (var i = _clientFactories.count - 1; i >= 0; i--) {
        fileClient = _clientFactories[i](fileClient, services);
        if (fileClient == null) {
          Throw.invalidOperationException(
                        'The ${nameof(HostedFileClientBuilder)} entry at index ${i} returned null. ' +
                        'Ensure that the callbacks passed to ${nameof(Use)} return non-null ${nameof(IHostedFileClient)} instances.');
        }
      }
    }
    return fileClient;
  }

  /// Adds a factory for an intermediate hosted file client to the hosted file
  /// client pipeline.
  ///
  /// Returns: The updated [HostedFileClientBuilder] instance.
  ///
  /// [clientFactory] The client factory function.
  HostedFileClientBuilder use({Func<HostedFileClient, HostedFileClient>? clientFactory}) {
    _ = Throw.ifNull(clientFactory);
    return use((innerClient, _) => clientFactory(innerClient));
  }
}
