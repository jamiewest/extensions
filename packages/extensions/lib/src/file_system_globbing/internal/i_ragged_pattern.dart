import 'i_path_segment.dart';
import 'i_pattern.dart';

/// A pattern containing at least one recursive wildcard (`**`).
///
/// The segments are split into the group before the first `**`
/// ([startsWith]), the groups between wildcards ([contains]), and the group
/// after the last `**` ([endsWith]).
///
/// The `I` prefix intentionally mirrors the upstream C# type
/// `Microsoft.Extensions.FileSystemGlobbing.Internal.IRaggedPattern`. This
/// API supports infrastructure and is not intended to be used directly.
abstract interface class IRaggedPattern implements IPattern {
  /// All segments of the pattern in order.
  List<IPathSegment> get segments;

  /// The segments before the first recursive wildcard.
  List<IPathSegment> get startsWith;

  /// The segment groups between recursive wildcards.
  List<List<IPathSegment>> get contains;

  /// The segments after the last recursive wildcard.
  List<IPathSegment> get endsWith;
}
