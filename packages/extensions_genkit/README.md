# extensions_genkit

Genkit adapter for the [`extensions`][extensions] AI abstractions.

Use any Genkit model through the existing `ChatClient` pipeline — logging,
caching, function-invocation middleware, and dependency injection — without
modifying the core packages.

## Features

- **`GenkitChatClient`** — streams responses from a Genkit model as
  `ChatResponseUpdate` values and surfaces tool requests as
  `FunctionCallContent` so the `FunctionInvokingChatClient` middleware can
  handle the execution loop.
- **`AIFunction.toGenkitToolDefinition()`** — converts an `extensions`
  `AIFunction` to a Genkit `ToolDefinition`.
- **`AIFunction.toGenkitTool()`** — wraps an `AIFunction` as a Genkit `Tool`
  suitable for passing to `Genkit.generateStream`.
- **`ServiceCollection.addGenkitChatClient()`** — registers the client and
  returns a `ChatClientBuilder` for attaching middleware.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  extensions_genkit: ^0.1.0
```

You will also need a Genkit model plugin, for example:

```yaml
dependencies:
  genkit: ^0.13.0
  genkit_google_genai: ^0.13.0
```

## Usage

### Basic streaming

```dart
import 'package:extensions/ai.dart';
import 'package:extensions_genkit/extensions_genkit.dart';
import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';

final ai = Genkit(plugins: [googleAI()]);
final client = GenkitChatClient(
  genkit: ai,
  model: googleAI.gemini('gemini-2.5-flash'),
);

final stream = client.getStreamingResponse(
  messages: [ChatMessage.fromText(ChatRole.user, 'Hello!')],
);

await for (final update in stream) {
  stdout.write(update.text);
}
```

### Dependency injection with middleware

```dart
import 'package:extensions/ai.dart';
import 'package:extensions/dependency_injection.dart';
import 'package:extensions_genkit/extensions_genkit.dart';
import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';

final services = ServiceCollection()
  ..addSingletonInstance<Genkit>(Genkit(plugins: [googleAI()]))
  ..addGenkitChatClient(model: googleAI.gemini('gemini-2.5-flash'))
    .useFunctionInvocation()
    .useLogging();

final sp = services.buildServiceProvider();
final client = sp.getRequiredService<ChatClient>();
```

### Tool calling

Define tools as `AIFunction` values and pass them via `ChatOptions`. The
`FunctionInvokingChatClient` middleware (`.useFunctionInvocation()`) handles
the call/respond loop automatically.

```dart
final weatherTool = AIFunctionFactory.create(
  name: 'getWeather',
  description: 'Returns the current weather for a location.',
  parametersSchema: {
    'type': 'object',
    'properties': {
      'location': {'type': 'string', 'description': 'City name'},
    },
    'required': ['location'],
  },
  callback: (args, {cancellationToken}) async {
    final location = args['location'] as String;
    return {'temperature': 22, 'condition': 'sunny', 'location': location};
  },
);

final response = await client.getResponse(
  messages: [ChatMessage.fromText(ChatRole.user, "What's the weather in Paris?")],
  options: ChatOptions(tools: [weatherTool]),
);

print(response.text);
```

## Additional information

- [extensions package][extensions]
- [Genkit Dart documentation](https://genkit.dev/docs/dart/)
- [File an issue](https://github.com/jamiewest/extensions/issues)

[extensions]: https://pub.dev/packages/extensions
