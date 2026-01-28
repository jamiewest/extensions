import '../../system/threading/cancellation_token.dart';
import 'delegating_speech_to_text_client.dart';
import 'speech_to_text_client.dart';

/// A delegating speech-to-text client that applies configuration to
/// [SpeechToTextOptions] before each request.
///
/// This is an experimental feature.
class ConfigureOptionsSpeechToTextClient extends DelegatingSpeechToTextClient {
  /// Creates a new [ConfigureOptionsSpeechToTextClient].
  ConfigureOptionsSpeechToTextClient(
    super.innerClient, {
    required this.configure,
  });

  /// The callback that configures options before each request.
  final SpeechToTextOptions Function(SpeechToTextOptions options) configure;

  @override
  Future<SpeechToTextResponse> getText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      super.getText(
        stream: stream,
        options: configure(options ?? SpeechToTextOptions()),
        cancellationToken: cancellationToken,
      );

  @override
  Stream<SpeechToTextResponse> getStreamingText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      super.getStreamingText(
        stream: stream,
        options: configure(options ?? SpeechToTextOptions()),
        cancellationToken: cancellationToken,
      );
}
