import 'package:extensions/ai.dart';
import 'package:extensions/system.dart';
import 'package:genkit/genkit.dart';

import '../functions/ai_function_genkit_extensions.dart';

/// A [ChatClient] that forwards requests to a Genkit model.
///
/// Converts between the `extensions` message/content types and Genkit's
/// [Message]/[Part] types in both directions. Tool calls returned by the
/// model are surfaced as [FunctionCallContent] rather than executed
/// immediately, so the [FunctionInvokingChatClient] middleware can own
/// the call/respond loop.
class GenkitChatClient extends DelegatingChatClient {
  /// Creates a [GenkitChatClient].
  ///
  /// The [genkit] instance must have the appropriate model plugin registered.
  /// The [model] reference selects which Genkit model receives each request.
  GenkitChatClient({required Genkit genkit, required ModelRef model})
      : _genkit = genkit,
        _model = model,
        super(_NoOpChatClient());

  final Genkit _genkit;
  final ModelRef _model;

  /// Streams response chunks from the Genkit model for [messages].
  ///
  /// Each yielded [ChatResponseUpdate] contains either text or tool-call
  /// content. Cancellation is checked between chunks; the stream stops
  /// early if [cancellationToken] is cancelled.
  ///
  /// Tools in [ChatOptions.tools] are converted to Genkit [ToolDefinition]
  /// values and passed with `returnToolRequests: true` so Genkit does not
  /// execute them itself.
  @override
  Stream<ChatResponseUpdate> getStreamingResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    final genkitTools = options?.tools
        ?.whereType<AIFunction>()
        .map((f) => f.toGenkitTool())
        .toList();
    final hasTools = genkitTools != null && genkitTools.isNotEmpty;

    final stream = _genkit.generateStream(
      messages: messages.map(_toGenkitMessage).toList(),
      model: _model,
      tools: hasTools ? genkitTools : null,
      // Prevent genkit from executing tools internally; the
      // FunctionInvokingChatClient middleware handles the call loop.
      returnToolRequests: hasTools ? true : null,
    );

    await for (final chunk in stream) {
      if (cancellationToken?.isCancellationRequested ?? false) break;
      final update = _chunkToUpdate(chunk);
      if (update.contents.isNotEmpty) yield update;
    }
  }

  /// Returns a single [ChatResponse] for [messages].
  ///
  /// Accumulates all updates from [getStreamingResponse] into one response.
  @override
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final updates = await getStreamingResponse(
      messages: messages,
      options: options,
      cancellationToken: cancellationToken,
    ).toList();
    final contents = updates.expand((u) => u.contents).toList();
    final role = updates.lastOrNull?.role ?? ChatRole.assistant;
    return ChatResponse.fromMessage(
      ChatMessage(role: role, contents: contents),
    );
  }

  /// Returns a service of type [T] from this client or its inner chain.
  ///
  /// Returns `this` if this client satisfies [T]; otherwise delegates to
  /// [innerClient].
  @override
  T? getService<T>({Object? key}) {
    if (this is T) return this as T;
    return innerClient.getService<T>(key: key);
  }

  // Converts a ChatMessage to a Genkit Message.
  Message _toGenkitMessage(ChatMessage msg) => Message(
        role: _toGenkitRole(msg.role),
        content: msg.contents.map(_toGenkitPart).toList(),
      );

  // Maps a ChatRole string value to the corresponding Genkit Role.
  // Unknown roles fall back to Role.user to avoid a hard failure when
  // a provider extends the standard role set.
  Role _toGenkitRole(ChatRole role) => switch (role.value) {
        'system' => Role.system,
        'user' => Role.user,
        'assistant' => Role.model,
        'tool' => Role.tool,
        _ => Role.user,
      };

  // Converts a single AIContent value to a Genkit Part.
  // Throws for content types not yet supported (image, audio, etc.).
  Part _toGenkitPart(AIContent content) => switch (content) {
        TextContent(:final text) => TextPart(text: text),
        FunctionCallContent(:final callId, :final name, :final arguments) =>
          ToolRequestPart(
            toolRequest: ToolRequest(
              ref: callId,
              name: name,
              input: arguments,
            ),
          ),
        FunctionResultContent(:final callId, :final name, :final result) =>
          ToolResponsePart(
            toolResponse: ToolResponse(
              ref: callId,
              name: name ?? callId,
              output: result,
            ),
          ),
        _ => throw UnimplementedError(
            'Unsupported content type: ${content.runtimeType}',
          ),
      };

  // Extracts text and tool-request parts from a chunk.
  // Other part types are skipped; the caller filters empty updates.
  ChatResponseUpdate _chunkToUpdate(GenerateResponseChunk chunk) {
    final contents = <AIContent>[];
    for (final part in chunk.content) {
      if (part.isText) {
        final t = part.text;
        if (t != null && t.isNotEmpty) contents.add(TextContent(t));
      } else if (part.isToolRequest) {
        final req = part.toolRequest!;
        contents.add(FunctionCallContent(
          callId: req.ref ?? req.name,
          name: req.name,
          arguments: req.input,
        ));
      }
    }
    return ChatResponseUpdate(role: ChatRole.assistant, contents: contents);
  }
}

// Placeholder inner client required by DelegatingChatClient's constructor.
// Never reached: GenkitChatClient overrides getStreamingResponse and
// getResponse, so the inner client is never invoked.
final class _NoOpChatClient implements ChatClient {
  @override
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      throw UnimplementedError();

  @override
  Stream<ChatResponseUpdate> getStreamingResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      throw UnimplementedError();

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}
