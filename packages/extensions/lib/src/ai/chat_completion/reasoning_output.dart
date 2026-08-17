/// Specifies how reasoning content should be included in the response.
///
/// Some providers support including reasoning or thinking traces in the
/// response. This controls whether and how that content is exposed.
enum ReasoningOutput {
  /// Do not include reasoning content in the response.
  none,

  /// Include a summary of the reasoning process.
  summary,

  /// Include all reasoning content in the response.
  full,
}
