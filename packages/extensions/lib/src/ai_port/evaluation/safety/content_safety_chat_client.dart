import '../../abstractions/chat_completion/chat_client.dart';
import '../../abstractions/chat_completion/chat_client_metadata.dart';
import '../../abstractions/chat_completion/chat_message.dart';
import '../../abstractions/chat_completion/chat_options.dart';
import '../../abstractions/chat_completion/chat_response_update.dart';
import '../../abstractions/chat_completion/chat_role.dart';
import '../utilities/model_info.dart';
import 'content_safety_service_configuration.dart';

class ContentSafetyChatClient implements ChatClient {
  ContentSafetyChatClient(
    ContentSafetyServiceConfiguration contentSafetyServiceConfiguration,
    {ChatClient? originalChatClient = null, },
  ) :
      _service = contentSafetyService(contentSafetyServiceConfiguration),
      _originalChatClient = originalChatClient {
    var originalMetadata = _originalChatClient?.getService<ChatClientMetadata>();
    if (originalMetadata == null) {
      _metadata =
                chatClientMetadata(
                    providerName: ModelInfo.knownModelProviders.azureAIFoundry,
                    defaultModelId: ModelInfo.knownModels.azureAIFoundryEvaluation);
    } else {
      // If we are wrapping an existing client, prefer its metadata. Preserving the metadata of the inner client
            // (when available) ensures that the contained information remains available for requests that are
            // delegated to the inner client and serviced by an LLM endpoint. For requests that are not delegated, the
            // ChatResponse.modelId for the produced response would be sufficient to identify that the model used was
            // the finetuned model provided by the Azure AI Foundry Evaluation service (even though the outer client's
            // metadata will not reflect this).
            _metadata = originalMetadata;
    }
  }

  final ContentSafetyService _service;

  final ChatClient? _originalChatClient;

  final ChatClientMetadata _metadata;

  @override
  Future<ChatResponse> getResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    if (options is ContentSafetyChatOptions) {
      final contentSafetyChatOptions = options as ContentSafetyChatOptions;
      validateSingleMessage(messages);
      var payload = messages.single().text;
      var annotationResult = await _service.annotateAsync(
                    payload,
                    contentSafetyChatOptions.annotationFuture,
                    contentSafetyChatOptions.evaluatorName,
                    cancellationToken).configureAwait(false);
      return chatResponse(chatMessage(ChatRole.assistant, annotationResult))
            {
                ModelId = ModelInfo.knownModels.azureAIFoundryEvaluation
            };
    } else {
      validateOriginalChatClientNotNull();
      return await _originalChatClient.getResponseAsync(
                messages,
                options,
                cancellationToken).configureAwait(false);
    }
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    if (options is ContentSafetyChatOptions) {
      final contentSafetyChatOptions = options as ContentSafetyChatOptions;
      validateSingleMessage(messages);
      var payload = messages.single().text;
      var annotationResult = await _service.annotateAsync(
                    payload,
                    contentSafetyChatOptions.annotationFuture,
                    contentSafetyChatOptions.evaluatorName,
                    cancellationToken).configureAwait(false);
      yield chatResponseUpdate(ChatRole.assistant, annotationResult);
    } else {
      validateOriginalChatClientNotNull();
      for (final update in _originalChatClient.getStreamingResponseAsync(
                    messages,
                    options,
                    cancellationToken).configureAwait(false)) {
        yield update;
      }
    }
  }

  @override
  Object? getService(Type serviceType, {Object? serviceKey, }) {
    if (serviceKey == null) {
      if (serviceType == typeof(ChatClientMetadata)) {
        return _metadata;
      } else if (serviceType == typeof(ContentSafetyChatClient)) {
        return this;
      }
    }
    return _originalChatClient?.getService(serviceType, serviceKey);
  }

  @override
  void dispose() {
    _originalChatClient?.dispose();
  }

  static void validateSingleMessage(Iterable<ChatMessage> messages) {
    if (!messages.any()) {
      var ErrorMessage = 'Expected '${nameof(messages)}' to contain exactly one message, but found none.';
      Debug.fail(ErrorMessage);
      Throw.argumentException(nameof(messages), ErrorMessage);
    } else if (messages.skip(1).any()) {
      var ErrorMessage = 'Expected '${nameof(messages)}' to contain exactly one message, but found more than one.';
      Debug.fail(ErrorMessage);
      Throw.argumentException(nameof(messages), ErrorMessage);
    }
  }

  void validateOriginalChatClientNotNull({String? callerMemberName}) {
    if (_originalChatClient == null) {
      var errorMessage = ''"
                Failed to invoke '{nameof(IChatClient)}.{callerMemberName}()'.
                Did you forget to specify the argument value for 'originalChatClient' or 'originalChatConfiguration' when calling '{nameof(ContentSafetyServiceConfiguration)}.toChatConfiguration()'?
                """;
      Throw.argumentNullException(nameof(_originalChatClient), errorMessage);
    }
  }
}
