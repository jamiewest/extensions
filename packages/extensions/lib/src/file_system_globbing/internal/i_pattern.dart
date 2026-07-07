import 'i_pattern_context.dart';

/// A parsed globbing pattern that can create traversal contexts.
///
/// The `I` prefix intentionally mirrors the upstream C# type
/// `Microsoft.Extensions.FileSystemGlobbing.Internal.IPattern`. This API
/// supports infrastructure and is not intended to be used directly.
abstract interface class IPattern {
  /// Creates a context that treats this pattern as an include filter.
  IPatternContext createPatternContextForInclude();

  /// Creates a context that treats this pattern as an exclude filter.
  IPatternContext createPatternContextForExclude();
}
