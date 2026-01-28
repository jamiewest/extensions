import 'package:extensions/ai.dart';
import 'package:test/test.dart';

class _TestTool extends AITool {
  _TestTool(String name) : super(name: name);
}

void main() {
  group('ChatOptions', () {
    test('clone copies lists and maps', () {
      final options = ChatOptions(
        conversationId: 'conv',
        modelId: 'model',
        stopSequences: ['stop'],
        tools: [_TestTool('tool')],
        additionalProperties: {'key': 'value'},
      );

      final clone = options.clone();

      expect(clone.conversationId, 'conv');
      expect(clone.modelId, 'model');
      expect(clone.stopSequences, ['stop']);
      expect(clone.tools, hasLength(1));
      expect(identical(clone.stopSequences, options.stopSequences), isFalse);
      expect(identical(clone.tools, options.tools), isFalse);
      expect(identical(clone.additionalProperties, options.additionalProperties),
          isFalse);

      clone.stopSequences!.add('extra');
      expect(options.stopSequences, ['stop']);

      clone.additionalProperties!['key'] = 'changed';
      expect(options.additionalProperties!['key'], 'value');
    });
  });

  group('EmbeddingGenerationOptions', () {
    test('clone copies properties', () {
      final options = EmbeddingGenerationOptions(
        modelId: 'model',
        dimensions: 128,
        additionalProperties: {'key': 1},
      );

      final clone = options.clone();

      expect(clone.modelId, 'model');
      expect(clone.dimensions, 128);
      expect(clone.additionalProperties, {'key': 1});
      expect(identical(clone.additionalProperties, options.additionalProperties),
          isFalse);
    });
  });

  group('ImageGenerationOptions', () {
    test('clone copies properties', () {
      final options = ImageGenerationOptions(
        count: 2,
        imageWidth: 256,
        imageHeight: 128,
        mediaType: 'image/png',
        modelId: 'model',
        additionalProperties: {'key': 'value'},
      );

      final clone = options.clone();

      expect(clone.count, 2);
      expect(clone.imageWidth, 256);
      expect(clone.imageHeight, 128);
      expect(clone.mediaType, 'image/png');
      expect(clone.modelId, 'model');
      expect(clone.additionalProperties, {'key': 'value'});
      expect(identical(clone.additionalProperties, options.additionalProperties),
          isFalse);
    });
  });

  group('SpeechToTextOptions', () {
    test('clone copies properties', () {
      final options = SpeechToTextOptions(
        modelId: 'model',
        speechLanguage: 'en-US',
        speechSampleRate: 44100,
        textLanguage: 'en',
        additionalProperties: {'key': 'value'},
      );

      final clone = options.clone();

      expect(clone.modelId, 'model');
      expect(clone.speechLanguage, 'en-US');
      expect(clone.speechSampleRate, 44100);
      expect(clone.textLanguage, 'en');
      expect(clone.additionalProperties, {'key': 'value'});
      expect(identical(clone.additionalProperties, options.additionalProperties),
          isFalse);
    });
  });
}
