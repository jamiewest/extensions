import '../../text_content.dart';
import '../evaluation_context.dart';

/// Contextual information for [GLEUEvaluator]: one or more reference
/// responses to compare against.
class GLEUEvaluatorContext extends EvaluationContext {
  /// Creates a [GLEUEvaluatorContext] with the given [references].
  GLEUEvaluatorContext({Iterable<String>? references})
    : references = List.unmodifiable(references ?? const []),
      super(
        referencesContextName,
        contents: [
          for (final r in references ?? const <String>[]) TextContent(r),
        ],
      );

  /// Unique context name used when recording contexts on metrics.
  static const String referencesContextName = 'references(GLEU)';

  /// The reference responses against which the evaluated response is compared.
  final List<String> references;
}
