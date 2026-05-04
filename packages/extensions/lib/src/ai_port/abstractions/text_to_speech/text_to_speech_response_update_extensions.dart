import 'text_to_speech_response.dart';
import 'text_to_speech_response_update.dart';

/// Provides extension methods for working with [TextToSpeechResponseUpdate]
/// instances.
extension TextToSpeechResponseUpdateExtensions on Iterable<TextToSpeechResponseUpdate> {
  /// Combines [TextToSpeechResponseUpdate] instances into a single
/// [TextToSpeechResponse].
///
/// Returns: The combined [TextToSpeechResponse].
///
/// [updates] The updates to be combined.
TextToSpeechResponse toTextToSpeechResponse() {
_ = Throw.ifNull(updates);
var response = new();
for (final update in updates) {
  processUpdate(update, response);
}
return response;
 }
/// Combines [TextToSpeechResponseUpdate] instances into a single
/// [TextToSpeechResponse].
///
/// Returns: The combined [TextToSpeechResponse].
///
/// [updates] The updates to be combined.
///
/// [cancellationToken] The [CancellationToken] to monitor for cancellation
/// requests. The default is [None].
Future<TextToSpeechResponse> toTextToSpeechResponseAsync({CancellationToken? cancellationToken}) {
_ = Throw.ifNull(updates);
return toResponseAsync(updates, cancellationToken);
/* TODO: unsupported node kind "unknown" */
// static async Task<TextToSpeechResponse> ToResponseAsync(
//             IAsyncEnumerable<TextToSpeechResponseUpdate> updates, CancellationToken cancellationToken)
//         {
//             TextToSpeechResponse response = new();
//
//             await foreach (var update in updates.WithCancellation(cancellationToken).ConfigureAwait(false))
//             {
//                 ProcessUpdate(update, response);
//             }
//
//             return response;
//         }
 }
 }
