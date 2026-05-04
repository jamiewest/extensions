import 'package:extensions/annotations.dart';

import 'reasoning_effort.dart';
import 'reasoning_output.dart';

/// Options for configuring reasoning behavior in chat requests.
///
/// Not all providers support all reasoning options. Implementations should
/// make a best-effort attempt to map these options to provider capabilities.
/// If a provider does not support reasoning, these options may be ignored.
@Source(
  name: 'ReasoningOptions.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/ChatCompletion/',
)
class ReasoningOptions {
  /// Creates a new [ReasoningOptions].
  ReasoningOptions({this.effort, this.output});

  /// The level of reasoning effort to apply.
  ReasoningEffort? effort;

  /// How reasoning content should be included in the response.
  ReasoningOutput? output;

  /// Creates a shallow clone of this [ReasoningOptions].
  ReasoningOptions clone() => ReasoningOptions(effort: effort, output: output);
}
