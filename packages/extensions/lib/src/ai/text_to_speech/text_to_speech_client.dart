import 'package:extensions/annotations.dart';

import '../../system/disposable.dart';
import '../../system/threading/cancellation_token.dart';
import 'text_to_speech_options.dart';
import 'text_to_speech_response.dart';
import 'text_to_speech_response_update.dart';

/// Represents a text-to-speech client.
///
/// Implementations must be thread-safe for concurrent use. Consumers should
/// not share [TextToSpeechOptions] instances across concurrent calls, as
/// implementations may mutate the options.
///
/// This is an experimental feature.
@Source(
  name: 'ITextToSpeechClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/TextToSpeech/',
)
abstract class TextToSpeechClient implements Disposable {
  /// Synthesizes [text] into audio and returns the complete response.
  Future<TextToSpeechResponse> getAudio(
    String text, {
    TextToSpeechOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Synthesizes [text] into audio and returns a stream of response updates.
  Stream<TextToSpeechResponseUpdate> getStreamingAudio(
    String text, {
    TextToSpeechOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Gets a service of the specified type.
  T? getService<T>({Object? key}) => null;
}
