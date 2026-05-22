import 'dart:async';
import 'dart:convert';

import 'package:extensions/annotations.dart';
import 'package:http/http.dart' as http;

import '../../system/threading/cancellation_token.dart';
import '../speech_to_text/speech_to_text_client.dart';
import '../speech_to_text/speech_to_text_client_builder.dart';
import '../speech_to_text/speech_to_text_client_metadata.dart';
import '../text_content.dart';
import '../usage_details.dart';
import 'open_ai_client_options.dart';

/// An [SpeechToTextClient] for the OpenAI audio transcription API.
///
/// Works with any OpenAI-compatible endpoint.
///
/// This is an experimental feature.
@Source(
  name: 'OpenAISpeechToTextClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.OpenAI/',
)
final class OpenAISpeechToTextClient implements SpeechToTextClient {
  /// Creates a new [OpenAISpeechToTextClient].
  OpenAISpeechToTextClient(
    String modelId,
    String apiKey, {
    OpenAIClientOptions? options,
  })  : _modelId = modelId,
        _apiKey = apiKey,
        _options = options ?? OpenAIClientOptions() {
    metadata = SpeechToTextClientMetadata(
      providerName: 'openai',
      providerUri: _options.endpoint,
      defaultModelId: modelId,
    );
  }

  final String _modelId;
  final String _apiKey;
  final OpenAIClientOptions _options;

  /// Metadata describing this client instance.
  late final SpeechToTextClientMetadata metadata;

  /// Creates a [SpeechToTextClientBuilder] wrapping this client.
  SpeechToTextClientBuilder asBuilder() => SpeechToTextClientBuilder(this);

  @override
  Future<SpeechToTextResponse> getText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final bytes = await _collectBytes(stream);
    final isTranslation = _isTranslationRequest(options);
    final endpoint = isTranslation ? 'audio/translations' : 'audio/transcriptions';

    final client = _options.httpClient ?? http.Client();
    final owned = _options.httpClient == null;

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${_options.endpoint}/$endpoint'),
      )
        ..headers['Authorization'] = 'Bearer $_apiKey'
        ..fields['model'] = options?.modelId ?? _modelId
        ..fields['response_format'] = 'verbose_json';

      if (options?.speechLanguage != null && !isTranslation) {
        request.fields['language'] = options!.speechLanguage!;
      }

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'audio.mp3',
      ));

      final streamed = await client.send(request);
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode != 200) {
        throw StateError(
          'OpenAI transcription error ${streamed.statusCode}: $body',
        );
      }

      final json = jsonDecode(body) as Map<String, dynamic>;
      return _fromResponse(json, options?.modelId ?? _modelId);
    } finally {
      if (owned) client.close();
    }
  }

  @override
  Stream<SpeechToTextResponse> getStreamingText({
    required Stream<List<int>> stream,
    SpeechToTextOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    // OpenAI does not support streaming transcription in the standard API;
    // fall back to the non-streaming method and yield a single update.
    yield await getText(
      stream: stream,
      options: options,
      cancellationToken: cancellationToken,
    );
  }

  @override
  T? getService<T>({Object? key}) {
    if (T == SpeechToTextClientMetadata) return metadata as T;
    if (T == OpenAISpeechToTextClient) return this as T;
    return null;
  }

  @override
  void dispose() {}

  bool _isTranslationRequest(SpeechToTextOptions? options) =>
      options?.textLanguage != null &&
      options!.textLanguage != options.speechLanguage;

  Future<List<int>> _collectBytes(Stream<List<int>> stream) async {
    final bytes = <int>[];
    await for (final chunk in stream) {
      bytes.addAll(chunk);
    }
    return bytes;
  }

  SpeechToTextResponse _fromResponse(
    Map<String, dynamic> json,
    String modelId,
  ) {
    final text = json['text'] as String? ?? '';
    final duration = json['duration'] as num?;
    final usageMap = json['usage'] as Map<String, dynamic>?;

    UsageDetails? usage;
    if (usageMap != null) {
      usage = UsageDetails(
        inputTokenCount: usageMap['prompt_tokens'] as int?,
        outputTokenCount: usageMap['completion_tokens'] as int?,
        totalTokenCount: usageMap['total_tokens'] as int?,
      );
    }

    return SpeechToTextResponse(
      contents: [TextContent(text)],
      endTime: duration != null
          ? Duration(milliseconds: (duration * 1000).round())
          : null,
      modelId: modelId,
      rawRepresentation: json,
      usage: usage,
    );
  }
}
