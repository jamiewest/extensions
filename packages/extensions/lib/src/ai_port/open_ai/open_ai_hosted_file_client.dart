import '../abstractions/contents/hosted_file_content.dart';
import '../abstractions/files/hosted_file_client.dart';
import '../abstractions/files/hosted_file_client_metadata.dart';
import '../abstractions/files/hosted_file_client_options.dart';
import '../abstractions/files/hosted_file_download_stream.dart';
import 'open_ai_file_download_stream.dart';

/// An [HostedFileClient] implementation for OpenAI file operations.
///
/// Remarks: This client supports both the standard Files API and
/// container-scoped files (used for code interpreter outputs). When a [Scope]
/// (container ID) is specified on a per-call options object or as the default
/// scope at construction time, operations target that container. Otherwise,
/// operations use the standard Files API. Depending on how this client is
/// constructed, it may support only file operations, only container
/// operations, or both. If an operation requires a client that was not
/// provided, an [InvalidOperationException] is thrown.
class OpenAHostedFileClient implements HostedFileClient {
  /// Initializes a new instance of the [OpenAIHostedFileClient] class from an
  /// [OpenAIClient].
  ///
  /// [openAIClient] The underlying [OpenAIClient].
  OpenAHostedFileClient({OpenAClient? openAIClient = null, OpenAFileClient? fileClient = null, ContainerClient? containerClient = null, String? defaultScope = null, }) : _fileClient = openAIClient.getOpenAIFileClient(), _containerClient = openAIClient.getContainerClient(), _metadata = hostedFileClientMetadata("openai", _fileClient.endpoint) {
    _ = Throw.ifNull(openAIClient);
  }

  /// The underlying [OpenAIFileClient] for standard file operations, or `null`
  /// if not available.
  final OpenAFileClient? _fileClient;

  /// The underlying [ContainerClient] for container file operations, or `null`
  /// if not available.
  final ContainerClient? _containerClient;

  /// The default scope (container ID) for operations, or `null` if not set.
  final String? _defaultScope;

  /// The metadata for this client.
  final HostedFileClientMetadata _metadata;

  @override
  Future<HostedFileContent> upload(
    Stream content,
    {String? mediaType, String? fileName, HostedFileClientOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNull(content);
    fileName ??= content is FileStream fs ? Path.getFileName(fs.name) : null;
    mediaType ??= fileName != null ? MediaTypeMap.getMediaType(fileName) : null;
    fileName ??= '${Guid.newGuid():N}${MediaTypeMap.getExtension(mediaType)}';
    if (resolveScope(options) is string) {
      final containerId = resolveScope(options) as string;
      mediaType ??= "application/octet-stream";
      var multipart = new();
      var fileContent = new(content);
      fileContent.headers.contentType = mediaTypeHeaderValue(mediaType);
      multipart.add(fileContent, "file", fileName);
      var binaryContent = httpContentBinaryContent(multipart);
      var requestOptions = options?.rawRepresentationFactory?.invoke(this) as RequestOptions ?? new();
      requestOptions.cancellationToken = cancellationToken;
      var result = await getContainerClient().createContainerFileAsync(
                containerId,
                binaryContent,
                multipart.headers.contentType!.toString(),
                requestOptions).configureAwait(false);
      var responseDoc = JsonDocument.parse(result.getRawResponse().content);
      return parseContainerFileJson(responseDoc.rootElement, containerId)
                ?? throw invalidOperationException("The container file upload response did not include a valid file ID.");
    } else {
      var purpose = options?.purpose == null ? FileUploadPurpose.userData :
                string.equals(
                  "assistants",
                  options.purpose,
                  StringComparison.ordinalIgnoreCase,
                ) ? FileUploadPurpose.assistants :
                string.equals(
                  "batch",
                  options.purpose,
                  StringComparison.ordinalIgnoreCase,
                ) ? FileUploadPurpose.batch :
                string.equals(
                  "evaluations",
                  options.purpose,
                  StringComparison.ordinalIgnoreCase,
                ) ? FileUploadPurpose.evaluations :
                string.equals(
                  "fine-tune",
                  options.purpose,
                  StringComparison.ordinalIgnoreCase,
                ) ? FileUploadPurpose.fineTune :
                string.equals(
                  "user_data",
                  options.purpose,
                  StringComparison.ordinalIgnoreCase,
                ) ? FileUploadPurpose.userData :
                string.equals(
                  "vision",
                  options.purpose,
                  StringComparison.ordinalIgnoreCase,
                ) ? FileUploadPurpose.vision :
                fileUploadPurpose(options.purpose);
      var result = await getFileClient().uploadFileAsync(content, fileName, purpose, cancellationToken).configureAwait(false);
      return toHostedFileContent(result.value);
    }
  }

  @override
  Future<HostedFileDownloadStream> download(
    String fileId,
    {HostedFileClientOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNullOrWhitespace(fileId);
    if (resolveScope(options) is string) {
      final containerId = resolveScope(options) as string;
      var containerClient = getContainerClient();
      var containerResult = await containerClient.downloadContainerFileAsync(
        containerId,
        fileId,
        cancellationToken,
      ) .configureAwait(false);
      var containerFileInfoResult = await containerClient.getContainerFileAsync(
                containerId, fileId, requestOptions()).configureAwait(false);
      var infoDoc = JsonDocument.parse(containerFileInfoResult.getRawResponse().content);
      var path = infoDoc.rootElement.tryGetProperty(
        "path",
        out var pathProp,
      ) ? pathProp.getString() : null;
      var containerFileName = path != null ? Path.getFileName(path) : fileId;
      var containerMediaType = MediaTypeMap.getMediaType(containerFileName) ?? "application/octet-stream";
      return openAFileDownloadStream(containerResult.value, containerMediaType, containerFileName);
    } else {
      var fileClient = getFileClient();
      var result = await fileClient.downloadFileAsync(
        fileId,
        cancellationToken,
      ) .configureAwait(false);
      var fileInfo = await fileClient.getFileAsync(fileId, cancellationToken).configureAwait(false);
      var mediaType = MediaTypeMap.getMediaType(fileInfo.value.filename) ?? "application/octet-stream";
      return openAFileDownloadStream(result.value, mediaType, fileInfo.value.filename);
    }
  }

  @override
  Future<HostedFileContent?> getFileInfo(
    String fileId,
    {HostedFileClientOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNullOrWhitespace(fileId);
    try {
      if (resolveScope(options) is string) {
        final containerId = resolveScope(options) as string;
        var containerResult = await getContainerClient().getContainerFileAsync(
                    containerId, fileId, requestOptions()).configureAwait(false);
        var doc = JsonDocument.parse(containerResult.getRawResponse().content);
        return parseContainerFileJson(doc.rootElement, containerId);
      } else {
        var result = await getFileClient().getFileAsync(fileId, cancellationToken).configureAwait(false);
        return toHostedFileContent(result.value);
      }
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {
          return null;
        }
      } else {
        rethrow;
      }
    }
  }

  @override
  Stream<HostedFileContent> listFiles({HostedFileClientOptions? options, CancellationToken? cancellationToken, }) async  {
    var limit = options?.limit ?? int.maxValue;
    if (resolveScope(options) is string) {
      final containerId = resolveScope(options) as string;
      var containerClient = getContainerClient();
      var count = 0;
      var after = null;
      while (true) {
        var result = containerClient.getContainerFilesAsync(
                    containerId, limit < int.maxValue ? limit : null,
                    null, after, new() { CancellationToken = cancellationToken });
        var pages = result.getRawPagesAsync().getAsyncEnumerator(cancellationToken);
        JsonDocument doc;
        try {
          if (!await pages.moveNextAsync().configureAwait(false)) {
            break;
          }
          doc = JsonDocument.parse(pages.current.getRawResponse().content);
        } finally {
          await pages.disposeAsync().configureAwait(false);
        }
        try {
          var root = doc.rootElement;
          if (root.tryGetProperty("data", out JsonElement data) && data.valueKind is JsonValueKind.array) {
            for (final fileElement in data.enumerateArray()) {
              if (count >= limit) {
                return;
              }
              var file = parseContainerFileJson(fileElement, containerId);
              if (file == null) {
                continue;
              }
              yield file;
              count++;
            }
          }
          var hasMore = root.tryGetProperty(
            "has_more",
            out var hm,
          ) && hm.valueKind is JsonValueKind.trueValue;
          var lastId = root.tryGetProperty("last_id", out var li) ? li.getString() : null;
          if (!hasMore || string.isNullOrEmpty(lastId)) {
            break;
          }
          after = lastId;
        } finally {
          doc.dispose();
        }
      }
    } else {
      var purpose = options?.purpose == null ? FilePurpose.userData :
                string.equals(
                  "assistants",
                  options.purpose,
                  StringComparison.ordinalIgnoreCase,
                ) ? FilePurpose.assistants :
                string.equals(
                  "assistants_output",
                  options.purpose,
                  StringComparison.ordinalIgnoreCase,
                ) ? FilePurpose.assistantsOutput :
                string.equals(
                  "batch",
                  options.purpose,
                  StringComparison.ordinalIgnoreCase,
                ) ? FilePurpose.batch :
                string.equals(
                  "batch_output",
                  options.purpose,
                  StringComparison.ordinalIgnoreCase,
                ) ? FilePurpose.batchOutput :
                string.equals(
                  "fine-tune",
                  options.purpose,
                  StringComparison.ordinalIgnoreCase,
                ) ? FilePurpose.fineTune :
                string.equals(
                  "fine-tune-results",
                  options.purpose,
                  StringComparison.ordinalIgnoreCase,
                ) ? FilePurpose.fineTuneResults :
                string.equals(
                  "vision",
                  options.purpose,
                  StringComparison.ordinalIgnoreCase,
                ) ? FilePurpose.vision :
                string.equals(
                  "evaluations",
                  options.purpose,
                  StringComparison.ordinalIgnoreCase,
                ) ? FilePurpose.evaluations :
                FilePurpose.userData;
      var fileClient = getFileClient();
      var result = await (purpose is FilePurpose p ?
                fileClient.getFilesAsync(p, cancellationToken) :
                fileClient.getFilesAsync(cancellationToken)).configureAwait(false);
      var count = 0;
      for (final file in result.value) {
        if (count >= limit) {
          return;
        }
        yield toHostedFileContent(file);
        count++;
      }
    }
  }

  @override
  Future<bool> delete(
    String fileId,
    {HostedFileClientOptions? options, CancellationToken? cancellationToken, },
  ) async  {
    _ = Throw.ifNullOrWhitespace(fileId);
    try {
      if (resolveScope(options) is string) {
        final containerId = resolveScope(options) as string;
        await getContainerClient().deleteContainerFileAsync(containerId, fileId, cancellationToken).configureAwait(false);
        return true;
      } else {
        var result = await getFileClient().deleteFileAsync(fileId, cancellationToken).configureAwait(false);
        return result.value.deleted;
      }
    } catch (e, s) {
      if (e is Exception) {
        final ex = e as Exception;
        {
          return false;
        }
      } else {
        rethrow;
      }
    }
  }

  @override
  Object? getService(Type serviceType, {Object? serviceKey, }) {
    _ = Throw.ifNull(serviceType);
    return serviceKey != null ? null :
            serviceType == typeof(HostedFileClientMetadata) ? _metadata :
            serviceType == typeof(OpenAIFileClient) ? _fileClient :
            serviceType == typeof(ContainerClient) ? _containerClient :
            serviceType.isInstanceOfType(this) ? this :
            null;
  }

  @override
  void dispose() {

  }

  static HostedFileContent toHostedFileContent(OpenAFile openAIFile) {
    return new(openAIFile.id)
        {
            Name = openAIFile.filename,
            SizeInBytes = openAIFile.sizeInBytes,
            CreatedAt = openAIFile.createdAt,
            Purpose = openAIFile.purpose.toString(),
            MediaType = MediaTypeMap.getMediaType(openAIFile.filename),
            RawRepresentation = openAIFile,
        };
  }

  /// Parses container file metadata from a JSON element into a
  /// [HostedFileContent].
  ///
  /// Remarks: This parses raw JSON rather than using the OpenAI SDK's typed
  /// deserialization, as a workaround for , where the SDK crashes deserializing
  /// container files when the "bytes" field is null. Once the SDK issue is
  /// fixed, call sites should revert to using the typed API.
  static HostedFileContent? parseContainerFileJson(JsonElement element, String? scope, ) {
    var idProp;
    if (!element.tryGetProperty("id") || idProp.getString() is not { } id) {
      return null;
    }
    var path = element.tryGetProperty("path", out var pathProp) ? pathProp.getString() : null;
    var name = path != null ? Path.getFileName(path) : id;
    var sizeInBytes = element.tryGetProperty(
      "bytes",
      out var bytesProp,
    ) && bytesProp.valueKind is JsonValueKind.number
            ? bytesProp.getInt64()
            : null;
    var createdAt = element.tryGetProperty(
      "created_at",
      out var createdProp,
    ) && createdProp.valueKind is JsonValueKind.number
            ? DateTimeOffset.fromUnixTimeSeconds(createdProp.getInt64())
            : null;
    return hostedFileContent(id);
  }

  static bool isNotFoundError(Exception ex) {
    return ex is ClientResultException { Status: 404 };
  }

  OpenAFileClient getFileClient() {
    return _fileClient ??
        throw invalidOperationException(
            'This operation requires the standard Files API, but this client was not constructed with an ${nameof(OpenAIFileClient)}. ' +
            'Use an ${nameof(IHostedFileClient)} created from an ${nameof(OpenAIClient)} or ${nameof(OpenAIFileClient)}, or set the Scope option to target a container instead.');
  }

  ContainerClient getContainerClient() {
    return _containerClient ??
        throw invalidOperationException(
            'This operation requires a container (Scope was specified), but this client was not constructed with a ${nameof(ContainerClient)}. ' +
            'Use an ${nameof(IHostedFileClient)} created from an ${nameof(OpenAIClient)} or ${nameof(ContainerClient)} to access container files.');
  }

  /// Resolves the scope (container ID) from per-call options or the default.
  String? resolveScope(HostedFileClientOptions? options) {
    return options?.scope ?? _defaultScope;
  }
}
/// A [BinaryContent] that writes an [HttpContent] directly to the output
/// stream.
class HttpContentBinaryContent extends BinaryContent {
  /// A [BinaryContent] that writes an [HttpContent] directly to the output
  /// stream.
  const HttpContentBinaryContent(HttpContent httpContent);

  @override
  void writeTo(Stream stream, {CancellationToken? cancellationToken, }) {
    #if NET
            httpContent.copyTo(stream, null, cancellationToken);
    #else
    #pragma warning disable VSTHRD002 // Synchronously waiting - no sync CopyTo on older TFMs
            httpContent.copyToAsync(stream).getAwaiter().getResult();
  }

  @override
  Future writeToAsync(Stream stream, {CancellationToken? cancellationToken, }) {
    return #if NET
            httpContent.copyToAsync(stream, cancellationToken);
    #else
            httpContent.copyToAsync(stream);
  }

  @override (bool, long?)
  tryComputeLength() {
    return (length >= 0, httpContent.headers.contentLength.getValueOrDefault(-1));
  }

  @override
  void dispose() {

  }
}
/// A [StreamContent] that does not dispose the underlying stream.
class NonDisposingStreamContent extends StreamContent {
  /// A [StreamContent] that does not dispose the underlying stream.
  const NonDisposingStreamContent(Stream stream);

  @override
  void dispose(bool disposing) {

  }
}
