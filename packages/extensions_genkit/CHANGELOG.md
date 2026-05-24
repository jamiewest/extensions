## 0.1.0

- Initial release.
- `GenkitChatClient` — adapts any Genkit model to the `extensions` `ChatClient`
  interface, including streaming, tool-call pass-through, and cancellation.
- `AIFunctionGenkitExtensions` — converts `AIFunction` metadata to Genkit
  `ToolDefinition` and wraps it as a Genkit `Tool`.
- `GenkitServiceCollectionExtensions.addGenkitChatClient` — registers the
  client in a `ServiceCollection` and returns a `ChatClientBuilder` for
  middleware chaining.
