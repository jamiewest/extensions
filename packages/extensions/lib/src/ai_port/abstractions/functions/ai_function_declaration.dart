import '../tools/ai_tool.dart';
import '../utilities/ai_json_schema_create_options.dart';
import 'ai_function.dart';
import 'ai_function_factory.dart';

/// Represents a function that can be described to an AI service.
///
/// Remarks: [AIFunctionDeclaration] is the base class for [AIFunction], which
/// adds the ability to invoke the function. Components can type test [AITool]
/// instances for [AIFunctionDeclaration] to determine whether they can be
/// described as functions, and can type test for [AIFunction] to determine
/// whether they can be invoked.
abstract class AFunctionDeclaration extends ATool {
  /// Initializes a new instance of the [AIFunctionDeclaration] class.
  const AFunctionDeclaration();

  /// Gets a JSON Schema describing the function and its input parameters.
  ///
  /// Remarks: When specified, declares a self-contained JSON schema document
  /// that describes the function and its input parameters. A simple example of
  /// a JSON schema for a function that adds two numbers together is shown
  /// below: { "type": "object", "properties": { "a" : { "type": "number" }, "b"
  /// : { "type": ["number","null"], "default": 1 } }, "required" : ["a"] } The
  /// metadata present in the schema document plays an important role in guiding
  /// AI function invocation. When an [AIFunction] is created via
  /// [AIFunctionFactory], this schema is automatically derived from the
  /// method's parameters using the configured [JsonSerializerOptions] and
  /// [AIJsonSchemaCreateOptions]. When no schema is specified, consuming chat
  /// clients should assume the "{}" or "true" schema, indicating that any JSON
  /// input is admissible.
  JsonElement get jsonSchema {
    return AIJsonUtilities.defaultJsonSchema;
  }

  /// Gets a JSON Schema describing the function's return value.
  ///
  /// Remarks: When an [AIFunction] is created via [AIFunctionFactory], this
  /// schema is automatically derived from the method's return type using the
  /// configured [JsonSerializerOptions] and [AIJsonSchemaCreateOptions]. For
  /// methods returning [Task] or [ValueTask], the schema is based on the
  /// unwrapped result type. Return schema generation can be excluded by setting
  /// [ExcludeResultSchema] to `true`. A `null` value typically reflects a
  /// function that doesn't specify a return schema, a function that returns
  /// [Void], [Task], or [ValueTask], or a function for which
  /// [ExcludeResultSchema] was set to `true`.
  JsonElement? get returnJsonSchema {
    return null;
  }
}
