import '../contents/data_content.dart';

/// Represents a stream for downloading file content from an AI service.
///
/// Remarks: This abstract class extends [Stream] to provide additional
/// metadata about the downloaded file, such as its media type and file name.
/// Implementations should override the abstract [Stream] members and
/// optionally override [MediaType] and [FileName] to provide file metadata.
/// The [CancellationToken)] method provides a convenient way to buffer the
/// entire stream content into a [DataContent] instance.
abstract class HostedFileDownloadStream extends Stream {
  /// Initializes a new instance of the [HostedFileDownloadStream] class.
  const HostedFileDownloadStream();

  /// Gets the media type (MIME type) of the file content.
  ///
  /// Remarks: Returns `null` if the media type is not known.
  String? get mediaType {
    return null;
  }

  /// Gets the file name.
  ///
  /// Remarks: Returns `null` if the file name is not known.
  String? get fileName {
    return null;
  }

  bool get canWrite {
    return false;
  }

  @override
  void setLength(long value) {
    throw notSupportedException();
  }

  @override
  AsyncResult beginWrite(
    List<int> buffer,
    int offset,
    int count,
    AsyncCallback? callback,
    Object? state,
  ) {
    return throw notSupportedException();
  }

  @override
  void endWrite(AsyncResult asyncResult) {
    throw notSupportedException();
  }

  @override
  void writeByte(int value) {
    throw notSupportedException();
  }

  @override
  void write(List<int> buffer, int offset, int count, ) {
    throw notSupportedException();
  }

  @override
  Future writeAsync(
    List<int> buffer,
    int offset,
    int count,
    CancellationToken cancellationToken,
  ) {
    return throw notSupportedException();
  }

  /// Reads the entire stream content from its current position and returns it
  /// as a [DataContent].
  ///
  /// Remarks: This method buffers the entire stream content into memory. For
  /// large files, consider streaming directly to the destination instead.
  ///
  /// Returns: A [DataContent] containing the buffered file content.
  ///
  /// [cancellationToken] The [CancellationToken] to monitor for cancellation
  /// requests.
  Future<DataContent> toDataContent({CancellationToken? cancellationToken}) async  {
    var memoryStream = new();
    await copyToAsync(memoryStream,
    #if !NET
            81920,
    #endif
            cancellationToken).configureAwait(false);
    return dataContent(
            memoryStream.getBuffer().asMemory(0, (int)memoryStream.length),
            mediaType ?? "application/octet-stream")
        {
            Name = fileName,
        };
  }
}
