import 'package:extensions/annotations.dart';

import '../../usage_details.dart';

/// Details for a single LLM chat conversation turn in a [ScenarioRun].
@Source(
  name: 'ChatTurnDetails.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Reporting',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Reporting/',
)
class ChatTurnDetails {
  /// Creates [ChatTurnDetails].
  ChatTurnDetails({
    required this.latency,
    this.model,
    this.modelProvider,
    this.usage,
    this.cacheKey,
    this.cacheHit,
  });

  /// Time between the request being sent and the response being received.
  Duration latency;

  /// Model that produced the response, or `null` if unavailable.
  String? model;

  /// Provider of [model], or `null` if unavailable.
  String? modelProvider;

  /// Token usage for this turn, or `null` if unavailable.
  UsageDetails? usage;

  /// Cache key when response caching is enabled; `null` otherwise.
  String? cacheKey;

  /// Whether the response was a cache hit; `null` when caching is disabled.
  bool? cacheHit;
}
