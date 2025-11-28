/// Represents one or more errors that occur during application execution.
///
/// This exception aggregates multiple exceptions that occurred during a
/// parallel or sequential operation. All inner exceptions are preserved
/// for debugging and error analysis.
class AggregateException implements Exception {
  final List<Exception> _innerExceptions;
  final String _message;

  /// Initializes a new instance of the [AggregateException] class with
  /// a specified error message and a reference to the inner exceptions.
  AggregateException({
    String? message,
    Iterable<Exception>? innerExceptions,
  })  : _message = message ?? 'One or more errors occurred.',
        _innerExceptions = innerExceptions?.toList() ?? [];

  /// Creates an [AggregateException] from a collection of exceptions.
  factory AggregateException.from(Iterable<Exception> exceptions) =>
      AggregateException(innerExceptions: exceptions);

  /// Gets the error message and information about the inner exceptions.
  String get message => _message;

  /// Gets a read-only collection of the [Exception] instances that caused
  /// the current exception.
  List<Exception> get innerExceptions => List.unmodifiable(_innerExceptions);

  /// Gets the number of inner exceptions.
  int get count => _innerExceptions.length;

  /// Flattens all inner [AggregateException] instances into a single
  /// [AggregateException].
  ///
  /// This recursively flattens any nested [AggregateException] instances
  /// and returns a new [AggregateException] containing all leaf exceptions.
  AggregateException flatten() {
    var flattenedExceptions = <Exception>[];
    var exceptionsToFlatten = <Exception>[..._innerExceptions];

    while (exceptionsToFlatten.isNotEmpty) {
      var exception = exceptionsToFlatten.removeAt(0);

      if (exception is AggregateException) {
        // Add all inner exceptions from nested AggregateException
        exceptionsToFlatten.insertAll(0, exception._innerExceptions);
      } else {
        // Add leaf exception
        flattenedExceptions.add(exception);
      }
    }

    return AggregateException(
      message: _message,
      innerExceptions: flattenedExceptions,
    );
  }

  @override
  String toString() {
    var buffer = StringBuffer()..write(_message);

    if (_innerExceptions.isNotEmpty) {
      buffer
        ..write(' (')
        ..writeAll(
          _innerExceptions.map((e) => e.toString()),
          ', ',
        )
        ..write(')');
    }

    return buffer.toString();
  }
}
