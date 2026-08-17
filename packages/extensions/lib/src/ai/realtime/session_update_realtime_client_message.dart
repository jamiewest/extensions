import 'realtime_client_message.dart';
import 'realtime_session_options.dart';

/// A client message that updates the session options.
///
/// This is an experimental feature.
class SessionUpdateRealtimeClientMessage extends RealtimeClientMessage {
  /// Creates a new [SessionUpdateRealtimeClientMessage] with the given
  /// [options].
  SessionUpdateRealtimeClientMessage(this.options);

  /// The session options to apply.
  RealtimeSessionOptions options;
}
