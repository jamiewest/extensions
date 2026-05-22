import 'dart:io';

import 'package:extensions/ai.dart';

/// Provides helpers for integration tests that require a live API key.
///
/// Mirrors [IntegrationTestHelpers] from the C# test suite.
///
/// Returns `null` when [_apiKeyEnvVar] is not set, allowing tests to skip
/// themselves gracefully.
class IntegrationTestHelpers {
  IntegrationTestHelpers._();

  static const String _apiKeyEnvVar = 'OPENAI_API_KEY';
  static const String _endpointEnvVar = 'OPENAI_ENDPOINT';

  /// Returns a configured [OpenAIChatClient] if [_apiKeyEnvVar] is set,
  /// otherwise returns `null`.
  ///
  /// Set [_endpointEnvVar] to target a local server such as LM Studio.
  static OpenAIChatClient? getChatClient({String modelId = 'gpt-4o-mini'}) {
    final apiKey = Platform.environment[_apiKeyEnvVar];
    if (apiKey == null || apiKey.isEmpty) return null;

    final endpointRaw = Platform.environment[_endpointEnvVar];
    final options = endpointRaw != null
        ? OpenAIClientOptions(endpoint: Uri.parse(endpointRaw))
        : null;

    return OpenAIChatClient(modelId, apiKey, options: options);
  }

  /// Returns a configured [OpenAIEmbeddingGenerator] if [_apiKeyEnvVar] is
  /// set, otherwise returns `null`.
  static OpenAIEmbeddingGenerator? getEmbeddingGenerator({
    String modelId = 'text-embedding-3-small',
  }) {
    final apiKey = Platform.environment[_apiKeyEnvVar];
    if (apiKey == null || apiKey.isEmpty) return null;

    final endpointRaw = Platform.environment[_endpointEnvVar];
    final options = endpointRaw != null
        ? OpenAIClientOptions(endpoint: Uri.parse(endpointRaw))
        : null;

    return OpenAIEmbeddingGenerator(modelId, apiKey, options: options);
  }
}
