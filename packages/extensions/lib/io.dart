/// Convenience library that exports all IO-specific functionality.
///
/// This library aggregates all platform-specific features that depend on
/// dart:io, including configuration from environment variables and
/// console lifetime management.
///
/// Import this library instead of importing individual IO libraries:
///
/// ```dart
/// import 'package:extensions/io.dart';
/// ```
library;

export 'configuration_io.dart';
export 'hosting_io.dart';
