## 0.3.0

- Barrel re-exports `package:extensions/ai.dart` and
  `package:extensions/dependency_injection.dart`, so consumers can import
  AI and DI types directly from `package:extensions_genkit/` without a
  secondary import.

## 0.2.0

- `GenkitChatClient` now extends `DelegatingChatClient` instead of implementing
  `ChatClient` directly, enabling correct service resolution through middleware
  chains.
- `getService()` now returns `this` when the client itself satisfies the
  requested type and delegates to the inner client otherwise; previously it
  always returned `null`.

## 0.1.0

- Initial release.
- `GenkitChatClient` — adapts any Genkit model to the `extensions` `ChatClient`
  interface, including streaming, tool-call pass-through, and cancellation.
- `AIFunctionGenkitExtensions` — converts `AIFunction` metadata to Genkit
  `ToolDefinition` and wraps it as a Genkit `Tool`.
- `GenkitServiceCollectionExtensions.addGenkitChatClient` — registers the
  client in a `ServiceCollection` and returns a `ChatClientBuilder` for
  middleware chaining.
