import 'tool_result_content.dart';

/// Represents the result of a function call.
class FunctionResultContent extends ToolResultContent {
  /// Initializes a new instance of the [FunctionResultContent] class.
  ///
  /// [callId] The function call ID for which this is the result.
  ///
  /// [result] `null` if the function returned `null` or was void-returning and
  /// thus had no result, or if the function call failed. Typically, however, to
  /// provide meaningfully representative information to an AI service, a
  /// human-readable representation of those conditions should be supplied.
  const FunctionResultContent(String callId, Object? result) : result = result;

  /// Gets or sets the result of the function call, or a generic error message
  /// if the function call failed.
  ///
  /// Remarks: `null` if the function returned `null` or was void-returning and
  /// thus had no result, or if the function call failed. Typically, however, to
  /// provide meaningfully representative information to an AI service, a
  /// human-readable representation of those conditions should be supplied.
  Object? result;

  /// Gets or sets an exception that occurred if the function call failed.
  ///
  /// Remarks: This property is for informational purposes only. The [Exception]
  /// is not serialized as part of serializing instances of this class with
  /// [JsonSerializer]. As such, upon deserialization, this property will be
  /// `null`. Consumers should not rely on `null` indicating success.
  Exception? exception;

  /// Gets a string representing this instance to display in the debugger.
  final String debuggerDisplay;
}
