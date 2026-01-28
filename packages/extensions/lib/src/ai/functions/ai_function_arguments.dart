import 'dart:collection';

/// Represents the arguments passed to an AI function invocation.
class AIFunctionArguments extends MapBase<String, Object?> {
  /// Creates a new [AIFunctionArguments].
  AIFunctionArguments([Map<String, Object?>? arguments])
      : _map = arguments != null
            ? Map<String, Object?>.of(arguments)
            : <String, Object?>{};

  final Map<String, Object?> _map;

  /// An optional service provider for dependency injection.
  Object? services;

  /// Arbitrary context data for the invocation.
  Map<Object, Object?>? context;

  @override
  Object? operator [](Object? key) => _map[key];

  @override
  void operator []=(String key, Object? value) => _map[key] = value;

  @override
  void clear() => _map.clear();

  @override
  Iterable<String> get keys => _map.keys;

  @override
  Object? remove(Object? key) => _map.remove(key);
}
