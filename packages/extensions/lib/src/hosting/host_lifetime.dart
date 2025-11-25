import '../system/threading/cancellation_token.dart';
import '../system/threading/tasks/task.dart';
import './host.dart';

/// Tracks host lifetime.
abstract interface class HostLifetime {
  /// Called at the start of [Host.start] which
  /// will wait until it's complete before continuing. This can be
  /// used to delay startup until signaled by an external event.
  Task waitForStart(CancellationToken cancellationToken);

  /// Called from [Host.stop] to indicate that the
  /// host is stopping and it's time to shut down.
  Task stop(CancellationToken cancellationToken);
}
