import '../../../../../lib/func_typedefs.dart';
import 'evaluation_context.dart';
import 'evaluation_diagnostic.dart';
import 'utilities/built_in_metric_utilities.dart';

/// Extension methods for [EvaluationMetric].
extension EvaluationMetricExtensions on EvaluationMetric {
  /// Adds or updates the supplied `context` objects in the supplied `metric`'s
  /// [Context] dictionary.
  ///
  /// [metric] The [EvaluationMetric].
  ///
  /// [context] The [EvaluationContext] objects to be added or updated.
  void addOrUpdateContext({Iterable<EvaluationContext>? context}) {
    _ = Throw.ifNull(metric);
    _ = Throw.ifNull(context);
    if (context.any()) {
      metric.context ??= new Dictionary<string, EvaluationContext>();
      for (final c in context) {
        metric.context[c.name] = c;
      }
    }
  }

  /// Determines if the supplied `metric` contains any [EvaluationDiagnostic]
  /// matching the supplied `predicate`.
  ///
  /// Returns: `true` if the supplied `metric` contains any
  /// [EvaluationDiagnostic] matching the supplied `predicate`; `false`
  /// otherwise.
  ///
  /// [metric] The [EvaluationMetric] that is to be inspected.
  ///
  /// [predicate] A predicate that returns `true` if a matching
  /// [EvaluationDiagnostic] is found; `false` otherwise.
  bool containsDiagnostics({Func<EvaluationDiagnostic, bool>? predicate}) {
    _ = Throw.ifNull(metric);
    return metric.diagnostics != null &&
        (predicate == null
            ? metric.diagnostics.any()
            : metric.diagnostics.any(predicate));
  }

  /// Adds the supplied [EvaluationDiagnostic]s to the supplied
  /// [EvaluationMetric]'s [Diagnostics] collection.
  ///
  /// [metric] The [EvaluationMetric].
  ///
  /// [diagnostics] The [EvaluationDiagnostic]s to be added.
  void addDiagnostics({Iterable<EvaluationDiagnostic>? diagnostics}) {
    _ = Throw.ifNull(metric);
    _ = Throw.ifNull(diagnostics);
    if (diagnostics.any()) {
      metric.diagnostics ??= [];
      for (final diagnostic in diagnostics) {
        metric.diagnostics.add(diagnostic);
      }
    }
  }

  /// Adds or updates metadata with the specified `name` and `value` in the
  /// supplied `metric`'s [Metadata] dictionary.
  ///
  /// [metric] The [EvaluationMetric].
  ///
  /// [name] The name of the metadata.
  ///
  /// [value] The value of the metadata.
  void addOrUpdateMetadata({
    String? name,
    String? value,
    Map<String, String>? metadata,
  }) {
    _ = Throw.ifNull(metric);
    metric.metadata ??= new Dictionary<String, String>();
    metric.metadata[name] = value;
  }

  /// Adds or updates metadata available as part of the evaluation `response`
  /// produced by an AI model, in the supplied `metric`'s [Metadata] dictionary.
  ///
  /// [metric] The [EvaluationMetric].
  ///
  /// [response] The [ChatResponse] that contains metadata to be added or
  /// updated.
  ///
  /// [duration] An optional duration that represents the amount of time that it
  /// took for the AI model to produce the supplied `response`. If supplied, the
  /// duration (in milliseconds) will also be included as part of the added
  /// metadata.
  void addOrUpdateChatMetadata(ChatResponse response, {Duration? duration}) {
    _ = Throw.ifNull(response);
    if (!string.isNullOrWhiteSpace(response.modelId)) {
      metric.addOrUpdateMetadata(
        name: BuiltInMetricUtilities.evalModelMetadataName,
        value: response.modelId!,
      );
    }
    if (response.usage is UsageDetails) {
      final usage = response.usage as UsageDetails;
      if (usage.inputTokenCount != null) {
        metric.addOrUpdateMetadata(
          name: BuiltInMetricUtilities.evalInputTokensMetadataName,
          value: usage.inputTokenCount.value.toInvariantString(),
        );
      }
      if (usage.outputTokenCount != null) {
        metric.addOrUpdateMetadata(
          name: BuiltInMetricUtilities.evalOutputTokensMetadataName,
          value: usage.outputTokenCount.value.toInvariantString(),
        );
      }
      if (usage.totalTokenCount != null) {
        metric.addOrUpdateMetadata(
          name: BuiltInMetricUtilities.evalTotalTokensMetadataName,
          value: usage.totalTokenCount.value.toInvariantString(),
        );
      }
    }
    if (duration != null) {
      metric.addOrUpdateDurationMetadata(duration.value);
    }
  }

  /// Adds or updates metadata identifying the amount of time (in milliseconds)
  /// that it took to perform the evaluation in the supplied `metric`'s
  /// [Metadata] dictionary.
  ///
  /// [metric] The [EvaluationMetric].
  ///
  /// [duration] The amount of time that it took to perform the evaluation that
  /// produced the supplied `metric`.
  void addOrUpdateDurationMetadata(Duration duration) {
    var durationInMilliseconds = duration.toMillisecondsText();
    metric.addOrUpdateMetadata(
      name: BuiltInMetricUtilities.evalDurationMillisecondsMetadataName,
      value: durationInMilliseconds,
    );
  }
}
