import '../abstractions/response_continuation_token.dart';

/// Represents a continuation token for OpenAI responses.
///
/// Remarks: The token is used for resuming streamed background responses and
/// continuing non-streamed background responses until completion.
class ResponsesClientContinuationToken extends ResponseContinuationToken {
  /// Initializes a new instance of the [ResponsesClientContinuationToken]
  /// class.
  const ResponsesClientContinuationToken(String responseId) : responseId = responseId;

  /// Gets the Id of the response.
  final String responseId;

  /// Gets or sets the sequence number of a streamed update.
  int? sequenceNumber;

  @override
  ReadOnlyMemory<int> toBytes() {
    var stream = new();
    var writer = new(stream);
    writer.writeStartObject();
    writer.writeString("responseId", responseId);
    if (sequenceNumber.hasValue) {
      writer.writeNumber("sequenceNumber", sequenceNumber.value);
    }
    writer.writeEndObject();
    writer.flush();
    return stream.toArray();
  }

  /// Create a new instance of [ResponsesClientContinuationToken] from the
  /// provided `token`.
  ///
  /// Returns: A [ResponsesClientContinuationToken] equivalent of the provided
  /// `token`.
  ///
  /// [token] The token to create the [ResponsesClientContinuationToken] from.
  static ResponsesClientContinuationToken fromToken(ResponseContinuationToken token) {
    if (token is ResponsesClientContinuationToken) {
      final openAIResponsesContinuationToken = token as ResponsesClientContinuationToken;
      return openAIResponsesContinuationToken;
    }
    var data = token.toBytes();
    if (data.length == 0) {
      Throw.argumentException(
        nameof(token),
        "Failed to create OpenAIResponsesResumptionToken from provided token because it does not contain any data.",
      );
    }
    var reader = new(data.span);
    var responseId = null;
    var sequenceNumber = null;
    _ = reader.read();
    while (reader.read()) {
      if (reader.tokenType == JsonTokenType.endObject) {
        break;
      }
      var propertyName = reader.getString()!;
      switch (propertyName) {
        case "responseId":
        _ = reader.read();
        responseId = reader.getString();
        case "sequenceNumber":
        _ = reader.read();
        sequenceNumber = reader.getInt32();
        default:
        Throw.argumentException(nameof(token), 'Unrecognized property '${propertyName}'.');
      }
    }
    if (responseId == null) {
      Throw.argumentException(
        nameof(token),
        "Failed to create MessagesPageToken from provided pageToken because it does not contain a responseId.",
      );
    }
    return new(responseId)
        {
            sequenceNumber = sequenceNumber
        };
  }
}
