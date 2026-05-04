import 'ai_content.dart';
import 'text_content.dart';

/// Represents text reasoning content in a chat.
///
/// Remarks: [TextReasoningContent] is distinct from [TextContent].
/// [TextReasoningContent] represents "thinking" or "reasoning" performed by
/// the model and is distinct from the actual output text from the model,
/// which is represented by [TextContent]. Neither types derives from the
/// other.
class TextReasoningContent extends AContent {
  /// Initializes a new instance of the [TextReasoningContent] class.
  ///
  /// [text] The text reasoning content.
  const TextReasoningContent(String? text) : text = text;

  /// Gets or sets the text reasoning content.
  String text;

  /// Gets or sets an optional opaque blob of data associated with this
  /// reasoning content.
  ///
  /// Remarks: This property is used to store data from a provider that should
  /// be roundtripped back to the provider but that is not intended for human
  /// consumption. It is often encrypted or otherwise redacted information that
  /// is only intended to be sent back to the provider and not displayed to the
  /// user. It's possible for a [TextReasoningContent] to contain only
  /// [ProtectedData] and have an empty [Text] property. This data also may be
  /// associated with the corresponding [Text], acting as a validation signature
  /// for it. Note that whereas [Text] can be provider agnostic, [ProtectedData]
  /// is provider-specific, and is likely to only be understood by the provider
  /// that created it.
  String? protectedData;

  @override
  String toString() {
    return text;
  }

  String get debuggerDisplay {
    return 'Reasoning = \"${text}\"';
  }
}
