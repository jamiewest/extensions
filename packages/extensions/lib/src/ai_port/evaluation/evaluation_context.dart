import '../abstractions/contents/ai_content.dart';
import '../abstractions/contents/data_content.dart';
import '../abstractions/contents/text_content.dart';
import '../abstractions/contents/uri_content.dart';
import 'evaluator.dart';

/// An `abstract` base class that models additional contextual information
/// (beyond that which is available in the conversation history) or other data
/// that an [Evaluator] may need to accurately evaluate supplied responses.
///
/// Remarks: [EvaluationContext] objects are intended to be simple data
/// containers that contain the contextual information required for evaluation
/// and little (if any) behavior. An [Evaluator] that needs additional
/// contextual information can require that callers should include an instance
/// of a specific derived [EvaluationContext] (containing the required
/// contextual information) when they call [CancellationToken)]. Derived
/// implementations of [EvaluationContext] are free to include any additional
/// properties as needed. However, the expectation is that the [Contents]
/// property will always return a collection of [AIContent]s that represent
/// all the contextual information that is modeled by the [EvaluationContext].
/// This is because an [Evaluator] can (optionally) choose to record any
/// [EvaluationContext]s that it used, in the [Context] property of each
/// [EvaluationMetric] that it produces. When [EvaluationMetric]s are
/// serialized (for example, as part of the result storage and report
/// generation functionality available in the
/// Microsoft.Extensions.AI.Evaluation.Reporting NuGet package), the
/// [EvaluationContext]s recorded within the [Context] will also be
/// serialized. However, for each such [EvaluationContext], only the
/// information captured within [Contents] will be serialized. Any information
/// that is (only) present in custom derived properties will not be
/// serialized. Therefore, in order to ensure that the contextual information
/// included as part of an [EvaluationContext] is stored and reported
/// accurately, it is important to ensure that the [Contents] property returns
/// a collection of [AIContent]s that represent all the contextual information
/// that is modeled by the [EvaluationContext].
abstract class EvaluationContext {
  /// Initializes a new instance of the [EvaluationContext] class.
  ///
  /// [name] The name of the [EvaluationContext].
  ///
  /// [contents] The contents of the [EvaluationContext]. (See [Contents].)
  EvaluationContext(
    String name,
    {Iterable<AContent>? contents = null, String? content = null, },
  ) :
      name = name,
      contents = [.. contents];

  /// Gets or sets the name for this [EvaluationContext].
  String name;

  /// Gets or sets a list of [AIContent] objects that include all the
  /// information present in this [EvaluationContext].
  ///
  /// Remarks: This property allows decomposition of the information present in
  /// an [EvaluationContext] into [TextContent] objects for text, [DataContent]
  /// or [UriContent] objects for images, and other similar [AIContent] objects
  /// for other modalities such as audio and video in the future. For simple
  /// [EvaluationContext]s that only contain text, this property can return a
  /// [TextContent] object that includes the contained text. Derived
  /// implementations of [EvaluationContext] are free to include any additional
  /// properties as needed. However, the expectation is that the [Contents]
  /// property will always return a collection of [AIContent]s that represent
  /// all the contextual information that is modeled by the [EvaluationContext].
  /// This is because an [Evaluator] can (optionally) choose to record any
  /// [EvaluationContext]s that it used, in the [Context] property of each
  /// [EvaluationMetric] that it produces. When [EvaluationMetric]s are
  /// serialized (for example, as part of the result storage and report
  /// generation functionality available in the
  /// Microsoft.Extensions.AI.Evaluation.Reporting NuGet package), the
  /// [EvaluationContext]s recorded within the [Context] will also be
  /// serialized. However, for each such [EvaluationContext], only the
  /// information captured within [Contents] will be serialized. Any information
  /// that is (only) present in custom derived properties will not be
  /// serialized. Therefore, in order to ensure that the contextual information
  /// included as part of an [EvaluationContext] is stored and reported
  /// accurately, it is important to ensure that the [Contents] property returns
  /// a collection of [AIContent]s that represent all the contextual information
  /// that is modeled by the [EvaluationContext].
  ///
  /// Returns: A list of [AIContent] objects that include all the information
  /// present in this [EvaluationContext].
  List<AContent> contents;

}
