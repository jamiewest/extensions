/// Provides a collection of utility methods for marshalling JSON data.
class AJsonUtilities {
  AJsonUtilities();

  /// Gets the [JsonSerializerOptions] singleton used as the default in JSON
  /// serialization operations.
  ///
  /// Remarks: For Native AOT or applications disabling
  /// [IsReflectionEnabledByDefault] this instance includes source generated
  /// contracts for all common exchange types contained in the
  /// Microsoft.Extensions.AI.Abstractions library. It additionally turns on the
  /// following settings: Enables the [WriteIndented] property. Enables string
  /// based enum serialization as implemented by [JsonStringEnumConverter].
  /// Enables [WhenWritingNull] as the default ignore condition for properties.
  /// Enables [UnsafeRelaxedJsonEscaping] when escaping JSON strings. Consuming
  /// applications must ensure that JSON outputs are adequately escaped before
  /// embedding in other document formats, such as HTML and XML.
  static final JsonSerializerOptions defaultOptions = CreateDefaultOptions();

  /// Creates the default [JsonSerializerOptions] to use for
  /// serialization-related operations.
  static JsonSerializerOptions createDefaultOptions() {
    var options = new(JsonContext.defaultValue.options)
        {
            Encoder = JavaScriptEncoder.unsafeRelaxedJsonEscaping,
        };
    if (JsonSerializer.isReflectionEnabledByDefault) {
      // If reflection-based serialization is enabled by default, use it as a fallback for all other types.
            // Also turn on string-based enum serialization for all unknown enums.
            options.typeInfoResolverChain.add(defaultJsonTypeInfoResolver());
      options.converters.add(jsonStringEnumConverter());
    }
    options.makeReadOnly();
    return options;
  }
}
class JsonContext extends JsonSerializerContext {
  JsonContext();

}
class JsonContextNoIndentation extends JsonSerializerContext {
  JsonContextNoIndentation();

}
