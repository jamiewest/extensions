import 'package:extensions/annotations.dart';

import '../additional_properties_dictionary.dart';
import '../response_continuation_token.dart';
import '../tools/ai_tool.dart';
import 'chat_response_format.dart';
import 'chat_tool_mode.dart';

/// Represents the options for a chat request.
@Source(
  name: 'ChatOptions.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/ChatCompletion/',
  commit: '19172fa728d335d112581b4e75f5762903281f60',
)
class ChatOptions {
  /// Creates a new [ChatOptions].
  ChatOptions({
    this.conversationId,
    this.modelId,
    this.temperature,
    this.topP,
    this.topK,
    this.maxOutputTokens,
    this.seed,
    this.frequencyPenalty,
    this.presencePenalty,
    this.responseFormat,
    this.stopSequences,
    this.instructions,
    this.tools,
    this.toolMode,
    this.allowMultipleToolCalls,
    this.continuationToken,
    this.additionalProperties,
  });

  /// Associates this request with a conversation.
  String? conversationId;

  /// The model to use for the request.
  String? modelId;

  /// Controls randomness in the response (0.0 - 2.0).
  double? temperature;

  /// Nucleus sampling factor (0.0 - 1.0).
  double? topP;

  /// Number of most probable tokens to consider.
  int? topK;

  /// Maximum number of tokens to generate.
  int? maxOutputTokens;

  /// Seed for reproducible generation.
  int? seed;

  /// Penalty for token frequency to reduce repetitions.
  double? frequencyPenalty;

  /// Penalty for token presence to reduce repetition.
  double? presencePenalty;

  /// The desired response format.
  ChatResponseFormat? responseFormat;

  /// Sequences that cause the model to stop generating.
  List<String>? stopSequences;

  /// Per-request instructions for the model.
  String? instructions;

  /// Tools available for the model to use.
  List<AITool>? tools;

  /// How the model should use the provided tools.
  ChatToolMode? toolMode;

  /// Whether the model may make multiple tool calls per response.
  bool? allowMultipleToolCalls;

  /// A token to resume an interrupted response.
  ResponseContinuationToken? continuationToken;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Creates a deep copy of this [ChatOptions].
  ChatOptions clone() => ChatOptions(
        conversationId: conversationId,
        modelId: modelId,
        temperature: temperature,
        topP: topP,
        topK: topK,
        maxOutputTokens: maxOutputTokens,
        seed: seed,
        frequencyPenalty: frequencyPenalty,
        presencePenalty: presencePenalty,
        responseFormat: responseFormat,
        stopSequences:
            stopSequences != null ? List<String>.of(stopSequences!) : null,
        instructions: instructions,
        tools: tools != null ? List<AITool>.of(tools!) : null,
        toolMode: toolMode,
        allowMultipleToolCalls: allowMultipleToolCalls,
        continuationToken: continuationToken,
        additionalProperties:
            additionalProperties != null ? Map.of(additionalProperties!) : null,
      );
}
