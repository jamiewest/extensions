/// Genkit adapter for the `extensions` AI abstractions.
///
/// Provides [GenkitChatClient] and DI helpers so Genkit models can be used
/// through the existing [ChatClient] pipeline (logging, caching,
/// function-invocation middleware) without modifying the core packages.
library;

export 'package:extensions/ai.dart';
export 'package:extensions/dependency_injection.dart';

export 'src/chat_completion/genkit_chat_client.dart';
export 'src/dependency_injection/genkit_service_collection_extensions.dart';
export 'src/functions/ai_function_genkit_extensions.dart';
