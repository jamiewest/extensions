import 'package:file/file.dart';
import 'package:file/memory.dart';

/// Returns the default [FileSystem] for web platforms.
///
/// The returned filesystem is an empty, posix-style [MemoryFileSystem]. Callers
/// that need seeded content should construct their own [MemoryFileSystem] and
/// pass it to the provider rather than relying on this default.
FileSystem defaultFileSystem() => MemoryFileSystem();
