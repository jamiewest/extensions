import 'chat_client_builder.dart';
import 'chat_options.dart';
import 'configure_options_chat_client.dart';

/// Provides extensions for adding [ConfigureOptionsChatClient] to a
/// [ChatClientBuilder] pipeline.
extension ConfigureOptionsChatClientBuilderExtensions on ChatClientBuilder {
  /// Adds a callback that configures the [ChatOptions] passed to each
  /// request.
  ChatClientBuilder useConfigureOptions(
    ChatOptions Function(ChatOptions options) configure,
  ) => use((inner) => ConfigureOptionsChatClient(inner, configure: configure));
}
