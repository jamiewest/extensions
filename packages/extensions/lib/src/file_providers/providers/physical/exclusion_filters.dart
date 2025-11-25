/// Specifies filtering behavior for files or directories.
enum ExclusionFilters {
  /// Do not exclude any files.
  none(0x0000),

  /// Exclude files and directories whose name begins with period.
  dotPrefixed(0x0001),

  /// Exclude files and directories marked as hidden (e.g., FileSystemEntity.isHidden).
  hidden(0x0002),

  /// Exclude files and directories marked as system files.
  system(0x0004),

  /// Exclude files and directories when the name begins with a period,
  /// or has hidden or system attributes.
  sensitive(0x0007); // dotPrefixed | hidden | system

  const ExclusionFilters(this.value);

  /// The numeric value of the filter.
  final int value;

  /// Checks if this filter includes the specified filter.
  bool hasFlag(ExclusionFilters filter) => (value & filter.value) != 0;

  /// Combines multiple filters.
  ExclusionFilters operator |(ExclusionFilters other) {
    final combinedValue = value | other.value;
    return ExclusionFilters.values.firstWhere(
      (f) => f.value == combinedValue,
      orElse: () => ExclusionFilters.none,
    );
  }

  /// Checks if a file or directory name should be excluded based on this filter.
  bool shouldExclude(String name, {bool isHidden = false}) {
    if (this == ExclusionFilters.none) {
      return false;
    }

    // Check dot-prefixed filter
    if (hasFlag(ExclusionFilters.dotPrefixed) && name.startsWith('.')) {
      return true;
    }

    // Check hidden filter
    if (hasFlag(ExclusionFilters.hidden) && isHidden) {
      return true;
    }

    // Note: System file detection is platform-specific and may require
    // additional platform-specific logic

    return false;
  }
}
