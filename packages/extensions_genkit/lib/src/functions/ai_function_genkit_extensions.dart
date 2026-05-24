import 'package:extensions/ai.dart';
import 'package:genkit/genkit.dart';

/// Extensions for converting [AIFunction] instances to Genkit types.
extension AIFunctionGenkitExtensions on AIFunction {
  /// Converts this function's metadata to a Genkit [ToolDefinition].
  ToolDefinition toGenkitToolDefinition() => ToolDefinition(
        name: name,
        description: description ?? name,
        inputSchema: parametersSchema,
      );

  /// Wraps this function as a Genkit [Tool] so it can be passed to
  /// [Genkit.generate] or [Genkit.generateStream].
  ///
  /// When called with `returnToolRequests: true` the tool's [fn] is never
  /// invoked by Genkit; [FunctionInvokingChatClient] middleware handles it.
  Tool<Map<String, dynamic>?, dynamic> toGenkitTool() =>
      Tool<Map<String, dynamic>?, dynamic>(
        name: name,
        description: description ?? name,
        fn: (input, _) async {
          final args = input != null
              ? AIFunctionArguments(input)
              : AIFunctionArguments();
          return invokeCore(args);
        },
      );
}
