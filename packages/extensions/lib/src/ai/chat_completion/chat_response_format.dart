/// Represents the desired format of a chat response.
sealed class ChatResponseFormat {
  const ChatResponseFormat._();

  /// Unstructured text response.
  static const ChatResponseFormatText text = ChatResponseFormatText();

  /// Structured JSON response without a specific schema.
  static const ChatResponseFormatJson json = ChatResponseFormatJson();

  /// Structured JSON response conforming to the given schema.
  static ChatResponseFormatJsonSchema forJsonSchema({
    required Map<String, dynamic> schema,
    String? schemaName,
    String? schemaDescription,
  }) =>
      ChatResponseFormatJsonSchema(
        schema: schema,
        schemaName: schemaName,
        schemaDescription: schemaDescription,
      );
}

/// Requests unstructured text output.
final class ChatResponseFormatText extends ChatResponseFormat {
  const ChatResponseFormatText() : super._();

  @override
  bool operator ==(Object other) => other is ChatResponseFormatText;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Requests structured JSON output without a specific schema.
final class ChatResponseFormatJson extends ChatResponseFormat {
  const ChatResponseFormatJson() : super._();

  @override
  bool operator ==(Object other) => other is ChatResponseFormatJson;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Requests structured JSON output conforming to a specific schema.
final class ChatResponseFormatJsonSchema extends ChatResponseFormat {
  const ChatResponseFormatJsonSchema({
    required this.schema,
    this.schemaName,
    this.schemaDescription,
  }) : super._();

  /// The JSON schema the response should conform to.
  final Map<String, dynamic> schema;

  /// An optional name for the schema.
  final String? schemaName;

  /// An optional description of the schema.
  final String? schemaDescription;

  @override
  bool operator ==(Object other) =>
      other is ChatResponseFormatJsonSchema && schemaName == other.schemaName;

  @override
  int get hashCode => Object.hash(runtimeType, schemaName);
}
