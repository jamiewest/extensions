import '../../abstractions/chat_completion/chat_client.dart';
import '../chat_configuration.dart';
import 'content_safety_chat_client.dart';
import 'content_safety_service_configuration.dart';

/// Extension methods for [ContentSafetyServiceConfiguration].
extension ContentSafetyServiceConfigurationExtensions
    on ContentSafetyServiceConfiguration {
  /// Returns a [ChatConfiguration] that can be used to communicate with the
  /// Azure AI Foundry Evaluation service for performing content safety
  /// evaluations.
  ///
  /// Returns: A [ChatConfiguration] that can be used to communicate with the
  /// Azure AI Foundry Evaluation service for performing content safety
  /// evaluations.
  ///
  /// [contentSafetyServiceConfiguration] An object that specifies configuration
  /// parameters such as the Azure AI project that should be used, and the
  /// credentials that should be used, when communicating with the Azure AI
  /// Foundry Evaluation service to perform content safety evaluations.
  ///
  /// [originalChatConfiguration] The original [ChatConfiguration], if any. If
  /// specified, the returned [ChatConfiguration] will be based on
  /// `originalChatConfiguration`, with the [ChatClient] in
  /// `originalChatConfiguration` being replaced with a new [ChatClient] that
  /// can be used both to communicate with the AI model that
  /// `originalChatConfiguration` is configured to communicate with, as well as
  /// to communicate with the Azure AI Foundry Evaluation service.
  ChatConfiguration toChatConfiguration({
    ChatConfiguration? originalChatConfiguration,
    ChatClient? originalChatClient,
  }) {
    _ = Throw.ifNull(contentSafetyServiceConfiguration);
    var newChatClient = contentSafetyChatClient(
      contentSafetyServiceConfiguration,
      originalChatClient: originalChatConfiguration?.chatClient,
    );
    return chatConfiguration(newChatClient);
  }
}
