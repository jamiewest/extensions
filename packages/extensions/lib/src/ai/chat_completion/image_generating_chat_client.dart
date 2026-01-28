import 'dart:async';

import '../../system/threading/cancellation_token.dart';
import '../ai_content.dart';
import '../image_generation/image_generation_tool_content.dart';
import '../image_generation/image_generator.dart';
import 'chat_message.dart';
import 'chat_options.dart';
import 'chat_response.dart';
import 'chat_role.dart';
import 'delegating_chat_client.dart';

/// A [DelegatingChatClient] that handles image generation tool calls
/// by delegating to an [ImageGenerator].
///
/// When the model requests image generation (e.g. via a tool call),
/// this client intercepts the request, generates the image using the
/// provided [ImageGenerator], and returns the result.
///
/// This is an experimental feature.
class ImageGeneratingChatClient extends DelegatingChatClient {
  /// Creates a new [ImageGeneratingChatClient].
  ImageGeneratingChatClient(
    super.innerClient, {
    required this.imageGenerator,
  });

  /// The image generator used to handle image generation requests.
  final ImageGenerator imageGenerator;

  @override
  Future<ChatResponse> getChatResponse({
    required Iterable<ChatMessage> messages,
    ChatOptions? options,
    CancellationToken? cancellationToken,
  }) async {
    final response = await super.getChatResponse(
      messages: messages,
      options: options,
      cancellationToken: cancellationToken,
    );

    return _processResponse(response, cancellationToken);
  }

  Future<ChatResponse> _processResponse(
    ChatResponse response,
    CancellationToken? cancellationToken,
  ) async {
    // Check if the response contains image generation tool calls.
    if (response.messages.isEmpty) return response;

    final lastMessage = response.messages.last;
    final imageGenCalls = lastMessage.contents
        .whereType<ImageGenerationToolCallContent>()
        .toList();

    if (imageGenCalls.isEmpty) return response;

    // Process each image generation request.
    final resultContents = <AIContent>[];
    for (final call in imageGenCalls) {
      final genResponse = await imageGenerator.generate(
        request: ImageGenerationRequest(prompt: call.imageId),
        cancellationToken: cancellationToken,
      );
      resultContents.addAll(genResponse.contents);
    }

    // Add the generated images as a new assistant message.
    final updatedMessages = [
      ...response.messages,
      ChatMessage(
        role: ChatRole.assistant,
        contents: resultContents,
      ),
    ];

    return ChatResponse(
      messages: updatedMessages,
      responseId: response.responseId,
      conversationId: response.conversationId,
      modelId: response.modelId,
      createdAt: response.createdAt,
      finishReason: response.finishReason,
      usage: response.usage,
      additionalProperties: response.additionalProperties,
    );
  }

}
