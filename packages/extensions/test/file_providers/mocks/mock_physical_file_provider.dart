import 'package:extensions/file_providers.dart';
import 'package:extensions/primitives.dart';

import 'mock_physical_files_watcher.dart';

/// A mock physical file provider for testing that uses a mock watcher.
class MockPhysicalFileProvider implements FileProvider {
  final PhysicalFileProvider _provider;
  final MockPhysicalFilesWatcher _mockWatcher;

  MockPhysicalFileProvider(String root)
      : _provider = PhysicalFileProvider(root),
        _mockWatcher = MockPhysicalFilesWatcher(root);

  PhysicalFileProvider get provider => _provider;
  MockPhysicalFilesWatcher get mockWatcher => _mockWatcher;

  @override
  FileInfo getFileInfo(String subpath) => _provider.getFileInfo(subpath);

  @override
  DirectoryContents getDirectoryContents(String subpath) =>
      _provider.getDirectoryContents(subpath);

  @override
  IChangeToken watch(String filter) => _mockWatcher.createFileChangeToken(filter);

  void dispose() {
    _provider.dispose();
    _mockWatcher.dispose();
  }
}
