import '../chat_completion/chat_client.dart';
import '../chat_completion/chat_response_format_json.dart';
import '../functions/ai_function.dart';
import '../functions/ai_function_declaration.dart';
import 'ai_json_schema_transform_options.dart';

/// Defines a cache for JSON schemas transformed according to the specified
/// [AIJsonSchemaTransformOptions] policy.
///
/// Remarks: This cache stores weak references from AI abstractions that
/// declare JSON schemas such as [AIFunction] or [ChatResponseFormatJson] to
/// their corresponding JSON schemas transformed according to the specified
/// [TransformOptions] policy. It is intended for use by [ChatClient]
/// implementations that enforce vendor-specific restrictions on what
/// constitutes a valid JSON schema for a given function or response format.
/// It is recommended [ChatClient] implementations with schema transformation
/// requirements create a single static instance of this cache.
class AJsonSchemaTransformCache {
  /// Initializes a new instance of the [AIJsonSchemaTransformCache] class with
  /// the specified options.
  ///
  /// [transformOptions] The options governing schema transformation.
  AJsonSchemaTransformCache(AJsonSchemaTransformOptions transformOptions) : transformOptions = transformOptions, _functionSchemaCreateValueCallback = function => AIJsonUtilities.transformSchema(function.jsonSchema, transformOptions), _responseFormatCreateValueCallback = responseFormat => AIJsonUtilities.transformSchema(responseFormat.schema!.value, transformOptions) {
    _ = Throw.ifNull(transformOptions);
    if (transformOptions == AIJsonSchemaTransformOptions.defaultValue) {
      Throw.argumentException(
        nameof(transformOptions),
        "The options instance does not specify any transformations.",
      );
    }
  }

  final ConditionalWeakTable<AFunctionDeclaration, Object> _functionSchemaCache;

  final ConditionalWeakTable<ChatResponseFormatJson, Object> _responseFormatCache;

  final CreateValueCallback _functionSchemaCreateValueCallback;

  final CreateValueCallback _responseFormatCreateValueCallback;

  /// Gets the options governing schema transformation.
  final AJsonSchemaTransformOptions transformOptions;

  /// Gets or creates a transformed JSON schema for the specified [AIFunction]
  /// instance.
  ///
  /// Returns: The transformed JSON schema corresponding to [TransformOptions].
  ///
  /// [function] The function whose JSON schema is to be transformed.
  JsonElement getOrCreateTransformedSchema({AFunction? function, ChatResponseFormatJson? responseFormat, }) {
    return getOrCreateTransformedSchema((AIFunctionDeclaration)function);
  }
}
