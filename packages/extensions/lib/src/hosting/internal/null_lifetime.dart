import '../../system/threading/cancellation_token.dart';

import '../host_lifetime.dart';

/// Minimalistic lifetime that does nothing.
class NullLifetime implements HostLifetime {
  @override
  Future<void> stop(CancellationToken cancellationToken) => Future.value();

  @override
  Future<void> waitForStart(CancellationToken cancellationToken) =>
      Future.value();
}
