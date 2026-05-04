class PathValidation {
  PathValidation();

  static final List<char> _invalidFileNameChars = Path.GetInvalidFileNameChars();

  static final StringComparison _pathComparison;

  /// Validates that a path segment is a safe single directory or file name.
  /// Throws [ArgumentException] if the segment contains path separators,
  /// invalid file name characters, or directory traversal sequences.
  static void validatePathSegment(String? segment, String paramName, ) {
    if (segment == null) {
      return;
    }
    if (segment.length == 0
            || segment != segment.trim()
            || segment is "."
            || segment is ".."
            || segment.indexOfAny(_invalidFileNameChars) >= 0) {
      Throw.argumentException(
                paramName,
                'The parameter '${paramName}' contains invalid path characters or directory traversal sequences.');
    }
  }

  /// Verifies that a fully resolved path is contained within the specified root
  /// directory. Both paths are canonicalized via [String)] before comparison.
  /// Throws [InvalidOperationException] if the resolved path escapes the root.
  static String ensureWithinRoot(String rootPath, String resolvedPath, ) {
    var fullRoot = Path.getFullPath(rootPath);
    var normalizedRoot = fullRoot;
    var fullResolved = Path.getFullPath(resolvedPath);
    if (!normalizedRoot.endsWith(Path.directorySeparatorChar.toString(), StringComparison.ordinal) &&
            !normalizedRoot.endsWith(
              Path.altDirectorySeparatorChar.toString(),
              StringComparison.ordinal,
            ) ) {
      normalizedRoot += Path.directorySeparatorChar;
    }
    if (!fullResolved.startsWith(normalizedRoot, _pathComparison) &&
            !string.equals(fullRoot, fullResolved, _pathComparison)) {
      throw invalidOperationException(
                "The resolved path escapes the configured root directory. " +
                "This may indicate a path traversal attempt.");
    }
    return fullResolved;
  }
}
