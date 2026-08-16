import 'package:extensions/ai.dart';
import 'package:extensions/system.dart' hide equals;
import 'package:test/test.dart';

final class _InnerGenerator implements EmbeddingGenerator {
  int calls = 0;

  @override
  Future<GeneratedEmbeddings> generateEmbeddings({
    required Iterable<String> values,
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    calls++;
    return GeneratedEmbeddings([
      for (final _ in values) Embedding(vector: const [1.0]),
    ]);
  }

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

void main() {
  group('AnonymousDelegatingEmbeddingGenerator', () {
    test('routes generateEmbeddings through the handler', () async {
      final inner = _InnerGenerator();
      final seen = <String>[];
      final generator = AnonymousDelegatingEmbeddingGenerator(
        inner,
        generateHandler: (values, options, innerGenerator, ct) {
          seen.addAll(values);
          return innerGenerator.generateEmbeddings(
            values: values,
            options: options,
            cancellationToken: ct,
          );
        },
      );

      final embeddings = await generator.generateEmbeddings(values: ['x']);

      expect(seen, equals(['x']));
      expect(inner.calls, 1);
      expect(embeddings.length, 1);
    });

    test('the handler can bypass the inner generator', () async {
      final inner = _InnerGenerator();
      final generator = AnonymousDelegatingEmbeddingGenerator(
        inner,
        generateHandler: (values, options, innerGenerator, ct) async =>
            GeneratedEmbeddings([
              Embedding(vector: const [42.0]),
            ]),
      );

      final embeddings = await generator.generateEmbeddings(values: ['x']);

      expect(embeddings[0].vector, equals([42.0]));
      expect(inner.calls, 0);
    });
  });

  group('EmbeddingGeneratorBuilder.useGenerate', () {
    test('wires the handler into the pipeline', () async {
      final inner = _InnerGenerator();
      var handlerRan = false;

      final generator = EmbeddingGeneratorBuilder(inner)
          .useGenerate((values, options, innerGenerator, ct) {
            handlerRan = true;
            return innerGenerator.generateEmbeddings(
              values: values,
              options: options,
              cancellationToken: ct,
            );
          })
          .build();

      await generator.generateEmbeddings(values: ['x']);

      expect(handlerRan, isTrue);
      expect(inner.calls, 1);
    });
  });
}
