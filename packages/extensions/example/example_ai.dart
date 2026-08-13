import 'package:extensions/ai.dart';
import 'package:extensions/logging.dart';
import 'package:extensions/system.dart';

/// Demonstrates the [ChatClient] middleware pipeline and function calling.
///
/// Run this file to see a request flow through logging and function-invocation
/// middleware into a local echo client — no network or API key required.
Future<void> main() async {
  print('=== AI Example ===');

  await _pipelineExample();
  await _functionCallingExample();
  await _streamingExample();
}

/// Composes middleware around an inner client.
Future<void> _pipelineExample() async {
  print('--- Chat Client Pipeline ---');

  final loggerFactory = LoggerFactory.create(
    (builder) => builder..addSimpleConsole(),
  );

  // #region chat_client_pipeline
  // Middleware runs outermost-first: logging wraps function invocation,
  // which wraps the provider client.
  final client = ChatClientBuilder(EchoChatClient())
      .useLogging(loggerFactory: loggerFactory)
      .useFunctionInvocation()
      .build();

  final response = await client.getResponse(
    messages: [ChatMessage.fromText(ChatRole.user, 'Hello, pipeline!')],
  );

  print(response.text);
  // #endregion

  client.dispose();
  loggerFactory.dispose();
}

/// Exposes a Dart callback to the model as a tool.
Future<void> _functionCallingExample() async {
  print('--- Function Calling ---');

  // #region ai_function
  final getWeather = AIFunctionFactory.create(
    name: 'get_weather',
    description: 'Gets the current weather for a city.',
    parametersSchema: <String, dynamic>{
      'type': 'object',
      'properties': <String, dynamic>{
        'city': <String, dynamic>{'type': 'string'},
      },
      'required': <String>['city'],
    },
    callback: (arguments, {cancellationToken}) async =>
        'It is 17°C and raining in ${arguments['city']}.',
  );

  final options = ChatOptions()..tools = [getWeather];
  // #endregion

  // #region ai_function_invoke
  final result = await getWeather.invoke(
    AIFunctionArguments(<String, Object?>{'city': 'Dublin'}),
  );

  print('$result');
  print('Tools advertised to the model: ${options.tools?.length}');
  // #endregion
}

/// Consumes a response incrementally.
Future<void> _streamingExample() async {
  print('--- Streaming Response ---');

  // #region chat_streaming
  final client = EchoChatClient();

  await for (final update in client.getStreamingResponse(
    messages: [ChatMessage.fromText(ChatRole.user, 'Stream this back')],
  )) {
    print('update: ${update.text}');
  }
  // #endregion

  client.dispose();
}

/// A local [ChatClient] that echoes the last user message.
///
/// Real applications substitute a provider-backed client here; the surrounding
/// pipeline code is identical either way.
// #region custom_chat_client
class EchoChatClient extends ChatClient {
  @override
  Future<ChatResponse> getResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async => ChatResponse.fromMessage(
    ChatMessage.fromText(ChatRole.assistant, 'echo: ${messages.last.text}'),
  );

  @override
  Stream<ChatResponseUpdate> getStreamingResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async* {
    for (final word in messages.last.text.split(' ')) {
      yield ChatResponseUpdate(
        role: ChatRole.assistant,
        contents: [TextContent('$word ')],
      );
    }
  }

  @override
  void dispose() {}
}
// #endregion
