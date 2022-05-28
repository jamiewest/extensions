// import 'dart:io';

// import 'package:watcher/watcher.dart';

// import '../../../primitives.dart';
// import 'exclusion_filters.dart';

// class PhysicalFilesWatcher implements Disposable {
//   final Watcher _watcher;
//   final String _root;
//   PhysicalFilesWatcher(
//     String root,
//     Watcher watcher,
//     bool pollForChanges,
//     ExclusionFilters filters,
//   )   : _root = root,
//         _watcher = watcher {
//     _watcher.events.listen((event) {
//       if (event.type == ChangeType.MODIFY)
//     });
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//   }

//   void _onRenamed(WatchEvent event) {} 

//   void _onFileSystemEntryChange(String fullPath) {
//     try {
//       var fileSystemInfo = File(fullPath);
//     } catch (e) {

//     }
//   }
// }
