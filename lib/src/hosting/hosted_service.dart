import '../shared/cancellation_token.dart';

/// Defines methods for objects that are managed by the host.
abstract class HostedService {
  /// Triggered when the application host is ready to start the service.
  Future<void> start(CancellationToken cancellationToken);

  /// Triggered when the application host is performing a graceful shutdown.
  Future<void> stop(CancellationToken cancellationToken);
}
