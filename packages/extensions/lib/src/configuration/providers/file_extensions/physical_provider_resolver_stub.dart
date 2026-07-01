import '../../../file_providers/file_provider.dart';

/// A resolved physical provider and the file path relative to it.
typedef ResolvedProvider = ({FileProvider provider, String path});

/// The current working directory path.
///
/// Returns the filesystem root on platforms without `dart:io`, since web has no
/// concept of a current directory.
String currentDirectoryPath() => '/';

/// Whether a file exists at [path] on disk.
///
/// Always `false` on platforms without `dart:io`.
bool fileExistsSync(String path) => false;

/// Resolves a [FileProvider] for the nearest existing ancestor directory of the
/// absolute [path].
///
/// Always `null` on platforms without `dart:io`; web callers seed and inject
/// their own provider instead.
ResolvedProvider? resolvePhysicalProvider(String path) => null;
