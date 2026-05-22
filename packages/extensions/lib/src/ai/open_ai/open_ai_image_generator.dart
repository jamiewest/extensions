import 'dart:convert';

import 'package:extensions/annotations.dart';
import 'package:http/http.dart' as http;

import '../../system/threading/cancellation_token.dart';
import '../ai_content.dart';
import '../data_content.dart';
import '../image_generation/image_generator.dart';
import '../image_generation/image_generator_builder.dart';
import '../image_generation/image_generator_metadata.dart';
import '../uri_content.dart';
import '../usage_details.dart';
import 'open_ai_client_options.dart';

/// An [ImageGenerator] for the OpenAI image generation API.
///
/// Works with any OpenAI-compatible endpoint.
///
/// This is an experimental feature.
@Source(
  name: 'OpenAIImageGenerator.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.OpenAI/',
)
final class OpenAIImageGenerator implements ImageGenerator {
  /// Creates a new [OpenAIImageGenerator].
  OpenAIImageGenerator(
    String modelId,
    String apiKey, {
    OpenAIClientOptions? options,
  })  : _modelId = modelId,
        _apiKey = apiKey,
        _options = options ?? OpenAIClientOptions() {
    metadata = ImageGeneratorMetadata(
      providerName: 'openai',
      providerUri: _options.endpoint,
      defaultModelId: modelId,
    );
  }

  final String _modelId;
  final String _apiKey;
  final OpenAIClientOptions _options;

  /// Metadata describing this generator instance.
  late final ImageGeneratorMetadata metadata;

  /// Creates an [ImageGeneratorBuilder] wrapping this generator.
  ImageGeneratorBuilder asBuilder() => ImageGeneratorBuilder(this);

  @override
  Future<ImageGenerationResponse> generate({
    required ImageGenerationRequest request,
    ImageGenerationOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final effectiveModel = options?.modelId ?? _modelId;
    final body = <String, dynamic>{
      'model': effectiveModel,
      'prompt': request.prompt ?? '',
      'response_format': 'b64_json',
    };

    if (options?.count != null) body['n'] = options!.count;
    if (options?.imageWidth != null && options?.imageHeight != null) {
      body['size'] = '${options!.imageWidth}x${options.imageHeight}';
    }

    final client = _options.httpClient ?? http.Client();
    final owned = _options.httpClient == null;

    try {
      final response = await client.post(
        Uri.parse('${_options.endpoint}/images/generations'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw StateError(
          'OpenAI image generation error ${response.statusCode}: '
          '${response.body}',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return _fromResponse(json, options);
    } finally {
      if (owned) client.close();
    }
  }

  @override
  T? getService<T>({Object? key}) {
    if (T == ImageGeneratorMetadata) return metadata as T;
    if (T == OpenAIImageGenerator) return this as T;
    return null;
  }

  @override
  void dispose() {}

  ImageGenerationResponse _fromResponse(
    Map<String, dynamic> json,
    ImageGenerationOptions? options,
  ) {
    final data = json['data'] as List<dynamic>? ?? [];
    final usageMap = json['usage'] as Map<String, dynamic>?;

    final contents = data.map<AIContent>((item) {
      final d = item as Map<String, dynamic>;
      final b64 = d['b64_json'] as String?;
      final url = d['url'] as String?;

      if (b64 != null) {
        final mediaType = options?.mediaType ?? 'image/png';
        return DataContent.fromUri('data:$mediaType;base64,$b64');
      }
      if (url != null) {
        return UriContent(Uri.parse(url), mediaType: 'image/png');
      }
      return DataContent.fromUri('data:image/png;base64,');
    }).toList();

    UsageDetails? usage;
    if (usageMap != null) {
      usage = UsageDetails(
        inputTokenCount: usageMap['input_tokens'] as int?,
        outputTokenCount: usageMap['output_tokens'] as int?,
        totalTokenCount: usageMap['total_tokens'] as int?,
      );
    }

    return ImageGenerationResponse(contents: contents, usage: usage);
  }
}
