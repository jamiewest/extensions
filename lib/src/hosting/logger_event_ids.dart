import '../logging/event_id.dart';

class LoggerEventIds {
  static EventId starting = const EventId(1, 'Starting');
  static EventId started = const EventId(2, 'Started');
  static EventId stopping = const EventId(1, 'Stopping');
  static EventId stopped = const EventId(1, 'Stopped');
  static EventId stoppedWithException =
      const EventId(1, 'StoppedWithException');
  static EventId applicationStartupException =
      const EventId(1, 'ApplicationStartupException');
  static EventId applicationStoppingException =
      const EventId(1, 'ApplicationStoppingException');
  static EventId applicationStoppedException =
      const EventId(1, 'ApplicationStoppedException');
  static EventId backgoundServiceFaulted =
      const EventId(1, 'BackgroundServiceFaulted');
}
