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
///   Future<ChatResponse> getResponse({
///     required Iterable<ChatMessage> messages,
///     ChatOptions? options,
///     CancellationToken? cancellationToken,
///   }) async {
///     final last = messages.last.text;
///     return ChatResponse.fromMessage(
///       ChatMessage.fromText(ChatRole.assistant, 'Echo: $last'),
///     );
///   }
///
///   @override
///   Stream<ChatResponseUpdate> getStreamingResponse({
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
///   final response = await client.getResponse(
///     messages: [ChatMessage.fromText(ChatRole.user, 'Hello')],
///   );
///   print(response.text);
/// }
/// ```
library;

// Core content types
export 'src/ai/additional_properties_dictionary.dart';
export 'src/ai/ai_annotation.dart';
export 'src/ai/ai_content.dart';
export 'src/ai/ai_content_extensions.dart';
export 'src/ai/code_interpreter_tool_call_content.dart';
export 'src/ai/code_interpreter_tool_result_content.dart';
export 'src/ai/data_content.dart';
export 'src/ai/error_content.dart';
export 'src/ai/function_call_content.dart';
export 'src/ai/function_result_content.dart';
export 'src/ai/hosted_file_content.dart';
export 'src/ai/hosted_vector_store_content.dart';
export 'src/ai/image_generation_tool_call_content.dart';
export 'src/ai/image_generation_tool_result_content.dart';
export 'src/ai/input_request_content.dart';
export 'src/ai/input_response_content.dart';
export 'src/ai/mcp_server_tool_call_content.dart';
export 'src/ai/mcp_server_tool_result_content.dart';
export 'src/ai/response_continuation_token.dart';
export 'src/ai/text_content.dart';
export 'src/ai/text_reasoning_content.dart';
export 'src/ai/tool_approval_request_content.dart';
export 'src/ai/tool_approval_response_content.dart';
export 'src/ai/tool_call_content.dart';
export 'src/ai/tool_result_content.dart';
export 'src/ai/uri_content.dart';
export 'src/ai/usage_content.dart';
export 'src/ai/usage_details.dart';
export 'src/ai/web_search_tool_call_content.dart';
export 'src/ai/web_search_tool_result_content.dart';
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
export 'src/ai/chat_completion/chat_response.dart';
export 'src/ai/chat_completion/chat_response_format.dart';
export 'src/ai/chat_completion/chat_response_update.dart';
export 'src/ai/chat_completion/chat_role.dart';
export 'src/ai/chat_completion/auto_chat_tool_mode.dart';
export 'src/ai/chat_completion/chat_tool_mode.dart';
export 'src/ai/chat_completion/configure_options_chat_client.dart';
export 'src/ai/chat_completion/delegating_chat_client.dart';
export 'src/ai/chat_completion/function_invocation_context.dart';
export 'src/ai/chat_completion/function_invoking_chat_client.dart';
export 'src/ai/chat_completion/function_invoking_chat_client_builder_extensions.dart';
export 'src/ai/chat_completion/image_generating_chat_client.dart';
export 'src/ai/chat_completion/logging_chat_client.dart';
export 'src/ai/chat_completion/message_counting_chat_reducer.dart';
export 'src/ai/chat_completion/reasoning_effort.dart';
export 'src/ai/chat_completion/reasoning_options.dart';
export 'src/ai/chat_completion/reasoning_output.dart';
export 'src/ai/chat_completion/open_telemetry_chat_client.dart';
export 'src/ai/chat_completion/open_telemetry_chat_client_builder_extensions.dart';
export 'src/ai/chat_completion/reducing_chat_client.dart';
export 'src/ai/chat_completion/summarizing_chat_reducer.dart';
// Chat reduction
export 'src/ai/chat_reduction/chat_reducer.dart';
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
export 'src/ai/embeddings/open_telemetry_embedding_generator.dart';
export 'src/ai/embeddings/open_telemetry_embedding_generator_builder_extensions.dart';
// Functions
export 'src/ai/functions/ai_function.dart';
export 'src/ai/functions/ai_function_arguments.dart';
export 'src/ai/functions/ai_function_declaration.dart';
export 'src/ai/functions/ai_function_factory.dart';
export 'src/ai/functions/ai_function_factory_options.dart';
export 'src/ai/functions/approval_required_ai_function.dart';
export 'src/ai/functions/delegating_ai_function.dart';
export 'src/ai/functions/delegating_ai_function_declaration.dart';
// Image generation
export 'src/ai/image_generation/configure_options_image_generator.dart';
export 'src/ai/image_generation/delegating_image_generator.dart';
export 'src/ai/image_generation/image_generator.dart';
export 'src/ai/image_generation/image_generator_builder.dart';
export 'src/ai/image_generation/image_generator_metadata.dart';
export 'src/ai/image_generation/logging_image_generator.dart';
export 'src/ai/image_generation/open_telemetry_image_generator.dart';
export 'src/ai/image_generation/open_telemetry_image_generator_builder_extensions.dart';
// Files (hosted)
export 'src/ai/files/delegating_hosted_file_client.dart';
export 'src/ai/files/hosted_file_client.dart';
export 'src/ai/files/hosted_file_client_builder.dart';
export 'src/ai/files/logging_hosted_file_client.dart';
// OpenTelemetry
export 'src/ai/open_telemetry_consts.dart';
// Text to speech
export 'src/ai/text_to_speech/configure_options_text_to_speech_client.dart';
export 'src/ai/text_to_speech/delegating_text_to_speech_client.dart';
export 'src/ai/text_to_speech/logging_text_to_speech_client.dart';
export 'src/ai/text_to_speech/open_telemetry_text_to_speech_client.dart';
export 'src/ai/text_to_speech/open_telemetry_text_to_speech_client_builder_extensions.dart';
export 'src/ai/text_to_speech/text_to_speech_client.dart';
export 'src/ai/text_to_speech/text_to_speech_client_builder.dart';
export 'src/ai/text_to_speech/text_to_speech_client_metadata.dart';
export 'src/ai/text_to_speech/text_to_speech_options.dart';
export 'src/ai/text_to_speech/text_to_speech_response.dart';
export 'src/ai/text_to_speech/text_to_speech_response_update.dart';
// Speech to text
export 'src/ai/speech_to_text/configure_options_speech_to_text_client.dart';
export 'src/ai/speech_to_text/delegating_speech_to_text_client.dart';
export 'src/ai/speech_to_text/logging_speech_to_text_client.dart';
export 'src/ai/speech_to_text/speech_to_text_client.dart';
export 'src/ai/speech_to_text/speech_to_text_client_builder.dart';
export 'src/ai/speech_to_text/speech_to_text_client_metadata.dart';
export 'src/ai/speech_to_text/speech_to_text_response_update.dart';
// Tool reduction
export 'src/ai/tool_reduction/tool_reduction_strategy.dart';
// Tools
export 'src/ai/tools/ai_tool.dart';
export 'src/ai/tools/hosted_code_interpreter_tool.dart';
export 'src/ai/tools/hosted_file_search_tool.dart';
export 'src/ai/tools/hosted_image_generation_tool.dart';
export 'src/ai/tools/hosted_mcp_server_tool.dart';
export 'src/ai/tools/hosted_tool_search_tool.dart';
export 'src/ai/tools/hosted_web_search_tool.dart';
// Evaluation — core abstractions
export 'src/ai/evaluation/boolean_metric.dart';
export 'src/ai/evaluation/chat_configuration.dart';
export 'src/ai/evaluation/composite_evaluator.dart';
export 'src/ai/evaluation/evaluation_context.dart';
export 'src/ai/evaluation/evaluation_diagnostic.dart';
export 'src/ai/evaluation/evaluation_diagnostic_severity.dart';
export 'src/ai/evaluation/evaluation_metric.dart';
export 'src/ai/evaluation/evaluation_metric_extensions.dart';
export 'src/ai/evaluation/evaluation_metric_interpretation.dart';
export 'src/ai/evaluation/evaluation_rating.dart';
export 'src/ai/evaluation/evaluation_result.dart';
export 'src/ai/evaluation/evaluator.dart';
export 'src/ai/evaluation/numeric_metric.dart';
export 'src/ai/evaluation/string_metric.dart';
// Evaluation — NLP algorithms (public surface)
export 'src/ai/evaluation/nlp/common/bleu_algorithm.dart';
export 'src/ai/evaluation/nlp/common/f1_algorithm.dart';
export 'src/ai/evaluation/nlp/common/gleu_algorithm.dart';
export 'src/ai/evaluation/nlp/common/n_gram.dart';
export 'src/ai/evaluation/nlp/common/simple_word_tokenizer.dart';
// Evaluation — NLP evaluators
export 'src/ai/evaluation/nlp/bleu_evaluator.dart';
export 'src/ai/evaluation/nlp/bleu_evaluator_context.dart';
export 'src/ai/evaluation/nlp/f1_evaluator.dart';
export 'src/ai/evaluation/nlp/f1_evaluator_context.dart';
export 'src/ai/evaluation/nlp/gleu_evaluator.dart';
export 'src/ai/evaluation/nlp/gleu_evaluator_context.dart';
// Evaluation — quality evaluators
export 'src/ai/evaluation/quality/coherence_evaluator.dart';
export 'src/ai/evaluation/quality/completeness_evaluator.dart';
export 'src/ai/evaluation/quality/completeness_evaluator_context.dart';
export 'src/ai/evaluation/quality/equivalence_evaluator.dart';
export 'src/ai/evaluation/quality/equivalence_evaluator_context.dart';
export 'src/ai/evaluation/quality/fluency_evaluator.dart';
export 'src/ai/evaluation/quality/groundedness_evaluator.dart';
export 'src/ai/evaluation/quality/groundedness_evaluator_context.dart';
export 'src/ai/evaluation/quality/intent_resolution_evaluator.dart';
export 'src/ai/evaluation/quality/intent_resolution_evaluator_context.dart';
export 'src/ai/evaluation/quality/quality_evaluator_base.dart';
export 'src/ai/evaluation/quality/relevance_evaluator.dart';
export 'src/ai/evaluation/quality/retrieval_evaluator.dart';
export 'src/ai/evaluation/quality/retrieval_evaluator_context.dart';
export 'src/ai/evaluation/quality/task_adherence_evaluator.dart';
export 'src/ai/evaluation/quality/task_adherence_evaluator_context.dart';
export 'src/ai/evaluation/quality/tool_call_accuracy_evaluator.dart';
export 'src/ai/evaluation/quality/tool_call_accuracy_evaluator_context.dart';
export 'src/ai/evaluation/quality/relevance_truth_and_completeness_rating.dart';
export 'src/ai/evaluation/quality/relevance_truth_and_completeness_evaluator.dart';
// Evaluation — safety evaluators
export 'src/ai/evaluation/safety/code_vulnerability_evaluator.dart';
export 'src/ai/evaluation/safety/content_harm_evaluator.dart';
export 'src/ai/evaluation/safety/content_safety_evaluator.dart';
export 'src/ai/evaluation/safety/content_safety_service_configuration.dart';
export 'src/ai/evaluation/safety/groundedness_pro_evaluator.dart';
export 'src/ai/evaluation/safety/groundedness_pro_evaluator_context.dart';
export 'src/ai/evaluation/safety/hate_and_unfairness_evaluator.dart';
export 'src/ai/evaluation/safety/indirect_attack_evaluator.dart';
export 'src/ai/evaluation/safety/protected_material_evaluator.dart';
export 'src/ai/evaluation/safety/self_harm_evaluator.dart';
export 'src/ai/evaluation/safety/sexual_evaluator.dart';
export 'src/ai/evaluation/safety/ungrounded_attributes_evaluator.dart';
export 'src/ai/evaluation/safety/ungrounded_attributes_evaluator_context.dart';
export 'src/ai/evaluation/safety/violence_evaluator.dart';
// Evaluation — reporting
export 'src/ai/evaluation/reporting/chat_details.dart';
export 'src/ai/evaluation/reporting/chat_turn_details.dart';
export 'src/ai/evaluation/reporting/evaluation_response_cache_provider.dart';
export 'src/ai/evaluation/reporting/evaluation_result_store.dart';
export 'src/ai/evaluation/reporting/reporting_configuration.dart';
export 'src/ai/evaluation/reporting/response_cache.dart';
export 'src/ai/evaluation/reporting/response_caching_chat_client.dart';
export 'src/ai/evaluation/reporting/scenario_run.dart';
export 'src/ai/evaluation/reporting/scenario_run_result.dart';
export 'src/ai/evaluation/reporting/storage/disk_based_reporting_configuration.dart';
export 'src/ai/evaluation/reporting/storage/disk_based_response_cache.dart';
export 'src/ai/evaluation/reporting/storage/disk_based_response_cache_provider.dart';
export 'src/ai/evaluation/reporting/storage/disk_based_result_store.dart';
