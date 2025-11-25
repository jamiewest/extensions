import 'background_service.dart';
import 'host.dart';

/// Specifies a behavior that the [Host] will honor if an unhandled
/// exception occurs in one of its [BackgroundService] instances.
enum BackgroundServiceExceptionBehavior {
  /// Stops the [Host] instance.
  stopHost,

  /// Ignore exceptions thrown in [BackgroundService].
  ignore,
}
