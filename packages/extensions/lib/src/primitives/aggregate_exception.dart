// /// Represents one or more errors that occur during application execution.
// class AggregateException implements Exception {
//   final List<Exception> _innerExceptions;
//   final String _message;

//   /// Initializes a new instance of the [AggregateException] class.
//   AggregateException({
//     String? message,
//     Iterable<Exception>? innerExceptions,
//   })  : _message = message ?? '',
//         _innerExceptions = innerExceptions?.toList() ?? [];

//   factory AggregateException.from(Iterable<Exception> exceptions) {
//     return AggregateException(
//       innerExceptions: exceptions,
//     );
//   }

//   @override
//   String toString() {
//     StringBuffer text = StringBuffer();
//     text.write(_message);
//     return text.toString();
//   }
// }
