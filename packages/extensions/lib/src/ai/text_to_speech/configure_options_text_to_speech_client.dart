import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import 'delegating_text_to_speech_client.dart';
import 'text_to_speech_options.dart';
import 'text_to_speech_response.dart';
import 'text_to_speech_response_update.dart';

/// A [DelegatingTextToSpeechClient] that applies a configuration callback to
/// [TextToSpeechOptions] before each request.
///
/// This is an experimental feature.
@Source(
  name: 'ConfigureOptionsTextToSpeechClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/TextToSpeech/',
)
class ConfigureOptionsTextToSpeechClient extends DelegatingTextToSpeechClient {
  /// Creates a new [ConfigureOptionsTextToSpeechClient].
  ConfigureOptionsTextToSpeechClient(
    super.innerClient, {
    required void Function(TextToSpeechOptions) configure,
  }) : _configure = configure;

  final void Function(TextToSpeechOptions) _configure;

  @override
  Future<TextToSpeechResponse> getAudio(
    String text, {
    TextToSpeechOptions? options,
    CancellationToken? cancellationToken,
  }) {
    final opts = (options ?? TextToSpeechOptions()).clone();
    _configure(opts);
    return super.getAudio(text, options: opts, cancellationToken: cancellationToken);
  }

  @override
  Stream<TextToSpeechResponseUpdate> getStreamingAudio(
    String text, {
    TextToSpeechOptions? options,
    CancellationToken? cancellationToken,
  }) {
    final opts = (options ?? TextToSpeechOptions()).clone();
    _configure(opts);
    return super.getStreamingAudio(text, options: opts, cancellationToken: cancellationToken);
  }
}
