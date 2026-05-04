import 'chat_response_format.dart';

/// Represents a response format for structured JSON data.
class ChatResponseFormatJson extends ChatResponseFormat {
  /// Initializes a new instance of the [ChatResponseFormatJson] class with the
  /// specified schema.
  ///
  /// [schema] The schema to associate with the JSON response.
  ///
  /// [schemaName] A name for the schema.
  ///
  /// [schemaDescription] A description of the schema.
  ChatResponseFormatJson(
    JsonElement? schema, {
    String? schemaName = null,
    String? schemaDescription = null,
  }) : schema = schema,
       schemaName = schemaName,
       schemaDescription = schemaDescription {
    if (schema == null && (schemaName != null || schemaDescription != null)) {
      Throw.argumentException(
        schemaName != null ? nameof(schemaName) : nameof(schemaDescription),
        "schema name and description can only be specified if a schema is provided.",
      );
    }
  }

  /// Gets the JSON schema associated with the response, or `null` if there is
  /// none.
  final JsonElement? schema;

  /// Gets a name for the schema.
  final String? schemaName;

  /// Gets a description of the schema.
  final String? schemaDescription;

  /// Gets a string representing this instance to display in the debugger.
  String get debuggerDisplay {
    return schema?.toString() ?? "JSON";
  }
}
