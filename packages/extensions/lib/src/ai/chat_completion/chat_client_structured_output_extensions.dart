import 'dart:convert';

import '../../system/threading/cancellation_token.dart';
import 'chat_client.dart';
import 'chat_message.dart';
import 'chat_options.dart';
import 'chat_response_format.dart';
import 'chat_role.dart';
import 'structured_chat_response.dart';

/// Provides extension methods on [ChatClient] that simplify working with
/// structured output.
///
/// Because the port performs no runtime reflection, callers supply the JSON
/// [Map] `schema` describing the expected shape and a
/// [StructuredResultFromJson] callback that converts the decoded JSON into
/// the result type (upstream derives both from `T` via
/// `AIJsonUtilities`).
extension ChatClientStructuredOutputExtensions on ChatClient {
  /// Sends chat messages, requesting a response matching [schema] and
  /// deserialized via [fromJson].
  ///
  /// When the schema's root is not an object, it is wrapped in an object
  /// schema with a single required `data` property, because LLM providers
  /// require an object schema at the root; unwrapping happens automatically
  /// when reading [StructuredChatResponse.result].
  ///
  /// [useJsonSchemaResponseFormat] defaults to `true`, which sets a JSON
  /// schema on the [ChatResponseFormat]. This improves reliability when the
  /// model supports native structured output but may cause an error when it
  /// does not; pass `false` to instead request generic JSON output and
  /// augment the prompt with the schema.
  Future<StructuredChatResponse<T>> getStructuredResponse<T>({
    required Iterable<ChatMessage> messages,
    required Map<String, dynamic> schema,
    required StructuredResultFromJson<T> fromJson,
    String? schemaName,
    String? schemaDescription,
    ChatOptions? options,
    bool? useJsonSchemaResponseFormat,
    CancellationToken? cancellationToken,
  }) async {
    var effectiveSchema = schema;
    var isWrappedInObject = false;
    if (schema['type'] != 'object') {
      // All the real LLM providers today require an object schema as the
      // root, even those that support native structured output.
      isWrappedInObject = true;
      effectiveSchema = <String, dynamic>{
        r'$schema': 'https://json-schema.org/draft/2020-12/schema',
        'type': 'object',
        'properties': <String, dynamic>{'data': schema},
        'additionalProperties': false,
        'required': <String>['data'],
      };
    }

    final effectiveOptions = options?.clone() ?? ChatOptions();
    var effectiveMessages = messages;

    if (useJsonSchemaResponseFormat ?? true) {
      // With native structured output the backend explains the schema to
      // the model, so no additional prompt is needed.
      effectiveOptions.responseFormat = ChatResponseFormat.forJsonSchema(
        schema: effectiveSchema,
        schemaName: schemaName,
        schemaDescription: schemaDescription,
      );
    } else {
      effectiveOptions.responseFormat = ChatResponseFormat.json;

      final promptAugmentation = ChatMessage.fromText(
        ChatRole.user,
        'Respond with a JSON value conforming to the following schema:\n'
        '```\n'
        '${jsonEncode(effectiveSchema)}\n'
        '```',
      );
      effectiveMessages = [...messages, promptAugmentation];
    }

    final response = await getResponse(
      messages: effectiveMessages,
      options: effectiveOptions,
      cancellationToken: cancellationToken,
    );

    return StructuredChatResponse<T>(
      response,
      fromJson: fromJson,
      wrappedInObject: isWrappedInObject,
    );
  }
}
