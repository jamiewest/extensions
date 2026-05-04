import 'package:extensions/annotations.dart';

/// Specifies how reasoning content should be included in the response.
///
/// Some providers support including reasoning or thinking traces in the
/// response. This controls whether and how that content is exposed.
@Source(
  name: 'ReasoningOutput.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/ChatCompletion/',
)
enum ReasoningOutput {
  /// Do not include reasoning content in the response.
  none,

  /// Include a summary of the reasoning process.
  summary,

  /// Include all reasoning content in the response.
  full,
}
