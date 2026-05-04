import 'text_to_speech_client.dart';

/// Extensions for [TextToSpeechClient].
extension TextToSpeechClientExtensions on TextToSpeechClient {
  /// Asks the [TextToSpeechClient] for an object of type `TService`.
///
/// Remarks: The purpose of this method is to allow for the retrieval of
/// strongly typed services that may be provided by the [TextToSpeechClient],
/// including itself or any services it might be wrapping.
///
/// Returns: The found object, otherwise `null`.
///
/// [client] The client.
///
/// [serviceKey] An optional key that can be used to help identify the target
/// service.
///
/// [TService] The type of the object to be retrieved.
TService? getService<TService>({Object? serviceKey}) {
_ = Throw.ifNull(client);
return (TService?)client.getService(typeof(TService), serviceKey);
 }
 }
