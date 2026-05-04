import '../abstractions/contents/data_content.dart';
import '../abstractions/files/hosted_file_download_stream.dart';

/// A [HostedFileDownloadStream] implementation for OpenAI file downloads.
class OpenAFileDownloadStream extends HostedFileDownloadStream {
  /// Initializes a new instance of the [OpenAIFileDownloadStream] class.
  ///
  /// [data] The downloaded file data.
  ///
  /// [mediaType] The media type of the file.
  ///
  /// [fileName] The file name.
  const OpenAFileDownloadStream(
    BinaryData data,
    String? mediaType,
    String? fileName,
  ) :
      _data = data,
      _innerStream = data.toStream(),
      mediaType = mediaType,
      fileName = fileName;

  final BinaryData _data;

  final Stream _innerStream;

  final String? mediaType;

  final String? fileName;

  long position;

  @override
  Future<DataContent> toDataContent({CancellationToken? cancellationToken}) {
    if (_innerStream.position == 0) {
      return Task.fromResult(dataContent(_data.toMemory(), mediaType ?? "application/octet-stream")
            {
                Name = fileName,
            });
    }
    return base.toDataContentAsync(cancellationToken);
  }

  bool get canRead {
    return _innerStream.canRead;
  }

  bool get canSeek {
    return _innerStream.canSeek;
  }

  long get length {
    return _innerStream.length;
  }

  @override
  void flush() {
    _innerStream.flush();
  }

  @override
  Future flushAsync(CancellationToken cancellationToken) {
    return _innerStream.flushAsync(cancellationToken);
  }

  @override
  int readByte() {
    return _innerStream.readByte();
  }

  @override
  int read(List<int> buffer, int offset, int count, ) {
    return _innerStream.read(buffer, offset, count);
  }

  @override
  Future<int> readAsync(
    List<int> buffer,
    int offset,
    int count,
    CancellationToken cancellationToken,
  ) {
    return _innerStream.readAsync(buffer, offset, count, cancellationToken);
  }

  @override
  long seek(long offset, SeekOrigin origin, ) {
    return _innerStream.seek(offset, origin);
  }

  @override
  Future copyTo(Stream destination, int bufferSize, CancellationToken cancellationToken, ) {
    return _innerStream.copyToAsync(destination, bufferSize, cancellationToken);
  }

  @override
  void dispose(bool disposing) {
    if (disposing) {
      _innerStream.dispose();
    }
    base.dispose(disposing);
  }
}
