import '../../../system/exceptions/argument_exception.dart';
import '../../util/string_comparison.dart';
import '../i_linear_pattern.dart';
import '../i_path_segment.dart';
import '../i_pattern.dart';
import '../i_pattern_context.dart';
import '../i_ragged_pattern.dart';
import '../path_segments/current_path_segment.dart';
import '../path_segments/literal_path_segment.dart';
import '../path_segments/parent_path_segment.dart';
import '../path_segments/recursive_wildcard_segment.dart';
import '../path_segments/wildcard_path_segment.dart';
import '../pattern_contexts/pattern_context_linear_exclude.dart';
import '../pattern_contexts/pattern_context_linear_include.dart';
import '../pattern_contexts/pattern_context_ragged_exclude.dart';
import '../pattern_contexts/pattern_context_ragged_include.dart';

/// Parses globbing pattern strings into [IPattern] instances.
///
/// This API supports infrastructure and is not intended to be used directly.
class PatternBuilder {
  static const _slashes = ['/', '\\'];

  /// The string comparison used for literal and wildcard segments.
  final StringComparison comparisonType;

  /// Creates a builder using [comparisonType], case-insensitive by default.
  PatternBuilder([this.comparisonType = StringComparison.ordinalIgnoreCase]);

  /// Parses [pattern] into an [IPattern].
  ///
  /// Throws [ArgumentException] when a `..` segment appears anywhere other
  /// than the beginning of the pattern.
  IPattern build(String pattern) {
    pattern = _trimChars(pattern, _slashes, trimEnd: false);

    final trimmedEnd = _trimChars(pattern, _slashes, trimStart: false);
    if (trimmedEnd.length < pattern.length) {
      // A pattern ending with a slash is treated as a directory.
      pattern = '$trimmedEnd/**';
    }

    final allSegments = <IPathSegment>[];
    var isParentSegmentLegal = true;

    List<IPathSegment>? segmentsPatternStartsWith;
    List<List<IPathSegment>>? segmentsPatternContains;
    List<IPathSegment>? segmentsPatternEndsWith;

    final endPattern = pattern.length;
    for (var scanPattern = 0; scanPattern < endPattern;) {
      final beginSegment = scanPattern;
      var endSegment = _nextIndex(pattern, _slashes, scanPattern, endPattern);
      var segmentStart = beginSegment;

      IPathSegment? segment;

      if (endSegment - segmentStart == 3 &&
          pattern[segmentStart] == '*' &&
          pattern[segmentStart + 1] == '.' &&
          pattern[segmentStart + 2] == '*') {
        // Turn '*.*' into '*'.
        segmentStart += 2;
      }

      if (endSegment - segmentStart == 2) {
        if (pattern[segmentStart] == '*' && pattern[segmentStart + 1] == '*') {
          segment = RecursiveWildcardSegment();
        } else if (pattern[segmentStart] == '.' &&
            pattern[segmentStart + 1] == '.') {
          if (!isParentSegmentLegal) {
            throw ArgumentException(
              message:
                  '".." can be only added at the beginning of the pattern.',
            );
          }
          segment = ParentPathSegment();
        }
      }

      if (segment == null &&
          endSegment - segmentStart == 1 &&
          pattern[segmentStart] == '.') {
        segment = CurrentPathSegment();
      }

      if (segment == null &&
          endSegment - segmentStart > 2 &&
          pattern[segmentStart] == '*' &&
          pattern[segmentStart + 1] == '*' &&
          pattern[segmentStart + 2] == '.') {
        // Recognize '**.': swallow the first '*', add the recursive
        // segment, and treat the remainder as a wildcard next iteration.
        segment = RecursiveWildcardSegment();
        endSegment = segmentStart;
      }

      if (segment == null) {
        var beginsWith = '';
        final contains = <String>[];
        var endsWith = '';

        for (var scanSegment = segmentStart; scanSegment < endSegment;) {
          final beginLiteral = scanSegment;
          final endLiteral =
              _nextIndex(pattern, const ['*'], scanSegment, endSegment);

          if (beginLiteral == segmentStart) {
            if (endLiteral == endSegment) {
              // The segment is a single literal.
              segment = LiteralPathSegment(
                pattern.substring(beginLiteral, endLiteral),
                comparisonType,
              );
            } else {
              beginsWith = pattern.substring(beginLiteral, endLiteral);
            }
          } else if (endLiteral == endSegment) {
            endsWith = pattern.substring(beginLiteral, endLiteral);
          } else if (beginLiteral != endLiteral) {
            contains.add(pattern.substring(beginLiteral, endLiteral));
          }

          scanSegment = endLiteral + 1;
        }

        segment ??=
            WildcardPathSegment(beginsWith, contains, endsWith, comparisonType);
      }

      if (segment is! ParentPathSegment) {
        isParentSegmentLegal = false;
      }

      if (segment is! CurrentPathSegment) {
        if (segment is RecursiveWildcardSegment) {
          if (segmentsPatternStartsWith == null) {
            segmentsPatternStartsWith = List.of(allSegments);
            segmentsPatternEndsWith = <IPathSegment>[];
            segmentsPatternContains = <List<IPathSegment>>[];
          } else if (segmentsPatternEndsWith!.isNotEmpty) {
            segmentsPatternContains!.add(segmentsPatternEndsWith);
            segmentsPatternEndsWith = <IPathSegment>[];
          }
        } else {
          segmentsPatternEndsWith?.add(segment);
        }

        allSegments.add(segment);
      }

      scanPattern = endSegment + 1;
    }

    if (segmentsPatternStartsWith == null) {
      return _LinearPattern(allSegments);
    } else {
      return _RaggedPattern(
        allSegments,
        segmentsPatternStartsWith,
        segmentsPatternEndsWith!,
        segmentsPatternContains!,
      );
    }
  }

  static int _nextIndex(
    String pattern,
    List<String> anyOf,
    int beginIndex,
    int endIndex,
  ) {
    for (var i = beginIndex; i < endIndex; i++) {
      if (anyOf.contains(pattern[i])) {
        return i;
      }
    }
    return endIndex;
  }

  static String _trimChars(
    String value,
    List<String> chars, {
    bool trimStart = true,
    bool trimEnd = true,
  }) {
    var start = 0;
    var end = value.length;
    if (trimStart) {
      while (start < end && chars.contains(value[start])) {
        start++;
      }
    }
    if (trimEnd) {
      while (end > start && chars.contains(value[end - 1])) {
        end--;
      }
    }
    return value.substring(start, end);
  }
}

class _LinearPattern implements ILinearPattern {
  @override
  final List<IPathSegment> segments;

  _LinearPattern(this.segments);

  @override
  IPatternContext createPatternContextForInclude() =>
      PatternContextLinearInclude(this);

  @override
  IPatternContext createPatternContextForExclude() =>
      PatternContextLinearExclude(this);
}

class _RaggedPattern implements IRaggedPattern {
  @override
  final List<IPathSegment> segments;

  @override
  final List<IPathSegment> startsWith;

  @override
  final List<IPathSegment> endsWith;

  @override
  final List<List<IPathSegment>> contains;

  _RaggedPattern(this.segments, this.startsWith, this.endsWith, this.contains);

  @override
  IPatternContext createPatternContextForInclude() =>
      PatternContextRaggedInclude(this);

  @override
  IPatternContext createPatternContextForExclude() =>
      PatternContextRaggedExclude(this);
}
