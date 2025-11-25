import 'package:extensions/file_providers.dart';
import 'package:extensions/primitives.dart';
import 'package:extensions/system.dart' show IDisposable;
import 'package:test/test.dart';

class FakeFileInfo implements FileInfo {
  FakeFileInfo(this.name, {this.exists = true});

  @override
  final bool exists;

  @override
  int get length => 0;

  @override
  String? get physicalPath => '/$name';

  @override
  DateTime get lastModified => DateTime.fromMillisecondsSinceEpoch(0);

  @override
  final String name;

  @override
  bool get isDirectory => false;

  @override
  Stream<dynamic> createReadStream() => const Stream.empty();
}

class FakeDirectoryContents extends DirectoryContents {
  FakeDirectoryContents(List<FileInfo> entries, {this.exists = true})
      : super(entries);

  @override
  final bool exists;
}

class FakeChangeToken implements IChangeToken {
  FakeChangeToken({this.activeChangeCallbacks = true});

  @override
  bool hasChanged = false;

  @override
  final bool activeChangeCallbacks;

  final List<void Function(Object?)> _callbacks =
      <void Function(Object?)>[];

  void trigger() {
    hasChanged = true;
    for (var cb in List.of(_callbacks)) {
      cb(null);
    }
  }

  @override
  IDisposable registerChangeCallback(
    void Function(Object? state) callback,
    Object? state,
  ) {
    void wrapper(Object? _) => callback(state);
    _callbacks.add(wrapper);
    return _CallbackDisposable(() {
      _callbacks.remove(wrapper);
    });
  }
}

class _CallbackDisposable implements IDisposable {
  _CallbackDisposable(this._onDispose);

  final void Function() _onDispose;

  @override
  void dispose() => _onDispose();
}

class FakeFileProvider implements FileProvider {
  FakeFileProvider({
    Map<String, FileInfo>? files,
    Map<String, DirectoryContents>? directories,
    IChangeToken? changeToken,
  })  : _files = files ?? <String, FileInfo>{},
        _directories = directories ?? <String, DirectoryContents>{},
        _changeToken = changeToken ?? FakeChangeToken();

  final Map<String, FileInfo> _files;
  final Map<String, DirectoryContents> _directories;
  final IChangeToken _changeToken;

  @override
  FileInfo getFileInfo(String subpath) =>
      _files[subpath] ?? NotFoundFileInfo(subpath);

  @override
  DirectoryContents getDirectoryContents(String subpath) =>
      _directories[subpath] ?? NotFoundDirectoryContents.singleton();

  @override
  IChangeToken watch(String filter) => _changeToken;
}

void main() {
  group('CompositeFileProvider', () {
    test('getFileInfo_uses_first_existing', () {
      var first = FakeFileInfo('a.txt');
      var provider1 = FakeFileProvider(files: {'/a.txt': first});
      var provider2 =
          FakeFileProvider(files: {'/a.txt': FakeFileInfo('a.txt')});

      var composite = CompositeFileProvider([provider1, provider2]);

      var result = composite.getFileInfo('/a.txt');

      expect(identical(result, first), isTrue);
    });

    test('getDirectoryContents_merges_and_deduplicates', () {
      var provider1 = FakeFileProvider(
        directories: {
          '/dir': FakeDirectoryContents(
            [FakeFileInfo('a.txt')],
          )
        },
      );
      var provider2 = FakeFileProvider(
        directories: {
          '/dir': FakeDirectoryContents(
            [
              FakeFileInfo('a.txt'),
              FakeFileInfo('b.txt'),
            ],
          )
        },
      );

      var composite = CompositeFileProvider([provider1, provider2]);

      var contents = composite.getDirectoryContents('/dir');

      expect(contents.exists, isTrue);
      expect(contents.map((f) => f.name).toList(), equals(['a.txt', 'b.txt']));
    });

    test('watch_triggers_when_any_child_changes', () {
      var token1 = FakeChangeToken();
      var token2 = FakeChangeToken();
      var provider1 = FakeFileProvider(changeToken: token1);
      var provider2 = FakeFileProvider(changeToken: token2);

      var composite = CompositeFileProvider([provider1, provider2]);
      var compositeToken = composite.watch('*.txt');

      var fired = 0;
      compositeToken.registerChangeCallback(
        (_) {
          fired++;
        },
        null,
      );

      token2.trigger();

      expect(fired, equals(1));
      expect(compositeToken.hasChanged, isTrue);
    });
  });
}
