import 'dart:typed_data';

import 'ai_content.dart';
import 'text_content.dart';

/// Represents reasoning or "thinking" content from an AI model.
///
/// This content type is distinct from [TextContent] and represents
/// the model's internal reasoning process, which may be displayed
/// differently or handled separately from regular output text.
class TextReasoningContent extends AIContent {
  /// Creates a new [TextReasoningContent].
  TextReasoningContent(
    this.text, {
    this.protectedData,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The reasoning text.
  final String text;

  /// Opaque data for provider roundtripping.
  ///
  /// This data is not meant to be interpreted by the caller,
  /// but can be passed back to the provider in subsequent requests.
  final Uint8List? protectedData;

  @override
  String toString() => text;
}
