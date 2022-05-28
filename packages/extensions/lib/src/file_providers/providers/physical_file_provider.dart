// import 'package:extensions/src/file_providers/providers/exclusion_filters.dart';
// import 'package:extensions/src/file_providers/providers/physical_file_info.dart';
// import 'package:extensions/src/file_providers/providers/physical_files_watcher.dart';
// import 'package:path/path.dart' as p;
// import 'package:watcher/watcher.dart';

// import '../../../primitives.dart';
// import '../directory_contents.dart';
// import '../file_info.dart';
// import '../file_provider.dart';

// class PhysicalFileProvider implements FileProvider, Disposable {
//   final List<String> _pathSeparators = <String>[p.separator];
//   int _exclusionFilters;
//   PhysicalFilesWatcher Function() _fileWatcherFactory;
//   PhysicalFilesWatcher? _fileWatcher;
//   bool _fileWatcherInitialized;
//   bool? _usePollingFileWatcher;
//   bool? _useActivePolling;
//   bool _disposed;

//   PhysicalFileProvider(String root, int filters) {
    
//   }

//   @override
//   void dispose() {}

//   @override
//   FileInfo? getfileInfo(String subpath) {
//     // TODO: implement getfileInfo
//     throw UnimplementedError();
//   }

//   @override
//   DirectoryContents? getDirectoryContents(String subpath) {
//     // TODO: implement getDirectoryContents
//     throw UnimplementedError();
//   }

//   @override
//   ChangeToken? watch(String filter) {
//     ChangeToken.onChange(() => null, () { })
//     var watcher = DirectoryWatcher(p.absolute(arguments[0]));
//     watcher.events.listen((event) {
      
//     });
//   }
// }
