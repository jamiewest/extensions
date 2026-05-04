import 'speech_to_text_options.dart';
import 'speech_to_text_response.dart';
import 'speech_to_text_response_update.dart';

/// Represents a speech to text client.
///
/// Remarks: Unless otherwise specified, all members of [SpeechToTextClient]
/// are thread-safe for concurrent use. It is expected that all
/// implementations of [SpeechToTextClient] support being used by multiple
/// requests concurrently. However, implementations of [SpeechToTextClient]
/// might mutate the arguments supplied to [CancellationToken)] and
/// [CancellationToken)], such as by configuring the options instance. Thus,
/// consumers of the interface either should avoid using shared instances of
/// these arguments for concurrent invocations or should otherwise ensure by
/// construction that no [SpeechToTextClient] instances are used which might
/// employ such mutation. For example, the ConfigureOptions method be provided
/// with a callback that could mutate the supplied options argument, and that
/// should be avoided if using a singleton options instance. The audio speech
/// stream passed to these methods will not be closed or disposed by the
/// implementation.
abstract class SpeechToTextClient implements Disposable {
  /// Sends audio speech content to the model and returns the generated text.
  ///
  /// Returns: The text generated.
  ///
  /// [audioSpeechStream] The audio speech stream to send.
  ///
  /// [options] The speech to text options to configure the request.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests. The default is [None].
  Future<SpeechToTextResponse> getText(
    Stream audioSpeechStream, {
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Sends audio speech content to the model and streams back the generated
  /// text.
  ///
  /// Returns: The text updates representing the streamed output.
  ///
  /// [audioSpeechStream] The audio speech stream to send.
  ///
  /// [options] The speech to text options to configure the request.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests. The default is [None].
  Stream<SpeechToTextResponseUpdate> getStreamingText(
    Stream audioSpeechStream, {
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Asks the [SpeechToTextClient] for an object of the specified type
  /// `serviceType`.
  ///
  /// Remarks: The purpose of this method is to allow for the retrieval of
  /// strongly typed services that might be provided by the
  /// [SpeechToTextClient], including itself or any services it might be
  /// wrapping.
  ///
  /// Returns: The found object, otherwise `null`.
  ///
  /// [serviceType] The type of object being requested.
  ///
  /// [serviceKey] An optional key that can be used to help identify the target
  /// service.
  Object? getService(Type serviceType, {Object? serviceKey});
}
