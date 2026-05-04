import '../../../../../../lib/func_typedefs.dart';

extension TaskExtensions on Iterable<Func<CancellationToken, Future<T>>> {Stream<T> executeConcurrentlyAndStreamResults<T>(
  CancellationToken cancellationToken,
  {Iterable<Func<CancellationToken, Future<T>>>? functions, },
) {
var concurrentTasks = functions.select((f) => f(cancellationToken));
return concurrentTasks.streamResultsAsync(preserveOrder, cancellationToken);
 }
/// This method assumes that all the tasks supplied via are already running.
/// Ideally, the passed via should also cancel the tasks supplied via .
///
/// Remarks: This method assumes that all the tasks supplied via
/// `concurrentTasks` are already running. Ideally, the [CancellationToken]
/// passed via `cancellationToken` should also cancel the tasks supplied via
/// `concurrentTasks`.
Stream<T> streamResults<T>(
  CancellationToken cancellationToken,
  {Iterable<Future<T>>? concurrentTasks, },
) async  {
if (preserveOrder) {
  for (final task in concurrentTasks) {
    cancellationToken.throwIfCancellationRequested();
    yield await task.configureAwait(false);
  }

} else {
  var remaining = HashSet<Future<T>>(concurrentTasks);
  while (remaining.count is not 0) {
    cancellationToken.throwIfCancellationRequested();
    var task = await Task.whenAny(remaining).configureAwait(false);
    _ = remaining.remove(task);
    yield await task.configureAwait(false);
  }
}
 }
 }
