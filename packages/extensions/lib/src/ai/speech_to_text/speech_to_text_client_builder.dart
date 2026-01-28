import '../../dependency_injection/service_provider.dart';
import '../empty_service_provider.dart';
import 'speech_to_text_client.dart';

/// A factory that creates a [SpeechToTextClient] from a [ServiceProvider].
typedef InnerSpeechToTextClientFactory = SpeechToTextClient Function(
    ServiceProvider services);

/// Builds a pipeline of speech-to-text client middleware.
///
/// The pipeline is composed by calling [use] one or more times, then
/// calling [build] to produce the final [SpeechToTextClient]. Middleware
/// factories are applied in reverse order so that the first call to
/// [use] produces the outermost wrapper.
///
/// This is an experimental feature.
class SpeechToTextClientBuilder {
  late final InnerSpeechToTextClientFactory _innerFactory;

  SpeechToTextClientBuilder._(InnerSpeechToTextClientFactory innerFactory)
      : _innerFactory = innerFactory;

  /// Creates a new [SpeechToTextClientBuilder] wrapping [innerClient].
  SpeechToTextClientBuilder(SpeechToTextClient innerClient) {
    _innerFactory = (services) => innerClient;
  }

  /// Creates a new [SpeechToTextClientBuilder] from a factory function.
  factory SpeechToTextClientBuilder.fromFactory(
          InnerSpeechToTextClientFactory innerFactory) =>
      SpeechToTextClientBuilder._(innerFactory);

  final List<SpeechToTextClient Function(SpeechToTextClient)> _factories = [];

  /// Adds a middleware factory to the pipeline.
  SpeechToTextClientBuilder use(
      SpeechToTextClient Function(SpeechToTextClient) factory) {
    _factories.add(factory);
    return this;
  }

  /// Builds the pipeline and returns the outermost [SpeechToTextClient].
  SpeechToTextClient build([ServiceProvider? services]) {
    services ??= EmptyServiceProvider.instance;

    var client = _innerFactory(services);
    for (var i = _factories.length - 1; i >= 0; i--) {
      client = _factories[i](client);
    }
    return client;
  }
}
