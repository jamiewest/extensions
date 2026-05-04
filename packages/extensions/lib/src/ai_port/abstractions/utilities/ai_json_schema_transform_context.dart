/// Defines the context for transforming a schema node withing a larger schema
/// document.
///
/// Remarks: This struct is being passed to the user-provided
/// [TransformSchemaNode] callback by the [AIJsonSchemaCreateOptions)] method
/// and cannot be instantiated directly.
class AJsonSchemaTransformContext {
  const AJsonSchemaTransformContext(List<String> path) : path = path, _path = path;

  final List<String> _path;

  /// Gets the path to the schema document currently being generated.
  ReadOnlySpan<String> get path {
    return _path;
  }

  /// Gets the containing property name if the current schema is a property of
  /// an object.
  String? get propertyName {
    return path is [.., "properties", string name] ? name : null;
  }

  /// Gets a value indicating whether the current schema is a collection
  /// element.
  bool get isCollectionElementSchema {
    return path is [.., "items"];
  }

  /// Gets a value indicating whether the current schema is a dictionary value.
  bool get isDictionaryValueSchema {
    return path is [.., "additionalProperties"];
  }
}
