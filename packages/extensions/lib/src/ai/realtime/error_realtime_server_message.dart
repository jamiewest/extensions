import 'package:extensions/annotations.dart';

import '../error_content.dart';
import 'realtime_server_message.dart';
import 'realtime_server_message_type.dart';

/// A server message indicating that an error occurred.
///
/// This is an experimental feature.
@Source(
  name: 'ErrorRealtimeServerMessage.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class ErrorRealtimeServerMessage extends RealtimeServerMessage {
  /// Creates a new [ErrorRealtimeServerMessage].
  ErrorRealtimeServerMessage() : super(RealtimeServerMessageType.error);

  /// The error content.
  ErrorContent? error;

  /// The ID of the message that originated the error.
  String? originatingMessageId;
}
