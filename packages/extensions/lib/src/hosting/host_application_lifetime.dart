import '../shared/cancellation_token.dart';

/// Allows consumers to be notified of application lifetime events.
/// This interface is not intended to be user-replaceable.
abstract class HostApplicationLifetime {
  /// Triggered when the application host has fully started.
  CancellationToken get applicationStarted;

  /// Triggered when the application host is starting a graceful shutdown.
  /// Shutdown will block until all callbacks registered on this token
  /// have completed.
  CancellationToken get applicationStopping;

  /// Triggered when the application host has completed a graceful shutdown.
  /// The application will not exit until all callbacks registered on this
  /// token have completed.
  CancellationToken get applicationStopped;

  /// Requests termination of the current application.
  void stopApplication();
}
