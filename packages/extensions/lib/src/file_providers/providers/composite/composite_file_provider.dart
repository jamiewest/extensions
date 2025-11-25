import 'package:path/path.dart' as p;

import '../../../primitives/change_token.dart';
import '../../../primitives/composite_change_token.dart';
import '../../directory_contents.dart';
import '../../file_info.dart';
import '../../file_provider.dart';
import '../../not_found_directory_contents.dart';
import '../../not_found_file_info.dart';
import 'composite_directory_contents.dart';

/// Aggregates multiple file providers into a single provider.
class CompositeFileProvider implements FileProvider {
  CompositeFileProvider(this.fileProviders);

  /// The underlying providers in order.
  final List<FileProvider> fileProviders;

  @override
  FileInfo getFileInfo(String subpath) {
    // Normalize the subpath similar to .NET implementation.
    if (subpath.isEmpty || subpath == '/' || subpath == '\\') {
      return NotFoundFileInfo(subpath);
    }

    var normalized = _normalizePath(subpath);

    for (var provider in fileProviders) {
      var fileInfo = provider.getFileInfo(normalized);
      if (fileInfo.exists) {
        return fileInfo;
      }
    }

    return NotFoundFileInfo(subpath);
  }

  @override
  DirectoryContents getDirectoryContents(String subpath) {
    // If any provider says the directory exists, we take the union.
    var contents = <DirectoryContents>[];
    for (var provider in fileProviders) {
      contents.add(provider.getDirectoryContents(subpath));
    }

    if (contents.any((c) => c.exists)) {
      return CompositeDirectoryContents(contents);
    }

    return NotFoundDirectoryContents.singleton();
  }

  @override
  IChangeToken watch(String filter) {
    // Composite change tokens: combine all watches.
    var tokens = fileProviders.map((fp) => fp.watch(filter)).toList();
    return CompositeChangeToken(tokens);
  }

  String _normalizePath(String subpath) {
    var path = p.normalize(subpath).replaceAll('\\', '/');
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    return path;
  }
}
