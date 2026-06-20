import 'package:extensions/annotations.dart';

import 'realtime_server_message_type.dart';

/// Represents a real-time server response message.
///
/// This is an experimental feature.
@Source(
  name: 'RealtimeServerMessage.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class RealtimeServerMessage {
  /// Creates a new [RealtimeServerMessage] with the given [type].
  RealtimeServerMessage(this.type);

  /// The type of the real-time response.
  RealtimeServerMessageType type;

  /// The optional message ID associated with the response.
  ///
  /// This can be used for tracking and correlation purposes.
  String? messageId;

  /// The raw representation of the response.
  ///
  /// This can be used to hold the original data structure received from the
  /// model.
  Object? rawRepresentation;
}
