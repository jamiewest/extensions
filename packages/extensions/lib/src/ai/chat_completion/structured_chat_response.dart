import 'dart:convert';

import 'package:extensions/annotations.dart';

import '../../system/exceptions/invalid_operation_exception.dart';
import 'chat_response.dart';

/// Deserializes a JSON value (as produced by `jsonDecode`) into a [T].
typedef StructuredResultFromJson<T> = T Function(Object? json);

/// Represents the response to a chat request with structured output.
///
/// Language models are not guaranteed to honor the requested schema. If the
/// model's output is not parseable, [tryGetResult] returns `null`; the raw
/// JSON remains available via [ChatResponse.text].
///
/// Because the port performs no runtime reflection, deserialization is
/// driven by the [StructuredResultFromJson] callback supplied at creation.
@Source(
  name: 'ChatResponse{T}.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/ChatCompletion/',
)
class StructuredChatResponse<T> extends ChatResponse {
  final StructuredResultFromJson<T> _fromJson;
  final bool _isWrappedInObject;

  T? _deserializedResult;
  bool _hasDeserializedResult = false;

  /// Creates a structured view over [response].
  ///
  /// [wrappedInObject] indicates the schema was wrapped in an object with a
  /// single `data` property, which is required for non-object root schemas.
  StructuredChatResponse(
    ChatResponse response, {
    required this._fromJson,
    bool wrappedInObject = false,
  }) : _isWrappedInObject = wrappedInObject,
       super(
         messages: response.messages,
         responseId: response.responseId,
         conversationId: response.conversationId,
         modelId: response.modelId,
         createdAt: response.createdAt,
         finishReason: response.finishReason,
         usage: response.usage,
         continuationToken: response.continuationToken,
         rawRepresentation: response.rawRepresentation,
         additionalProperties: response.additionalProperties,
       );

  /// The result value of the chat response as an instance of [T].
  ///
  /// Throws [InvalidOperationException] when the response contains no JSON
  /// or the expected wrapper property is missing, and propagates any error
  /// thrown while decoding or converting. Use [tryGetResult] to avoid
  /// exceptions.
  T get result => _getResultCore();

  /// Attempts to deserialize the result, returning `null` on any failure.
  T? tryGetResult() {
    try {
      return _getResultCore();
    } catch (_) {
      return null;
    }
  }

  T _getResultCore() {
    if (_hasDeserializedResult) {
      return _deserializedResult as T;
    }

    final json = messages.isNotEmpty ? messages.last.text : '';
    if (json.isEmpty) {
      throw InvalidOperationException(
        message: 'The response did not contain JSON to be deserialized.',
      );
    }

    var decoded = _decodeFirstTopLevelValue(json);

    if (_isWrappedInObject) {
      if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
        decoded = decoded['data'];
      } else {
        throw InvalidOperationException(
          message:
              'The response did not contain the expected '
              "'data' property.",
        );
      }
    }

    final deserialized = _fromJson(decoded);
    _deserializedResult = deserialized;
    _hasDeserializedResult = true;
    return deserialized;
  }

  /// Decodes the first top-level JSON value in [json].
  ///
  /// Some model backends occasionally emit multiple top-level JSON values
  /// after a function call, so trailing content after the first complete
  /// value is ignored.
  static Object? _decodeFirstTopLevelValue(String json) {
    try {
      return jsonDecode(json);
    } on FormatException {
      final end = _endOfFirstValue(json);
      if (end == null) {
        rethrow;
      }
      return jsonDecode(json.substring(0, end));
    }
  }

  static int? _endOfFirstValue(String json) {
    var depth = 0;
    var inString = false;
    var escaped = false;
    for (var i = 0; i < json.length; i++) {
      final char = json[i];
      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (char == r'\') {
          escaped = true;
        } else if (char == '"') {
          inString = false;
        }
        continue;
      }
      switch (char) {
        case '"':
          inString = true;
        case '{' || '[':
          depth++;
        case '}' || ']':
          depth--;
          if (depth == 0) {
            return i + 1;
          }
      }
    }
    return null;
  }
}
