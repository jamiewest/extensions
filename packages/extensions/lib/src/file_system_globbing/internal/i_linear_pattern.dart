import 'i_path_segment.dart';
import 'i_pattern.dart';

/// A pattern without a recursive wildcard (`**`), matched segment by segment.
///
/// The `I` prefix intentionally mirrors the upstream C# type
/// `Microsoft.Extensions.FileSystemGlobbing.Internal.ILinearPattern`. This
/// API supports infrastructure and is not intended to be used directly.
abstract interface class ILinearPattern implements IPattern {
  /// The ordered segments of the pattern.
  List<IPathSegment> get segments;
}
