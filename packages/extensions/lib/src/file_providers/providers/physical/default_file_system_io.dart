import 'package:file/file.dart';
import 'package:file/local.dart';

/// Returns the default [FileSystem] for VM and native/device platforms.
FileSystem defaultFileSystem() => const LocalFileSystem();
