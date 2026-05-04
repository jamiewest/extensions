import '../../../../../../lib/func_typedefs.dart';
import 'ai_json_schema_transform_context.dart';

/// Provides options for configuring the behavior of [AIJsonUtilities] JSON
/// schema transformation functionality.
class AJsonSchemaTransformOptions {
  AJsonSchemaTransformOptions();

  /// Gets a callback that is invoked for every schema that is generated within
  /// the type graph.
  Func2<AJsonSchemaTransformContext, JsonNode, JsonNode>? transformSchemaNode;

  /// Gets a value indicating whether to convert boolean schemas to equivalent
  /// object-based representations.
  bool convertBooleanSchemas;

  /// Gets a value indicating whether to generate schemas with the
  /// additionalProperties set to false for .NET objects.
  bool disallowAdditionalProperties;

  /// Gets a value indicating whether to mark all properties as required in the
  /// schema.
  bool requireAllProperties;

  /// Gets a value indicating whether to substitute nullable "type" keywords
  /// with OpenAPI 3.0 style "nullable" keywords in the schema.
  bool useNullableKeyword;

  /// Gets a value indicating whether to move the default keyword to the
  /// description field in the schema.
  bool moveDefaultKeywordToDescription;

  /// Gets the default options instance.
  static final AJsonSchemaTransformOptions defaultValue;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AJsonSchemaTransformOptions &&
        transformSchemaNode == other.transformSchemaNode &&
        convertBooleanSchemas == other.convertBooleanSchemas &&
        disallowAdditionalProperties == other.disallowAdditionalProperties &&
        requireAllProperties == other.requireAllProperties &&
        useNullableKeyword == other.useNullableKeyword &&
        moveDefaultKeywordToDescription ==
            other.moveDefaultKeywordToDescription &&
        defaultValue == other.defaultValue;
  }

  @override
  int get hashCode {
    return Object.hash(
      transformSchemaNode,
      convertBooleanSchemas,
      disallowAdditionalProperties,
      requireAllProperties,
      useNullableKeyword,
      moveDefaultKeywordToDescription,
      defaultValue,
    );
  }
}
