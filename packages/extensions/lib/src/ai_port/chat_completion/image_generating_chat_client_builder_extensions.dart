import '../../../../../lib/func_typedefs.dart';
import '../abstractions/image/image_generator.dart';
import '../abstractions/tools/hosted_image_generation_tool.dart';
import 'chat_client_builder.dart';
import 'image_generating_chat_client.dart';

/// Provides extensions for configuring [ImageGeneratingChatClient] instances.
extension ImageGeneratingChatClientBuilderExtensions on ChatClientBuilder {
  /// Adds image generation capabilities to the chat client pipeline.
///
/// Remarks: This method enables the chat client to handle
/// [HostedImageGenerationTool] instances by converting them into function
/// tools that can be invoked by the underlying chat model to perform image
/// generation and editing operations.
///
/// Returns: The `builder`.
///
/// [builder] The [ChatClientBuilder].
///
/// [imageGenerator] An optional [ImageGenerator] used for image generation
/// operations. If not supplied, a required instance will be resolved from the
/// service provider.
///
/// [configure] An optional callback that can be used to configure the
/// [ImageGeneratingChatClient] instance.
ChatClientBuilder useImageGeneration({ImageGenerator? imageGenerator, Action<ImageGeneratingChatClient>? configure, }) {
_ = Throw.ifNull(builder);
return builder.use((innerClient, services) =>
        {
            imageGenerator ??= services.getRequiredService<ImageGenerator>();

            var chatClient = imageGeneratingChatClient(innerClient, imageGenerator);
            configure?.invoke(chatClient);
            return chatClient;
        });
 }
 }
