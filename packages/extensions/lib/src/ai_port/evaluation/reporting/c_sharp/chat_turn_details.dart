import '../../../abstractions/chat_completion/chat_client.dart';
import '../../../abstractions/chat_completion/chat_client_metadata.dart';
import '../../../abstractions/usage_details.dart';
import 'scenario_run.dart';

/// A class that records details related to a particular LLM chat conversation
/// turn involved in the execution of a particular [ScenarioRun].
class ChatTurnDetails {
  /// Initializes a new instance of the [ChatTurnDetails] class.
  ///
  /// [latency] The duration between the time when the request was sent to the
  /// LLM and the time when the response was received for the chat conversation
  /// turn.
  ///
  /// [model] The model that was used in the creation of the response for the
  /// chat conversation turn. Can be `null` if this information was not
  /// available via [ModelId].
  ///
  /// [usage] Usage details for the chat conversation turn (including input and
  /// output token counts). Can be `null` if usage details were not available
  /// via [Usage].
  ///
  /// [cacheKey] The cache key for the cached model response for the chat
  /// conversation turn if response caching was enabled; `null` otherwise.
  ///
  /// [cacheHit] `true` if response caching was enabled and the model response
  /// for the chat conversation turn was retrieved from the cache; `false` if
  /// response caching was enabled and the model response was not retrieved from
  /// the cache; `null` if response caching was disabled.
  ChatTurnDetails(
    Duration latency,
    String? model,
    UsageDetails? usage,
    String? cacheKey,
    bool? cacheHit, {
    String? modelProvider = null,
  }) : latency = latency,
       model = model,
       usage = usage,
       cacheKey = cacheKey,
       cacheHit = cacheHit;

  /// Gets or sets the duration between the time when the request was sent to
  /// the LLM and the time when the response was received for the chat
  /// conversation turn.
  Duration latency;

  /// Gets or sets the model that was used in the creation of the response for
  /// the chat conversation turn.
  ///
  /// Remarks: Returns `null` if this information was not available via
  /// [ModelId].
  String? model;

  /// Gets or sets the name of the provider for the model identified by [Model].
  ///
  /// Remarks: Can be `null` if this information was not available via the
  /// [ChatClientMetadata] for the [ChatClient].
  String? modelProvider;

  /// Gets or sets usage details for the chat conversation turn (including input
  /// and output token counts).
  ///
  /// Remarks: Returns `null` if usage details were not available via [Usage].
  UsageDetails? usage;

  /// Gets or sets the cache key for the cached model response for the chat
  /// conversation turn.
  ///
  /// Remarks: Returns `null` if response caching was disabled.
  String? cacheKey;

  /// Gets or sets a value indicating whether the model response was retrieved
  /// from the cache.
  ///
  /// Remarks: Returns `null` if response caching was disabled.
  bool? cacheHit;
}
