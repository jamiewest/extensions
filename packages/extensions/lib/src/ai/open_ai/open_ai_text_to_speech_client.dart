import 'dart:convert';
import 'dart:typed_data';

import 'package:extensions/annotations.dart';
import 'package:http/http.dart' as http;

import '../../system/threading/cancellation_token.dart';
import '../data_content.dart';
import '../text_to_speech/text_to_speech_client.dart';
import '../text_to_speech/text_to_speech_client_builder.dart';
import '../text_to_speech/text_to_speech_client_metadata.dart';
import '../text_to_speech/text_to_speech_options.dart';
import '../text_to_speech/text_to_speech_response.dart';
import '../text_to_speech/text_to_speech_response_update.dart';
import 'open_ai_client_options.dart';

/// An [TextToSpeechClient] for the OpenAI audio speech API.
///
/// Works with any OpenAI-compatible endpoint.
///
/// This is an experimental feature.
@Source(
  name: 'OpenAITextToSpeechClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.OpenAI/',
)
final class OpenAITextToSpeechClient implements TextToSpeechClient {
  /// Creates a new [OpenAITextToSpeechClient].
  OpenAITextToSpeechClient(
    String modelId,
    String apiKey, {
    OpenAIClientOptions? options,
  })  : _modelId = modelId,
        _apiKey = apiKey,
        _options = options ?? OpenAIClientOptions() {
    metadata = TextToSpeechClientMetadata(
      providerName: 'openai',
      providerUri: _options.endpoint,
      defaultModelId: modelId,
    );
  }

  final String _modelId;
  final String _apiKey;
  final OpenAIClientOptions _options;

  static const String _defaultVoice = 'alloy';

  /// Metadata describing this client instance.
  late final TextToSpeechClientMetadata metadata;

  /// Creates a [TextToSpeechClientBuilder] wrapping this client.
  TextToSpeechClientBuilder asBuilder() => TextToSpeechClientBuilder(this);

  @override
  Future<TextToSpeechResponse> getAudio(
    String text, {
    TextToSpeechOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final body = _buildRequestBody(text, options);
    final client = _options.httpClient ?? http.Client();
    final owned = _options.httpClient == null;

    try {
      final response = await client.post(
        Uri.parse('${_options.endpoint}/audio/speech'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw StateError(
          'OpenAI text-to-speech error ${response.statusCode}: '
          '${response.body}',
        );
      }

      final mediaType = _mediaTypeForFormat(
        options?.audioFormat ?? 'mp3',
      );
      return TextToSpeechResponse(
        audio: DataContent(
          Uint8List.fromList(response.bodyBytes),
          mediaType: mediaType,
        ),
        modelId: options?.modelId ?? _modelId,
        rawRepresentation: response,
      );
    } finally {
      if (owned) client.close();
    }
  }

  @override
  Stream<TextToSpeechResponseUpdate> getStreamingAudio(
    String text, {
    TextToSpeechOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    final body = _buildRequestBody(text, options);
    final client = _options.httpClient ?? http.Client();
    final owned = _options.httpClient == null;

    try {
      final request = http.Request(
        'POST',
        Uri.parse('${_options.endpoint}/audio/speech'),
      )
        ..headers['Authorization'] = 'Bearer $_apiKey'
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(body);

      final response = await client.send(request);
      if (response.statusCode != 200) {
        final body_ = await response.stream.bytesToString();
        throw StateError(
          'OpenAI text-to-speech error ${response.statusCode}: $body_',
        );
      }

      final mediaType = _mediaTypeForFormat(options?.audioFormat ?? 'mp3');
      final modelId = options?.modelId ?? _modelId;

      await for (final chunk in response.stream) {
        if (cancellationToken?.isCancellationRequested ?? false) break;
        yield TextToSpeechResponseUpdate(
          audio: DataContent(Uint8List.fromList(chunk), mediaType: mediaType),
          modelId: modelId,
        );
      }
    } finally {
      if (owned) client.close();
    }
  }

  @override
  T? getService<T>({Object? key}) {
    if (T == TextToSpeechClientMetadata) return metadata as T;
    if (T == OpenAITextToSpeechClient) return this as T;
    return null;
  }

  @override
  void dispose() {}

  Map<String, dynamic> _buildRequestBody(
    String text,
    TextToSpeechOptions? options,
  ) {
    final body = <String, dynamic>{
      'model': options?.modelId ?? _modelId,
      'input': text,
      'voice': options?.voiceId ?? _defaultVoice,
    };

    final format = options?.audioFormat;
    if (format != null) body['response_format'] = _formatForMediaType(format);
    if (options?.speed != null) body['speed'] = options!.speed;

    return body;
  }

  String _formatForMediaType(String audioFormat) => switch (audioFormat) {
        'audio/mpeg' || 'mp3' => 'mp3',
        'audio/opus' || 'opus' => 'opus',
        'audio/aac' || 'aac' => 'aac',
        'audio/flac' || 'flac' => 'flac',
        'audio/wav' || 'wav' => 'wav',
        'audio/pcm' || 'pcm' => 'pcm',
        _ => 'mp3',
      };

  String _mediaTypeForFormat(String audioFormat) => switch (audioFormat) {
        'mp3' || 'audio/mpeg' => 'audio/mpeg',
        'opus' || 'audio/opus' => 'audio/opus',
        'aac' || 'audio/aac' => 'audio/aac',
        'flac' || 'audio/flac' => 'audio/flac',
        'wav' || 'audio/wav' => 'audio/wav',
        'pcm' || 'audio/pcm' => 'audio/pcm',
        _ => 'audio/mpeg',
      };
}

