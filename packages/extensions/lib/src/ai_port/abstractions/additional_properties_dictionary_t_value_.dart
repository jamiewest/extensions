/// Provides a dictionary used as the AdditionalProperties dictionary on
/// Microsoft.Extensions.AI objects.
///
/// [TValue] The type of the values in the dictionary.
class AdditionalPropertiesDictionary<TValue> implements Map<String, TValue> {
  /// Initializes a new instance of the [AdditionalPropertiesDictionary] class.
  AdditionalPropertiesDictionary({Map<String, TValue>? dictionary = null, Iterable<MapEntry<String, TValue>>? collection = null, }) {
    #if NET
        _dictionary = new(collection, StringComparer.ordinalIgnoreCase);
    #else
        _dictionary = new Dictionary<String, TValue>(StringComparer.ordinalIgnoreCase);
    for (final item in collection) {
      _dictionary.add(item.key, item.value);
    }
  }

  /// The underlying dictionary.
  final Map<String, TValue> _dictionary;

  TValue item;

  /// Creates a shallow clone of the properties dictionary.
  ///
  /// Returns: A shallow clone of the properties dictionary. The instance will
  /// not be the same as the current instance, but it will contain all of the
  /// same key-value pairs.
  AdditionalPropertiesDictionary<TValue> clone() {
    return new(_dictionary);
  }

  List<String> get keys {
    return _dictionary.keys;
  }

  List<TValue> get values {
    return _dictionary.values;
  }

  int get count {
    return _dictionary.count;
  }

  bool get isReadOnly {
    return false;
  }

  Iterable<String> get keys {
    return _dictionary.keys;
  }

  Iterable<TValue> get values {
    return _dictionary.values;
  }

  @override
  void add(String key, TValue value, ) {
    _dictionary.add(key, value);
  }

  /// Attempts to add the specified key and value to the dictionary.
  ///
  /// Returns: `true` if the key/value pair was added to the dictionary
  /// successfully; otherwise, `false`.
  ///
  /// [key] The key of the element to add.
  ///
  /// [value] The value of the element to add.
  bool tryAdd(String key, TValue value, ) {
    if (!_dictionary.containsKey(key)) {
      _dictionary.add(key, value);
      return true;
    }
    return false;
  }

  void add(MapEntry<String, TValue> item) {
    ((ICollection<MapEntry<String, TValue>>)_dictionary).add(item);
  }

  @override
  void clear() {
    _dictionary.clear();
  }

  bool contains(MapEntry<String, TValue> item) {
    return ((ICollection<MapEntry<String, TValue>>)_dictionary).contains(item);
  }

  @override
  bool containsKey(String key) {
    return _dictionary.containsKey(key);
  }

  void copyTo(List<MapEntry<String, TValue>> array, int arrayIndex, ) {
    ((ICollection<MapEntry<String, TValue>>)_dictionary).copyTo(array, arrayIndex);
  }

  /// Returns an enumerator that iterates through the
  /// [AdditionalPropertiesDictionary].
  ///
  /// Returns: An [Enumerator] that enumerates the contents of the
  /// [AdditionalPropertiesDictionary].
  Enumerator getIterable() {
    return new(_dictionary.getIterable());
  }

  Iterable<MapEntry<String, TValue>> getIterable() {
    return getIterable();
  }

  Iterable getIterable() {
    return getIterable();
  }

  @override
  bool remove(String key) {
    return _dictionary.remove(key);
  }

  bool remove(MapEntry<String, TValue> item) {
    return ((ICollection<MapEntry<String, TValue>>)_dictionary).remove(item);
  }

  /// Attempts to extract a typed value from the dictionary.
  ///
  /// Remarks: If a non-`null` value is found for the key in the dictionary, but
  /// the value is not of the requested type and is an [Convertible] object, the
  /// method attempts to convert the object to the requested type.
  ///
  /// Returns: `true` if a non-`null` value was found for `key` in the
  /// dictionary and converted to the requested type; otherwise, `false`.
  ///
  /// [key] The key to locate.
  ///
  /// [value] When this method returns, contains the value retrieved from the
  /// dictionary, if found and successfully converted to the requested type;
  /// otherwise, the default value of `T`.
  ///
  /// [T] The type of the value to be retrieved.
  bool tryGetValue<T>(String key, {T? value, }) {
    TValue? obj;
    if (tryGetValue(key)) {
      switch (obj) {
        case T t:
        // The object is already of the requested type. Return it.
                    value = t;
        return true;
        case IConvertible:
        try {
          value = (T)Convert.changeType(obj, typeof(T), CultureInfo.invariantCulture);
          return true;
        } catch (e, s) {
          if (e is Exception) {
            final e = e as Exception;
            {}
          } else {
            rethrow;
          }
        }
      }
    }
    // Unable to find the value or convert it to the requested type.
        value = default;
    return false;
  }

  (bool, TValue?) tryGetValue(String key) {
    // TODO(transpiler): implement out-param body
    throw UnimplementedError();
  }

  (bool, TValue?) tryGetValue(String key) {
    // TODO(transpiler): implement out-param body
    throw UnimplementedError();
  }

  /// Copies all of the entries from `items` into the dictionary, overwriting
  /// any existing items in the dictionary with the same key.
  ///
  /// [items] The items to add.
  void setAll(Iterable<MapEntry<String, TValue>> items) {
    _ = Throw.ifNull(items);
    for (final item in items) {
      _dictionary[item.key] = item.value;
    }
  }
}
/// Provides a debugger view for the collection.
class DebugView {
  /// Provides a debugger view for the collection.
  const DebugView(AdditionalPropertiesDictionary<TValue> properties) : _properties = properties;

  final AdditionalPropertiesDictionary<TValue> _properties = Throw.IfNull(properties);

  List<AdditionalProperty> get items {
    return (from p in _properties select additionalProperty(p.key, p.value)).toArray();
  }
}
class AdditionalProperty {
  const AdditionalProperty(String key, TValue value, ) : key = key, value = value;

  final String key = key;

  final TValue value = value;

}
/// Enumerates the elements of an [AdditionalPropertiesDictionary].
class Enumerator {
  /// Initializes a new instance of the [Enumerator] struct with the dictionary
  /// enumerator to wrap.
  ///
  /// [dictionaryEnumerator] The dictionary enumerator to wrap.
  Enumerator(Enumerator dictionaryEnumerator) : _dictionaryEnumerator = dictionaryEnumerator;

  /// The wrapped dictionary enumerator.
  Enumerator _dictionaryEnumerator;

  MapEntry<String, TValue> get current {
    return _dictionaryEnumerator.current;
  }

  Object get current {
    return current;
  }

  @override
  void dispose() {
    _dictionaryEnumerator.dispose();
  }

  @override
  bool moveNext() {
    return _dictionaryEnumerator.moveNext();
  }

  /// Calls [Reset] on an enumerator.
  @override
  static void reset<TEnumerator>({TEnumerator? enumerator}) {
    enumerator.reset();
  }
}
