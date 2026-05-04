import 'chat_response_format.dart';

/// Represents a response format with no constraints around the format.
///
/// Remarks: Use [Text] to get an instance of [ChatResponseFormatText].
class ChatResponseFormatText extends ChatResponseFormat {
  /// Initializes a new instance of the [ChatResponseFormatText] class.
  ///
  /// Remarks: Use [Text] to get an instance of [ChatResponseFormatText].
  const ChatResponseFormatText();

  @override
  bool equals(Object? obj) {
    return obj is ChatResponseFormatText;
  }

  @override
  int getHashCode() {
    return typeof(ChatResponseFormatText).getHashCode();
  }
}
