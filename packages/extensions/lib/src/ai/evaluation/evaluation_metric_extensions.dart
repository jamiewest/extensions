import '../chat_completion/chat_response.dart';
import 'evaluation_context.dart';
import 'evaluation_diagnostic.dart';
import 'evaluation_metric.dart';
import 'evaluation_metric_interpretation.dart';
import 'evaluation_rating.dart';
import 'numeric_metric.dart';

/// Extension methods for [EvaluationMetric].
extension EvaluationMetricExtensions on EvaluationMetric {
  /// Adds [diagnostic] to [EvaluationMetric.diagnostics].
  void addDiagnostic(EvaluationDiagnostic diagnostic) {
    diagnostics ??= [];
    diagnostics!.add(diagnostic);
  }

  /// Adds all [newDiagnostics] to [EvaluationMetric.diagnostics].
  void addDiagnostics(Iterable<EvaluationDiagnostic> newDiagnostics) {
    final list = newDiagnostics.toList();
    if (list.isEmpty) return;
    diagnostics ??= [];
    diagnostics!.addAll(list);
  }

  /// Adds or replaces [ctx] in [EvaluationMetric.context] by name.
  void addOrUpdateContext(EvaluationContext ctx) {
    context ??= {};
    context![ctx.name] = ctx;
  }

  /// Adds or replaces multiple contexts by name.
  void addOrUpdateContextAll(Iterable<EvaluationContext> contexts) {
    context ??= {};
    for (final c in contexts) {
      context![c.name] = c;
    }
  }

  /// Sets a metadata entry.
  void addOrUpdateMetadata(String name, String value) {
    metadata ??= {};
    metadata![name] = value;
  }

  /// Records the evaluation duration in milliseconds as metadata.
  void addOrUpdateDurationMetadata(Duration duration) {
    addOrUpdateMetadata(
      'evaluation.duration_ms',
      duration.inMicroseconds / 1000.0 ~/ 1 == 0
          ? (duration.inMicroseconds / 1000.0).toStringAsFixed(2)
          : duration.inMilliseconds.toString(),
    );
  }

  /// Records model ID and token counts from a [ChatResponse] as metadata.
  void addOrUpdateChatMetadata(ChatResponse response, {Duration? duration}) {
    if (response.modelId != null && response.modelId!.isNotEmpty) {
      addOrUpdateMetadata('evaluation.model', response.modelId!);
    }
    final usage = response.usage;
    if (usage != null) {
      if (usage.inputTokenCount != null) {
        addOrUpdateMetadata(
            'evaluation.input_tokens', usage.inputTokenCount.toString());
      }
      if (usage.outputTokenCount != null) {
        addOrUpdateMetadata(
            'evaluation.output_tokens', usage.outputTokenCount.toString());
      }
      if (usage.totalTokenCount != null) {
        addOrUpdateMetadata(
            'evaluation.total_tokens', usage.totalTokenCount.toString());
      }
    }
    if (duration != null) {
      addOrUpdateDurationMetadata(duration);
    }
  }
}

/// Score interpretation helpers for [NumericMetric].
extension NumericMetricInterpretationExtensions on NumericMetric {
  /// Interprets a 0.0–1.0 score (NLP metrics like BLEU/F1/GLEU).
  ///
  /// Pass threshold is 0.5.
  EvaluationMetricInterpretation interpret() {
    final v = value;
    if (v == null || v < 0 || v > 1) {
      return EvaluationMetricInterpretation(
          rating: EvaluationRating.inconclusive);
    }
    final rating = v > 0.8
        ? EvaluationRating.exceptional
        : v > 0.6
            ? EvaluationRating.good
            : v > 0.4
                ? EvaluationRating.average
                : v > 0.2
                    ? EvaluationRating.poor
                    : EvaluationRating.unacceptable;
    const threshold = 0.5;
    if (v < threshold) {
      return EvaluationMetricInterpretation(
        rating: rating,
        failed: true,
        reason: '$name is less than $threshold.',
      );
    }
    return EvaluationMetricInterpretation(rating: rating);
  }

  /// Interprets a 1–5 score (quality evaluators like Coherence, Fluency).
  ///
  /// Scores below 3 are considered failures.
  EvaluationMetricInterpretation interpretScore() {
    final v = value;
    if (v == null) {
      return EvaluationMetricInterpretation(
          rating: EvaluationRating.inconclusive);
    }
    final rating = v >= 5
        ? EvaluationRating.exceptional
        : v >= 4
            ? EvaluationRating.good
            : v >= 3
                ? EvaluationRating.average
                : v >= 2
                    ? EvaluationRating.poor
                    : EvaluationRating.unacceptable;
    return EvaluationMetricInterpretation(rating: rating, failed: v < 3);
  }

  /// Interprets a 0–7 severity scale used by content safety evaluators.
  ///
  /// Scores above 0 are failures.
  EvaluationMetricInterpretation interpretContentHarmScore() {
    final v = value;
    if (v == null) {
      return EvaluationMetricInterpretation(
          rating: EvaluationRating.inconclusive);
    }
    final rating = v == 0
        ? EvaluationRating.exceptional
        : v <= 2
            ? EvaluationRating.poor
            : v <= 4
                ? EvaluationRating.unacceptable
                : EvaluationRating.unacceptable;
    return EvaluationMetricInterpretation(rating: rating, failed: v > 0);
  }

  /// Parses a tagged evaluation response (XML `<S0>`, `<S1>`, `<S2>` format).
  ///
  /// Returns `true` if a score was successfully parsed.
  bool tryParseEvaluationResponseWithTags(
      ChatResponse response, Duration duration) {
    final text = response.text;
    if (text.isEmpty) return false;

    final scoreMatch =
        RegExp(r'<S2>\s*(\d+(?:\.\d+)?)\s*</S2>').firstMatch(text);
    if (scoreMatch == null) return false;

    final score = double.tryParse(scoreMatch.group(1) ?? '');
    if (score == null) return false;
    value = score;

    final explanationMatch =
        RegExp(r'<S1>(.*?)</S1>', dotAll: true).firstMatch(text);
    if (explanationMatch != null) {
      reason = explanationMatch.group(1)?.trim();
    }

    addOrUpdateChatMetadata(response, duration: duration);
    return true;
  }
}
