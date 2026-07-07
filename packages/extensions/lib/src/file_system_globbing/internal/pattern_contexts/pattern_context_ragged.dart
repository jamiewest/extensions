import '../../../system/exceptions/invalid_operation_exception.dart';
import '../../abstractions/directory_info_base.dart';
import '../../abstractions/file_info_base.dart';
import '../../abstractions/file_system_info_base.dart';
import '../i_path_segment.dart';
import '../i_ragged_pattern.dart';
import '../matcher_context.dart';
import '../pattern_test_result.dart';
import 'pattern_context.dart';

/// Per-directory state for [PatternContextRagged].
///
/// This API supports infrastructure and is not intended to be used directly.
class RaggedFrameData {
  /// Whether nothing under the current directory can match the pattern.
  bool isNotApplicable;

  /// The index of the segment group being matched: `-1` for the starting
  /// group, `contains.length` for the ending group.
  int segmentGroupIndex;

  /// The segment group being matched.
  List<IPathSegment> segmentGroup;

  /// How many directory levels a `**` has consumed and could give back.
  int backtrackAvailable;

  /// The index within [segmentGroup] the current directory must match.
  int segmentIndex;

  /// Whether directories from here on contribute to the stem.
  bool inStem;

  List<String>? _stemItems;

  /// Whether the current directory added an entry to [stemItems].
  bool addedStemItem;

  /// Creates a default frame, equivalent to C# `default(FrameData)`.
  RaggedFrameData({
    this.isNotApplicable = false,
    this.segmentGroupIndex = 0,
    this.segmentGroup = const [],
    this.backtrackAvailable = 0,
    this.segmentIndex = 0,
    this.inStem = false,
    List<String>? stemItems,
    this.addedStemItem = false,
  }) : _stemItems = stemItems;

  /// The directory names accumulated for the stem. The list is shared
  /// between copied frames, matching the C# struct's list reference copy.
  List<String> get stemItems => _stemItems ??= [];

  /// Whether stem items have been accumulated.
  bool get hasStemItems => _stemItems != null && _stemItems!.isNotEmpty;

  /// The stem accumulated so far, or `null` when none was recorded.
  String? get stem => _stemItems?.join('/');

  /// Returns a shallow copy sharing the stem item list.
  RaggedFrameData copy() => RaggedFrameData(
        isNotApplicable: isNotApplicable,
        segmentGroupIndex: segmentGroupIndex,
        segmentGroup: segmentGroup,
        backtrackAvailable: backtrackAvailable,
        segmentIndex: segmentIndex,
        inStem: inStem,
        stemItems: _stemItems,
        addedStemItem: addedStemItem,
      );
}

/// Matches a pattern containing recursive wildcards (`**`) as a directory
/// tree is walked.
///
/// This API supports infrastructure and is not intended to be used directly.
abstract class PatternContextRagged extends PatternContext<RaggedFrameData> {
  /// The pattern being matched.
  final IRaggedPattern pattern;

  /// Creates a context for [pattern].
  PatternContextRagged(this.pattern) {
    frame = RaggedFrameData();
  }

  @override
  PatternTestResult testFile(FileInfoBase file) {
    if (isStackEmpty()) {
      throw InvalidOperationException(
        message: 'Can\'t test file before entering a directory.',
      );
    }

    if (!frame.isNotApplicable && isEndingGroup() && testMatchingGroup(file)) {
      return PatternTestResult.success(calculateStem(file));
    }
    return PatternTestResult.failed;
  }

  @override
  void pushDirectory(DirectoryInfoBase directory) {
    final newFrame = frame.copy()..addedStemItem = false;

    if (isStackEmpty()) {
      newFrame.segmentGroupIndex = -1;
      newFrame.segmentGroup = pattern.startsWith;
    } else if (frame.isNotApplicable) {
      // No change is required down this path.
    } else if (isStartingGroup()) {
      if (!testMatchingSegment(directory.name)) {
        newFrame.isNotApplicable = true;
      } else {
        newFrame.segmentIndex += 1;
      }
    } else if (directory.name == '..') {
      // A parent path segment is not applicable inside '**'.
      newFrame.isNotApplicable = true;
    } else if (!isEndingGroup() && testMatchingGroup(directory)) {
      newFrame.segmentIndex = frame.segmentGroup.length;
      newFrame.backtrackAvailable = 0;
    } else {
      newFrame.backtrackAvailable += 1;
    }

    if (newFrame.inStem) {
      newFrame.stemItems.add(directory.name);
      newFrame.addedStemItem = true;
    }

    while (newFrame.segmentIndex == newFrame.segmentGroup.length &&
        newFrame.segmentGroupIndex != pattern.contains.length) {
      newFrame.segmentGroupIndex += 1;
      newFrame.segmentIndex = 0;
      if (newFrame.segmentGroupIndex < pattern.contains.length) {
        newFrame.segmentGroup = pattern.contains[newFrame.segmentGroupIndex];
      } else {
        newFrame.segmentGroup = pattern.endsWith;
      }

      newFrame.inStem = true;
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

  /// Whether the starting segment group is being matched.
  bool isStartingGroup() => frame.segmentGroupIndex == -1;

  /// Whether the ending segment group is being matched.
  bool isEndingGroup() => frame.segmentGroupIndex == pattern.contains.length;

  /// Tests [value] against the current segment of the current group.
  bool testMatchingSegment(String value) {
    if (frame.segmentIndex >= frame.segmentGroup.length) {
      return false;
    }
    return frame.segmentGroup[frame.segmentIndex].match(value);
  }

  /// Tests whether [value] and its ancestors match the current segment
  /// group in reverse order.
  bool testMatchingGroup(FileSystemInfoBase value) {
    final groupLength = frame.segmentGroup.length;
    final backtrackLength = frame.backtrackAvailable + 1;
    if (backtrackLength < groupLength) {
      return false;
    }

    FileSystemInfoBase? scan = value;
    for (var index = 0; index != groupLength; ++index) {
      final segment = frame.segmentGroup[groupLength - index - 1];
      if (scan == null || !segment.match(scan.name)) {
        return false;
      }
      scan = scan.parentDirectory;
    }
    return true;
  }

  /// Combines the accumulated stem with the matched file's name.
  String calculateStem(FileInfoBase matchedFile) =>
      MatcherContext.combinePath(frame.stem, matchedFile.name);
}
