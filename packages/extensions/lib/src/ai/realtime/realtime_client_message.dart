import 'package:extensions/annotations.dart';

/// Represents a real-time message the client sends to the model.
///
/// This is an experimental feature.
@Source(
  name: 'RealtimeClientMessage.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class RealtimeClientMessage {
  /// Creates a new [RealtimeClientMessage].
  RealtimeClientMessage();

  /// The optional message ID associated with the message.
  ///
  /// This can be used for tracking and correlation purposes.
  String? messageId;

  /// The raw representation of the message.
  ///
  /// This can be used to send raw data to the model, typically for custom or
  /// unsupported message types.
  Object? rawRepresentation;
}
