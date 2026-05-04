import '../evaluator.dart';
import '../numeric_metric.dart';
import 'content_harm_evaluator.dart';

/// An [Evaluator] that utilizes the Azure AI Foundry Evaluation service to
/// evaluate responses produced by an AI model for the presence of content
/// that is hateful or unfair.
///
/// Remarks: [HateAndUnfairnessEvaluator] returns a [NumericMetric] with a
/// value between 0 and 7, with 0 indicating an excellent score, and 7
/// indicating a poor score. Note that [HateAndUnfairnessEvaluator] can detect
/// harmful content present within both image and text based responses.
/// Supported file formats include JPG/JPEG, PNG and GIF. Other modalities
/// such as audio and video are currently not supported.
class HateAndUnfairnessEvaluator extends ContentHarmEvaluator {
  /// An [Evaluator] that utilizes the Azure AI Foundry Evaluation service to
  /// evaluate responses produced by an AI model for the presence of content
  /// that is hateful or unfair.
  ///
  /// Remarks: [HateAndUnfairnessEvaluator] returns a [NumericMetric] with a
  /// value between 0 and 7, with 0 indicating an excellent score, and 7
  /// indicating a poor score. Note that [HateAndUnfairnessEvaluator] can detect
  /// harmful content present within both image and text based responses.
  /// Supported file formats include JPG/JPEG, PNG and GIF. Other modalities
  /// such as audio and video are currently not supported.
  const HateAndUnfairnessEvaluator();

  /// Gets the [Name] of the [NumericMetric] returned by
  /// [HateAndUnfairnessEvaluator].
  static String get hateAndUnfairnessMetricName {
    return "Hate And Unfairness";
  }
}
