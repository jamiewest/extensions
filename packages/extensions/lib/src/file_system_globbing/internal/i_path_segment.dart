/// A segment of a globbing pattern, such as a literal name, `*`, or `**`.
///
/// The `I` prefix intentionally mirrors the upstream C# type
/// `Microsoft.Extensions.FileSystemGlobbing.Internal.IPathSegment`. This API
/// supports infrastructure and is not intended to be used directly.
abstract interface class IPathSegment {
  /// Whether a directory matched by this segment contributes to the stem of
  /// a match.
  bool get canProduceStem;

  /// Tests whether [value] (a single file or directory name) matches this
  /// segment.
  bool match(String value);
}
