import '../../../../../lib/func_typedefs.dart';
import 'chat_client_builder.dart';
import 'function_invoking_chat_client.dart';

/// Provides extension methods for attaching a [FunctionInvokingChatClient] to
/// a chat pipeline.
extension FunctionInvokingChatClientBuilderExtensions on ChatClientBuilder {
  /// Enables automatic function call invocation on the chat pipeline.
///
/// Remarks: This works by adding an instance of [FunctionInvokingChatClient]
/// with default options.
///
/// Returns: The supplied `builder`.
///
/// [builder] The [ChatClientBuilder] being used to build the chat pipeline.
///
/// [loggerFactory] An optional [LoggerFactory] to use to create a logger for
/// logging function invocations.
///
/// [configure] An optional callback that can be used to configure the
/// [FunctionInvokingChatClient] instance.
ChatClientBuilder useFunctionInvocation({LoggerFactory? loggerFactory, Action<FunctionInvokingChatClient>? configure, }) {
_ = Throw.ifNull(builder);
return builder.use((innerClient, services) =>
        {
            loggerFactory ??= services.getService<LoggerFactory>();

            var chatClient = functionInvokingChatClient(innerClient, loggerFactory, services);
            configure?.invoke(chatClient);
            return chatClient;
        });
 }
 }
