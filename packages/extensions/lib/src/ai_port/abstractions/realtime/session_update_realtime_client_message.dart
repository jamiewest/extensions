import 'realtime_client_message.dart';
import 'realtime_session_options.dart';

/// Represents a client message that requests updating the session
/// configuration.
///
/// Remarks: Sending this message requests that the provider update the active
/// session with new options. Not all providers support mid-session updates.
/// Providers that do not support this message may ignore it or throw a
/// [NotSupportedException]. When a provider processes this message, it should
/// update its [Options] property to reflect the new configuration.
class SessionUpdateRealtimeClientMessage extends RealtimeClientMessage {
  /// Initializes a new instance of the [SessionUpdateRealtimeClientMessage]
  /// class.
  ///
  /// [options] The session options to apply.
  const SessionUpdateRealtimeClientMessage(RealtimeSessionOptions options)
    : options = Throw.ifNull(options);

  /// Gets or sets the session options to apply.
  RealtimeSessionOptions options;
}
