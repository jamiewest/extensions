import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import '../chat_completion/chat_message.dart';
import '../chat_completion/chat_response.dart';
import 'chat_configuration.dart';
import 'evaluation_context.dart';
import 'evaluation_result.dart';

/// Evaluates AI model responses and returns [EvaluationResult]s.
@Source(
  name: 'IEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation/',
)
abstract class Evaluator {
  /// The names of the [EvaluationMetric]s produced by this evaluator.
  List<String> get evaluationMetricNames;

  /// Evaluates [modelResponse] and returns an [EvaluationResult].
  ///
  /// [messages] is the full conversation history that produced
  /// [modelResponse]. [chatConfiguration] is required when the evaluator
  /// itself uses an AI model. [additionalContext] provides domain-specific
  /// context beyond what is in [messages].
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse, {
    ChatConfiguration? chatConfiguration,
    Iterable<EvaluationContext>? additionalContext,
    CancellationToken? cancellationToken,
  });
}
