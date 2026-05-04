import 'dart:convert';

import 'package:extensions/annotations.dart';

/// The structured JSON response from [RelevanceTruthAndCompletenessEvaluator].
///
/// Holds scores (1–5) and reasoning for all three evaluation dimensions.
@Source(
  name: 'RelevanceTruthAndCompletenessRating.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Quality',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Quality/',
)
class RelevanceTruthAndCompletenessRating {
  /// Creates a [RelevanceTruthAndCompletenessRating].
  RelevanceTruthAndCompletenessRating({
    required this.relevance,
    this.relevanceReasoning,
    List<String>? relevanceReasons,
    required this.truth,
    this.truthReasoning,
    List<String>? truthReasons,
    required this.completeness,
    this.completenessReasoning,
    List<String>? completenessReasons,
  })  : relevanceReasons = relevanceReasons ?? const [],
        truthReasons = truthReasons ?? const [],
        completenessReasons = completenessReasons ?? const [];

  /// Relevance score (1–5).
  final int relevance;

  /// Reasoning for the relevance score.
  final String? relevanceReasoning;

  /// Category labels for the relevance reasoning.
  final List<String> relevanceReasons;

  /// Truth score (1–5).
  final int truth;

  /// Reasoning for the truth score.
  final String? truthReasoning;

  /// Category labels for the truth reasoning.
  final List<String> truthReasons;

  /// Completeness score (1–5).
  final int completeness;

  /// Reasoning for the completeness score.
  final String? completenessReasoning;

  /// Category labels for the completeness reasoning.
  final List<String> completenessReasons;

  /// `true` if any score is outside the valid 1–5 range.
  bool get isInconclusive =>
      relevance < 1 ||
      relevance > 5 ||
      truth < 1 ||
      truth > 5 ||
      completeness < 1 ||
      completeness > 5;

  /// Parses a [RelevanceTruthAndCompletenessRating] from a JSON string.
  ///
  /// Strips leading/trailing markdown code fences before parsing.
  static RelevanceTruthAndCompletenessRating? tryParse(String raw) {
    var text = raw.trim();
    // Strip markdown fences (```json ... ``` or ``` ... ```)
    if (text.startsWith('```')) {
      final start = text.indexOf('\n');
      final end = text.lastIndexOf('```');
      if (start != -1 && end > start) {
        text = text.substring(start + 1, end).trim();
      }
    }
    try {
      final j = jsonDecode(text) as Map<String, dynamic>;
      return RelevanceTruthAndCompletenessRating.fromJson(j);
    } catch (_) {
      return null;
    }
  }

  /// Deserializes from a JSON map.
  factory RelevanceTruthAndCompletenessRating.fromJson(
          Map<String, dynamic> j) =>
      RelevanceTruthAndCompletenessRating(
        relevance: (j['relevance'] as num?)?.toInt() ?? 0,
        relevanceReasoning: j['relevanceReasoning'] as String?,
        relevanceReasons: (j['relevanceReasons'] as List?)?.cast<String>(),
        truth: (j['truth'] as num?)?.toInt() ?? 0,
        truthReasoning: j['truthReasoning'] as String?,
        truthReasons: (j['truthReasons'] as List?)?.cast<String>(),
        completeness: (j['completeness'] as num?)?.toInt() ?? 0,
        completenessReasoning: j['completenessReasoning'] as String?,
        completenessReasons:
            (j['completenessReasons'] as List?)?.cast<String>(),
      );
}
