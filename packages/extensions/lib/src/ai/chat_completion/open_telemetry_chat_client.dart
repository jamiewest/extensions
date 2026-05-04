import 'dart:developer' as developer;

import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import '../open_telemetry_consts.dart';
import 'chat_message.dart';
import 'chat_options.dart';
import 'chat_response.dart';
import 'chat_response_update.dart';
import 'delegating_chat_client.dart';

/// A [DelegatingChatClient] that records OpenTelemetry spans for each request.
///
/// This implementation uses `dart:developer` timeline events. To connect it
/// to a real OpenTelemetry SDK, subclass and override [onSpanStart] and
/// [onSpanEnd].
@Source(
  name: 'OpenTelemetryChatClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/ChatCompletion/',
)
class OpenTelemetryChatClient extends DelegatingChatClient {
  /// Creates a new [OpenTelemetryChatClient].
  OpenTelemetryChatClient(super.innerClient, {this.modelId, this.system});

  /// The model ID to record on spans (overrides per-request model).
  final String? modelId;

  /// The AI system name (e.g. `"openai"`).
  final String? system;

  @override
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    developer.Timeline.startSync(
      OpenTelemetryConsts.chatSpanName,
      arguments: _buildArguments(options),
    );
    try {
      final response = await super.getResponse(
        messages: messages,
        options: options,
        cancellationToken: cancellationToken,
      );
      developer.Timeline.finishSync();
      return response;
    } catch (e) {
      developer.Timeline.finishSync();
      rethrow;
    }
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    developer.Timeline.startSync(
      '${OpenTelemetryConsts.chatSpanName}.streaming',
      arguments: _buildArguments(options),
    );
    try {
      yield* super.getStreamingResponse(
        messages: messages,
        options: options,
        cancellationToken: cancellationToken,
      );
      developer.Timeline.finishSync();
    } catch (e) {
      developer.Timeline.finishSync();
      rethrow;
    }
  }

  Map<String, Object?> _buildArguments(ChatOptions? options) => {
        if (system != null) OpenTelemetryConsts.systemKey: system,
        OpenTelemetryConsts.requestModelKey:
            options?.modelId ?? modelId ?? 'unknown',
        if (options?.temperature != null)
          OpenTelemetryConsts.requestTemperatureKey: options!.temperature,
        if (options?.maxOutputTokens != null)
          OpenTelemetryConsts.requestMaxTokensKey: options!.maxOutputTokens,
      };
}
