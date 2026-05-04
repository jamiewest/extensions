import '../abstractions/chat_completion/chat_client.dart';
import '../abstractions/chat_completion/chat_message.dart';
import 'chat_configuration.dart';
import 'evaluation_context.dart';
import 'evaluation_result.dart';

/// Evaluates responses produced by an AI model.
abstract class Evaluator {
  /// Gets the [Name]s of the [EvaluationMetric]s produced by this [Evaluator].
  ReadOnlyCollection<String> get evaluationMetricNames;

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
  /// [messages] The conversation history including the request that produced
  /// the supplied `modelResponse`.
  ///
  /// [modelResponse] The response that is to be evaluated.
  ///
  /// [chatConfiguration] A [ChatConfiguration] that specifies the [ChatClient]
  /// that should be used if one or more composed [Evaluator]s use an AI model
  /// to perform evaluation.
  ///
  /// [additionalContext] Additional contextual information (beyond that which
  /// is available in `messages`) that the [Evaluator] may need to accurately
  /// evaluate the supplied `modelResponse`.
  ///
  /// [cancellationToken] A [CancellationToken] that can cancel the evaluation
  /// operation.
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse, {
    ChatConfiguration? chatConfiguration,
    Iterable<EvaluationContext>? additionalContext,
    CancellationToken? cancellationToken,
  });
}
