import '../system/threading/cancellation_token.dart';
import 'hosted_service.dart';

/// Defines methods that are run before or after
/// [HostedService.start] and [HostedService.stop].
abstract class HostedLifecycleService extends HostedService {
  /// Triggered before [HostedService.start].
  Future<void> starting(CancellationToken cancellationToken);

  /// Triggered after [HostedService.start].
  Future<void> started(CancellationToken cancellationToken);

  /// Triggered before [HostedService.start].
  Future<void> stopping(CancellationToken cancellationToken);

  /// Triggered after [HostedService.start].
  Future<void> stopped(CancellationToken cancellationToken);
}
