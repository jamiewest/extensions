/// Specifies filtering behavior for files or directories.
class ExclusionFilters {
  /// Equivalent to `DotPrefixed | Hidden | System`. Exclude files and
  /// directories when the name begins with a period, or has either
  /// `FileAttributes.Hidden` or `FileAttributes.System` is set on
  /// `FileSystemInfo.Attributes`.
  static const int sensitive = dotPrefixed | hidden | system;

  /// Exclude files and directories when the name begins with period.
  static const int dotPrefixed = 0x0001;

  /// Exclude files and directories when `FileAttributes.Hidden`
  /// is set on `FileSystemInfo.Attributes`.
  static const int hidden = 0x0002;

  /// Exclude files and directories when `FileAttributes.System`
  /// is set on `FileSystemInfo.Attributes`.
  static const int system = 0x0004;

  /// Do not exclude any files.
  static const int none = 0;
}
