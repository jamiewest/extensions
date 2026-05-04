import 'dart:developer' as developer;

import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import '../open_telemetry_consts.dart';
import 'delegating_embedding_generator.dart';
import 'embedding_generation_options.dart';
import 'generated_embeddings.dart';

/// A [DelegatingEmbeddingGenerator] that records OpenTelemetry spans.
@Source(
  name: 'OpenTelemetryEmbeddingGenerator.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/Embeddings/',
)
class OpenTelemetryEmbeddingGenerator extends DelegatingEmbeddingGenerator {
  /// Creates a new [OpenTelemetryEmbeddingGenerator].
  OpenTelemetryEmbeddingGenerator(super.innerGenerator,
      {this.modelId, this.system});

  /// The model ID to record on spans.
  final String? modelId;

  /// The AI system name (e.g. `"openai"`).
  final String? system;

  @override
  Future<GeneratedEmbeddings> generateEmbeddings({
    required Iterable<String> values,
    EmbeddingGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    developer.Timeline.startSync(
      OpenTelemetryConsts.embeddingsSpanName,
      arguments: {
        if (system != null) OpenTelemetryConsts.systemKey: system,
        OpenTelemetryConsts.requestModelKey:
            options?.modelId ?? modelId ?? 'unknown',
      },
    );
    try {
      final result = await super.generateEmbeddings(
        values: values,
        options: options,
        cancellationToken: cancellationToken,
      );
      developer.Timeline.finishSync();
      return result;
    } catch (e) {
      developer.Timeline.finishSync();
      rethrow;
    }
  }
}
