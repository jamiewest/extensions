import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

/// A fake [http.BaseClient] that returns a predetermined response body.
///
/// Mirrors [VerbatimHttpHandler] from the C# test suite.
///
/// When [expectedRequestBody] is provided the client asserts that the
/// outgoing request JSON matches it before returning [responseBody].
class VerbatimHttpClient extends http.BaseClient {
  VerbatimHttpClient(
    this.responseBody, {
    this.expectedRequestBody,
    this.statusCode = 200,
    this.contentType = 'application/json',
  });

  /// Optional JSON string the outgoing request body must equal.
  final String? expectedRequestBody;

  /// The body returned to the caller.
  final String responseBody;

  /// The HTTP status code to return.
  final int statusCode;

  /// The Content-Type header value to return.
  final String contentType;

  String? _capturedRequestBody;

  /// The request body that was sent (available after [send] is called).
  String? get capturedRequestBody => _capturedRequestBody;

  /// The last [http.BaseRequest] received.
  http.BaseRequest? lastRequest;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastRequest = request;

    if (request is http.Request) {
      _capturedRequestBody = request.body;
      if (expectedRequestBody != null) {
        expect(
          _normalizeJson(request.body),
          equals(_normalizeJson(expectedRequestBody!)),
        );
      }
    }

    final bytes = utf8.encode(responseBody);
    return http.StreamedResponse(
      Stream.value(bytes),
      statusCode,
      headers: {'content-type': contentType},
    );
  }
}

/// A fake [http.BaseClient] that returns a streaming SSE response.
///
/// Used for testing [OpenAIChatClient.getStreamingResponse].
class StreamingHttpClient extends http.BaseClient {
  StreamingHttpClient(this.sseLines);

  /// The SSE lines to emit, one per element.
  final List<String> sseLines;

  /// The last [http.BaseRequest] received.
  http.BaseRequest? lastRequest;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastRequest = request;
    final body = sseLines.map((l) => '$l\n').join();
    final bytes = utf8.encode(body);
    return http.StreamedResponse(
      Stream.value(bytes),
      200,
      headers: {'content-type': 'text/event-stream'},
    );
  }
}

/// A fake [http.BaseClient] that returns an error response.
class ErrorHttpClient extends http.BaseClient {
  ErrorHttpClient({this.statusCode = 500, this.body = '{"error":"test"}'});

  final int statusCode;
  final String body;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(
        Stream.value(utf8.encode(body)),
        statusCode,
        headers: {'content-type': 'application/json'},
      );
}

/// Normalises a JSON string for comparison by decoding and re-encoding.
String _normalizeJson(String json) {
  try {
    return jsonEncode(jsonDecode(json));
  } catch (_) {
    return json;
  }
}
