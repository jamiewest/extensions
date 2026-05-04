import '../evaluation_context.dart';
import 'retrieval_evaluator.dart';

/// Contextual information that the [RetrievalEvaluator] uses to evaluate an
/// AI system's performance in retrieving information for additional context.
///
/// Remarks: [RetrievalEvaluator] measures the degree to which the information
/// present in the context chunks supplied via [RetrievedContextChunks] are
/// relevant to the user request, and how well these chunks are ranked (with
/// the most relevant information appearing before less relevant information).
/// High retrieval scores indicate that the AI system has successfully
/// extracted and ranked the most relevant information at the top, without
/// introducing bias from external knowledge and ignoring factual correctness.
/// Conversely, low retrieval scores suggest that the AI system has failed to
/// surface the most relevant context chunks at the top of the list and / or
/// introduced bias and ignored factual correctness.
class RetrievalEvaluatorContext extends EvaluationContext {
  /// Initializes a new instance of the [RetrievalEvaluatorContext] class.
  ///
  /// [retrievedContextChunks] The context chunks that were retrieved in
  /// response to the user request being evaluated.
  RetrievalEvaluatorContext({List<String>? retrievedContextChunks = null})
    : retrievedContextChunks = retrievedContextChunks;

  /// Gets the context chunks that were retrieved in response to the user
  /// request being evaluated.
  final List<String> retrievedContextChunks;

  /// Gets the unique [Name] that is used for [RetrievalEvaluatorContext].
  static String get retrievedContextChunksContextName {
    return "Retrieved Context chunks(Retrieval)";
  }
}
