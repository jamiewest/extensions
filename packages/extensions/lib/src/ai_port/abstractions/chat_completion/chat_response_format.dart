import '../utilities/ai_json_schema_create_options.dart';
import 'chat_response_format_json.dart';
import 'chat_response_format_text.dart';

/// Represents the response format that is desired by the caller.
class ChatResponseFormat {
  /// Initializes a new instance of the [ChatResponseFormat] class.
  ///
  /// Remarks: Prevents external instantiation. Close the inheritance hierarchy
  /// for now until we have good reason to open it.
  const ChatResponseFormat();

  static final AJsonSchemaCreateOptions _inferenceOptions;

  /// Gets a singleton instance representing unstructured textual data.
  static final ChatResponseFormatText text;

  /// Gets a singleton instance representing structured JSON data but without
  /// any particular schema.
  static final ChatResponseFormatJson json = new(schema: null);

  static final Regex _invalidNameCharsRegex = new("[^0-9A-Za-z_]", RegexOptions.Compiled);

  /// Creates a [ChatResponseFormatJson] representing structured JSON data with
  /// the specified schema.
  ///
  /// Returns: The [ChatResponseFormatJson] instance.
  ///
  /// [schema] The JSON schema.
  ///
  /// [schemaName] An optional name of the schema. For example, if the schema
  /// represents a particular class, this could be the name of the class.
  ///
  /// [schemaDescription] An optional description of the schema.
  static ChatResponseFormatJson forJsonSchema(
    String? schemaName,
    String? schemaDescription,
    {JsonElement? schema, JsonSerializerOptions? serializerOptions, Type? schemaType, },
  ) {
    return new(schema, schemaName, schemaDescription);
  }

  /// Regex that flags any character other than ASCII digits, ASCII letters, or
  /// underscore.
  static Regex invalidNameCharsRegex() {
    return _invalidNameCharsRegex;
  }
}
