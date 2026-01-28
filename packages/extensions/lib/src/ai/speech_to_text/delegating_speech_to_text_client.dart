import '../../system/threading/cancellation_token.dart';
import 'speech_to_text_client.dart';

/// A [SpeechToTextClient] that delegates all calls to an inner client.
///
/// Subclass this to create middleware that wraps specific methods
/// while delegating others.
///
/// This is an experimental feature.
abstract class DelegatingSpeechToTextClient implements SpeechToTextClient {
  /// Creates a new [DelegatingSpeechToTextClient] wrapping [innerClient].
  DelegatingSpeechToTextClient(this.innerClient);

  /// The inner client to delegate to.
  final SpeechToTextClient innerClient;

  @override
  Future<SpeechToTextResponse> getText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      innerClient.getText(
        stream: stream,
        options: options,
        cancellationToken: cancellationToken,
      );

  @override
  Stream<SpeechToTextResponse> getStreamingText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      innerClient.getStreamingText(
        stream: stream,
        options: options,
        cancellationToken: cancellationToken,
      );

  @override
  T? getService<T>({Object? key}) =>
      innerClient.getService<T>(key: key);

  @override
  void dispose() => innerClient.dispose();
}
