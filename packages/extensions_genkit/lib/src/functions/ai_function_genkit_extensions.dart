import 'package:extensions/ai.dart';
import 'package:genkit/genkit.dart';

/// Extensions for converting [AIFunction] instances to Genkit types.
extension AIFunctionGenkitExtensions on AIFunction {
  /// Converts this function's metadata to a Genkit [ToolDefinition].
  ///
  /// Maps [AIFunction.name], [AIFunction.description], and
  /// [AIFunction.parametersSchema] to the corresponding [ToolDefinition]
  /// fields. Falls back to [name] when [description] is null.
  ToolDefinition toGenkitToolDefinition() => ToolDefinition(
        name: name,
        description: description ?? name,
        inputSchema: parametersSchema,
      );

  /// Wraps this function as a Genkit [Tool] suitable for passing to
  /// [Genkit.generate] or [Genkit.generateStream].
  ///
  /// The tool's callback invokes this function via [AIFunction.invokeCore]
  /// with the input deserialized into [AIFunctionArguments]. A `null`
  /// input map is treated as an empty argument set.
  Tool<Map<String, dynamic>?, dynamic> toGenkitTool() =>
      Tool<Map<String, dynamic>?, dynamic>(
        name: name,
        description: description ?? name,
        fn: (input, _) async {
          // Null input is valid when the tool takes no arguments.
          final args = input != null
              ? AIFunctionArguments(input)
              : AIFunctionArguments();
          return invokeCore(args);
        },
      );
}
