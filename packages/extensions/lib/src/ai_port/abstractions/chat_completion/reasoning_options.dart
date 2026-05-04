import 'reasoning_effort.dart';
import 'reasoning_output.dart';

/// Represents options for configuring reasoning behavior in chat requests.
///
/// Remarks: Reasoning options allow control over how much computational
/// effort the model should put into reasoning about the response, and how
/// that reasoning should be exposed to the caller. Not all providers support
/// all reasoning options. Implementations should make a best-effort attempt
/// to map the requested options to the provider's capabilities. If a provider
/// or model doesn't support reasoning or doesn't support the requested
/// configuration of reasoning, these options may be ignored.
class ReasoningOptions {
  ReasoningOptions();

  /// Gets or sets the level of reasoning effort to apply.
  ReasoningEffort? effort;

  /// Gets or sets how reasoning content should be included in the response.
  ReasoningOutput? output;

  /// Creates a shallow clone of this [ReasoningOptions] instance.
  ///
  /// Returns: A shallow clone of this instance.
  ReasoningOptions clone() {
    return new()
    {
        effort = effort,
        output = output,
    };
  }
}
