import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import 'text_to_speech_client.dart';
import 'text_to_speech_options.dart';
import 'text_to_speech_response.dart';
import 'text_to_speech_response_update.dart';

/// A [TextToSpeechClient] that delegates all calls to an inner client.
///
/// Subclass this to build middleware that wraps specific methods while
/// delegating others to the inner client.
///
/// This is an experimental feature.
@Source(
  name: 'DelegatingTextToSpeechClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/TextToSpeech/',
)
class DelegatingTextToSpeechClient implements TextToSpeechClient {
  /// Creates a new [DelegatingTextToSpeechClient] wrapping [innerClient].
  DelegatingTextToSpeechClient(this.innerClient);

  /// The inner client to delegate to.
  final TextToSpeechClient innerClient;

  @override
  Future<TextToSpeechResponse> getAudio(
    String text, {
    TextToSpeechOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      innerClient.getAudio(
        text,
        options: options,
        cancellationToken: cancellationToken,
      );

  @override
  Stream<TextToSpeechResponseUpdate> getStreamingAudio(
    String text, {
    TextToSpeechOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      innerClient.getStreamingAudio(
        text,
        options: options,
        cancellationToken: cancellationToken,
      );

  @override
  T? getService<T>({Object? key}) {
    if (this is T) return this as T;
    return innerClient.getService<T>(key: key);
  }

  @override
  void dispose() => innerClient.dispose();
}
