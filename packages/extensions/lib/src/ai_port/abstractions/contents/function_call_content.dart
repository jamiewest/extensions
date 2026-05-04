import '../../../../../../lib/func_typedefs.dart';
import '../../open_telemetry_consts.dart';
import 'tool_call_content.dart';

/// Represents a function call request.
class FunctionCallContent extends ToolCallContent {
  /// Initializes a new instance of the [FunctionCallContent] class.
  ///
  /// [callId] The function call ID.
  ///
  /// [name] The function name.
  ///
  /// [arguments] The function original arguments.
  FunctionCallContent(
    String callId,
    String name, {
    Map<String, Object?>? arguments = null,
  }) : name = Throw.ifNull(name),
       arguments = arguments;

  /// Gets the name of the function requested.
  final String name;

  /// Gets or sets the arguments requested to be provided to the function.
  Map<String, Object?>? arguments;

  /// Gets or sets any exception that occurred while mapping the original
  /// function call data to this class.
  ///
  /// Remarks: This property is for information purposes only. The [Exception]
  /// is not serialized as part of serializing instances of this class with
  /// [JsonSerializer]; as such, upon deserialization, this property will be
  /// `null`. Consumers should not rely on `null` indicating success.
  Exception? exception;

  /// Gets or sets a value indicating whether this function call is purely
  /// informational.
  ///
  /// Remarks: This property defaults to `false`, indicating that the function
  /// call should be processed. When set to `true`, it indicates that the
  /// function has already been processed or is otherwise purely informational
  /// and should be ignored by components that process function calls.
  bool informationalOnly;

  /// Gets a string representing this instance to display in the debugger.
  final String debuggerDisplay;

  /// Creates a new instance of [FunctionCallContent] parsing arguments using a
  /// specified encoding and parser.
  ///
  /// Returns: A new instance of [FunctionCallContent] containing the parse
  /// result.
  ///
  /// [encodedArguments] The input arguments encoded in `TEncoding`.
  ///
  /// [callId] The function call ID.
  ///
  /// [name] The function name.
  ///
  /// [argumentParser] The parsing implementation converting the encoding to a
  /// dictionary of arguments.
  ///
  /// [TEncoding] The encoding format from which to parse function call
  /// arguments.
  static FunctionCallContent createFromParsedArguments<TEncoding>(
    TEncoding encodedArguments,
    String callId,
    String name,
    Func<TEncoding, Map<String, Object?>?> argumentParser,
  ) {
    _ = Throw.ifNull(encodedArguments);
    _ = Throw.ifNull(callId);
    _ = Throw.ifNull(name);
    _ = Throw.ifNull(argumentParser);
    var arguments = null;
    var parsingException = null;
    try {
      arguments = argumentParser(encodedArguments);
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {
          parsingException = invalidOperationException(
            "Error parsing function call arguments.",
            ex,
          );
        }
      } else {
        rethrow;
      }
    }
    return functionCallContent(callId, name, arguments);
  }
}
