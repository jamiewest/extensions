import 'dart:typed_data';

import 'package:extensions/ai.dart';
import 'package:extensions/system.dart' hide equals;
import 'package:test/test.dart';

final class _FakeImageGenerator implements ImageGenerator {
  ImageGenerationRequest? lastRequest;
  ImageGenerationOptions? lastOptions;

  @override
  Future<ImageGenerationResponse> generate({
    required ImageGenerationRequest request,
    ImageGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    lastRequest = request;
    lastOptions = options;
    return ImageGenerationResponse();
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

void main() {
  group('ImageGeneratorExtensions', () {
    test('generateImages builds a prompt-only request', () async {
      final generator = _FakeImageGenerator();

      await generator.generateImages('a fox');

      expect(generator.lastRequest!.prompt, 'a fox');
      expect(generator.lastRequest!.originalImages, isNull);
    });

    test('editImage wraps the single image', () async {
      final generator = _FakeImageGenerator();
      final image = DataContent(
        Uint8List.fromList([1, 2, 3]),
        mediaType: 'image/png',
      );

      await generator.editImage(image, 'add a hat');

      expect(generator.lastRequest!.prompt, 'add a hat');
      expect(generator.lastRequest!.originalImages, equals([image]));
    });

    test('editImages passes images and options through', () async {
      final generator = _FakeImageGenerator();
      final images = [
        DataContent(Uint8List.fromList([1]), mediaType: 'image/png'),
        DataContent(Uint8List.fromList([2]), mediaType: 'image/png'),
      ];
      final options = ImageGenerationOptions(count: 2);

      await generator.editImages(images, 'merge', options: options);

      expect(generator.lastRequest!.originalImages, equals(images));
      expect(generator.lastOptions, same(options));
    });
  });
}
