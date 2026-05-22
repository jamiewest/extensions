import 'dart:convert';

import 'package:extensions/annotations.dart';
import 'package:http/http.dart' as http;

import '../../system/threading/cancellation_token.dart';
import '../ai_content.dart';
import '../function_call_content.dart';
import '../function_result_content.dart';
import '../text_content.dart';
import '../usage_details.dart';
import '../chat_completion/chat_client.dart';
import '../chat_completion/chat_client_metadata.dart';
import '../chat_completion/chat_finish_reason.dart';
import '../chat_completion/chat_message.dart';
import '../chat_completion/chat_options.dart';
import '../chat_completion/chat_response.dart';
import '../chat_completion/chat_response_format.dart';
import '../chat_completion/chat_response_update.dart';
import '../chat_completion/chat_role.dart';
import 'open_ai_client_options.dart';

/// An [ChatClient] for the OpenAI chat completions API.
///
/// This client communicates directly with any OpenAI-compatible endpoint,
/// including the OpenAI API itself, Azure OpenAI, and local inference
/// servers such as LM Studio.
///
/// ```dart
/// final client = OpenAIChatClient(
///   'gemma-4',
///   'lm-studio',
///   options: OpenAIClientOptions(
///     endpoint: Uri.parse('http://localhost:1234/v1'),
///   ),
/// );
/// ```
@Source(
  name: 'OpenAIChatClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.OpenAI/',
)
final class OpenAIChatClient implements ChatClient {
  /// Creates a new [OpenAIChatClient].
  ///
  /// [modelId] is the model identifier (e.g. `'gpt-4o'` or `'gemma-4'`).
  /// [apiKey] is sent in the `Authorization` header. LM Studio accepts any
  /// non-empty string.
  /// [options] allows overriding the endpoint and HTTP client.
  OpenAIChatClient(
    String modelId,
    String apiKey, {
    OpenAIClientOptions? options,
  })  : _modelId = modelId,
        _apiKey = apiKey,
        _options = options ?? OpenAIClientOptions() {
    metadata = ChatClientMetadata(
      providerName: 'openai',
      providerUri: _options.endpoint,
      defaultModelId: modelId,
    );
  }

  final String _modelId;
  final String _apiKey;
  final OpenAIClientOptions _options;

  /// Metadata describing this client instance.
  late final ChatClientMetadata metadata;

  @override
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final body = _buildRequestBody(messages, options, stream: false);
    final json = await _postJson(body, cancellationToken);
    return _fromCompletion(json, options);
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    final body = _buildRequestBody(messages, options, stream: true);
    final client = _options.httpClient ?? http.Client();
    final owned = _options.httpClient == null;

    try {
      final request = http.Request(
        'POST',
        Uri.parse('${_options.endpoint}/chat/completions'),
      )
        ..headers['Authorization'] = 'Bearer $_apiKey'
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(body);

      final response = await client.send(request);
      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        throw StateError(
          'OpenAI chat completions error ${response.statusCode}: $body',
        );
      }

      final stream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in stream) {
        if (cancellationToken?.isCancellationRequested ?? false) break;
        if (!line.startsWith('data: ')) continue;
        final data = line.substring(6).trim();
        if (data == '[DONE]') break;
        final chunk = jsonDecode(data) as Map<String, dynamic>;
        final update = _fromStreamChunk(chunk);
        if (update != null) yield update;
      }
    } finally {
      if (owned) client.close();
    }
  }

  @override
  T? getService<T>({Object? key}) {
    if (T == ChatClientMetadata) return metadata as T;
    if (T == OpenAIChatClient) return this as T;
    return null;
  }

  @override
  void dispose() {}

  // ---------------------------------------------------------------------------
  // Request building
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _buildRequestBody(
    Iterable<ChatMessage> messages,
    ChatOptions? options, {
    required bool stream,
  }) {
    final effectiveModel = options?.modelId ?? _modelId;
    final body = <String, dynamic>{
      'model': effectiveModel,
      'messages': _toOpenAIMessages(messages, options),
      'stream': stream,
    };

    if (options != null) {
      if (options.temperature != null) {
        body['temperature'] = options.temperature;
      }
      if (options.topP != null) body['top_p'] = options.topP;
      if (options.maxOutputTokens != null) {
        body['max_tokens'] = options.maxOutputTokens;
      }
      if (options.seed != null) body['seed'] = options.seed;
      if (options.frequencyPenalty != null) {
        body['frequency_penalty'] = options.frequencyPenalty;
      }
      if (options.presencePenalty != null) {
        body['presence_penalty'] = options.presencePenalty;
      }
      if (options.stopSequences != null && options.stopSequences!.isNotEmpty) {
        body['stop'] = options.stopSequences;
      }
      if (options.responseFormat != null) {
        body['response_format'] =
            _toOpenAIResponseFormat(options.responseFormat!);
      }
    }

    if (stream) {
      body['stream_options'] = {'include_usage': true};
    }

    final raw = options?.rawRepresentationFactory?.call(this);
    if (raw is Map<String, dynamic>) {
      body.addAll(raw);
    }

    return body;
  }

  List<Map<String, dynamic>> _toOpenAIMessages(
    Iterable<ChatMessage> messages,
    ChatOptions? options,
  ) {
    final result = <Map<String, dynamic>>[];

    if (options?.instructions != null) {
      result.add({'role': 'system', 'content': options!.instructions});
    }

    for (final message in messages) {
      if (message.contents.isEmpty) continue;

      final toolResults = message.contents.whereType<FunctionResultContent>();
      if (toolResults.isNotEmpty) {
        for (final result_ in toolResults) {
          result.add({
            'role': 'tool',
            'tool_call_id': result_.callId,
            'content': result_.result?.toString() ?? '',
          });
        }
        continue;
      }

      final toolCalls = message.contents.whereType<FunctionCallContent>();
      if (toolCalls.isNotEmpty) {
        final calls = toolCalls
            .map((c) => {
                  'id': c.callId,
                  'type': 'function',
                  'function': {
                    'name': c.name,
                    'arguments':
                        c.arguments != null ? jsonEncode(c.arguments) : '{}',
                  },
                })
            .toList();
        result.add({
          'role': message.role.value,
          'tool_calls': calls,
        });
        continue;
      }

      final text = message.text;
      result.add({
        'role': message.role.value,
        'content': text,
      });
    }

    return result;
  }

  Map<String, dynamic> _toOpenAIResponseFormat(ChatResponseFormat format) {
    if (format == ChatResponseFormat.json) {
      return {'type': 'json_object'};
    }
    if (format is ChatResponseFormatJsonSchema) {
      return {
        'type': 'json_schema',
        'json_schema': {
          'name': format.schemaName ?? 'response',
          'schema': format.schema,
          'strict': true,
        },
      };
    }
    return {'type': 'text'};
  }

  // ---------------------------------------------------------------------------
  // Response parsing
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> _postJson(
    Map<String, dynamic> body,
    CancellationToken? cancellationToken,
  ) async {
    final client = _options.httpClient ?? http.Client();
    final owned = _options.httpClient == null;
    try {
      final response = await client.post(
        Uri.parse('${_options.endpoint}/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode != 200) {
        throw StateError(
          'OpenAI chat completions error ${response.statusCode}: '
          '${response.body}',
        );
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } finally {
      if (owned) client.close();
    }
  }

  ChatResponse _fromCompletion(
    Map<String, dynamic> json,
    ChatOptions? options,
  ) {
    final choices = json['choices'] as List<dynamic>? ?? [];
    final usage = _parseUsage(json['usage'] as Map<String, dynamic>?);
    final modelId = json['model'] as String?;
    final responseId = json['id'] as String?;
    final created = json['created'] as int?;

    final messages = <ChatMessage>[];
    ChatFinishReason? finishReason;

    for (final choice in choices) {
      final c = choice as Map<String, dynamic>;
      final message = c['message'] as Map<String, dynamic>?;
      if (message == null) continue;

      final role = _parseRole(message['role'] as String? ?? 'assistant');
      final contents = _parseContents(message);

      messages.add(ChatMessage(role: role, contents: contents));

      final rawReason = c['finish_reason'] as String?;
      if (rawReason != null) {
        finishReason = ChatFinishReason(rawReason);
      }
    }

    return ChatResponse(
      messages: messages,
      responseId: responseId,
      modelId: modelId,
      createdAt: created != null
          ? DateTime.fromMillisecondsSinceEpoch(created * 1000, isUtc: true)
          : null,
      finishReason: finishReason,
      usage: usage,
      rawRepresentation: json,
    );
  }

  ChatResponseUpdate? _fromStreamChunk(Map<String, dynamic> json) {
    final choices = json['choices'] as List<dynamic>? ?? [];
    final modelId = json['model'] as String?;
    final responseId = json['id'] as String?;
    final created = json['created'] as int?;

    UsageDetails? usage;
    if (choices.isEmpty) {
      usage = _parseUsage(json['usage'] as Map<String, dynamic>?);
      if (usage == null) return null;
      return ChatResponseUpdate(
        usage: usage,
        responseId: responseId,
        modelId: modelId,
        rawRepresentation: json,
      );
    }

    final choice = choices.first as Map<String, dynamic>;
    final delta = choice['delta'] as Map<String, dynamic>? ?? {};
    final rawReason = choice['finish_reason'] as String?;

    final role = delta['role'] != null
        ? _parseRole(delta['role'] as String)
        : ChatRole.assistant;
    final contents = _parseDeltaContents(delta);

    return ChatResponseUpdate(
      role: role,
      contents: contents,
      finishReason: rawReason != null ? ChatFinishReason(rawReason) : null,
      responseId: responseId,
      modelId: modelId,
      createdAt: created != null
          ? DateTime.fromMillisecondsSinceEpoch(created * 1000, isUtc: true)
          : null,
      rawRepresentation: json,
    );
  }

  List<AIContent> _parseContents(Map<String, dynamic> message) {
    final toolCalls = message['tool_calls'] as List<dynamic>?;
    if (toolCalls != null && toolCalls.isNotEmpty) {
      return toolCalls.map((tc) {
        final t = tc as Map<String, dynamic>;
        final fn = t['function'] as Map<String, dynamic>? ?? {};
        Map<String, dynamic>? args;
        final rawArgs = fn['arguments'] as String?;
        if (rawArgs != null && rawArgs.isNotEmpty) {
          try {
            args = jsonDecode(rawArgs) as Map<String, dynamic>;
          } catch (_) {
            // leave null if unparseable
          }
        }
        return FunctionCallContent(
          callId: t['id'] as String? ?? '',
          name: fn['name'] as String? ?? '',
          arguments: args,
        );
      }).toList();
    }

    final content = message['content'];
    if (content is String) return [TextContent(content)];
    if (content is List) {
      return content.expand<AIContent>((part) {
        final p = part as Map<String, dynamic>;
        if (p['type'] == 'text') return [TextContent(p['text'] as String)];
        return const [];
      }).toList();
    }
    return [];
  }

  List<AIContent> _parseDeltaContents(Map<String, dynamic> delta) {
    final text = delta['content'] as String?;
    if (text != null && text.isNotEmpty) return [TextContent(text)];
    return [];
  }

  UsageDetails? _parseUsage(Map<String, dynamic>? usage) {
    if (usage == null) return null;
    return UsageDetails(
      inputTokenCount: usage['prompt_tokens'] as int?,
      outputTokenCount: usage['completion_tokens'] as int?,
      totalTokenCount: usage['total_tokens'] as int?,
    );
  }

  ChatRole _parseRole(String role) => switch (role) {
        'system' => ChatRole.system,
        'assistant' => ChatRole.assistant,
        'tool' => ChatRole.tool,
        _ => ChatRole.user,
      };
}
