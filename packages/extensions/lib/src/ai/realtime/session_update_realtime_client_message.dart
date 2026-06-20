import 'package:extensions/annotations.dart';

import 'realtime_client_message.dart';
import 'realtime_session_options.dart';

/// A client message that updates the session options.
///
/// This is an experimental feature.
@Source(
  name: 'SessionUpdateRealtimeClientMessage.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class SessionUpdateRealtimeClientMessage extends RealtimeClientMessage {
  /// Creates a new [SessionUpdateRealtimeClientMessage] with the given
  /// [options].
  SessionUpdateRealtimeClientMessage(this.options);

  /// The session options to apply.
  RealtimeSessionOptions options;
}
