import '../../../system/threading/cancellation_token.dart';
import '../../chat_completion/chat_message.dart';
import '../../chat_completion/chat_options.dart';
import '../../chat_completion/chat_response.dart';
import '../../chat_completion/chat_role.dart';
import '../chat_configuration.dart';
import '../evaluation_context.dart';
import '../evaluation_diagnostic.dart';
import '../evaluation_metric_extensions.dart';
import '../evaluation_result.dart';
import '../evaluator.dart';
import '../numeric_metric.dart';

/// Shared evaluation loop for AI-based quality evaluators (1–5 scale).
///
/// Subclasses provide the metric name and evaluation instructions; this class
/// handles calling the model, parsing the tagged response, and interpreting
/// the score.
abstract class QualityEvaluatorBase implements Evaluator {
  static final _chatOptions = ChatOptions(temperature: 0);

  @override
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse, {
    ChatConfiguration? chatConfiguration,
    Iterable<EvaluationContext>? additionalContext,
    CancellationToken? cancellationToken,
  }) async {
    final metricName = evaluationMetricNames.first;
    final metric = NumericMetric(metricName);
    final result = EvaluationResult.fromList([metric]);

    if (chatConfiguration == null) {
      metric.addDiagnostic(EvaluationDiagnostic.error(
          'chatConfiguration is required for AI-based evaluators.'));
      return result;
    }

    if (modelResponse.text.isEmpty) {
      metric.addDiagnostic(EvaluationDiagnostic.error(
          'The modelResponse supplied for evaluation was null or empty.'));
      return result;
    }

    final instructions = buildEvaluationInstructions(
      messages.toList(),
      modelResponse,
      additionalContext?.toList() ?? const [],
    );

    if (instructions == null) {
      metric.addDiagnostic(EvaluationDiagnostic.error(
          'Could not build evaluation instructions. '
          'A required evaluation context may be missing.'));
      return result;
    }

    final start = DateTime.now();
    final evalResponse = await chatConfiguration.chatClient.getResponse(
      messages: instructions,
      options: _chatOptions,
      cancellationToken: cancellationToken,
    );
    final duration = DateTime.now().difference(start);

    if (!metric.tryParseEvaluationResponseWithTags(evalResponse, duration)) {
      metric.addDiagnostic(EvaluationDiagnostic.error(
          'Could not parse a score from the evaluation response.'));
    } else {
      metric.interpretation = metric.interpretScore();
    }
    return result;
  }

  /// Builds the evaluation instructions (system + user messages).
  ///
  /// Return `null` to signal that a required context was missing.
  List<ChatMessage>? buildEvaluationInstructions(
    List<ChatMessage> messages,
    ChatResponse modelResponse,
    List<EvaluationContext> additionalContext,
  );
}

/// Finds the last user message in a list.
extension QualityMessageListExtensions on List<ChatMessage> {
  ChatMessage? get lastUserMessage => cast<ChatMessage?>()
      .lastWhere((m) => m?.role == ChatRole.user, orElse: () => null);
}
