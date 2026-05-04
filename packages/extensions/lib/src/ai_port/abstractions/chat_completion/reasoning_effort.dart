/// Specifies the level of reasoning effort that should be applied when
/// generating chat responses.
///
/// Remarks: This value suggests how much computational effort the model
/// should put into reasoning. Higher values may result in more thoughtful
/// responses but with increased latency and token usage. The specific
/// interpretation and support for each level may vary between providers or
/// even between models from the same provider.
enum ReasoningEffort {
  /// No reasoning effort.
  none,

  /// Low reasoning effort. Minimal reasoning for faster responses.
  low,

  /// Medium reasoning effort. Balanced reasoning for most use cases.
  medium,

  /// High reasoning effort. Extensive reasoning for complex tasks.
  high,

  /// Extra high reasoning effort. Maximum reasoning for the most demanding
  /// tasks.
  extraHigh,
}
