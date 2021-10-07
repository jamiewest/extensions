import '../shared/cancellation_token.dart';

abstract class HostLifetime {
  /// Called at the start of `Host.start(cancellationToken)` which
  /// will wait until it's complete before continuing. This can be
  /// used to delay startup until signaled by an external event.
  Future<void> waitForStart(CancellationToken cancellationToken);

  /// Called from `Host.stop(cancellationToken)` to indicate that the
  /// host is stopping and it's time to shut down.
  Future<void> stop(CancellationToken cancellationToken);
}
