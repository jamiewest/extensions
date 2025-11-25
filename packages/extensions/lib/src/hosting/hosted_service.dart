import '../system/threading/cancellation_token.dart';
import '../system/threading/tasks/task.dart';

/// Defines methods for objects that are managed by the host.
abstract class HostedService {
  /// Triggered when the application host is ready to start the service.
  Task start(CancellationToken cancellationToken);

  /// Triggered when the application host is performing a graceful shutdown.
  Task stop(CancellationToken cancellationToken);
}
