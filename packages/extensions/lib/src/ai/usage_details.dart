import 'additional_properties_dictionary.dart';

/// Provides usage details about a request/response.
class UsageDetails {
  /// Creates a new [UsageDetails].
  UsageDetails({
    this.inputTokenCount,
    this.outputTokenCount,
    this.totalTokenCount,
    this.cachedInputTokenCount,
    this.reasoningTokenCount,
    this.additionalCounts,
    this.additionalProperties,
  });

  /// The number of input tokens used.
  int? inputTokenCount;

  /// The number of output tokens generated.
  int? outputTokenCount;

  /// The total number of tokens used.
  int? totalTokenCount;

  /// The number of input tokens that were served from cache.
  int? cachedInputTokenCount;

  /// The number of tokens used for reasoning.
  int? reasoningTokenCount;

  /// Additional usage counts not covered by the standard properties.
  Map<String, int>? additionalCounts;

  /// Additional properties.
  AdditionalPropertiesDictionary? additionalProperties;

  /// Adds the usage details from [other] into this instance.
  void add(UsageDetails other) {
    inputTokenCount = _addNullable(inputTokenCount, other.inputTokenCount);
    outputTokenCount = _addNullable(outputTokenCount, other.outputTokenCount);
    totalTokenCount = _addNullable(totalTokenCount, other.totalTokenCount);
    cachedInputTokenCount =
        _addNullable(cachedInputTokenCount, other.cachedInputTokenCount);
    reasoningTokenCount =
        _addNullable(reasoningTokenCount, other.reasoningTokenCount);

    if (other.additionalCounts != null) {
      additionalCounts ??= {};
      for (final entry in other.additionalCounts!.entries) {
        additionalCounts![entry.key] =
            (additionalCounts![entry.key] ?? 0) + entry.value;
      }
    }
  }

  static int? _addNullable(int? a, int? b) {
    if (a == null && b == null) return null;
    return (a ?? 0) + (b ?? 0);
  }
}
