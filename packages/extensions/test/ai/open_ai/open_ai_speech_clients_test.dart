import 'dart:convert';

import 'package:extensions/ai.dart';
import 'package:test/test.dart';

import 'helpers/verbatim_http_client.dart';

void main() {
  // ---------------------------------------------------------------------------
  // OpenAISpeechToTextClient
  // ---------------------------------------------------------------------------

  group('OpenAISpeechToTextClient', () {
    group('metadata', () {
      test('provider name is openai', () {
        final client = OpenAISpeechToTextClient('whisper-1', 'key');
        expect(client.metadata.providerName, equals('openai'));
      });

      test('default model id is surfaced', () {
        final client = OpenAISpeechToTextClient('whisper-1', 'key');
        expect(client.metadata.defaultModelId, equals('whisper-1'));
      });

      test('provider uri reflects custom endpoint', () {
        final endpoint = Uri.parse('http://localhost:1234/v1');
        final client = OpenAISpeechToTextClient(
          'whisper-1',
          'key',
          options: OpenAIClientOptions(endpoint: endpoint),
        );
        expect(client.metadata.providerUri, equals(endpoint));
      });
    });

    group('getService', () {
      test('returns metadata', () {
        final client = OpenAISpeechToTextClient('whisper-1', 'key');
        expect(client.getService<SpeechToTextClientMetadata>(), isNotNull);
      });

      test('returns self', () {
        final client = OpenAISpeechToTextClient('whisper-1', 'key');
        expect(client.getService<OpenAISpeechToTextClient>(), same(client));
      });

      test('returns null for unknown type', () {
        final client = OpenAISpeechToTextClient('whisper-1', 'key');
        expect(client.getService<String>(), isNull);
      });
    });

    group('getText', () {
      test('returns transcription text', () async {
        final responseJson = jsonEncode({
          'text': 'Hello, world.',
          'duration': 1.5,
        });

        final fakeHttp = VerbatimHttpClient(responseJson);
        final client = OpenAISpeechToTextClient(
          'whisper-1',
          'key',
          options: OpenAIClientOptions(httpClient: fakeHttp),
        );

        final result = await client.getText(
          stream: Stream.value([0x01, 0x02, 0x03]),
        );

        expect(result.text, equals('Hello, world.'));
      });

      test('populates end time from duration', () async {
        final responseJson = jsonEncode({'text': 'Hi', 'duration': 2.5});
        final fakeHttp = VerbatimHttpClient(responseJson);
        final client = OpenAISpeechToTextClient(
          'whisper-1',
          'key',
          options: OpenAIClientOptions(httpClient: fakeHttp),
        );

        final result = await client.getText(
          stream: Stream.value([0x01]),
        );

        expect(result.endTime, equals(const Duration(milliseconds: 2500)));
      });

      test('throws on error response', () async {
        final fakeHttp = ErrorHttpClient(statusCode: 400);
        final client = OpenAISpeechToTextClient(
          'whisper-1',
          'key',
          options: OpenAIClientOptions(httpClient: fakeHttp),
        );

        await expectLater(
          client.getText(stream: Stream.value([0x01])),
          throwsStateError,
        );
      });
    });

    group('getStreamingText', () {
      test('yields single update (fallback behaviour)', () async {
        final responseJson = jsonEncode({'text': 'Streaming text.'});
        final fakeHttp = VerbatimHttpClient(responseJson);
        final client = OpenAISpeechToTextClient(
          'whisper-1',
          'key',
          options: OpenAIClientOptions(httpClient: fakeHttp),
        );

        final updates = await client
            .getStreamingText(stream: Stream.value([0x01]))
            .toList();

        expect(updates, hasLength(1));
        expect(updates.first.text, equals('Streaming text.'));
      });
    });
  });

  // ---------------------------------------------------------------------------
  // OpenAITextToSpeechClient
  // ---------------------------------------------------------------------------

  group('OpenAITextToSpeechClient', () {
    group('metadata', () {
      test('provider name is openai', () {
        final client = OpenAITextToSpeechClient('tts-1', 'key');
        expect(client.metadata.providerName, equals('openai'));
      });

      test('default model id is surfaced', () {
        final client = OpenAITextToSpeechClient('tts-1-hd', 'key');
        expect(client.metadata.defaultModelId, equals('tts-1-hd'));
      });

      test('provider uri reflects custom endpoint', () {
        final endpoint = Uri.parse('http://localhost:1234/v1');
        final client = OpenAITextToSpeechClient(
          'tts-1',
          'key',
          options: OpenAIClientOptions(endpoint: endpoint),
        );
        expect(client.metadata.providerUri, equals(endpoint));
      });
    });

    group('getService', () {
      test('returns metadata', () {
        final client = OpenAITextToSpeechClient('tts-1', 'key');
        expect(client.getService<TextToSpeechClientMetadata>(), isNotNull);
      });

      test('returns self', () {
        final client = OpenAITextToSpeechClient('tts-1', 'key');
        expect(client.getService<OpenAITextToSpeechClient>(), same(client));
      });

      test('returns null for unknown type', () {
        final client = OpenAITextToSpeechClient('tts-1', 'key');
        expect(client.getService<String>(), isNull);
      });
    });

    group('getAudio', () {
      test('returns DataContent with audio bytes', () async {
        final audioBytes = [0xFF, 0xFB, 0x00];
        final fakeHttp = VerbatimHttpClient(
          String.fromCharCodes(audioBytes),
          contentType: 'audio/mpeg',
        );
        final client = OpenAITextToSpeechClient(
          'tts-1',
          'key',
          options: OpenAIClientOptions(httpClient: fakeHttp),
        );

        final result = await client.getAudio('Hello world');

        expect(result.audio, isNotNull);
        expect(result.audio!.mediaType, equals('audio/mpeg'));
      });

      test('voice defaults to alloy', () async {
        final fakeHttp = VerbatimHttpClient(
          'audio',
          contentType: 'audio/mpeg',
        );
        final client = OpenAITextToSpeechClient(
          'tts-1',
          'key',
          options: OpenAIClientOptions(httpClient: fakeHttp),
        );

        await client.getAudio('Hello');

        final body =
            jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
        expect(body['voice'], equals('alloy'));
      });

      test('custom voice is sent', () async {
        final fakeHttp = VerbatimHttpClient(
          'audio',
          contentType: 'audio/mpeg',
        );
        final client = OpenAITextToSpeechClient(
          'tts-1',
          'key',
          options: OpenAIClientOptions(httpClient: fakeHttp),
        );

        await client.getAudio(
          'Hello',
          options: TextToSpeechOptions(voiceId: 'nova'),
        );

        final body =
            jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
        expect(body['voice'], equals('nova'));
      });

      test('speed is sent when specified', () async {
        final fakeHttp = VerbatimHttpClient(
          'audio',
          contentType: 'audio/mpeg',
        );
        final client = OpenAITextToSpeechClient(
          'tts-1',
          'key',
          options: OpenAIClientOptions(httpClient: fakeHttp),
        );

        await client.getAudio(
          'Hello',
          options: TextToSpeechOptions(speed: 1.5),
        );

        final body =
            jsonDecode(fakeHttp.capturedRequestBody!) as Map<String, dynamic>;
        expect(body['speed'], equals(1.5));
      });

      test('throws on error response', () async {
        final fakeHttp = ErrorHttpClient(statusCode: 400);
        final client = OpenAITextToSpeechClient(
          'tts-1',
          'key',
          options: OpenAIClientOptions(httpClient: fakeHttp),
        );

        await expectLater(
          client.getAudio('Hello'),
          throwsStateError,
        );
      });
    });

    group('getStreamingAudio', () {
      test('yields update per chunk', () async {
        final fakeHttp = StreamingHttpClient(['chunk1', 'chunk2']);
        final client = OpenAITextToSpeechClient(
          'tts-1',
          'key',
          options: OpenAIClientOptions(httpClient: fakeHttp),
        );

        final updates =
            await client.getStreamingAudio('Hello world').toList();

        expect(updates, isNotEmpty);
        for (final update in updates) {
          expect(update.audio, isNotNull);
        }
      });
    });
  });
}
