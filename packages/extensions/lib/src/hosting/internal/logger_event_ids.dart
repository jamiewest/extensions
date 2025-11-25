import '../../logging/event_id.dart';

/// Adapted from [`Microsoft.Extensions.Hosting`](https://github.com/dotnet/runtime/tree/main/src/libraries/Microsoft.Extensions.Hosting/src/Internal)
class LoggerEventIds {
  static EventId starting = const EventId(1, 'Starting');
  static EventId started = const EventId(2, 'Started');
  static EventId stopping = const EventId(3, 'Stopping');
  static EventId stopped = const EventId(4, 'Stopped');
  static EventId stoppedWithException =
      const EventId(5, 'StoppedWithException');
  static EventId applicationStartupException =
      const EventId(6, 'ApplicationStartupException');
  static EventId applicationStoppingException =
      const EventId(7, 'ApplicationStoppingException');
  static EventId applicationStoppedException =
      const EventId(8, 'ApplicationStoppedException');
  static EventId backgroundServiceFaulted =
      const EventId(9, 'BackgroundServiceFaulted');
  static EventId backgroundServiceStoppingHost =
      const EventId(10, 'BackgroundServiceStoppingHost');
  static EventId hostedServiceStartupFaulted =
      const EventId(11, 'HostedServiceStartupFaulted');
}
