import 'package:extensions/annotations.dart';

import 'realtime_server_message.dart';

/// A server message carrying incremental or complete text/audio output.
///
/// This is an experimental feature.
@Source(
  name: 'OutputTextAudioRealtimeServerMessage.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class OutputTextAudioRealtimeServerMessage extends RealtimeServerMessage {
  /// Creates a new [OutputTextAudioRealtimeServerMessage] with the given
  /// [type].
  OutputTextAudioRealtimeServerMessage(super.type);

  /// The index of the content part.
  int? contentIndex;

  /// The text output.
  String? text;

  /// The audio output.
  String? audio;

  /// The ID of the item.
  String? itemId;

  /// The index of the output item.
  int? outputIndex;

  /// The ID of the response.
  String? responseId;
}
