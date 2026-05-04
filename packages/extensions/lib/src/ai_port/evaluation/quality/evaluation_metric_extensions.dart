import '../boolean_metric.dart';
import '../evaluation_diagnostic.dart';
import '../evaluation_metric_interpretation.dart';
import '../evaluation_rating.dart';
import '../numeric_metric.dart';

extension EvaluationMetricExtensions on NumericMetric {EvaluationMetricInterpretation interpretScore({bool? passValue}) {
var rating = metric.value switch
        {
            (null) => EvaluationRating.inconclusive,
            > 5.0 => EvaluationRating.inconclusive,
            > 4.0 and <= 5.0 => EvaluationRating.exceptional,
            > 3.0 and <= 4.0 => EvaluationRating.good,
            > 2.0 and <= 3.0 => EvaluationRating.average,
            > 1.0 and <= 2.0 => EvaluationRating.poor,
            > 0.0 and <= 1.0 => EvaluationRating.unacceptable,
            <= 0.0 => EvaluationRating.inconclusive,
            (_) => EvaluationRating.inconclusive,
        };
var MinimumPassingScore = 4.0;
return metric.value is double value && value < MinimumPassingScore
            ? evaluationMetricInterpretation(
                rating,
                failed: true,
                reason: '${metric.name} is less than ${MinimumPassingScore}.')
            : evaluationMetricInterpretation(rating);
 }
bool tryParseEvaluationResponseWithValue<T>(
  ChatResponse evaluationResponse,
  Duration evaluationDuration,
) {
metric.addOrUpdateChatMetadata(evaluationResponse, evaluationDuration);
var evaluationResponseText = evaluationResponse.text.trim();
return metric.tryParseValue(valueText: evaluationResponseText);
 }
bool tryParseEvaluationResponseWithTags<T>(
  ChatResponse evaluationResponse,
  Duration evaluationDuration,
) {
metric.addOrUpdateChatMetadata(evaluationResponse, evaluationDuration);
var evaluationResponseText = evaluationResponse.text.trim();
string? chainOfThought;
if (tryParseTag(evaluationResponseText, tagName: "S0")) {
  metric.addDiagnostics(EvaluationDiagnostic.informational(
                'Model's evaluation chain of thought: ${chainOfThought}'));
}
string? reason;
if (tryParseTag(evaluationResponseText, tagName: "S1")) {
  metric.reason = reason;
}
string? valueText;
if (!tryParseTag(evaluationResponseText, tagName: "S2")) {
  metric.addDiagnostics(
                EvaluationDiagnostic.error(
                    ''"
                    Failed to parse score for '{metric.name}' from the following evaluation response:
                    {evaluationResponseText}
                    """));
  return false;
}
return metric.tryParseValue(valueText);
/* TODO: unsupported node kind "unknown" */
// static bool TryParseTag(string text, string tagName, [NotNullWhen(true)] out string? tagValue)
//         {
//             const RegexOptions Options = RegexOptions.Singleline;
//             Match match = Regex.Match(text, $@"<{tagName}>(?<value>.*?)</{tagName}>", Options);
//
//             if (!match.Success || match.Groups["value"] is not Group valueGroup || !valueGroup.Success)
//             {
//                 tagValue = null;
//                 return false;
//             }
//
//             if (valueGroup.Value is not string matchText ||
//                 matchText.Trim() is not string trimmedMatchText ||
//                 string.IsNullOrEmpty(trimmedMatchText))
//             {
//                 tagValue = null;
//                 return false;
//             }
//
//             tagValue = trimmedMatchText;
//             return true;
//         }
 }
bool tryParseValue<T>(String valueText) {
switch (metric) {
  case NumericMetric numericMetric:
    {
      double doubleValue;
      if (double.tryParse(valueText)) {
        numericMetric.value = doubleValue;
        return true;
      } else {
        metric.addDiagnostics(
                        EvaluationDiagnostic.error(
                            ''"
                            Failed to parse numeric score for '{metric.name}' from the following text:
                            {valueText}
                            """));
        return false;
      }
    }
  case BooleanMetric booleanMetric:
    {
      bool booleanValue;
      if (bool.tryParse(valueText)) {
        booleanMetric.value = booleanValue;
        return true;
      } else {
        int intValue;
        if (int.tryParse(valueText) && (intValue is 0 or 1)) {
          booleanMetric.value = intValue is 1;
          return true;
        } else {
          metric.addDiagnostics(
                        EvaluationDiagnostic.error(
                            ''"
                            Failed to parse boolean score for '{metric.name}' from the following text:
                            {valueText}
                            """));
          return false;
        }
      }
    }
  default:
    throw notSupportedException('${metric.getType().name} is! supported.');
}
 }
 }
