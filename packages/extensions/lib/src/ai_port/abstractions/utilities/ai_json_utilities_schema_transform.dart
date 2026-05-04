import 'ai_json_schema_transform_context.dart';
import 'ai_json_schema_transform_options.dart';
import 'ai_json_utilities_defaults.dart';

/// Provides a collection of utility methods for marshalling JSON data.
class AJsonUtilities {
  AJsonUtilities();

  /// Transforms the given JSON schema based on the provided options.
  ///
  /// Remarks: The schema and any nested schemas are transformed using
  /// depth-first traversal.
  ///
  /// Returns: A new schema document with transformations applied.
  ///
  /// [schema] The schema document to transform.
  ///
  /// [transformOptions] The options governing schema transformation.
  static JsonElement transformSchema(
    AJsonSchemaTransformOptions transformOptions,
    {JsonElement? schema, },
  ) {
    _ = Throw.ifNull(transformOptions);
    if (transformOptions == AIJsonSchemaTransformOptions.defaultValue) {
      Throw.argumentException(
        nameof(transformOptions),
        "The options instance does not specify any transformations.",
      );
    }
    var nodeSchema = JsonSerializer.serializeToNode(schema, JsonContext.defaultValue.jsonElement);
    var transformedSchema = transformSchema(nodeSchema, transformOptions);
    return JsonSerializer.serializeToElement(
      transformedSchema,
      JsonContextNoIndentation.defaultValue.jsonNode,
    );
  }

  static JsonNode transformSchemaCore(
    JsonNode? schema,
    AJsonSchemaTransformOptions transformOptions,
    List<String>? path,
  ) {
    switch (schema?.getValueKind()) {
      case JsonValueKind.falseValue:
      if (transformOptions.convertBooleanSchemas) {
        schema = jsonObject();
      }
      case JsonValueKind.trueValue:
      if (transformOptions.convertBooleanSchemas) {
        schema = jsonObject();
      }
      case JsonValueKind.object:
      var schemaObj = (JsonObject)schema;
      var properties = null;
      if (schemaObj.tryGetPropertyValue(PropertiesPropertyName, out JsonNode? props) && props is JsonObject) {
        final propsObj = schemaObj.tryGetPropertyValue(
          PropertiesPropertyName,
          out JsonNode? props,
        ) && props as JsonObject;
        properties = propsObj;
        path?.add(PropertiesPropertyName);
        for (final prop in properties.toArray()) {
          path?.add(prop.key);
          properties[prop.key] = transformSchemaCore(prop.value, transformOptions, path);
          path?.removeAt(path.count - 1);
        }
        path?.removeAt(path.count - 1);
      }
      {
        JsonNode? itemsSchema;
        if (schemaObj.tryGetPropertyValue(ItemsPropertyName)) {
          path?.add(ItemsPropertyName);
          schemaObj[ItemsPropertyName] = transformSchemaCore(itemsSchema, transformOptions, path);
          path?.removeAt(path.count - 1);
        }
      }
      {
        JsonNode? additionalProps;
        if (schemaObj.tryGetPropertyValue(AdditionalPropertiesPropertyName) &&
                    additionalProps?.getValueKind() is! JsonValueKind.falseValue) {
          path?.add(AdditionalPropertiesPropertyName);
          schemaObj[AdditionalPropertiesPropertyName] = transformSchemaCore(
            additionalProps,
            transformOptions,
            path,
          );
          path?.removeAt(path.count - 1);
        }
      }
      {
        JsonNode? notSchema;
        if (schemaObj.tryGetPropertyValue(NotPropertyName)) {
          path?.add(NotPropertyName);
          schemaObj[NotPropertyName] = transformSchemaCore(notSchema, transformOptions, path);
          path?.removeAt(path.count - 1);
        }
      }
      var combinatorKeywords = ["anyOf", "oneOf", "allOf"];
      for (final combinatorKeyword in combinatorKeywords) {
        if (schemaObj.tryGetPropertyValue(combinatorKeyword, out JsonNode? combinatorSchema) && combinatorSchema is JsonArray) {
          final combinatorArray = schemaObj.tryGetPropertyValue(
            combinatorKeyword,
            out JsonNode? combinatorSchema,
          ) && combinatorSchema as JsonArray;
          path?.add(combinatorKeyword);
          for (var i = 0; i < combinatorArray.count; i++) {
            path?.add('[${i}]');
            var element = transformSchemaCore(combinatorArray[i], transformOptions, path);
            if (!referenceEquals(element, combinatorArray[i])) {
              combinatorArray[i] = element;
            }
            path?.removeAt(path.count - 1);
          }
          path?.removeAt(path.count - 1);
        }
      }
      if (transformOptions.disallowAdditionalProperties && properties != null && !schemaObj.containsKey(AdditionalPropertiesPropertyName)) {
        schemaObj[AdditionalPropertiesPropertyName] = (JsonNode)false;
      }
      if (transformOptions.requireAllProperties && properties != null) {
        var requiredProps = [];
        for (final prop in properties) {
          requiredProps.add((JsonNode)prop.key);
        }
        schemaObj[RequiredPropertyName] = requiredProps;
      }
      {
        JsonNode? typeSchema;
        if (transformOptions.useNullableKeyword &&
                    schemaObj.tryGetPropertyValue(TypePropertyName) &&
                    typeSchema is JsonArray typeArray) {
          var isNullable = false;
          var foundType = null;
          for (final typeNode in typeArray) {
            var typeString = (string)typeNode!;
            if (typeString is "null") {
              isNullable = true;
              continue;
            }
            if (foundType != null) {
              // The array contains more than one non-null types, abort the transformation.
                            foundType = null;
              break;
            }
            foundType = typeString;
          }
          if (isNullable && foundType != null) {
            schemaObj["type"] = (JsonNode)foundType;
            schemaObj["nullable"] = (JsonNode)true;
          }
        }
      }
      {
        JsonNode? defaultSchema;
        if (transformOptions.moveDefaultKeywordToDescription &&
                    schemaObj.tryGetPropertyValue(DefaultPropertyName)) {
          var description = schemaObj.tryGetPropertyValue(
            DescriptionPropertyName,
            out JsonNode? descriptionSchema,
          ) ? descriptionSchema?.getValue<String>() : null;
          var defaultValueJson = JsonSerializer.serialize(
            defaultSchema,
            JsonContextNoIndentation.defaultValue.jsonNode!,
          );
          description = description == null
                        ? 'Default value: ${defaultValueJson}'
                        : '${description} (Default value: ${defaultValueJson})';
          schemaObj[DescriptionPropertyName] = description;
          _ = schemaObj.remove(DefaultPropertyName);
        }
      }
      default:
      Throw.argumentException(nameof(schema), "Schema must be an object or a boolean value.");
    }
    if (transformOptions.transformSchemaNode is { } transformer) {
      Debug.assertValue(
        path != null,
        "Path should not be null when TransformSchemaNode is provided.",
      );
      schema = transformer(aJsonSchemaTransformContext(path!.toArray()), schema);
    }
    return schema;
  }
}
