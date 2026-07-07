import '../../abstractions/directory_info_base.dart';
import '../../abstractions/file_info_base.dart';
import '../i_pattern_context.dart';
import '../pattern_test_result.dart';

/// Base class for pattern contexts that keep per-directory state on a stack.
///
/// The upstream C# `TFrame` is a struct, so pushing a directory copies the
/// current frame by value. Dart frame classes replicate that with an explicit
/// shallow `copy()` invoked by subclasses before mutation.
///
/// This API supports infrastructure and is not intended to be used directly.
abstract class PatternContext<TFrame> implements IPatternContext {
  final List<TFrame> _stack = [];

  /// The state for the directory currently being visited.
  ///
  /// Subclass constructors must initialize this to a default frame, matching
  /// the C# `default(TFrame)` value that exists before the first push.
  late TFrame frame;

  @override
  void declare(OnDeclareSegment onDeclare) {}

  @override
  PatternTestResult testFile(FileInfoBase file);

  @override
  bool testDirectory(DirectoryInfoBase directory);

  @override
  void pushDirectory(DirectoryInfoBase directory);

  @override
  void popDirectory() {
    frame = _stack.removeLast();
  }

  /// Saves the current [frame] and makes [newFrame] current.
  void pushDataFrame(TFrame newFrame) {
    _stack.add(frame);
    frame = newFrame;
  }

  /// Whether no directory has been pushed yet.
  bool isStackEmpty() => _stack.isEmpty;
}
