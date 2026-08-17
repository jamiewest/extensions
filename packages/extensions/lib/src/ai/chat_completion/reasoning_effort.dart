/// Specifies the level of reasoning effort to apply when generating responses.
///
/// Higher values may produce more thoughtful responses but with increased
/// latency and token usage. Support for each level varies by provider.
enum ReasoningEffort {
  /// No reasoning effort.
  none,

  /// Minimal reasoning for faster responses.
  low,

  /// Balanced reasoning for most use cases.
  medium,

  /// Extensive reasoning for complex tasks.
  high,

  /// Maximum reasoning for the most demanding tasks.
  extraHigh,
}
