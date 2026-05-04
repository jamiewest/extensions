extension ExceptionUtilities on Exception {bool isCancellation() {
return exception switch
        {
            (OperationCanceledException) => true,
            AggregateException (aggregateException) => aggregateException.containsOnlyCancellations(),
            (_) => false
        };
 }
bool containsOnlyCancellations() {
var toCheck = Stack<Exception>();
toCheck.push(exception);
var seen = HashSet<Exception>();
var containsAtLeastOneCancellation = false;
while (toCheck.tryPop(out Exception? current)) {
  if (seen.add(current)) {
    if (current is AggregateException) {
        final aggregateException = current as AggregateException;
        for (final innerException in aggregateException.innerExceptions) {
          toCheck.push(innerException);
        }
      } else if (current is OperationCanceledException) {
        containsAtLeastOneCancellation = true;
      } else {
        return false;
      }
  }
}
return containsAtLeastOneCancellation;
 }
 }
