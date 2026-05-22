import 'package:http/http.dart' as http;

/// Configuration options for an OpenAI-compatible API client.
///
/// Pass an instance to any `OpenAI*` client constructor to customise the
/// endpoint (e.g. to point at an LM Studio local server) or to inject an
/// [http.Client] for testing.
class OpenAIClientOptions {
  /// Creates a new [OpenAIClientOptions].
  ///
  /// [endpoint] defaults to `https://api.openai.com/v1` when omitted.
  OpenAIClientOptions({Uri? endpoint, this.httpClient})
      : endpoint = endpoint ?? _defaultEndpoint;

  static final Uri _defaultEndpoint =
      Uri.parse('https://api.openai.com/v1');

  /// The base URI of the OpenAI-compatible API.
  ///
  /// Override this to target a local server, a proxy, or an alternative
  /// provider. For LM Studio use `Uri.parse('http://localhost:1234/v1')`.
  final Uri endpoint;

  /// An optional HTTP client to use for requests.
  ///
  /// Primarily useful for testing — inject a fake [http.Client] to avoid
  /// real network calls.
  final http.Client? httpClient;
}
