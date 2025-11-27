// ignore_for_file: avoid_print

import 'package:extensions/dependency_injection.dart';
import 'package:extensions/http.dart';
import 'package:extensions/logging.dart';
import 'package:extensions/system.dart';
import 'package:http/http.dart' as http;

/// Example demonstrating HTTP client factory with logging integration.
///
/// This example shows how to:
/// 1. Configure HTTP clients with automatic request/response logging
/// 2. Redact sensitive headers like Authorization
/// 3. Use named HTTP clients with different configurations
/// 4. Integrate with the Microsoft.Extensions.Logging pattern
void main() async {
  // Create service collection
  final services = ServiceCollection()

    // Add logging services
    ..addLogging((builder) {
      builder
        ..setMinimumLevel(LogLevel.debug)
        ..addSimpleConsole();
    })

    // Add HTTP client factory
    ..addHttpClient()

    // Add HTTP client logging filter
    ..addHttpClientLogging();

  // Configure a named HTTP client for GitHub API
  services.addHttpClient('GitHub').configureHttpClient((client, sp) {
    // Note: BaseClient doesn't have baseAddress, this is conceptual
    print('Configuring GitHub client');
  }).redactLoggedHeaderNames([
    'Authorization',
    'X-GitHub-Token'
  ]).setHandlerLifetime(const Duration(minutes: 5));

  // Configure a named HTTP client for weather API
  services.addHttpClient('WeatherApi').configureHttpClient((client, sp) {
    print('Configuring WeatherApi client');
  }).redactLoggedHeaders(
    (name) =>
        name.toLowerCase() == 'x-api-key' ||
        name.toLowerCase() == 'authorization',
  );

  // Build service provider
  final provider = services.buildServiceProvider();

  // Get HTTP client factory
  final factory = provider.getRequiredService<HttpClientFactory>();

  print('\n=== Example 1: GitHub API Request ===\n');
  await _makeGitHubRequest(factory);

  print('\n=== Example 2: Weather API Request ===\n');
  await _makeWeatherRequest(factory);

  print('\n=== Example 3: Default Client Request ===\n');
  await _makeDefaultRequest(factory);

  // Cleanup
  await (provider as AsyncDisposable).disposeAsync();
}

Future<void> _makeGitHubRequest(HttpClientFactory factory) async {
  final client = factory.createClient('GitHub');

  try {
    final request = http.Request(
      'GET',
      Uri.parse('https://api.github.com/users/octocat'),
    );

    request.headers.addAll({
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'Dart-HTTP-Example',
      // This would be redacted in logs
      'Authorization': 'Bearer super-secret-token-12345',
    });

    print('Sending GitHub API request...');
    final response = await client.send(request);

    print('Response status: ${response.statusCode}');
    print('Response headers: ${response.headers}');

    // Read response body
    final body = await response.stream.bytesToString();
    print('Response body length: ${body.length} bytes\n');
  } catch (e) {
    print('Request failed: $e');
  } finally {
    client.close();
  }
}

Future<void> _makeWeatherRequest(HttpClientFactory factory) async {
  final client = factory.createClient('WeatherApi');

  try {
    final uri = Uri.parse('https://api.open-meteo.com/v1/forecast').replace(
      queryParameters: {
        'latitude': '52.52',
        'longitude': '13.41',
        'current_weather': 'true',
      },
    );

    final request = http.Request('GET', uri);

    request.headers.addAll({
      // This would be redacted in logs
      'X-Api-Key': 'my-secret-api-key',
    });

    print('Sending Weather API request...');
    final response = await client.send(request);

    print('Response status: ${response.statusCode}');

    final body = await response.stream.bytesToString();
    print('Response body length: ${body.length} bytes\n');
  } catch (e) {
    print('Request failed: $e');
  } finally {
    client.close();
  }
}

Future<void> _makeDefaultRequest(HttpClientFactory factory) async {
  final client = factory.createClient();

  try {
    final request = http.Request(
      'GET',
      Uri.parse('https://httpbin.org/headers'),
    );

    request.headers.addAll({
      'User-Agent': 'Dart-HTTP-Example',
      'Custom-Header': 'custom-value',
    });

    print('Sending request to httpbin...');
    final response = await client.send(request);

    print('Response status: ${response.statusCode}');

    final body = await response.stream.bytesToString();
    final previewLength = body.length > 100 ? 100 : body.length;
    print('Response body preview: ${body.substring(0, previewLength)}...\n');
  } catch (e) {
    print('Request failed: $e');
  } finally {
    client.close();
  }
}
