/// Specifies how two strings are compared during pattern matching.
///
/// Mirrors the subset of .NET `StringComparison` values supported by
/// `Microsoft.Extensions.FileSystemGlobbing`.
enum StringComparison {
  /// Compare strings using ordinal (binary) sort rules.
  ordinal,

  /// Compare strings using ordinal (binary) sort rules, ignoring case.
  ordinalIgnoreCase,
}

/// Returns a canonical key for [value] under [comparisonType], suitable for
/// direct `==` comparison or use in hash-based collections.
String stringComparisonKey(String value, StringComparison comparisonType) =>
    comparisonType == StringComparison.ordinalIgnoreCase
    ? value.toLowerCase()
    : value;
