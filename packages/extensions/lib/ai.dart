/// AI extension library.
///
/// This library provides abstractions for chat completion, embeddings,
/// image generation, speech-to-text, and tool pipelines. You supply
/// provider-specific clients and then layer cross-cutting concerns
/// like logging, caching, or message reduction via builders.
///
/// Example: build a simple chat pipeline and send a message.
/// ```dart
/// import 'package:extensions/ai.dart';
///
/// class EchoChatClient implements ChatClient {
///   @override
///   Future<ChatResponse> getChatResponse({
///     required Iterable<ChatMessage> messages,
///     ChatOptions? options,
///     CancellationToken? cancellationToken,
///   }) async {
///     final last = messages.last.text ?? '';
///     return ChatResponse(
///       message: ChatMessage.fromText(ChatRole.assistant, 'Echo: $last'),
///     );
///   }
///
///   @override
///   Stream<ChatResponseUpdate> getStreamingChatResponse({
///     required Iterable<ChatMessage> messages,
///     ChatOptions? options,
///     CancellationToken? cancellationToken,
///   }) async* {}
///
///   @override
///   void dispose() {}
/// }
///
/// Future<void> main() async {
///   final client = ChatClientBuilder(EchoChatClient()).build();
///   final response = await client.getChatResponseFromText('Hello');
///   print(response.message?.text);
/// }
/// ```
///
/// Example: streaming responses.
/// ```dart
/// import 'package:extensions/ai.dart';
///
/// class StreamingEchoChatClient implements ChatClient {
///   @override
///   Future<ChatResponse> getChatResponse({
///     required Iterable<ChatMessage> messages,
///     ChatOptions? options,
///     CancellationToken? cancellationToken,
///   }) async =>
///       ChatResponse();
///
///   @override
///   Stream<ChatResponseUpdate> getStreamingChatResponse({
///     required Iterable<ChatMessage> messages,
///     ChatOptions? options,
///     CancellationToken? cancellationToken,
///   }) async* {
///     yield ChatResponseUpdate(
///       message: ChatMessage.fromText(ChatRole.assistant, 'Hello'),
///     );
///     yield ChatResponseUpdate(
///       message: ChatMessage.fromText(ChatRole.assistant, ' world'),
///     );
///   }
///
///   @override
///   void dispose() {}
/// }
///
/// Future<void> main() async {
///   final client = ChatClientBuilder(StreamingEchoChatClient()).build();
///   await for (final update in client.getStreamingChatResponseFromText('Hi')) {
///     print(update.message?.text);
///   }
/// }
/// ```
///
/// Example: registering a chat client with DI.
/// ```dart
/// import 'package:extensions/ai.dart';
/// import 'package:extensions/dependency_injection.dart';
///
/// class MyChatClient implements ChatClient {
///   @override
///   Future<ChatResponse> getChatResponse({
///     required Iterable<ChatMessage> messages,
///     ChatOptions? options,
///     CancellationToken? cancellationToken,
///   }) async => ChatResponse();
///
///   @override
///   Stream<ChatResponseUpdate> getStreamingChatResponse({
///     required Iterable<ChatMessage> messages,
///     ChatOptions? options,
///     CancellationToken? cancellationToken,
///   }) async* {}
///
///   @override
///   void dispose() {}
/// }
///
/// final services = ServiceCollection()
///   ..addSingleton<MyChatClient>((_) => MyChatClient());
///
/// final provider = services.buildServiceProvider();
/// final client = provider.getRequiredService<MyChatClient>();
/// ```
library;

// Core content types
export 'src/ai/additional_properties_dictionary.dart';
export 'src/ai/ai_annotation.dart';
export 'src/ai/ai_content.dart';
// Chat completion
export 'src/ai/chat_completion/anonymous_delegating_chat_client.dart';
export 'src/ai/chat_completion/caching_chat_client.dart';
export 'src/ai/chat_completion/chat_client.dart';
export 'src/ai/chat_completion/chat_client_builder.dart';
export 'src/ai/chat_completion/chat_client_builder_service_collection_extensions.dart';
export 'src/ai/chat_completion/chat_client_extensions.dart';
export 'src/ai/chat_completion/chat_client_metadata.dart';
export 'src/ai/chat_completion/chat_finish_reason.dart';
export 'src/ai/chat_completion/chat_message.dart';
export 'src/ai/chat_completion/chat_options.dart';
export 'src/ai/chat_reduction/chat_reducer.dart';
export 'src/ai/chat_completion/chat_response.dart';
export 'src/ai/chat_completion/chat_response_format.dart';
export 'src/ai/chat_completion/chat_response_update.dart';
export 'src/ai/chat_completion/chat_role.dart';
export 'src/ai/chat_completion/chat_tool_mode.dart';
export 'src/ai/chat_completion/configure_options_chat_client.dart';
export 'src/ai/chat_completion/delegating_chat_client.dart';
export 'src/ai/chat_completion/function_invocation_context.dart';
export 'src/ai/chat_completion/function_invoking_chat_client.dart';
export 'src/ai/chat_completion/image_generating_chat_client.dart';
export 'src/ai/chat_completion/logging_chat_client.dart';
export 'src/ai/chat_completion/message_counting_chat_reducer.dart';
export 'src/ai/chat_completion/reducing_chat_client.dart';
export 'src/ai/chat_completion/summarizing_chat_reducer.dart';
export 'src/ai/code_interpreter_content.dart';
export 'src/ai/data_content.dart';
// Embeddings
export 'src/ai/embeddings/configure_options_embedding_generator.dart';
export 'src/ai/embeddings/delegating_embedding_generator.dart';
export 'src/ai/embeddings/embedding.dart';
export 'src/ai/embeddings/embedding_generation_options.dart';
export 'src/ai/embeddings/embedding_generator.dart';
export 'src/ai/embeddings/embedding_generator_builder.dart';
export 'src/ai/embeddings/embedding_generator_metadata.dart';
export 'src/ai/embeddings/generated_embeddings.dart';
export 'src/ai/embeddings/logging_embedding_generator.dart';
export 'src/ai/error_content.dart';
export 'src/ai/function_call_content.dart';
export 'src/ai/function_result_content.dart';
// Functions
export 'src/ai/functions/ai_function.dart';
export 'src/ai/functions/ai_function_arguments.dart';
export 'src/ai/functions/ai_function_factory.dart';
export 'src/ai/functions/delegating_ai_function.dart';
export 'src/ai/hosted_file_content.dart';
export 'src/ai/hosted_vector_store_content.dart';
// Image generation
export 'src/ai/image_generation/configure_options_image_generator.dart';
export 'src/ai/image_generation/delegating_image_generator.dart';
export 'src/ai/image_generation/image_generation_tool_content.dart';
export 'src/ai/image_generation/image_generator.dart';
export 'src/ai/image_generation/image_generator_builder.dart';
export 'src/ai/image_generation/image_generator_metadata.dart';
export 'src/ai/image_generation/logging_image_generator.dart';
export 'src/ai/mcp_server_content.dart';
export 'src/ai/response_continuation_token.dart';
// Speech to text
export 'src/ai/speech_to_text/configure_options_speech_to_text_client.dart';
export 'src/ai/speech_to_text/delegating_speech_to_text_client.dart';
export 'src/ai/speech_to_text/logging_speech_to_text_client.dart';
export 'src/ai/speech_to_text/speech_to_text_client.dart';
export 'src/ai/speech_to_text/speech_to_text_client_builder.dart';
export 'src/ai/speech_to_text/speech_to_text_client_metadata.dart';
export 'src/ai/speech_to_text/speech_to_text_response_update.dart';
export 'src/ai/text_content.dart';
export 'src/ai/text_reasoning_content.dart';
// Tool reduction
export 'src/ai/tool_reduction/tool_reduction_strategy.dart';
// Tools
export 'src/ai/tools/ai_tool.dart';
export 'src/ai/tools/hosted_code_interpreter_tool.dart';
export 'src/ai/tools/hosted_file_search_tool.dart';
export 'src/ai/tools/hosted_image_generation_tool.dart';
export 'src/ai/tools/hosted_mcp_server_tool.dart';
export 'src/ai/tools/hosted_web_search_tool.dart';
export 'src/ai/uri_content.dart';
export 'src/ai/usage_content.dart';
export 'src/ai/usage_details.dart';
export 'src/ai/user_input_content.dart';
