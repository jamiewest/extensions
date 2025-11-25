import '../configuration/configuration.dart';
import 'background_service.dart';
import 'background_service_exception_behavior.dart';
import 'host.dart';
import 'hosted_service.dart';

/// Options for [Host].
class HostOptions {
  /// The default timeout for [Host.Stop(cancellationToken)].
  Duration? shutdownTimeout = const Duration(seconds: 30);

  /// The default timeout for [Host.start(cancellationToken)].
  Duration? startupTimeout;

  /// Determines if the [Host] will start registered instances of
  /// [HostedService] concurrently or sequentially.
  ///
  /// Defaults to false.
  bool servicesStartConcurrently = false;

  /// Determines if the [Host] will stop registered instances of
  /// [HostedService] concurrently or sequentially.
  ///
  /// Defaults to false.
  bool servicesStopConcurrently = false;

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

    timeoutSeconds = configuration['startupTimeoutSeconds'];
    if (timeoutSeconds != null) {
      if (timeoutSeconds.isNotEmpty) {
        startupTimeout = Duration(seconds: int.parse(timeoutSeconds));
      }
    }

    var servicesStartConcurrently = configuration['servicesStartConcurrently'];
    if (servicesStartConcurrently != null) {
      if (servicesStartConcurrently.isNotEmpty) {
        this.servicesStartConcurrently = bool.parse(servicesStartConcurrently);
      }
    }

    var servicesStopConcurrently = configuration['servicesStopConcurrently'];
    if (servicesStopConcurrently != null) {
      if (servicesStopConcurrently.isNotEmpty) {
        this.servicesStopConcurrently = bool.parse(servicesStopConcurrently);
      }
    }

    var backgroundServiceExceptionBehaviorConfig =
        configuration['backgroundServiceExceptionBehavior'];
    if (backgroundServiceExceptionBehaviorConfig != null &&
        backgroundServiceExceptionBehaviorConfig.isNotEmpty) {
      switch (backgroundServiceExceptionBehaviorConfig.toLowerCase()) {
        case 'stophost':
          backgroundServiceExceptionBehavior =
              BackgroundServiceExceptionBehavior.stopHost;
          break;
        case 'ignore':
          backgroundServiceExceptionBehavior =
              BackgroundServiceExceptionBehavior.ignore;
          break;
      }
    }
  }
}
