import '../../system/threading/cancellation_token.dart';
import '../data_content.dart';
import 'speech_to_text_client.dart';
import 'speech_to_text_response_update.dart';

/// Convenience operations for [SpeechToTextClient].
///
/// The upstream `GetService` overloads collapse into the interface's own
/// [SpeechToTextClient.getService] per the porting rules.
///
/// This is an experimental feature.
extension SpeechToTextClientExtensions on SpeechToTextClient {
  /// Transcribes the audio carried by [audioSpeechContent].
  ///
  /// Throws [ArgumentError] when the content carries no in-memory data
  /// (for example, a URI-only [DataContent]).
  Future<SpeechToTextResponse> getTextFromDataContent(
    DataContent audioSpeechContent, {
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) {
    final data = audioSpeechContent.data;
    if (data == null) {
      throw ArgumentError.value(
        audioSpeechContent,
        'audioSpeechContent',
        'The DataContent must carry in-memory data.',
      );
    }
    return getText(
      stream: Stream.value(data),
      options: options,
      cancellationToken: cancellationToken,
    );
  }

  /// Transcribes the audio carried by [audioSpeechContent] as a stream of
  /// updates.
  ///
  /// Throws [ArgumentError] when the content carries no in-memory data.
  Stream<SpeechToTextResponseUpdate> getStreamingTextFromDataContent(
    DataContent audioSpeechContent, {
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) {
    final data = audioSpeechContent.data;
    if (data == null) {
      throw ArgumentError.value(
        audioSpeechContent,
        'audioSpeechContent',
        'The DataContent must carry in-memory data.',
      );
    }
    return getStreamingText(
      stream: Stream.value(data),
      options: options,
      cancellationToken: cancellationToken,
    );
  }
}
