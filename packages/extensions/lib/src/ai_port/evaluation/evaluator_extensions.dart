import '../abstractions/chat_completion/chat_client.dart';
import 'chat_configuration.dart';
import 'evaluation_context.dart';
import 'evaluation_result.dart';
import 'evaluator.dart';

/// Extension methods for [Evaluator].
extension EvaluatorExtensions on Evaluator {
  /// Evaluates the supplied `modelResponse` and returns an [EvaluationResult]
  /// containing one or more [EvaluationMetric]s.
  ///
  /// Remarks: The [Name]s of the [EvaluationMetric]s contained in the returned
  /// [EvaluationResult] should match [EvaluationMetricNames]. Also note that
  /// `chatConfiguration` must not be omitted if the evaluation is performed
  /// using an AI model.
  ///
  /// Returns: An [EvaluationResult] containing one or more [EvaluationMetric]s.
  ///
  /// [evaluator] The [Evaluator] that should perform the evaluation.
  ///
  /// [modelResponse] The response that is to be evaluated.
  ///
  /// [chatConfiguration] A [ChatConfiguration] that specifies the [ChatClient]
  /// that should be used if one or more composed [Evaluator]s use an AI model
  /// to perform evaluation.
  ///
  /// [additionalContext] Additional contextual information that the `evaluator`
  /// may need to accurately evaluate the supplied `modelResponse`.
  ///
  /// [cancellationToken] A [CancellationToken] that can cancel the evaluation
  /// operation.
  Future<EvaluationResult> evaluate(
    ChatConfiguration? chatConfiguration,
    Iterable<EvaluationContext>? additionalContext,
    CancellationToken cancellationToken, {
    String? modelResponse,
    String? userRequest,
  }) {
    // TODO(ai): implement dispatch
    throw UnimplementedError();
  }
}
