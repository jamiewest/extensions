import '../abstractions/chat_completion/chat_message.dart';
import '../abstractions/chat_completion/chat_role.dart';
import '../abstractions/contents/ai_content.dart';
import '../abstractions/contents/text_content.dart';

/// Extension methods for [ChatMessage].
extension ChatMessageExtensions on Iterable<ChatMessage> {
  /// Decomposes the supplied collection of `messages` representing an LLM chat
/// conversation into a single [ChatMessage] representing the last
/// `userRequest` in this conversation and a collection of `remainingMessages`
/// representing the rest of the conversation history.
///
/// Returns: `true` if the last [ChatMessage] in the supplied collection of
/// `messages` has [Role] set to [User]; `false` otherwise.
///
/// [messages] A collection of [ChatMessage]s representing an LLM chat
/// conversation history.
///
/// [userRequest] Returns the last [ChatMessage] in the supplied collection of
/// `messages` if this last [ChatMessage] has [Role] set to [User]; `null`
/// otherwise.
///
/// [remainingMessages] Returns the remaining [ChatMessage]s in the
/// conversation history excluding `userRequest`.
bool tryGetUserRequest(ChatMessage? userRequest, {List<ChatMessage>? remainingMessages, }) {
var conversationHistory = [.. messages];
var lastMessageIndex = conversationHistory.count - 1;
if (lastMessageIndex >= 0 &&
            conversationHistory[lastMessageIndex] is ChatMessage lastMessage &&
            lastMessage.role == ChatRole.user) {
  userRequest = lastMessage;
  conversationHistory.removeAt(lastMessageIndex);
} else {
  userRequest = null;
}
remainingMessages = conversationHistory;
return userRequest != null;
 }
/// Renders the supplied `message` to a `string`. The returned `string` can
/// used as part of constructing an evaluation prompt to evaluate a
/// conversation that includes the supplied `message`.
///
/// Remarks: This function only considers the [Text] and ignores any
/// [AIContent]s (present within the [Contents] of the `message`) that are not
/// [TextContent]s. If the `message` does not contain any [TextContent]s then
/// this function returns an empty string. The returned string is prefixed
/// with the [Role] and [AuthorName] (if available). The returned string also
/// always has a new line character at the end.
///
/// Returns: A `string` containing the rendered `message`.
///
/// [message] The [ChatMessage] that is to be rendered.
String renderText({Iterable<ChatMessage>? messages}) {
_ = Throw.ifNull(message);
if (!message.contents.ofType<TextContent>().any()) {
  return string.empty;
}
var author = message.authorName;
var role = message.role.value;
var content = message.text;
return string.isNullOrWhiteSpace(author)
            ? '[${role}] ${content}\n'
            : '[${author} (${role})] ${content}\n';
 }
 }
