/// Specifies how reasoning content should be included in the response.
///
/// Remarks: Some providers support including reasoning or thinking traces in
/// the response. This setting controls whether and how that reasoning content
/// is exposed.
enum ReasoningOutput {
  /// No reasoning output. Do not include reasoning content in the response.
  none,

  /// Summary reasoning output. Include a summary of the reasoning process.
  summary,

  /// Full reasoning output. Include all reasoning content in the response.
  full,
}
