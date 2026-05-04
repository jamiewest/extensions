import 'package:extensions/annotations.dart';

import '../ai_content.dart';
import '../text_content.dart';

/// Base class for contextual information beyond the conversation history that
/// an [Evaluator] may need to accurately evaluate a response.
///
/// Subclasses are free to add domain-specific properties. However, the
/// [contents] list should always represent all contextual information as
/// [AIContent] objects so that it can be serialized when recording results.
@Source(
  name: 'EvaluationContext.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation/',
)
abstract class EvaluationContext {
  /// Creates an [EvaluationContext] with the given [name] and optional
  /// [contents].
  ///
  /// If [text] is supplied and [contents] is null, the context will contain a
  /// single [TextContent] wrapping [text].
  EvaluationContext(
    this.name, {
    List<AIContent>? contents,
    String? text,
  }) : contents = contents ?? (text != null ? [TextContent(text)] : []);

  /// The name of this context, used as the key in metric context maps.
  String name;

  /// All contextual information decomposed into [AIContent] objects.
  List<AIContent> contents;
}
