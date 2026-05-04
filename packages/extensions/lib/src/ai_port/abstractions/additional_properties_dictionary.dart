/// Provides a dictionary used as the AdditionalProperties dictionary on
/// Microsoft.Extensions.AI objects.
class AdditionalPropertiesDictionary extends AdditionalPropertiesDictionary<Object?> {
  /// Initializes a new instance of the [AdditionalPropertiesDictionary] class.
  AdditionalPropertiesDictionary({Map<String, Object?>? dictionary = null, Iterable<MapEntry<String, Object?>>? collection = null, });

  /// Creates a shallow clone of the properties dictionary.
  ///
  /// Returns: A shallow clone of the properties dictionary. The instance will
  /// not be the same as the current instance, but it will contain all of the
  /// same key-value pairs.
  AdditionalPropertiesDictionary clone() {
    return new(this);
  }
}
