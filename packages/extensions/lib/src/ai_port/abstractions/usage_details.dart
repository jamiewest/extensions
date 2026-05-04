/// Provides usage details about a request/response.
class UsageDetails {
  UsageDetails();

  /// Gets or sets the number of tokens in the input.
  long? inputTokenCount;

  /// Gets or sets the number of tokens in the output.
  long? outputTokenCount;

  /// Gets or sets the total number of tokens used to produce the response.
  long? totalTokenCount;

  /// Gets or sets the number of input tokens that were read from a cache.
  ///
  /// Remarks: Cached input tokens should be counted as part of
  /// [InputTokenCount].
  long? cachedInputTokenCount;

  /// Gets or sets the number of "reasoning" / "thinking" tokens used internally
  /// by the model.
  ///
  /// Remarks: Reasoning tokens should be counted as part of [OutputTokenCount].
  long? reasoningTokenCount;

  /// Gets or sets the number of audio input tokens used.
  ///
  /// Remarks: Audio input tokens should be counted as part of
  /// [InputTokenCount].
  long? inputAudioTokenCount;

  long? inputAudioTokenCountCore;

  /// Gets or sets the number of text input tokens used.
  ///
  /// Remarks: Text input tokens should be counted as part of [InputTokenCount].
  long? inputTextTokenCount;

  long? inputTextTokenCountCore;

  /// Gets or sets the number of audio output tokens used.
  ///
  /// Remarks: Audio output tokens should be counted as part of
  /// [OutputTokenCount].
  long? outputAudioTokenCount;

  long? outputAudioTokenCountCore;

  /// Gets or sets the number of text output tokens used.
  ///
  /// Remarks: Text output tokens should be counted as part of
  /// [OutputTokenCount].
  long? outputTextTokenCount;

  long? outputTextTokenCountCore;

  /// Gets or sets a dictionary of additional usage counts.
  ///
  /// Remarks: All values set here are assumed to be summable. For example, when
  /// middleware makes multiple calls to an underlying service, it may sum the
  /// counts from multiple results to produce an overall [UsageDetails].
  AdditionalPropertiesDictionary<long>? additionalCounts;

  /// Gets a string representing this instance to display in the debugger.
  final String debuggerDisplay;

  /// Adds usage data from another [UsageDetails] into this instance.
  ///
  /// [usage] The source [UsageDetails] with which to augment this instance.
  void add(UsageDetails usage) {
    _ = Throw.ifNull(usage);
    inputTokenCount = nullableSum(inputTokenCount, usage.inputTokenCount);
    outputTokenCount = nullableSum(outputTokenCount, usage.outputTokenCount);
    totalTokenCount = nullableSum(totalTokenCount, usage.totalTokenCount);
    cachedInputTokenCount = nullableSum(cachedInputTokenCount, usage.cachedInputTokenCount);
    reasoningTokenCount = nullableSum(reasoningTokenCount, usage.reasoningTokenCount);
    inputAudioTokenCount = nullableSum(inputAudioTokenCount, usage.inputAudioTokenCount);
    inputTextTokenCount = nullableSum(inputTextTokenCount, usage.inputTextTokenCount);
    outputAudioTokenCount = nullableSum(outputAudioTokenCount, usage.outputAudioTokenCount);
    outputTextTokenCount = nullableSum(outputTextTokenCount, usage.outputTextTokenCount);
    if (usage.additionalCounts is { } countsToAdd) {
      if (additionalCounts == null) {
        additionalCounts = new(countsToAdd);
      } else {
        for (final kvp in countsToAdd) {
          additionalCounts[kvp.key] = additionalCounts.tryGetValue(kvp.key, out var existingValue) ?
                        kvp.value + existingValue :
                        kvp.value;
        }
      }
    }
  }

  static long? nullableSum(long? a, long? b, ) {
    return (a.hasValue || b.hasValue) ? (a ?? 0) + (b ?? 0) : null;
  }
}
