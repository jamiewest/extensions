/// Provides the default [FileSystem] for the current platform.
///
/// On the Dart VM and native/device targets this resolves to a
/// `LocalFileSystem`; on web it resolves to an in-memory filesystem so that
/// filesystem-backed providers remain compilable and usable.
library;

export 'default_file_system_web.dart'
    if (dart.library.io) 'default_file_system_io.dart';
