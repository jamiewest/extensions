// ignore: avoid_classes_with_only_static_members
/// Utility methods and constants for manipulating Configuration paths
class ConfigurationPath {
  /// The delimiter ":" used to separate individual keys in a path.
  static String keyDelimiter = ':';

  /// Combines path segments into one path.
  static String combine(Iterable<String> pathSegments) =>
      pathSegments.join(keyDelimiter);

  // Extracts the last path segment from the path.
  static String? getSectionKey(String? path) {
    if (path == null) {
      return path;
    }

    var lastDelimiterIndex = path.lastIndexOf(keyDelimiter);
    return lastDelimiterIndex == -1
        ? path
        : path.substring(lastDelimiterIndex + 1);
  }

  /// Extracts the path corresponding to the parent node for a given path.
  static String? getParentPath(String? path) {
    if (path == null) {
      return null;
    }
    if (path.isEmpty) {
      return null;
    }
    var lastDelimiterIndex = path.lastIndexOf(keyDelimiter);
    return lastDelimiterIndex == -1
        ? null
        : path.substring(0, lastDelimiterIndex);
  }
}
