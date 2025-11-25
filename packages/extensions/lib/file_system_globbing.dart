/// Provides support for matching file system names/paths using glob patterns.
///
/// This library enables pattern-based file matching similar to
/// Microsoft.Extensions.FileSystemGlobbing.
library file_system_globbing;

// Core classes
export 'src/file_system_globbing/file_pattern_match.dart';
export 'src/file_system_globbing/matcher.dart';
export 'src/file_system_globbing/matcher_extensions.dart';
export 'src/file_system_globbing/pattern_matching_result.dart';

// Abstractions
export 'src/file_system_globbing/abstractions/directory_info_base.dart';
export 'src/file_system_globbing/abstractions/directory_info_wrapper.dart';
export 'src/file_system_globbing/abstractions/file_info_base.dart';
export 'src/file_system_globbing/abstractions/file_info_wrapper.dart';
export 'src/file_system_globbing/abstractions/file_system_info_base.dart';

// In-memory support
export 'src/file_system_globbing/in_memory_directory_info.dart';

export 'package:glob/glob.dart';
