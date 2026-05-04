import 'text_to_speech_client.dart';
import 'text_to_speech_options.dart';
import 'text_to_speech_response.dart';
import 'text_to_speech_response_update.dart';

/// Provides an optional base class for an [TextToSpeechClient] that passes
/// through calls to another instance.
///
/// Remarks: This is recommended as a base type when building clients that can
/// be chained in any order around an underlying [TextToSpeechClient]. The
/// default implementation simply passes each call to the inner client
/// instance.
class DelegatingTextToSpeechClient implements TextToSpeechClient {
  /// Initializes a new instance of the [DelegatingTextToSpeechClient] class.
  ///
  /// [innerClient] The wrapped client instance.
  const DelegatingTextToSpeechClient(TextToSpeechClient innerClient)
    : innerClient = Throw.ifNull(innerClient);

  /// Gets the inner [TextToSpeechClient].
  final TextToSpeechClient innerClient;

  /// Provides a mechanism for releasing unmanaged resources.
  ///
  /// [disposing] `true` if being called from [Dispose]; otherwise, `false`.
  @override
  void dispose({bool? disposing}) {
    if (disposing) {
      innerClient.dispose();
    }
  }

  @override
  Future<TextToSpeechResponse> getAudio(
    String text, {
    TextToSpeechOptions? options,
    CancellationToken? cancellationToken,
  }) {
    return innerClient.getAudioAsync(text, options, cancellationToken);
  }

  @override
  Stream<TextToSpeechResponseUpdate> getStreamingAudio(
    String text, {
    TextToSpeechOptions? options,
    CancellationToken? cancellationToken,
  }) {
    return innerClient.getStreamingAudioAsync(text, options, cancellationToken);
  }

  @override
  Object? getService(Type serviceType, {Object? serviceKey}) {
    _ = Throw.ifNull(serviceType);
    return serviceKey == null && serviceType.isInstanceOfType(this)
        ? this
        : innerClient.getService(serviceType, serviceKey);
  }
}
