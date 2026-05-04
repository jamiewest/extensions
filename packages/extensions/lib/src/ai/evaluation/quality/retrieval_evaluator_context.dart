import 'package:extensions/annotations.dart';

import '../../text_content.dart';
import '../evaluation_context.dart';

/// Context for [RetrievalEvaluator]: the retrieved context chunks to assess.
@Source(
  name: 'RetrievalEvaluatorContext.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Quality',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Quality/',
)
class RetrievalEvaluatorContext extends EvaluationContext {
  /// Creates a [RetrievalEvaluatorContext] from [retrievedContextChunks].
  RetrievalEvaluatorContext({List<String>? retrievedContextChunks})
      : retrievedContextChunks =
            List.unmodifiable(retrievedContextChunks ?? const []),
        super(
          retrievedContextChunksContextName,
          contents: [
            for (final c in retrievedContextChunks ?? const <String>[])
              TextContent(c),
          ],
        );

  /// Unique context name used when recording contexts on metrics.
  static const String retrievedContextChunksContextName =
      'Retrieved Context chunks(Retrieval)';

  /// The context chunks retrieved in response to the user request.
  final List<String> retrievedContextChunks;
}
