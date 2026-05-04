import 'ai_function.dart';

/// Represents arguments to be used with [CancellationToken)].
///
/// Remarks: [AIFunctionArguments] is a dictionary of name/value pairs that
/// are used as inputs to an [AIFunction]. However, an instance carries
/// additional non-nominal information, such as an optional [ServiceProvider]
/// that can be used by an [AIFunction] if it needs to resolve any services
/// from a dependency injection container.
class AFunctionArguments implements Map<String, Object?> {
  /// Initializes a new instance of the [AIFunctionArguments] class containing
  /// the specified `arguments`.
  ///
  /// Remarks: The `arguments` reference will be stored if the instance is
  /// already a [Dictionary] with the same [EqualityComparer] or if `arguments`
  /// is `null` in which case all dictionary operations on this instance will be
  /// routed directly to that instance otherwise a shallow clone of the provided
  /// `arguments`. A `null` `arguments` is will be treated as an empty
  /// parameters dictionary.
  ///
  /// [arguments] The arguments represented by this instance.
  ///
  /// [comparer] The [EqualityComparer] to be used.
  AFunctionArguments({Map<String, Object?>? arguments = null, EqualityComparer<String>? comparer = null, }) : _arguments = arguments == null ? new(comparer) :
            arguments is Dictionary<String, Object?> dc && (comparer == null || referenceEquals(dc.comparer, comparer)) ? dc :
            new(arguments, comparer);

  /// The nominal arguments.
  final Map<String, Object?> _arguments;

  /// Gets or sets services optionally associated with these arguments.
  ServiceProvider? services;

  /// Gets or sets additional context associated with these arguments.
  ///
  /// Remarks: The context is a dictionary of name/value pairs that can be used
  /// to store arbitrary information for use by an [AIFunction] implementation.
  /// The meaning of this data is left up to the implementer of the
  /// [AIFunction].
  Map<Object, Object?>? context;

  Object? item;

  List<String> get keys {
    return _arguments.keys;
  }

  List<Object?> get values {
    return _arguments.values;
  }

  int get count {
    return _arguments.count;
  }

  bool get isReadOnly {
    return false;
  }

  Iterable<String> get keys {
    return keys;
  }

  Iterable<Object?> get values {
    return values;
  }

  @override
  void add(String key, Object? value, ) {
    _arguments.add(key, value);
  }

  void add(MapEntry<String, Object?> item) {
    ((ICollection<MapEntry<String, Object?>>)_arguments).add(item);
  }

  @override
  void clear() {
    _arguments.clear();
  }

  bool contains(MapEntry<String, Object?> item) {
    return ((ICollection<MapEntry<String, Object?>>)_arguments).contains(item);
  }

  @override
  bool containsKey(String key) {
    return _arguments.containsKey(key);
  }

  @override
  void copyTo(List<MapEntry<String, Object?>> array, int arrayIndex, ) {
    ((ICollection<MapEntry<String, Object?>>)_arguments).copyTo(array, arrayIndex);
  }

  @override
  Iterable<MapEntry<String, Object?>> getIterable() {
    return _arguments.getIterable();
  }

  @override
  bool remove(String key) {
    return _arguments.remove(key);
  }

  bool remove(MapEntry<String, Object?> item) {
    return ((ICollection<MapEntry<String, Object?>>)_arguments).remove(item);
  }

  @override (bool, Object??)
  tryGetValue(String key) {
    // TODO(transpiler): implement out-param body
    throw UnimplementedError();
  }

  Iterable getIterable() {
    return getIterable();
  }
}
