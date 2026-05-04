import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import '../chat_completion/chat_message.dart';
import '../chat_completion/chat_response.dart';
import 'chat_configuration.dart';
import 'evaluation_context.dart';
import 'evaluation_diagnostic.dart';
import 'evaluation_metric.dart';
import 'evaluation_result.dart';
import 'evaluator.dart';

/// An [Evaluator] that composes multiple [Evaluator]s and runs them
/// concurrently.
@Source(
  name: 'CompositeEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation/',
)
class CompositeEvaluator implements Evaluator {
  /// Creates a [CompositeEvaluator] from the supplied [evaluators].
  CompositeEvaluator(List<Evaluator> evaluators)
      : _evaluators = List.unmodifiable(evaluators);

  final List<Evaluator> _evaluators;

  @override
  List<String> get evaluationMetricNames =>
      _evaluators.expand((e) => e.evaluationMetricNames).toList();

  @override
  Future<EvaluationResult> evaluate(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse, {
    ChatConfiguration? chatConfiguration,
    Iterable<EvaluationContext>? additionalContext,
    CancellationToken? cancellationToken,
  }) async {
    final results = await Future.wait(
      _evaluators.map((e) => _safeEvaluate(
            e,
            messages,
            modelResponse,
            chatConfiguration: chatConfiguration,
            additionalContext: additionalContext,
            cancellationToken: cancellationToken,
          )),
    );
    final merged = EvaluationResult();
    for (final result in results) {
      result.metrics.forEach((k, v) => merged.metrics[k] = v);
    }
    return merged;
  }

  /// Streams results as each evaluator completes.
  Stream<EvaluationResult> evaluateAndStreamResults(
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse, {
    ChatConfiguration? chatConfiguration,
    Iterable<EvaluationContext>? additionalContext,
    CancellationToken? cancellationToken,
  }) async* {
    final futures = _evaluators
        .map((e) => _safeEvaluate(
              e,
              messages,
              modelResponse,
              chatConfiguration: chatConfiguration,
              additionalContext: additionalContext,
              cancellationToken: cancellationToken,
            ))
        .toList();

    for (final future in futures) {
      yield await future;
    }
  }

  Future<EvaluationResult> _safeEvaluate(
    Evaluator evaluator,
    Iterable<ChatMessage> messages,
    ChatResponse modelResponse, {
    ChatConfiguration? chatConfiguration,
    Iterable<EvaluationContext>? additionalContext,
    CancellationToken? cancellationToken,
  }) async {
    try {
      return await evaluator.evaluate(
        messages,
        modelResponse,
        chatConfiguration: chatConfiguration,
        additionalContext: additionalContext,
        cancellationToken: cancellationToken,
      );
    } catch (e) {
      final message = e.toString();
      final result = EvaluationResult();
      final names = evaluator.evaluationMetricNames;
      if (names.isEmpty) {
        return result;
      }
      for (final name in names) {
        final metric = EvaluationMetric(name);
        metric.diagnostics = [EvaluationDiagnostic.error(message)];
        result.metrics[name] = metric;
      }
      return result;
    }
  }
}
