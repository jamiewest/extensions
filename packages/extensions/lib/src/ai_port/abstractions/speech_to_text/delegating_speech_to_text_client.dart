import 'speech_to_text_client.dart';
import 'speech_to_text_options.dart';
import 'speech_to_text_response.dart';
import 'speech_to_text_response_update.dart';

/// Provides an optional base class for an [SpeechToTextClient] that passes
/// through calls to another instance.
///
/// Remarks: This is recommended as a base type when building clients that can
/// be chained in any order around an underlying [SpeechToTextClient]. The
/// default implementation simply passes each call to the inner client
/// instance.
class DelegatingSpeechToTextClient implements SpeechToTextClient {
  /// Initializes a new instance of the [DelegatingSpeechToTextClient] class.
  ///
  /// [innerClient] The wrapped client instance.
  const DelegatingSpeechToTextClient(SpeechToTextClient innerClient)
    : innerClient = Throw.ifNull(innerClient);

  /// Gets the inner [SpeechToTextClient].
  final SpeechToTextClient innerClient;

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
  Future<SpeechToTextResponse> getText(
    Stream audioSpeechStream, {
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) {
    return innerClient.getTextAsync(
      audioSpeechStream,
      options,
      cancellationToken,
    );
  }

  @override
  Stream<SpeechToTextResponseUpdate> getStreamingText(
    Stream audioSpeechStream, {
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) {
    return innerClient.getStreamingTextAsync(
      audioSpeechStream,
      options,
      cancellationToken,
    );
  }

  @override
  Object? getService(Type serviceType, {Object? serviceKey}) {
    _ = Throw.ifNull(serviceType);
    return serviceKey == null && serviceType.isInstanceOfType(this)
        ? this
        : innerClient.getService(serviceType, serviceKey);
  }
}
