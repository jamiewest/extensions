import '../../../../../lib/func_typedefs.dart';
import '../abstractions/text_to_speech/text_to_speech_client.dart';
import '../empty_service_provider.dart';

/// A builder for creating pipelines of [TextToSpeechClient].
class TextToSpeechClientBuilder {
  /// Initializes a new instance of the [TextToSpeechClientBuilder] class.
  ///
  /// [innerClient] The inner [TextToSpeechClient] that represents the
  /// underlying backend.
  TextToSpeechClientBuilder({TextToSpeechClient? innerClient = null, Func<ServiceProvider, TextToSpeechClient>? innerClientFactory = null, }) : _innerClientFactory = _ => innerClient {
    _ = Throw.ifNull(innerClient);
  }

  final Func<ServiceProvider, TextToSpeechClient> _innerClientFactory;

  /// The registered client factory instances.
  List<Func2<TextToSpeechClient, ServiceProvider, TextToSpeechClient>>? _clientFactories;

  /// Builds an [TextToSpeechClient] that represents the entire pipeline. Calls
  /// to this instance will pass through each of the pipeline stages in turn.
  ///
  /// Returns: An instance of [TextToSpeechClient] that represents the entire
  /// pipeline.
  ///
  /// [services] The [ServiceProvider] that should provide services to the
  /// [TextToSpeechClient] instances. If null, an empty [ServiceProvider] will
  /// be used.
  TextToSpeechClient build({ServiceProvider? services}) {
    services ??= EmptyServiceProvider.instance;
    var client = _innerClientFactory(services);
    if (_clientFactories != null) {
      for (var i = _clientFactories.count - 1; i >= 0; i--) {
        client = _clientFactories[i](client, services) ??
                    throw invalidOperationException(
                        'The ${nameof(TextToSpeechClientBuilder)} entry at index ${i} returned null. ' +
                        'Ensure that the callbacks passed to ${nameof(Use)} return non-null ${nameof(ITextToSpeechClient)} instances.');
      }
    }
    return client;
  }

  /// Adds a factory for an intermediate text-to-speech client to the
  /// text-to-speech client pipeline.
  ///
  /// Returns: The updated [TextToSpeechClientBuilder] instance.
  ///
  /// [clientFactory] The client factory function.
  TextToSpeechClientBuilder use({Func<TextToSpeechClient, TextToSpeechClient>? clientFactory}) {
    _ = Throw.ifNull(clientFactory);
    return use((innerClient, _) => clientFactory(innerClient));
  }
}
