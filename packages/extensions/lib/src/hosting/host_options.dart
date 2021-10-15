import '../configuration/configuration.dart';
import 'background_service.dart';
import 'background_service_exception_behavior.dart';
import 'host.dart';

/// Options for [Host].
class HostOptions {
  /// The default timeout for [Host.Stop(cancellationToken)].
  Duration shutdownTimeout = const Duration(seconds: 5);

  /// The behavior the [Host] will follow when any of
  /// its [BackgroundService] instances throw an unhandled exception.
  BackgroundServiceExceptionBehavior backgroundServiceExceptionBehavior =
      BackgroundServiceExceptionBehavior.stopHost;

  void initialize(Configuration configuration) {
    var timeoutSeconds = configuration['shutdownTimeoutSeconds'];
    if (timeoutSeconds != null) {
      if (timeoutSeconds.isNotEmpty) {
        shutdownTimeout = Duration(seconds: int.parse(timeoutSeconds));
      }
    }
  }
}
