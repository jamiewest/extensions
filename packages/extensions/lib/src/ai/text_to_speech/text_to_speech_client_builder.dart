import 'package:extensions/annotations.dart';

import '../../dependency_injection/service_provider.dart';
import '../empty_service_provider.dart';
import 'text_to_speech_client.dart';

/// A factory that creates a [TextToSpeechClient] from a [ServiceProvider].
typedef InnerTextToSpeechClientFactory = TextToSpeechClient Function(
    ServiceProvider services);

/// Builds a pipeline of text-to-speech client middleware.
///
/// The pipeline is composed by calling [use] one or more times, then
/// [build] to produce the final [TextToSpeechClient]. Middleware factories are
/// applied in reverse order so that the first [use] call produces the
/// outermost wrapper.
///
/// This is an experimental feature.
@Source(
  name: 'TextToSpeechClientBuilder.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/TextToSpeech/',
)
class TextToSpeechClientBuilder {
  late final InnerTextToSpeechClientFactory _innerFactory;
  final List<TextToSpeechClient Function(TextToSpeechClient)> _factories = [];

  TextToSpeechClientBuilder._(InnerTextToSpeechClientFactory innerFactory)
      : _innerFactory = innerFactory;

  /// Creates a new [TextToSpeechClientBuilder] wrapping [innerClient].
  TextToSpeechClientBuilder(TextToSpeechClient innerClient) {
    _innerFactory = (_) => innerClient;
  }

  /// Creates a new [TextToSpeechClientBuilder] from a factory function.
  factory TextToSpeechClientBuilder.fromFactory(
          InnerTextToSpeechClientFactory innerFactory) =>
      TextToSpeechClientBuilder._(innerFactory);

  /// Adds a middleware factory to the pipeline.
  TextToSpeechClientBuilder use(
      TextToSpeechClient Function(TextToSpeechClient) factory) {
    _factories.add(factory);
    return this;
  }

  /// Builds the pipeline and returns the outermost [TextToSpeechClient].
  TextToSpeechClient build([ServiceProvider? services]) {
    services ??= EmptyServiceProvider.instance;
    var client = _innerFactory(services);
    for (var i = _factories.length - 1; i >= 0; i--) {
      client = _factories[i](client);
    }
    return client;
  }
}
