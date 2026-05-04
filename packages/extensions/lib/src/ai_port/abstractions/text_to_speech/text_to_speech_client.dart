import 'text_to_speech_options.dart';
import 'text_to_speech_response.dart';
import 'text_to_speech_response_update.dart';

/// Represents a text to speech client.
///
/// Remarks: Unless otherwise specified, all members of [TextToSpeechClient]
/// are thread-safe for concurrent use. It is expected that all
/// implementations of [TextToSpeechClient] support being used by multiple
/// requests concurrently. However, implementations of [TextToSpeechClient]
/// might mutate the arguments supplied to [CancellationToken)] and
/// [CancellationToken)], such as by configuring the options instance. Thus,
/// consumers of the interface either should avoid using shared instances of
/// these arguments for concurrent invocations or should otherwise ensure by
/// construction that no [TextToSpeechClient] instances are used which might
/// employ such mutation. For example, the ConfigureOptions method may be
/// provided with a callback that could mutate the supplied options argument,
/// and that should be avoided if using a singleton options instance.
abstract class TextToSpeechClient implements Disposable {
  /// Sends text content to the model and returns the generated audio speech.
  ///
  /// Returns: The audio speech generated.
  ///
  /// [text] The text to synthesize into speech.
  ///
  /// [options] The text to speech options to configure the request.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests. The default is [None].
  Future<TextToSpeechResponse> getAudio(
    String text, {
    TextToSpeechOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Sends text content to the model and streams back the generated audio
  /// speech.
  ///
  /// Returns: The audio speech updates representing the streamed output.
  ///
  /// [text] The text to synthesize into speech.
  ///
  /// [options] The text to speech options to configure the request.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests. The default is [None].
  Stream<TextToSpeechResponseUpdate> getStreamingAudio(
    String text, {
    TextToSpeechOptions? options,
    CancellationToken? cancellationToken,
  });

  /// Asks the [TextToSpeechClient] for an object of the specified type
  /// `serviceType`.
  ///
  /// Remarks: The purpose of this method is to allow for the retrieval of
  /// strongly typed services that might be provided by the
  /// [TextToSpeechClient], including itself or any services it might be
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
