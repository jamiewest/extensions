import 'package:extensions/annotations.dart';

import '../additional_properties_dictionary.dart';
import '../chat_completion/chat_tool_mode.dart';
import '../tools/ai_tool.dart';
import 'realtime_audio_format.dart';
import 'realtime_client_message.dart';
import 'realtime_conversation_item.dart';

/// A client message that requests the model to create a response.
///
/// This is an experimental feature.
@Source(
  name: 'CreateResponseRealtimeClientMessage.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class CreateResponseRealtimeClientMessage extends RealtimeClientMessage {
  /// Creates a new [CreateResponseRealtimeClientMessage].
  CreateResponseRealtimeClientMessage({
    this.items,
    this.outputAudioOptions,
    this.outputVoice,
    this.excludeFromConversation,
    this.instructions,
    this.maxOutputTokens,
    this.additionalProperties,
    this.outputModalities,
    this.toolMode,
    this.tools,
  });

  /// The conversation items to include in the response request.
  List<RealtimeConversationItem>? items;

  /// The output audio format for the response.
  RealtimeAudioFormat? outputAudioOptions;

  /// The output voice for the response.
  String? outputVoice;

  /// Whether the response should be excluded from the conversation.
  bool? excludeFromConversation;

  /// The system instructions for the response.
  String? instructions;

  /// The maximum number of response tokens.
  int? maxOutputTokens;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;

  /// The output modalities for the response.
  List<String>? outputModalities;

  /// The tool choice mode for the response.
  ChatToolMode? toolMode;

  /// The AI tools available for generating the response.
  List<AITool>? tools;
}
