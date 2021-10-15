import '../../shared/cancellation_token.dart';
import '../host_lifetime.dart';

/// Minimalistic lifetime that does nothing.
class NullLifetime implements HostLifetime {
  @override
  Future<void> stop(CancellationToken cancellationToken) => Future.value(null);

  @override
  Future<void> waitForStart(CancellationToken cancellationToken) =>
      Future.value(null);
}
