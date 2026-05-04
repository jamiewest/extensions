import '../../../../../../lib/func_typedefs.dart';
import '../contents/ai_content.dart';
import '../contents/text_content.dart';
import 'chat_message.dart';
import 'chat_response_update.dart';

/// Provides extension methods for working with [ChatResponse] and
/// [ChatResponseUpdate] instances.
extension ChatResponseExtensions on List<ChatMessage> {
  /// Adds all of the messages from `response` into `list`.
///
/// [list] The destination list to which the messages from `response` should
/// be added.
///
/// [response] The response containing the messages to add.
void addMessages({ChatResponse? response, Iterable<ChatResponseUpdate>? updates, ChatResponseUpdate? update, Func<AContent, bool>? filter, }) {
_ = Throw.ifNull(list);
_ = Throw.ifNull(response);
if (list is ListChatMessage) {
    final listConcrete = list as ListChatMessage;
    listConcrete.addRange(response.messages);
  } else {
    for (final message in response.messages) {
      list.add(message);
    }
  }
 }
/// Converts the `updates` into [ChatMessage] instances and adds them to
/// `list`.
///
/// Remarks: As part of combining `updates` into a series of [ChatMessage]
/// instances, tne method may use [MessageId] to determine message boundaries,
/// as well as coalesce contiguous [AIContent] items where applicable, e.g.
/// multiple [TextContent] instances in a row may be combined into a single
/// [TextContent].
///
/// Returns: A [Task] representing the completion of the operation.
///
/// [list] The list to which the newly constructed messages should be added.
///
/// [updates] The [ChatResponseUpdate] instances to convert to messages and
/// add to the list.
///
/// [cancellationToken] The [CancellationToken] to monitor for cancellation
/// requests. The default is [None].
Future addMessagesAsync(
  Stream<ChatResponseUpdate> updates,
  {CancellationToken? cancellationToken, },
) {
_ = Throw.ifNull(list);
_ = Throw.ifNull(updates);
return addMessagesAsync(list, updates, cancellationToken);
/* TODO: unsupported node kind "unknown" */
// static async Task AddMessagesAsync(
//             IList<ChatMessage> list, IAsyncEnumerable<ChatResponseUpdate> updates, CancellationToken cancellationToken) =>
//             list.AddMessages(await updates.ToChatResponseAsync(cancellationToken).ConfigureAwait(false));
 }
/// Combines [ChatResponseUpdate] instances into a single [ChatResponse].
///
/// Remarks: As part of combining `updates` into a single [ChatResponse], the
/// method will attempt to reconstruct [ChatMessage] instances. This includes
/// using [MessageId] to determine message boundaries, as well as coalescing
/// contiguous [AIContent] items where applicable, e.g. multiple [TextContent]
/// instances in a row may be combined into a single [TextContent].
///
/// Returns: The combined [ChatResponse].
///
/// [updates] The updates to be combined.
ChatResponse toChatResponse() {
_ = Throw.ifNull(updates);
var response = new();
for (final update in updates) {
  processUpdate(update, response);
}
finalizeResponse(response);
return response;
 }
/// Combines [ChatResponseUpdate] instances into a single [ChatResponse].
///
/// Remarks: As part of combining `updates` into a single [ChatResponse], the
/// method will attempt to reconstruct [ChatMessage] instances. This includes
/// using [MessageId] to determine message boundaries, as well as coalescing
/// contiguous [AIContent] items where applicable, e.g. multiple [TextContent]
/// instances in a row may be combined into a single [TextContent].
///
/// Returns: The combined [ChatResponse].
///
/// [updates] The updates to be combined.
///
/// [cancellationToken] The [CancellationToken] to monitor for cancellation
/// requests. The default is [None].
Future<ChatResponse> toChatResponseAsync({CancellationToken? cancellationToken}) {
_ = Throw.ifNull(updates);
return toChatResponseAsync(updates, cancellationToken);
/* TODO: unsupported node kind "unknown" */
// static async Task<ChatResponse> ToChatResponseAsync(
//             IAsyncEnumerable<ChatResponseUpdate> updates, CancellationToken cancellationToken)
//         {
//             ChatResponse response = new();
//
//             await foreach (var update in updates.WithCancellation(cancellationToken).ConfigureAwait(false))
//             {
//                 ProcessUpdate(update, response);
//             }
//
//             FinalizeResponse(response);
//
//             return response;
//         }
 }
 }
