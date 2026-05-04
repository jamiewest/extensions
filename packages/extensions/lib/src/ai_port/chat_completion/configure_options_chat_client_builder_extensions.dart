import '../../../../../lib/func_typedefs.dart';
import '../abstractions/chat_completion/chat_options.dart';
import 'chat_client_builder.dart';
import 'configure_options_chat_client.dart';

/// Provides extensions for configuring [ConfigureOptionsChatClient]
/// instances.
extension ConfigureOptionsChatClientBuilderExtensions on ChatClientBuilder {
  /// Adds a callback that configures a [ChatOptions] to be passed to the next
  /// client in the pipeline.
  ///
  /// Remarks: This method can be used to set default options. The `configure`
  /// delegate is passed either a new instance of [ChatOptions] if the caller
  /// didn't supply a [ChatOptions] instance, or a clone (via [Clone]) of the
  /// caller-supplied instance if one was supplied.
  ///
  /// Returns: The `builder`.
  ///
  /// [builder] The [ChatClientBuilder].
  ///
  /// [configure] The delegate to invoke to configure the [ChatOptions]
  /// instance. It is passed a clone of the caller-supplied [ChatOptions]
  /// instance (or a newly constructed instance if the caller-supplied instance
  /// is `null`).
  ChatClientBuilder configureOptions(Action<ChatOptions> configure) {
    _ = Throw.ifNull(builder);
    _ = Throw.ifNull(configure);
    return builder.use(
      (innerClient) => configureOptionsChatClient(innerClient, configure),
    );
  }
}
