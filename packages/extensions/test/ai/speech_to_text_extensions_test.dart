import 'dart:typed_data';

import 'package:extensions/ai.dart';
import 'package:extensions/system.dart' hide equals;
import 'package:test/test.dart';

final class _RecordingClient implements SpeechToTextClient {
  List<int>? receivedBytes;

  @override
  Future<SpeechToTextResponse> getText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    receivedBytes = [await stream.expand((c) => c).toList()].first;
    return SpeechToTextResponse.fromText('ok');
  }

  @override
  Stream<SpeechToTextResponseUpdate> getStreamingText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    receivedBytes = await stream.expand((c) => c).toList();
    yield SpeechToTextResponseUpdate.fromText(
      SpeechToTextResponseUpdateKind.textUpdated,
      'ok',
    );
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

void main() {
  group('SpeechToTextClientExtensions', () {
    test('getTextFromDataContent feeds the bytes to getText', () async {
      final client = _RecordingClient();
      final audio = DataContent(
        Uint8List.fromList([1, 2, 3]),
        mediaType: 'audio/wav',
      );

      final response = await client.getTextFromDataContent(audio);

      expect(response.text, 'ok');
      expect(client.receivedBytes, equals([1, 2, 3]));
    });

    test('getTextFromDataContent rejects data-less content', () {
      final client = _RecordingClient();
      final uriOnly = DataContent.fromUri('https://example.com/a.wav');

      expect(() => client.getTextFromDataContent(uriOnly), throwsArgumentError);
    });

    test('getStreamingTextFromDataContent feeds bytes and streams', () async {
      final client = _RecordingClient();
      final audio = DataContent(
        Uint8List.fromList([9, 8]),
        mediaType: 'audio/wav',
      );

      final updates = await client
          .getStreamingTextFromDataContent(audio)
          .toList();

      expect(updates.single.text, 'ok');
      expect(client.receivedBytes, equals([9, 8]));
    });
  });

  group('SpeechToTextResponseUpdatesExtensions', () {
    test('toSpeechToTextResponse merges metadata, times, and usage', () {
      final updates = [
        SpeechToTextResponseUpdate(
          kind: SpeechToTextResponseUpdateKind.sessionOpen,
          responseId: 'r1',
          modelId: 'm1',
          startTime: const Duration(seconds: 3),
          endTime: const Duration(seconds: 4),
        ),
        SpeechToTextResponseUpdate(
          kind: SpeechToTextResponseUpdateKind.textUpdating,
          contents: [TextContent('Hello, ')],
          startTime: const Duration(seconds: 1),
          usage: UsageDetails(inputTokenCount: 2),
        ),
        SpeechToTextResponseUpdate(
          kind: SpeechToTextResponseUpdateKind.textUpdated,
          contents: [TextContent('world!')],
          endTime: const Duration(seconds: 9),
          usage: UsageDetails(inputTokenCount: 3),
        ),
      ];

      final response = updates.toSpeechToTextResponse();

      expect(response.responseId, 'r1');
      expect(response.modelId, 'm1');
      expect(response.startTime, const Duration(seconds: 1));
      expect(response.endTime, const Duration(seconds: 9));
      expect(response.text, 'Hello, world!');
      expect(response.usage!.inputTokenCount, 5);
    });

    test('adjacent text contents are coalesced into one item', () {
      final updates = [
        SpeechToTextResponseUpdate.fromText(
          SpeechToTextResponseUpdateKind.textUpdating,
          'a',
        ),
        SpeechToTextResponseUpdate.fromText(
          SpeechToTextResponseUpdateKind.textUpdating,
          'b',
        ),
        SpeechToTextResponseUpdate.fromText(
          SpeechToTextResponseUpdateKind.textUpdated,
          'c',
        ),
      ];

      final response = updates.toSpeechToTextResponse();

      expect(response.contents, hasLength(1));
      expect((response.contents.single as TextContent).text, 'abc');
    });

    test('usage contents fold into usage instead of contents', () {
      final updates = [
        SpeechToTextResponseUpdate(
          kind: SpeechToTextResponseUpdateKind.textUpdated,
          contents: [
            TextContent('hi'),
            UsageContent(UsageDetails(totalTokenCount: 7)),
          ],
        ),
      ];

      final response = updates.toSpeechToTextResponse();

      expect(response.contents.whereType<UsageContent>(), isEmpty);
      expect(response.usage!.totalTokenCount, 7);
    });

    test('a stream of updates combines the same way', () async {
      final response = await Stream.fromIterable([
        SpeechToTextResponseUpdate.fromText(
          SpeechToTextResponseUpdateKind.textUpdating,
          'strea',
        ),
        SpeechToTextResponseUpdate.fromText(
          SpeechToTextResponseUpdateKind.textUpdated,
          'ming',
        ),
      ]).toSpeechToTextResponse();

      expect(response.text, 'streaming');
    });
  });
}
