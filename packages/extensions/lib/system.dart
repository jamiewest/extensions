/// Provides fundamental system types for resource management, threading,
/// and common exceptions.
///
/// This library contains core system abstractions inspired by the .NET
/// System namespace, including disposal patterns, cancellation tokens,
/// and base exception types.
///
/// ## Resource Management
///
/// Dispose of resources properly:
///
/// ```dart
/// class MyResource implements Disposable {
///   @override
///   void dispose() {
///     // Clean up resources
///   }
/// }
///
/// // Synchronous disposal
/// using((resource) {
///   // Use resource
/// }, MyResource());
///
/// // Asynchronous disposal
/// await using((resource) async {
///   // Use resource
/// }, MyAsyncResource());
/// ```
///
/// ## Cancellation Support
///
/// Cancel long-running operations:
///
/// ```dart
/// final cts = CancellationTokenSource();
///
/// // Cancel after timeout
/// cts.cancelAfter(Duration(seconds: 30));
///
/// // Perform cancellable work
/// await doWorkAsync(cts.token);
///
/// // Cancel manually
/// cts.cancel();
/// ```
///
/// ## Exception Types
///
/// Standard exception types for common error conditions:
///
/// ```dart
/// throw ArgumentNullException('paramName');
/// throw ObjectDisposedException('MyClass');
/// throw OperationCancelledException();
/// ```
library;

export 'src/system/async_disposable.dart';
export 'src/system/disposable.dart';
export 'src/system/enum.dart';
export 'src/system/exceptions/argument_exception.dart';
export 'src/system/exceptions/argument_null_exception.dart';
export 'src/system/exceptions/object_disposed_exception.dart';
export 'src/system/exceptions/operation_cancelled_exception.dart';
export 'src/system/exceptions/system_exception.dart';
export 'src/system/string.dart';
export 'src/system/threading/cancellation_token.dart';
export 'src/system/threading/cancellation_token_registration.dart';
export 'src/system/threading/cancellation_token_source.dart';
export 'src/system/threading/tasks/task.dart';

typedef TimerCallback = void Function(Object? state);
