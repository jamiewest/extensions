import 'dart:typed_data';

import 'package:extensions/ai.dart';
import 'package:extensions/system.dart';
import 'package:test/test.dart';

void main() {
  group('TextReasoningContent', () {
    test('stores text and protectedData', () {
      final data = Uint8List.fromList([1, 2, 3]);
      final content = TextReasoningContent('thinking...', protectedData: data);
      expect(content.text, 'thinking...');
      expect(content.protectedData, data);
      expect(content.toString(), 'thinking...');
    });
  });

  group('HostedFileContent', () {
    test('stores fileId and mediaType', () {
      final content = HostedFileContent(
        fileId: 'file-123',
        mediaType: 'image/png',
        name: 'test.png',
      );
      expect(content.fileId, 'file-123');
      expect(content.mediaType, 'image/png');
      expect(content.name, 'test.png');
      expect(content.toString(), 'file-123');
    });

    test('hasTopLevelMediaType checks correctly', () {
      final content = HostedFileContent(
        fileId: 'f1',
        mediaType: 'image/png',
      );
      expect(content.hasTopLevelMediaType('image'), isTrue);
      expect(content.hasTopLevelMediaType('text'), isFalse);
    });

    test('hasTopLevelMediaType returns false when null', () {
      final content = HostedFileContent(fileId: 'f1');
      expect(content.hasTopLevelMediaType('image'), isFalse);
    });
  });

  group('HostedVectorStoreContent', () {
    test('stores vectorStoreId', () {
      final content =
          HostedVectorStoreContent(vectorStoreId: 'vs-123');
      expect(content.vectorStoreId, 'vs-123');
      expect(content.toString(), 'vs-123');
    });
  });

  group('ChatClientMetadata', () {
    test('stores provider info', () {
      final meta = ChatClientMetadata(
        providerName: 'OpenAI',
        providerUri: Uri.parse('https://api.openai.com'),
        defaultModelId: 'gpt-4',
      );
      expect(meta.providerName, 'OpenAI');
      expect(meta.defaultModelId, 'gpt-4');
    });
  });

  group('EmbeddingGeneratorMetadata', () {
    test('stores dimensions', () {
      final meta = EmbeddingGeneratorMetadata(
        defaultModelDimensions: 1536,
      );
      expect(meta.defaultModelDimensions, 1536);
    });
  });

  group('SpeechToTextResponseUpdateKind', () {
    test('equality is case-insensitive', () {
      expect(
        const SpeechToTextResponseUpdateKind('Session_Open'),
        SpeechToTextResponseUpdateKind.sessionOpen,
      );
    });

    test('constants have expected values', () {
      expect(
        SpeechToTextResponseUpdateKind.textUpdated.value,
        'text_updated',
      );
      expect(
        SpeechToTextResponseUpdateKind.sessionClose.value,
        'session_close',
      );
    });
  });

  group('SpeechToTextResponseUpdate', () {
    test('fromText creates text content', () {
      final update = SpeechToTextResponseUpdate.fromText(
        SpeechToTextResponseUpdateKind.textUpdated,
        'hello world',
      );
      expect(update.text, 'hello world');
      expect(update.kind, SpeechToTextResponseUpdateKind.textUpdated);
    });
  });

  group('MessageCountingChatReducer', () {
    test('keeps last N messages', () async {
      final reducer = MessageCountingChatReducer(2);
      final messages = [
        ChatMessage.fromText(ChatRole.user, 'first'),
        ChatMessage.fromText(ChatRole.assistant, 'second'),
        ChatMessage.fromText(ChatRole.user, 'third'),
      ];
      final result = await reducer.reduce(messages);
      expect(result.length, 2);
      expect(result[0].text, 'second');
      expect(result[1].text, 'third');
    });

    test('returns all if under target', () async {
      final reducer = MessageCountingChatReducer(5);
      final messages = [
        ChatMessage.fromText(ChatRole.user, 'only'),
      ];
      final result = await reducer.reduce(messages);
      expect(result.length, 1);
    });

    test('throws on invalid count', () {
      expect(
        () => MessageCountingChatReducer(0),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('ConfigureOptionsChatClient', () {
    test('applies configuration to options', () async {
      final inner = _FakeChatClient();
      final client = ConfigureOptionsChatClient(
        inner,
        configure: (options) {
          options.modelId = 'configured-model';
          return options;
        },
      );

      await client.getChatResponse(
        messages: [ChatMessage.fromText(ChatRole.user, 'hi')],
      );

      expect(inner.lastOptions?.modelId, 'configured-model');
    });
  });

  group('DelegatingAIFunction', () {
    test('delegates to inner function', () async {
      final inner = _TestFunction();
      final delegating = DelegatingAIFunction(inner);
      expect(delegating.name, 'test_fn');
      expect(delegating.description, 'A test function');

      final result = await delegating.invoke(AIFunctionArguments());
      expect(result, 'invoked');
    });
  });

  group('Hosted tools', () {
    test('HostedCodeInterpreterTool has correct name', () {
      final tool = HostedCodeInterpreterTool();
      expect(tool.name, 'code_interpreter');
    });

    test('HostedFileSearchTool has correct name', () {
      final tool = HostedFileSearchTool(maximumResultCount: 10);
      expect(tool.name, 'file_search');
      expect(tool.maximumResultCount, 10);
    });

    test('HostedWebSearchTool has correct name', () {
      final tool = HostedWebSearchTool();
      expect(tool.name, 'web_search');
    });

    test('HostedImageGenerationTool has correct name', () {
      final tool = HostedImageGenerationTool();
      expect(tool.name, 'image_generation');
    });

    test('HostedMcpServerTool stores properties', () {
      final tool = HostedMcpServerTool(
        serverName: 'test-server',
        serverAddress: Uri.parse('https://mcp.example.com'),
        approvalMode: HostedMcpServerToolApprovalMode.alwaysRequire,
      );
      expect(tool.name, 'mcp');
      expect(tool.serverName, 'test-server');
      expect(
        tool.approvalMode,
        isA<HostedMcpServerToolAlwaysRequireApprovalMode>(),
      );
    });
  });

  group('Experimental content types', () {
    test('CodeInterpreterToolCallContent', () {
      final content = CodeInterpreterToolCallContent(callId: 'c1');
      expect(content.callId, 'c1');
    });

    test('CodeInterpreterToolResultContent', () {
      final content = CodeInterpreterToolResultContent(callId: 'c1');
      expect(content.callId, 'c1');
    });

    test('McpServerToolCallContent', () {
      final content = McpServerToolCallContent(
        callId: 'c1',
        toolName: 'search',
        serverName: 'server1',
      );
      expect(content.toolName, 'search');
      expect(content.serverName, 'server1');
    });

    test('FunctionApprovalRequestContent creates response', () {
      final call = FunctionCallContent(
        callId: 'fc1',
        name: 'doSomething',
      );
      final request = FunctionApprovalRequestContent(
        id: 'req1',
        functionCall: call,
      );
      final response = request.createResponse(true, 'Looks good');
      expect(response.approved, isTrue);
      expect(response.reason, 'Looks good');
      expect(response.id, 'req1');
    });

    test('McpServerToolApprovalRequestContent creates response', () {
      final toolCall = McpServerToolCallContent(
        callId: 'mc1',
        toolName: 'search',
      );
      final request = McpServerToolApprovalRequestContent(
        id: 'req2',
        toolCall: toolCall,
      );
      final response = request.createResponse(false);
      expect(response.approved, isFalse);
      expect(response.id, 'req2');
    });

    test('ImageGenerationToolCallContent', () {
      final content = ImageGenerationToolCallContent(imageId: 'img1');
      expect(content.imageId, 'img1');
    });
  });
}

class _FakeChatClient extends DelegatingChatClient {
  _FakeChatClient() : super(_NullChatClient());

  ChatOptions? lastOptions;

  @override
  Future<ChatResponse> getChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    lastOptions = options;
    return ChatResponse.fromMessage(
      ChatMessage.fromText(ChatRole.assistant, 'ok'),
    );
  }

  @override
  Stream<ChatResponseUpdate> getStreamingChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    lastOptions = options;
    yield ChatResponseUpdate.fromText(ChatRole.assistant, 'ok');
  }
}

class _NullChatClient implements ChatClient {
  @override
  Future<ChatResponse> getChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async =>
      ChatResponse();

  @override
  Stream<ChatResponseUpdate> getStreamingChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) =>
      const Stream.empty();

  @override
  T? getService<T>({Object? key}) => null;

  @override
  void dispose() {}
}

class _TestFunction extends AIFunction {
  _TestFunction()
      : super(name: 'test_fn', description: 'A test function');

  @override
  Future<Object?> invokeCore(
    AIFunctionArguments arguments, {
    CancellationToken? cancellationToken,
  }) async =>
      'invoked';
}
