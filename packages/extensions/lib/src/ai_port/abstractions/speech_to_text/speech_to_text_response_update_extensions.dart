import '../chat_completion/chat_response_extensions.dart';
import '../contents/ai_content.dart';
import 'speech_to_text_response.dart';
import 'speech_to_text_response_update.dart';

/// Provides extension methods for working with [SpeechToTextResponseUpdate]
/// instances.
extension SpeechToTextResponseUpdateExtensions on Iterable<SpeechToTextResponseUpdate> {
  /// Combines [SpeechToTextResponseUpdate] instances into a single
/// [SpeechToTextResponse].
///
/// Returns: The combined [SpeechToTextResponse].
///
/// [updates] The updates to be combined.
SpeechToTextResponse toSpeechToTextResponse() {
_ = Throw.ifNull(updates);
var response = new();
for (final update in updates) {
  processUpdate(update, response);
}
ChatResponseExtensions.coalesceContent((List<AContent>)response.contents);
return response;
 }
/// Combines [SpeechToTextResponseUpdate] instances into a single
/// [SpeechToTextResponse].
///
/// Returns: The combined [SpeechToTextResponse].
///
/// [updates] The updates to be combined.
///
/// [cancellationToken] The [CancellationToken] to monitor for cancellation
/// requests. The default is [None].
Future<SpeechToTextResponse> toSpeechToTextResponseAsync({CancellationToken? cancellationToken}) {
_ = Throw.ifNull(updates);
return toResponseAsync(updates, cancellationToken);
/* TODO: unsupported node kind "unknown" */
// static async Task<SpeechToTextResponse> ToResponseAsync(
//             IAsyncEnumerable<SpeechToTextResponseUpdate> updates, CancellationToken cancellationToken)
//         {
//             SpeechToTextResponse response = new();
//
//             await foreach (var update in updates.WithCancellation(cancellationToken).ConfigureAwait(false))
//             {
//                 ProcessUpdate(update, response);
//             }
//
//             ChatResponseExtensions.CoalesceContent((List<AIContent>)response.Contents);
//
//             return response;
//         }
 }
 }
