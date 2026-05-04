import '../abstractions/chat_completion/chat_client.dart';
import '../abstractions/chat_completion/chat_message.dart';
import '../abstractions/chat_completion/chat_options.dart';
import '../abstractions/chat_completion/chat_response_update.dart';
import '../abstractions/chat_completion/delegating_chat_client.dart';
import '../abstractions/contents/ai_content.dart';
import '../abstractions/contents/data_content.dart';
import '../abstractions/contents/function_call_content.dart';
import '../abstractions/contents/function_result_content.dart';
import '../abstractions/contents/image_generation_tool_call_content.dart';
import '../abstractions/contents/image_generation_tool_result_content.dart';
import '../abstractions/image/image_generation_options.dart';
import '../abstractions/image/image_generation_request.dart';
import '../abstractions/image/image_generator.dart';
import '../abstractions/tools/hosted_image_generation_tool.dart';
import 'function_invoking_chat_client.dart';

/// A delegating chat client that enables image generation capabilities by
/// converting [HostedImageGenerationTool] instances to function tools.
///
/// Remarks: The provided implementation of [ChatClient] is thread-safe for
/// concurrent use so long as the [ImageGenerator] employed is also
/// thread-safe for concurrent use. This client automatically detects
/// [HostedImageGenerationTool] instances in the [Tools] collection and
/// replaces them with equivalent function tools that the chat client can
/// invoke to perform image generation and editing operations.
class ImageGeneratingChatClient extends DelegatingChatClient {
  /// Initializes a new instance of the [ImageGeneratingChatClient] class.
  ///
  /// [innerClient] The underlying [ChatClient].
  ///
  /// [imageGenerator] An [ImageGenerator] instance that will be used for image
  /// generation operations.
  ///
  /// [dataContentHandling] Specifies how to handle [DataContent] instances when
  /// passing messages to the inner client. The default is [AllImages].
  ImageGeneratingChatClient(
    ChatClient innerClient,
    ImageGenerator imageGenerator,
    {DataContentHandling? dataContentHandling = null, },
  ) :
      _imageGenerator = Throw.ifNull(imageGenerator),
      _dataContentHandling = dataContentHandling;

  final ImageGenerator _imageGenerator;

  final DataContentHandling _dataContentHandling;

  @override
  Future<ChatResponse> getResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(messages);
    var requestState = requestState(_imageGenerator, _dataContentHandling);
    var processedOptions = requestState.processChatOptions(options);
    var processedMessages = requestState.processChatMessages(messages);
    var response = await base.getResponseAsync(
      processedMessages,
      processedOptions,
      cancellationToken,
    );
    for (final message in response.messages) {
      message.contents = requestState.replaceImageGenerationFunctionResults(message.contents);
    }
    return response;
  }

  @override
  Stream<ChatResponseUpdate> getStreamingResponse(
    Iterable<ChatMessage> messages,
    {ChatOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(messages);
    var requestState = requestState(_imageGenerator, _dataContentHandling);
    var processedOptions = requestState.processChatOptions(options);
    var processedMessages = requestState.processChatMessages(messages);
    for (final update in base.getStreamingResponseAsync(processedMessages, processedOptions, cancellationToken)) {
      var newContents = requestState.replaceImageGenerationFunctionResults(update.contents);
      if (!referenceEquals(newContents, update.contents)) {
        var modifiedUpdate = update.clone();
        modifiedUpdate.contents = newContents;
        yield modifiedUpdate;
      } else {
        yield update;
      }
    }
  }

  /// Provides a mechanism for releasing unmanaged resources.
  ///
  /// [disposing] `true` to dispose managed resources; otherwise, `false`.
  @override
  void dispose(bool disposing) {
    if (disposing) {
      _imageGenerator.dispose();
    }
    base.dispose(disposing);
  }
}
/// Specifies how image and other data content is handled when passing data to
/// an inner client.
///
/// Remarks: Use this enumeration to control whether images in the data
/// content are passed as-is, replaced with unique identifiers, or only
/// generated images are replaced. This setting affects how downstream clients
/// receive and process image data. Reducing what's passed downstream can help
/// manage the context window.
enum DataContentHandling { /// Pass all DataContent to inner client.
none,
/// Replace all images with unique identifiers when passing to inner client.
allImages,
/// Replace only images that were produced by past image generation requests
/// with unique identifiers when passing to inner client.
generatedImages }
/// Contains all the per-request state and methods for handling image
/// generation requests. This class is created fresh for each request to
/// ensure thread safety. This class is not exposed publicly and does not own
/// any of it's resources.
class RequestState {
  RequestState(
    ImageGenerator imageGenerator,
    DataContentHandling dataContentHandling,
  ) :
      _imageGenerator = imageGenerator,
      _dataContentHandling = dataContentHandling;

  final ImageGenerator _imageGenerator;

  final DataContentHandling _dataContentHandling;

  final Set<String> _toolNames = new(StringComparer.Ordinal);

  final Map<String, List<AContent>> _imageContentByCallId = [];

  final Map<String, AContent> _imageContentById = new(StringComparer.OrdinalIgnoreCase);

  ImageGenerationOptions? _imageGenerationOptions;

  /// Processes the chat messages to replace images in data content with unique
  /// identifiers as needed. All images will be stored for later retrieval
  /// during image editing operations. See [DataContentHandling] for details on
  /// image replacement behavior.
  ///
  /// Returns: Processed messages, or the original messages if no changes were
  /// made.
  ///
  /// [messages] Messages to process.
  Iterable<ChatMessage> processChatMessages(Iterable<ChatMessage> messages) {
    var newMessages = null;
    var messageIndex = 0;
    for (final message in messages) {
      var newContents = null;
      for (var contentIndex = 0; contentIndex < message.contents.count; contentIndex++) {
        var content = message.contents[contentIndex];
        /* TODO: unsupported node kind "unknown" */
        // void ReplaceImage(string imageId, DataContent dataContent)
        //                     {
          //                         // Replace image with a placeholder text content, to give an indication to the model of its placement in the context
          //                         newContents ??= CopyList(message.Contents, contentIndex);
          //                         newContents.Add(new TextContent($"[{ImageKey}:{imageId}] available for edit.")
          //                         {
            //                             Annotations = dataContent.Annotations,
            //                             AdditionalProperties = dataContent.AdditionalProperties
            //                         });
          //                     }
        if (content is DataContent dataContent && dataContent.hasTopLevelMediaType("image")) {
          var imageId = storeImage(dataContent);
          if (_dataContentHandling == DataContentHandling.allImages) {
            replaceImage(imageId, dataContent);
            continue;
          }
        } else if (content is ImageGenerationToolResultContent) {
          final toolResultContent = content as ImageGenerationToolResultContent;
          for (final output in toolResultContent.outputs ?? []) {
            if (output is DataContent generatedDataContent && generatedDataContent.hasTopLevelMediaType("image")) {
              var imageId = storeImage(generatedDataContent, isGenerated: true);
              if (_dataContentHandling == DataContentHandling.allImages ||
                                    _dataContentHandling == DataContentHandling.generatedImages) {
                replaceImage(imageId, generatedDataContent);
              }
            }
          }
          if (_dataContentHandling == DataContentHandling.allImages ||
                            _dataContentHandling == DataContentHandling.generatedImages) {
            continue;
          }
        }
        // Add the original content if no replacement was made
                    newContents?.add(content);
      }
      if (newContents != null) {
        newMessages ??= [.. messages.take(messageIndex)];
        var newMessage = message.clone();
        newMessage.contents = newContents;
        newMessages.add(newMessage);
      } else {
        newMessages?.add(message);
      }
      messageIndex++;
    }
    return newMessages ?? messages;
  }

  ChatOptions? processChatOptions(ChatOptions? options) {
    if (options?.tools == null || options.tools.count == 0) {
      return options;
    }
    var newTools = null;
    var tools = options.tools;
    for (var i = 0; i < tools.count; i++) {
      var tool = tools[i];
      if (tool is HostedImageGenerationTool) {
        final imageGenerationTool = tool as HostedImageGenerationTool;
        _imageGenerationOptions = imageGenerationTool.options;
        // for the first image generation tool, clone the options and insert our function tools
                    // remove any subsequent image generation tools
                    newTools ??= initializeTools(tools, i);
      } else {
        newTools?.add(tool);
      }
    }
    if (newTools != null) {
      var newOptions = options.clone();
      newOptions.tools = newTools;
      return newOptions;
    }
    return options;
    /* TODO: unsupported node kind "unknown" */
    // List<AITool> InitializeTools(IList<AITool> existingTools, int toOffsetExclusive)
    //             {
      // #if NET
      //                 ReadOnlySpan<AITool> tools =
      // #else
      //                 AITool[] tools =
      // #endif
      //                 [
      //                     AIFunctionFactory.Create(GenerateImageAsync),
      //                     AIFunctionFactory.Create(EditImageAsync),
      //                     AIFunctionFactory.Create(GetImagesForEdit)
      //                 ];
      //
      //                 foreach (var tool in tools)
      //                 {
        //                     _toolNames.Add(tool.Name);
        //                 }
      //
      //                 var result = CopyList(existingTools, toOffsetExclusive, tools.Length);
      //                 result.AddRange(tools);
      //                 return result;
      //             }
  }

  /// Replaces FunctionResultContent instances for image generation functions
  /// with actual generated image content. We will have two messages 1. Role:
  /// Assistant, FunctionCall 2. Role: Tool, FunctionResult We need to replace
  /// content from both but we shouldn't remove the messages. If we do not then
  /// ChatClient's may not accept our altered history. When interating with a
  /// HostedImageGenerationTool we will have typically only see a single Message
  /// with Role: Assistant that contains the DataContent (or a provider specific
  /// content, that's exposed as DataContent).
  ///
  /// [contents] The list of AI content to process.
  List<AContent> replaceImageGenerationFunctionResults(List<AContent> contents) {
    var newContents = null;
    for (var i = contents.count - 1; i >= 0; i--) {
      var content = contents[i];
      if (content is FunctionCallContent functionCall &&
                    _toolNames.contains(functionCall.name)) {
        // create a new list and omit the FunctionCallContent
                    newContents ??= copyList(contents, i);
        if (functionCall.name != nameof(GetImagesForEdit)) {
          newContents.add(imageGenerationToolCallContent(functionCall.callId));
        }
      } else {
        var imageContents;
        if (content is FunctionResultContent functionResult &&
                    _imageContentByCallId.tryGetValue(functionResult.callId)) {
          newContents ??= copyList(contents, i);
          if (imageContents.any()) {
            // Insert ImageGenerationToolResultContent in its place, do not preserve the FunctionResultContent
                        newContents.add(imageGenerationToolResultContent(functionResult.callId));
          }
          // Remove the mapping as it's no longer needed
                    _ = _imageContentByCallId.remove(functionResult.callId);
        } else {
          // keep the existing content if we have a new list
                    newContents?.add(content);
        }
      }
    }
    return newContents ?? contents;
  }

  Future<String> generateImage(String prompt, {CancellationToken? cancellationToken, }) async  {
    var callId = FunctionInvokingChatClient.currentContext?.callContent.callId;
    if (callId == null) {
      return "No call ID available for image generation.";
    }
    var request = imageGenerationRequest(prompt);
    var options = _imageGenerationOptions ?? imageGenerationOptions();
    options.count ??= 1;
    var response = await _imageGenerator.generateAsync(request, options, cancellationToken);
    if (response.contents.count == 0) {
      return "No image was generated.";
    }
    var imageIds = [];
    var imageContents = _imageContentByCallId[callId] = [];
    for (final content in response.contents) {
      if (content is DataContent imageContent && imageContent.mediaType.startsWith("image/", StringComparison.ordinalIgnoreCase)) {
        imageContents.add(imageContent);
        imageIds.add(storeImage(imageContent, true));
      }
    }
    return "Generated image successfully.";
  }

  Iterable<String> getImagesForEdit() {
    var callId = FunctionInvokingChatClient.currentContext?.callContent.callId;
    if (callId == null) {
      return ["No call ID available for image editing."];
    }
    _imageContentByCallId[callId] = [];
    return _imageContentById.keys.asEnumerable();
  }

  Future<String> editImage(
    String prompt,
    String imageId,
    {CancellationToken? cancellationToken, },
  ) async  {
    var callId = FunctionInvokingChatClient.currentContext?.callContent.callId;
    if (callId == null) {
      return "No call ID available for image editing.";
    }
    if (string.isNullOrEmpty(imageId)) {
      return "No imageId provided";
    }
    try {
      var originalImage = retrieveImageContent(imageId);
      if (originalImage == null) {
        return 'No image found with: ${imageId}';
      }
      var request = imageGenerationRequest(prompt, [originalImage]);
      var response = await _imageGenerator.generateAsync(
        request,
        _imageGenerationOptions,
        cancellationToken,
      );
      if (response.contents.count == 0) {
        return "No edited image was generated.";
      }
      var imageIds = [];
      var imageContents = _imageContentByCallId[callId] = [];
      for (final content in response.contents) {
        if (content is DataContent imageContent && imageContent.mediaType.startsWith("image/", StringComparison.ordinalIgnoreCase)) {
          imageContents.add(imageContent);
          imageIds.add(storeImage(imageContent, true));
        }
      }
      return "Edited image successfully.";
    } catch (e, s) {
      if (e is FormatException) {
        final  = e as FormatException;
        {
          return "Invalid image data format. Please provide a valid base64-encoded image.";
        }
      } else {
        rethrow;
      }
    }
  }

  static List<T> copyList<T>(List<T> original, int toOffsetExclusive, {int? additionalCapacity, }) {
    var newList = List<T>(original.count + additionalCapacity);
    for (var j = 0; j < toOffsetExclusive; j++) {
      newList.add(original[j]);
    }
    return newList;
  }

  DataContent? retrieveImageContent(String imageId) {
    var imageContent;
    if (_imageContentById.tryGetValue(imageId)) {
      return imageContent as DataContent;
    }
    return null;
  }

  String storeImage(DataContent imageContent, {bool? isGenerated, }) {
    var imageId = null;
    if (imageContent.additionalProperties?.tryGetValue(ImageKey, out imageId) is false || imageId == null) {
      imageId = imageContent.name ?? Guid.newGuid().toString();
    }
    if (isGenerated) {
      imageContent.additionalProperties ??= [];
      imageContent.additionalProperties[ImageKey] = imageId;
    }
    // Store the image content for later retrieval
            _imageContentById[imageId] = imageContent;
    return imageId;
  }
}
