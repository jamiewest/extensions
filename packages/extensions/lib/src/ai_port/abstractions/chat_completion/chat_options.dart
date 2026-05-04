import '../../../../../../lib/func_typedefs.dart';
import '../response_continuation_token.dart';
import '../tools/ai_tool.dart';
import 'chat_client.dart';
import 'chat_message.dart';
import 'chat_response_format.dart';
import 'chat_response_format_json.dart';
import 'chat_tool_mode.dart';
import 'reasoning_options.dart';

/// Represents the options for a chat request.
class ChatOptions {
  /// Initializes a new instance of the [ChatOptions] class, performing a
  /// shallow copy of all properties from `other`.
  ChatOptions(ChatOptions? other) : additionalProperties = other.additionalProperties?.clone(), allowBackgroundResponses = other.allowBackgroundResponses, allowMultipleToolCalls = other.allowMultipleToolCalls, conversationId = other.conversationId, continuationToken = other.continuationToken, frequencyPenalty = other.frequencyPenalty, instructions = other.instructions, maxOutputTokens = other.maxOutputTokens, modelId = other.modelId, presencePenalty = other.presencePenalty, rawRepresentationFactory = other.rawRepresentationFactory, reasoning = other.reasoning?.clone(), responseFormat = other.responseFormat, seed = other.seed, temperature = other.temperature, toolMode = other.toolMode, topK = other.topK, topP = other.topP {
    if (other == null) {
      return;
    }
    if (other.stopSequences != null) {
      stopSequences = [.. other.stopSequences];
    }
    if (other.tools != null) {
      tools = [.. other.tools];
    }
  }

  /// Gets or sets an optional identifier used to associate a request with an
  /// existing conversation.
  String? conversationId;

  /// Gets or sets additional per-request instructions to be provided to the
  /// [ChatClient].
  String? instructions;

  /// Gets or sets the temperature for generating chat responses.
  ///
  /// Remarks: This value controls the randomness of predictions made by the
  /// model. Use a lower value to decrease randomness in the response.
  double? temperature;

  /// Gets or sets the maximum number of tokens in the generated chat response.
  int? maxOutputTokens;

  /// Gets or sets the "nucleus sampling" factor (or "top p") for generating
  /// chat responses.
  ///
  /// Remarks: Nucleus sampling is an alternative to sampling with temperature
  /// where the model considers the results of the tokens with [TopP]
  /// probability mass. For example, 0.1 means only the tokens comprising the
  /// top 10% probability mass are considered.
  double? topP;

  /// Gets or sets the number of most probable tokens that the model considers
  /// when generating the next part of the text.
  ///
  /// Remarks: This property reduces the probability of generating nonsense. A
  /// higher value gives more diverse answers, while a lower value is more
  /// conservative.
  int? topK;

  /// Gets or sets the penalty for repeated tokens in chat responses
  /// proportional to how many times they've appeared.
  ///
  /// Remarks: You can modify this value to reduce the repetitiveness of
  /// generated tokens. The higher the value, the stronger a penalty is applied
  /// to previously present tokens, proportional to how many times they've
  /// already appeared in the prompt or prior generation.
  double? frequencyPenalty;

  /// Gets or sets a value that influences the probability of generated tokens
  /// appearing based on their existing presence in generated text.
  ///
  /// Remarks: You can modify this value to reduce repetitiveness of generated
  /// tokens. Similar to [FrequencyPenalty], except that this penalty is applied
  /// equally to all tokens that have already appeared, regardless of their
  /// exact frequencies.
  double? presencePenalty;

  /// Gets or sets a seed value used by a service to control the reproducibility
  /// of results.
  long? seed;

  /// Gets or sets the reasoning options for the chat request.
  ReasoningOptions? reasoning;

  /// Gets or sets the response format for the chat request.
  ///
  /// Remarks: If `null`, no response format is specified and the client will
  /// use its default. This property can be set to [Text] to specify that the
  /// response should be unstructured text, to [Json] to specify that the
  /// response should be structured JSON data, or an instance of
  /// [ChatResponseFormatJson] constructed with a specific JSON schema to
  /// request that the response be structured JSON data according to that
  /// schema. It is up to the client implementation if or how to honor the
  /// request. If the client implementation doesn't recognize the specific kind
  /// of [ChatResponseFormat], it can be ignored.
  ChatResponseFormat? responseFormat;

  /// Gets or sets the model ID for the chat request.
  String? modelId;

  /// Gets or sets the list of stop sequences.
  ///
  /// Remarks: After a stop sequence is detected, the model stops generating
  /// further tokens for chat responses.
  List<String>? stopSequences;

  /// Gets or sets a value that indicates whether a single response is allowed
  /// to include multiple tool calls.
  ///
  /// Remarks: When used with function calling middleware, this does not affect
  /// the ability to perform multiple function calls in sequence. It only
  /// affects the number of function calls within a single iteration of the
  /// function calling loop. The underlying provider is not guaranteed to
  /// support or honor this flag. For example it might choose to ignore it and
  /// return multiple tool calls regardless.
  bool? allowMultipleToolCalls;

  /// Gets or sets the tool mode for the chat request.
  ChatToolMode? toolMode;

  /// Gets or sets the list of tools to include with a chat request.
  List<ATool>? tools;

  /// Gets or sets a value indicating whether the background responses are
  /// allowed.
  ///
  /// Remarks: Background responses allow running long-running operations or
  /// tasks asynchronously in the background that can be resumed by streaming
  /// APIs and polled for completion by non-streaming APIs. When this property
  /// is set to `true`, non-streaming APIs have permission to start a background
  /// operation and return an initial response with a continuation token.
  /// Subsequent calls to the same API should be made in a polling manner with
  /// the continuation token to get the final result of the operation. When this
  /// property is set to `true`, streaming APIs are also permitted to start a
  /// background operation and begin streaming response updates until the
  /// operation is completed. If the streaming connection is interrupted, the
  /// continuation token obtained from the last update that has one should be
  /// supplied to a subsequent call to the same streaming API to resume the
  /// stream from the point of interruption and continue receiving updates until
  /// the operation is completed. This property only takes effect if the
  /// implementation it's used with supports background responses. If the
  /// implementation does not support background responses, this property will
  /// be ignored.
  bool? allowBackgroundResponses;

  bool? allowBackgroundResponsesCore;

  /// Gets or sets the continuation token for resuming and getting the result of
  /// the chat response identified by this token.
  ///
  /// Remarks: This property is used for background responses that can be
  /// activated via the [AllowBackgroundResponses] property if the [ChatClient]
  /// implementation supports them. Streamed background responses, such as those
  /// returned by default by [CancellationToken)], can be resumed if
  /// interrupted. This means that a continuation token obtained from the
  /// [ContinuationToken] of an update just before the interruption occurred can
  /// be passed to this property to resume the stream from the point of
  /// interruption. Non-streamed background responses, such as those returned by
  /// [CancellationToken)], can be polled for completion by obtaining the token
  /// from the [ContinuationToken] property and passing it to this property on
  /// subsequent calls to [CancellationToken)].
  ResponseContinuationToken? continuationToken;

  ResponseContinuationToken? continuationTokenCore;

  /// Gets or sets a callback responsible for creating the raw representation of
  /// the chat options from an underlying implementation.
  ///
  /// Remarks: The underlying [ChatClient] implementation might have its own
  /// representation of options. When [CancellationToken)] or
  /// [CancellationToken)] is invoked with a [ChatOptions], that implementation
  /// might convert the provided options into its own representation in order to
  /// use it while performing the operation. For situations where a consumer
  /// knows which concrete [ChatClient] is being used and how it represents
  /// options, a new instance of that implementation-specific options type can
  /// be returned by this callback for the [ChatClient] implementation to use,
  /// instead of creating a new instance. Such implementations might mutate the
  /// supplied options instance further based on other settings supplied on this
  /// [ChatOptions] instance or from other inputs, like the enumerable of
  /// [ChatMessage]s. Therefore, it is strongly recommended to not return shared
  /// instances and instead make the callback return a new instance on each
  /// call. This is typically used to set an implementation-specific setting
  /// that isn't otherwise exposed from the strongly typed properties on
  /// [ChatOptions].
  Func<ChatClient, Object?>? rawRepresentationFactory;

  /// Gets or sets any additional properties associated with the options.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Produces a clone of the current [ChatOptions] instance.
  ///
  /// Remarks: The clone will have the same values for all properties as the
  /// original instance. Any collections, like [Tools], [StopSequences], and
  /// [AdditionalProperties], are shallow-cloned, meaning a new collection
  /// instance is created, but any references contained by the collections are
  /// shared with the original. Derived types should override [Clone] to return
  /// an instance of the derived type.
  ///
  /// Returns: A clone of the current [ChatOptions] instance.
  ChatOptions clone() {
    return new(this);
  }
}
