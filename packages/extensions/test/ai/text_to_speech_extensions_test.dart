import 'dart:typed_data';

import 'package:extensions/ai.dart';
import 'package:test/test.dart';

void main() {
  group('TextToSpeechResponseUpdateKind', () {
    test('defaults to audioUpdating on updates', () {
      expect(
        TextToSpeechResponseUpdate().kind,
        TextToSpeechResponseUpdateKind.audioUpdating,
      );
    });

    test('equality is case-insensitive', () {
      expect(
        const TextToSpeechResponseUpdateKind('Audio_Updated'),
        equals(TextToSpeechResponseUpdateKind.audioUpdated),
      );
    });
  });

  group('TextToSpeechResponseUpdatesExtensions', () {
    test('toTextToSpeechResponse concatenates audio chunks', () {
      final updates = [
        TextToSpeechResponseUpdate(
          responseId: 'r1',
          modelId: 'm1',
          audio: DataContent(
            Uint8List.fromList([1, 2]),
            mediaType: 'audio/wav',
            name: 'clip.wav',
          ),
        ),
        TextToSpeechResponseUpdate(
          kind: TextToSpeechResponseUpdateKind.audioUpdated,
          audio: DataContent(
            Uint8List.fromList([3, 4]),
            mediaType: 'audio/wav',
          ),
        ),
      ];

      final response = updates.toTextToSpeechResponse();

      expect(response.responseId, 'r1');
      expect(response.modelId, 'm1');
      expect(response.audio!.data, equals([1, 2, 3, 4]));
      expect(response.audio!.mediaType, 'audio/wav');
      expect(response.audio!.name, 'clip.wav');
    });

    test('a single chunk is passed through unchanged', () {
      final audio = DataContent(
        Uint8List.fromList([5]),
        mediaType: 'audio/mpeg',
      );

      final response = [TextToSpeechResponseUpdate(audio: audio)]
          .toTextToSpeechResponse();

      expect(response.audio, same(audio));
    });

    test('a data-less chunk makes the last chunk win', () {
      final last = DataContent.fromUri('https://example.com/audio.mp3');

      final response = [
        TextToSpeechResponseUpdate(
          audio: DataContent(Uint8List.fromList([1]), mediaType: 'audio/wav'),
        ),
        TextToSpeechResponseUpdate(audio: last),
      ].toTextToSpeechResponse();

      expect(response.audio, same(last));
    });

    test('a stream of updates combines the same way', () async {
      final response = await Stream.fromIterable([
        TextToSpeechResponseUpdate(
          audio: DataContent(Uint8List.fromList([1]), mediaType: 'audio/wav'),
        ),
        TextToSpeechResponseUpdate(
          audio: DataContent(Uint8List.fromList([2]), mediaType: 'audio/wav'),
        ),
      ]).toTextToSpeechResponse();

      expect(response.audio!.data, equals([1, 2]));
    });

    test('no audio chunks yields a null audio', () {
      final response = [TextToSpeechResponseUpdate(responseId: 'r1')]
          .toTextToSpeechResponse();

      expect(response.audio, isNull);
      expect(response.responseId, 'r1');
    });
  });
}
