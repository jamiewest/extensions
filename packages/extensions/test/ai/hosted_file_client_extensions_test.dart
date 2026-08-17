import 'dart:typed_data';

import 'package:extensions/ai.dart';
import 'package:extensions/system.dart' hide equals;
import 'package:test/test.dart';

final class _FakeHostedFileClient implements HostedFileClient {
  _FakeHostedFileClient({this.metadataByFileId = const {}});

  final Map<String, HostedFileContent> metadataByFileId;
  final Map<String, List<int>> stored = {};
  String? lastUploadMediaType;
  String? lastUploadFileName;

  @override
  Future<HostedFileContent> upload(
    Stream<List<int>> content, {
    String? mediaType,
    String? fileName,
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final bytes = await content.expand((c) => c).toList();
    final id = 'file-${stored.length}';
    stored[id] = bytes;
    lastUploadMediaType = mediaType;
    lastUploadFileName = fileName;
    return HostedFileContent(fileId: id, mediaType: mediaType, name: fileName);
  }

  @override
  Stream<List<int>> download(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) => Stream.fromIterable([stored[fileId] ?? const []]);

  @override
  Future<HostedFileContent?> getFile(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) async => metadataByFileId[fileId];

  @override
  Stream<HostedFileContent> listFiles({
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) => const Stream.empty();

  @override
  Future<bool> delete(
    String fileId, {
    HostedFileClientOptions? options,
    CancellationToken? cancellationToken,
  }) async => stored.remove(fileId) != null;

  @override
  T? getService<T>({Object? key}) {
    if (T == HostedFileClientMetadata) {
      return const HostedFileClientMetadata(providerName: 'fake') as T;
    }
    return null;
  }

  @override
  void dispose() {}
}

void main() {
  group('HostedFileClientExtensions', () {
    test('uploadDataContent forwards bytes, media type, and name', () async {
      final client = _FakeHostedFileClient();
      final content = DataContent(
        Uint8List.fromList([1, 2, 3]),
        mediaType: 'application/pdf',
        name: 'doc.pdf',
      );

      final hosted = await client.uploadDataContent(content);

      expect(client.stored[hosted.fileId], equals([1, 2, 3]));
      expect(client.lastUploadMediaType, 'application/pdf');
      expect(client.lastUploadFileName, 'doc.pdf');
    });

    test('uploadDataContent rejects data-less content', () {
      final client = _FakeHostedFileClient();
      final uriOnly = DataContent.fromUri('https://example.com/doc.pdf');

      expect(() => client.uploadDataContent(uriOnly), throwsArgumentError);
    });

    test('downloadAsDataContent joins bytes with getFile metadata', () async {
      final client = _FakeHostedFileClient(
        metadataByFileId: {
          'f1': HostedFileContent(
            fileId: 'f1',
            mediaType: 'text/plain',
            name: 'a.txt',
          ),
        },
      );
      client.stored['f1'] = [104, 105];

      final content = await client.downloadAsDataContent('f1');

      expect(content.data, equals([104, 105]));
      expect(content.mediaType, 'text/plain');
      expect(content.name, 'a.txt');
    });

    test('downloadAsDataContent falls back to octet-stream', () async {
      final client = _FakeHostedFileClient();
      client.stored['f2'] = [1];

      final content = await client.downloadAsDataContent('f2');

      expect(content.mediaType, 'application/octet-stream');
      expect(content.name, isNull);
    });

    test('downloadFromContent downloads by the content fileId', () async {
      final client = _FakeHostedFileClient();
      client.stored['f3'] = [7, 7];

      final bytes = await client
          .downloadFromContent(HostedFileContent(fileId: 'f3'))
          .expand((c) => c)
          .toList();

      expect(bytes, equals([7, 7]));
    });

    test('getMetadata resolves through getService', () {
      final client = _FakeHostedFileClient();

      expect(client.getMetadata()!.providerName, 'fake');
    });
  });
}
