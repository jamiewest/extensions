import 'background_service.dart';
import 'host.dart';

/// Specifies a behavior that the [Host] will honor if an unhandled
/// exception occurs in one of its [BackgroundService] instances.
enum BackgroundServiceExceptionBehavior {
  /// Stops the [Host] instance.
  ///
  /// If a [BackgroundService] throws an exception, the [Host] instance is
  /// stopped, usually leading to the termination of the process.
  ///
  /// The faulting exception is logged, and the application is asked to stop;
  /// it is not re-thrown from [Host.stop].
  stopHost,

  /// Ignore exceptions thrown in [BackgroundService].
  ///
  /// If a [BackgroundService] throws an exception, the [Host] will log the
  /// error, but otherwise ignore it. The [BackgroundService] is not restarted.
  ignore,
}
