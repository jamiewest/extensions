import '../../../system/exceptions/invalid_operation_exception.dart';
import '../../abstractions/directory_info_base.dart';
import '../../abstractions/file_info_base.dart';
import '../i_linear_pattern.dart';
import '../matcher_context.dart';
import '../pattern_test_result.dart';
import 'pattern_context.dart';

/// Per-directory state for [PatternContextLinear].
///
/// This API supports infrastructure and is not intended to be used directly.
class LinearFrameData {
  /// Whether nothing under the current directory can match the pattern.
  bool isNotApplicable;

  /// The index of the pattern segment the current directory must match.
  int segmentIndex;

  /// Whether directories from here on contribute to the stem.
  bool inStem;

  List<String>? _stemItems;

  /// Whether the current directory added an entry to [stemItems].
  bool addedStemItem;

  /// Creates a default frame, equivalent to C# `default(FrameData)`.
  LinearFrameData({
    this.isNotApplicable = false,
    this.segmentIndex = 0,
    this.inStem = false,
    this._stemItems,
    this.addedStemItem = false,
  });

  /// The directory names accumulated for the stem. The list is shared
  /// between copied frames, matching the C# struct's list reference copy.
  List<String> get stemItems => _stemItems ??= [];

  /// Whether stem items have been accumulated.
  bool get hasStemItems => _stemItems != null && _stemItems!.isNotEmpty;

  /// The stem accumulated so far, or `null` when none was recorded.
  String? get stem => _stemItems?.join('/');

  /// Returns a shallow copy sharing the stem item list.
  LinearFrameData copy() => LinearFrameData(
    isNotApplicable: isNotApplicable,
    segmentIndex: segmentIndex,
    inStem: inStem,
    stemItems: _stemItems,
    addedStemItem: addedStemItem,
  );
}

/// Matches a pattern without recursive wildcards segment by segment as a
/// directory tree is walked.
///
/// This API supports infrastructure and is not intended to be used directly.
abstract class PatternContextLinear extends PatternContext<LinearFrameData> {
  /// The pattern being matched.
  final ILinearPattern pattern;

  /// Creates a context for [pattern].
  PatternContextLinear(this.pattern) {
    frame = LinearFrameData();
  }

  @override
  PatternTestResult testFile(FileInfoBase file) {
    if (isStackEmpty()) {
      throw InvalidOperationException(
        message: 'Can\'t test file before entering a directory.',
      );
    }

    if (!frame.isNotApplicable &&
        isLastSegment() &&
        testMatchingSegment(file.name)) {
      return PatternTestResult.success(calculateStem(file));
    }

    return PatternTestResult.failed;
  }

  @override
  void pushDirectory(DirectoryInfoBase directory) {
    final newFrame = frame.copy()..addedStemItem = false;

    if (isStackEmpty() || frame.isNotApplicable) {
      // Initializing the stack, or nothing under this path can match.
    } else if (!testMatchingSegment(directory.name)) {
      newFrame.isNotApplicable = true;
    } else {
      final segment = pattern.segments[frame.segmentIndex];
      if (newFrame.inStem || segment.canProduceStem) {
        newFrame.inStem = true;
        newFrame.stemItems.add(directory.name);
        newFrame.addedStemItem = true;
      }

      newFrame.segmentIndex++;
    }

    pushDataFrame(newFrame);
  }

  @override
  void popDirectory() {
    final addedStem = frame.addedStemItem;
    super.popDirectory();
    if (addedStem && frame.hasStemItems) {
      frame.stemItems.removeLast();
    }
  }

  /// Whether the current segment is the final segment of the pattern.
  bool isLastSegment() => frame.segmentIndex == pattern.segments.length - 1;

  /// Tests [value] against the current pattern segment.
  bool testMatchingSegment(String value) {
    if (frame.segmentIndex >= pattern.segments.length) {
      return false;
    }

    return pattern.segments[frame.segmentIndex].match(value);
  }

  /// Combines the accumulated stem with the matched file's name.
  String calculateStem(FileInfoBase matchedFile) =>
      MatcherContext.combinePath(frame.stem, matchedFile.name);
}
