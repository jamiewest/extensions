import '../../../../../lib/func_typedefs.dart';
import '../abstractions/speech_to_text/speech_to_text_client.dart';
import '../empty_service_provider.dart';

/// A builder for creating pipelines of [SpeechToTextClient].
class SpeechToTextClientBuilder {
  /// Initializes a new instance of the [SpeechToTextClientBuilder] class.
  ///
  /// [innerClient] The inner [SpeechToTextClient] that represents the
  /// underlying backend.
  SpeechToTextClientBuilder({SpeechToTextClient? innerClient = null, Func<ServiceProvider, SpeechToTextClient>? innerClientFactory = null, }) : _innerClientFactory = _ => innerClient {
    _ = Throw.ifNull(innerClient);
  }

  final Func<ServiceProvider, SpeechToTextClient> _innerClientFactory;

  /// The registered client factory instances.
  List<Func2<SpeechToTextClient, ServiceProvider, SpeechToTextClient>>? _clientFactories;

  /// Builds an [SpeechToTextClient] that represents the entire pipeline. Calls
  /// to this instance will pass through each of the pipeline stages in turn.
  ///
  /// Returns: An instance of [SpeechToTextClient] that represents the entire
  /// pipeline.
  ///
  /// [services] The [ServiceProvider] that should provide services to the
  /// [SpeechToTextClient] instances. If null, an empty [ServiceProvider] will
  /// be used.
  SpeechToTextClient build({ServiceProvider? services}) {
    services ??= EmptyServiceProvider.instance;
    var audioClient = _innerClientFactory(services);
    if (_clientFactories != null) {
      for (var i = _clientFactories.count - 1; i >= 0; i--) {
        audioClient = _clientFactories[i](audioClient, services) ??
                    throw invalidOperationException(
                        'The ${nameof(SpeechToTextClientBuilder)} entry at index ${i} returned null. ' +
                        'Ensure that the callbacks passed to ${nameof(Use)} return non-null ${nameof(ISpeechToTextClient)} instances.');
      }
    }
    return audioClient;
  }

  /// Adds a factory for an intermediate speech-to-text client to the
  /// speech-to-text client pipeline.
  ///
  /// Returns: The updated [SpeechToTextClientBuilder] instance.
  ///
  /// [clientFactory] The client factory function.
  SpeechToTextClientBuilder use({Func<SpeechToTextClient, SpeechToTextClient>? clientFactory}) {
    _ = Throw.ifNull(clientFactory);
    return use((innerClient, _) => clientFactory(innerClient));
  }
}
