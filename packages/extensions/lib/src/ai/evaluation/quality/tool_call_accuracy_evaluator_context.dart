import 'package:extensions/annotations.dart';

import '../../functions/ai_function_declaration.dart';
import '../../text_content.dart';
import '../../tools/ai_tool.dart';
import '../evaluation_context.dart';

/// Context for [ToolCallAccuracyEvaluator]: the tool definitions used when
/// generating the response.
@Source(
  name: 'ToolCallAccuracyEvaluatorContext.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Quality',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Quality/',
)
class ToolCallAccuracyEvaluatorContext extends EvaluationContext {
  /// Creates a [ToolCallAccuracyEvaluatorContext] with [toolDefinitions].
  ToolCallAccuracyEvaluatorContext({List<AITool>? toolDefinitions})
      : toolDefinitions = List.unmodifiable(toolDefinitions ?? const []),
        super(
          toolDefinitionsContextName,
          contents: [
            for (final t in toolDefinitions ?? const <AITool>[])
              if (t is AIFunctionDeclaration)
                TextContent(
                  '${t.name}: ${t.description ?? ""}'
                  '${t.parametersSchema != null ? " | params: ${t.parametersSchema}" : ""}',
                ),
          ],
        );

  /// Unique context name used when recording contexts on metrics.
  static const String toolDefinitionsContextName =
      'Tool definitions(Tool Call Accuracy)';

  /// The tool definitions available when generating the response.
  final List<AITool> toolDefinitions;
}
