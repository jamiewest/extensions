import 'package:extensions/ai.dart';
import 'package:extensions/dependency_injection.dart';
import 'package:genkit/genkit.dart';

import '../chat_completion/genkit_chat_client.dart';

/// Extension methods for registering Genkit services with a
/// [ServiceCollection].
///
/// Each method returns a [ChatClientBuilder] to allow fluent
/// middleware chaining.
extension GenkitServiceCollectionExtensions on ServiceCollection {
  /// Registers a [GenkitChatClient] for [model] and returns a
  /// [ChatClientBuilder] for attaching middleware.
  ///
  /// If [genkit] is provided it is registered as the [Genkit] singleton;
  /// otherwise the caller must register [Genkit] separately before building
  /// the service provider.
  ///
  /// Example:
  /// ```dart
  /// services
  ///   ..addSingletonInstance<Genkit>(Genkit(plugins: [googleAI()]))
  ///   ..addGenkitChatClient(model: googleAI.gemini('gemini-2.5-flash'))
  ///     .useFunctionInvocation()
  ///     .useLogging();
  /// ```
  ChatClientBuilder addGenkitChatClient({
    required ModelRef model,
    Genkit? genkit,
  }) {
    if (genkit != null) {
      addSingletonInstance<Genkit>(genkit);
    }
    return addChatClient(
      (sp) => GenkitChatClient(
        genkit: sp.getRequiredService<Genkit>(),
        model: model,
      ),
    );
  }
}
