import 'package:extensions/annotations.dart';

import '../additional_properties_dictionary.dart';
import '../error_content.dart';
import '../usage_details.dart';
import 'realtime_audio_format.dart';
import 'realtime_conversation_item.dart';
import 'realtime_server_message.dart';

/// A server message indicating that a response has been created or completed.
///
/// This is an experimental feature.
@Source(
  name: 'ResponseCreatedRealtimeServerMessage.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class ResponseCreatedRealtimeServerMessage extends RealtimeServerMessage {
  /// Creates a new [ResponseCreatedRealtimeServerMessage] with the given
  /// [type].
  ResponseCreatedRealtimeServerMessage(super.type);

  /// The output audio format for the response.
  RealtimeAudioFormat? outputAudioOptions;

  /// The output voice for the response.
  String? outputVoice;

  /// The ID of the response.
  String? responseId;

  /// The maximum number of response tokens.
  int? maxOutputTokens;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;

  /// The conversation items associated with the response.
  List<RealtimeConversationItem>? items;

  /// The output modalities for the response.
  List<String>? outputModalities;

  /// The response status.
  String? status;

  /// The error content, if the response failed.
  ErrorContent? error;

  /// Usage details for the response.
  UsageDetails? usage;
}
