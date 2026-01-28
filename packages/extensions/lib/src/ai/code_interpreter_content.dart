import 'ai_content.dart';

/// Represents a code interpreter tool call.
///
/// This is an experimental feature.
class CodeInterpreterToolCallContent extends AIContent {
  /// Creates a new [CodeInterpreterToolCallContent].
  CodeInterpreterToolCallContent({
    required this.callId,
    this.inputs,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The unique identifier for this tool call.
  final String callId;

  /// The input content items for the code interpreter.
  final List<AIContent>? inputs;

  @override
  String toString() => 'CodeInterpreterToolCall($callId)';
}

/// Represents the result of a code interpreter tool call.
///
/// This is an experimental feature.
class CodeInterpreterToolResultContent extends AIContent {
  /// Creates a new [CodeInterpreterToolResultContent].
  CodeInterpreterToolResultContent({
    required this.callId,
    this.outputs,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The unique identifier for the corresponding tool call.
  final String callId;

  /// The output content items.
  final List<AIContent>? outputs;

  @override
  String toString() => 'CodeInterpreterToolResult($callId)';
}
