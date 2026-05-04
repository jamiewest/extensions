/// Defines the context in which a JSON schema within a type graph is being
/// generated.
///
/// Remarks: This struct is being passed to the user-provided
/// [TransformSchemaNode] callback by the [AIJsonSchemaCreateOptions)] method
/// and cannot be instantiated directly.
class AJsonSchemaCreateContext {
  const AJsonSchemaCreateContext(JsonSchemaExporterContext exporterContext)
    : _exporterContext = exporterContext;

  final JsonSchemaExporterContext _exporterContext;

  /// Gets the path to the schema document currently being generated.
  ReadOnlySpan<String> get path {
    return _exporterContext.path;
  }

  /// Gets the [JsonTypeInfo] for the type being processed.
  JsonTypeInfo get typeInfo {
    return _exporterContext.typeInfo;
  }

  /// Gets the type info for the polymorphic base type if generated as a derived
  /// type.
  JsonTypeInfo? get baseTypeInfo {
    return _exporterContext.baseTypeInfo;
  }

  /// Gets the [JsonPropertyInfo] if the schema is being generated for a
  /// property.
  JsonPropertyInfo? get propertyInfo {
    return _exporterContext.propertyInfo;
  }

  /// Gets the declaring type of the property or parameter being processed.
  Type? get declaringType {
    return _exporterContext.propertyInfo?.declaringType;
  }

  /// Gets the [CustomAttributeProvider] corresponding to the property or field
  /// being processed.
  CustomAttributeProvider? get propertyAttributeProvider {
    return _exporterContext.propertyInfo?.attributeProvider;
  }

  /// Gets the [CustomAttributeProvider] of the constructor parameter associated
  /// with the accompanying [PropertyInfo].
  CustomAttributeProvider? get parameterAttributeProvider {
    return _exporterContext
        .propertyInfo
        ?.associatedParameter
        ?.attributeProvider;
  }

  /// Retrieves a custom attribute of a specified type that is applied to the
  /// specified schema node context.
  ///
  /// Remarks: This helper method resolves attributes from context locations in
  /// the following order: Attributes specified on the property of the context,
  /// if specified. Attributes specified on the constructor parameter of the
  /// context, if specified. Attributes specified on the type of the context.
  ///
  /// Returns: The first occurrence of `TAttribute` if found, or `null`
  /// otherwise.
  ///
  /// [inherit] If `true`, specifies to also search the ancestors of the context
  /// members for custom attributes.
  ///
  /// [TAttribute] The type of attribute to search for.
  TAttribute? getCustomAttribute<TAttribute>({bool? inherit}) {
    return getCustomAttr(propertyAttributeProvider) ??
        getCustomAttr(parameterAttributeProvider) ??
        getCustomAttr(typeInfo.type);
    /* TODO: unsupported node kind "unknown" */
    // TAttribute? GetCustomAttr(ICustomAttributeProvider? provider) =>
    //             (TAttribute?)provider?.GetCustomAttributes(typeof(TAttribute), inherit).FirstOrDefault();
  }
}
