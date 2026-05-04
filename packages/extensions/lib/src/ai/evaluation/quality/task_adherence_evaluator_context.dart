import 'package:extensions/annotations.dart';

import '../../functions/ai_function_declaration.dart';
import '../../text_content.dart';
import '../../tools/ai_tool.dart';
import '../evaluation_context.dart';

/// Context for [TaskAdherenceEvaluator]: the tool definitions used when
/// generating the response.
@Source(
  name: 'TaskAdherenceEvaluatorContext.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Quality',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Quality/',
)
class TaskAdherenceEvaluatorContext extends EvaluationContext {
  /// Creates a [TaskAdherenceEvaluatorContext] with [toolDefinitions].
  TaskAdherenceEvaluatorContext({List<AITool>? toolDefinitions})
      : toolDefinitions = List.unmodifiable(toolDefinitions ?? const []),
        super(
          toolDefinitionsContextName,
          contents: [
            for (final t in toolDefinitions ?? const <AITool>[])
              if (t is AIFunctionDeclaration)
                TextContent('${t.name}: ${t.description ?? ""}'),
          ],
        );

  /// Unique context name used when recording contexts on metrics.
  static const String toolDefinitionsContextName =
      'Tool definitions(Task Adherence)';

  /// The tool definitions available when generating the response.
  final List<AITool> toolDefinitions;
}
