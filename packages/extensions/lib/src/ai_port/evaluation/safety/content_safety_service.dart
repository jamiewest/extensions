import '../boolean_metric.dart';
import '../evaluation_result.dart';
import '../numeric_metric.dart';
import '../string_metric.dart';
import 'content_safety_service_configuration.dart';
import 'content_safety_service_url_cache_key.dart';

class ContentSafetyService {
  ContentSafetyService(ContentSafetyServiceConfiguration serviceConfiguration);

  static final ConcurrentDictionary<UrlCacheKey, String> _serviceUrlCache = ConcurrentDictionary<UrlCacheKey, string>();

  final HttpClient _httpClient = serviceConfiguration.HttpClient ?? SharedHttpClient;

  String? _serviceUrl;

  static HttpClient get sharedHttpClient {
    return field ??
        Interlocked.compareExchange(ref field, new(), null) ??
        field;
  }

  static EvaluationResult parseAnnotationResult(String annotationResponse) {
    var result = evaluationResult();
    var annotationResponseDocument = JsonDocument.parse(annotationResponse);
    var metricElement = annotationResponseDocument.rootElement.enumerateArray().last();
    for (final metricProperty in metricElement.enumerateObject()) {
      var metricName = metricProperty.name;
      var metricDetails = metricProperty.value.getString()!;
      var metricDetailsDocument = JsonDocument.parse(metricDetails);
      var metricDetailsRootElement = metricDetailsDocument.rootElement;
      var labelElement = metricDetailsRootElement.getProperty("label");
      var reason = metricDetailsRootElement.getProperty("reasoning").getString();
      EvaluationMetric metric;
      switch (labelElement.valueKind) {
        case JsonValueKind.number:
        var doubleValue = labelElement.getDouble();
        metric = numericMetric(metricName, doubleValue, reason);
        case JsonValueKind.trueValue || JsonValueKind.falseValue:
        var booleanValue = labelElement.getBoolean();
        metric = booleanMetric(metricName, booleanValue, reason);
        case JsonValueKind.string:
        var stringValue = labelElement.getString()!;
        if (double.tryParse(stringValue, out doubleValue)) {
          metric = numericMetric(metricName, doubleValue, reason);
        } else if (bool.tryParse(stringValue, out booleanValue)) {
          metric = booleanMetric(metricName, booleanValue, reason);
        } else {
          metric = stringMetric(metricName, stringValue, reason);
        }
        default:
        metric = stringMetric(metricName, labelElement.toString(), reason);
      }
      for (final property in metricDetailsRootElement.enumerateObject()) {
        if (property.name != "label" && property.name != "reasoning") {
          metric.addOrUpdateMetadata(property.name, property.value.toString());
        }
      }
      result.metrics.add(metric.name, metric);
    }
    return result;
  }

  Future<String> annotate(
    String payload,
    String annotationTask,
    String evaluatorName,
    {CancellationToken? cancellationToken, },
  ) async  {
    var serviceUrl = await getServiceUrlAsync(
      annotationTask,
      evaluatorName,
      cancellationToken,
    ) .configureAwait(false);
    var resultUrl = await submitAnnotationRequestAsync(
                serviceUrl,
                payload,
                evaluatorName,
                cancellationToken).configureAwait(false);
    var annotationResult = await fetchAnnotationResultAsync(
                resultUrl,
                evaluatorName,
                cancellationToken).configureAwait(false);
    return annotationResult;
  }

  Future<String> getServiceUrl(
    String annotationTask,
    String evaluatorName,
    CancellationToken cancellationToken,
  ) async  {
    if (_serviceUrl != null) {
      return _serviceUrl;
    }
    var key = urlCacheKey(serviceConfiguration, annotationTask);
    String? serviceUrl;
    if (_serviceUrlCache.tryGetValue(key)) {
      _serviceUrl = serviceUrl;
      return _serviceUrl;
    }
    if (serviceConfiguration.isHubBasedProject) {
      var discoveryUrl = await getServiceDiscoveryUrlAsync(
        evaluatorName,
        cancellationToken,
      ) .configureAwait(false);
      serviceUrl =
                '${discoveryUrl}/raisvc/v1.0' +
                '/subscriptions/${serviceConfiguration.subscriptionId}' +
                '/resourceGroups/${serviceConfiguration.resourceGroupName}' +
                '/providers/Microsoft.machineLearningServices/workspaces/${serviceConfiguration.projectName}';
    } else {
      serviceUrl = '${serviceConfiguration.endpoint.absoluteUri}/evaluations';
    }
    await ensureServiceAvailabilityAsync(
                serviceUrl,
                capability: annotationTask,
                evaluatorName,
                cancellationToken).configureAwait(false);
    _ = _serviceUrlCache.tryAdd(key, serviceUrl);
    _serviceUrl = serviceUrl;
    return _serviceUrl;
  }

  Future<String> getServiceDiscoveryUrl(
    String evaluatorName,
    CancellationToken cancellationToken,
  ) async  {
    var resourceManagerUrl = 'https://management.azure.com/subscriptions/${serviceConfiguration.subscriptionId}' +
            '/resourceGroups/${serviceConfiguration.resourceGroupName}' +
            '/providers/Microsoft.machineLearningServices/workspaces/${serviceConfiguration.projectName}' +
            '${APIVersionForServiceDiscoveryInHubBasedProjects}';
    var response = await getResponseAsync(
                resourceManagerUrl,
                evaluatorName,
                cancellationToken: cancellationToken).configureAwait(false);
    if (!response.isSuccessStatusCode) {
      throw invalidOperationException(
                ''"
                {evaluatorName} failed to retrieve discovery URL for Azure AI Foundry Evaluation service.
                {response.statusCode} ({(int)response.statusCode}): {response.reasonPhrase}.
                To troubleshoot, see https://aka.ms/azsdk/python/evaluation/safetyevaluator/troubleshoot.
                """);
    }
    var responseContent = #if NET
            await response.content.readAsStringAsync(cancellationToken).configureAwait(false);
    #else
            await response.content.readAsStringAsync().configureAwait(false);
    var document = JsonDocument.parse(responseContent);
    var discoveryUrl = document.rootElement.getProperty("properties").getProperty("discoveryUrl").getString();
    if (string.isNullOrWhiteSpace(discoveryUrl)) {
      throw invalidOperationException(
                ''"
                {evaluatorName} failed to retrieve discovery URL from the Azure AI Foundry Evaluation service's response below.
                To troubleshoot, see https://aka.ms/azsdk/python/evaluation/safetyevaluator/troubleshoot.

                {responseContent}
                """);
    }
    var discoveryUri = uri(discoveryUrl);
    return '${discoveryUri.scheme}://${discoveryUri.host}';
  }

  Future ensureServiceAvailability(
    String serviceUrl,
    String capability,
    String evaluatorName,
    CancellationToken cancellationToken,
  ) async  {
    var serviceAvailabilityUrl = serviceConfiguration.isHubBasedProject
                ? '${serviceUrl}/checkannotation'
                : '${serviceUrl}/checkannotation${APIVersionForNonHubBasedProjects}';
    var response = await getResponseAsync(
                serviceAvailabilityUrl,
                evaluatorName,
                cancellationToken: cancellationToken).configureAwait(false);
    if (!response.isSuccessStatusCode) {
      throw invalidOperationException(
                ''"
                {evaluatorName} failed to check service availability for the Azure AI Foundry Evaluation service.
                The service is either unavailable in this region, or you lack the necessary permissions to access the AI project.
                {response.statusCode} ({(int)response.statusCode}): {response.reasonPhrase}.
                To troubleshoot, see https://aka.ms/azsdk/python/evaluation/safetyevaluator/troubleshoot.
                """);
    }
    var responseContent = #if NET
            await response.content.readAsStringAsync(cancellationToken).configureAwait(false);
    #else
            await response.content.readAsStringAsync().configureAwait(false);
    var document = JsonDocument.parse(responseContent);
    for (final element in document.rootElement.enumerateArray()) {
      var supportedCapability = element.getString();
      if (!string.isNullOrWhiteSpace(supportedCapability) &&
                string.equals(supportedCapability, capability, StringComparison.ordinal)) {
        return;
      }
    }
    throw invalidOperationException(
            ''"
            The required {nameof(capability)} '{capability}' required for {evaluatorName} is! supported by the Azure AI Foundry Evaluation service in this region.
            To troubleshoot, see https://aka.ms/azsdk/python/evaluation/safetyevaluator/troubleshoot.

            The following response identifies the capabilities that are supported:
            {responseContent}
            """);
  }

  Future<String> submitAnnotationRequest(
    String serviceUrl,
    String payload,
    String evaluatorName,
    CancellationToken cancellationToken,
  ) async  {
    var annotationUrl = serviceConfiguration.isHubBasedProject
                ? '${serviceUrl}/submitannotation'
                : '${serviceUrl}/submitannotation${APIVersionForNonHubBasedProjects}';
    var response = await getResponseAsync(
                annotationUrl,
                evaluatorName,
                requestMethod: HttpMethod.post,
                payload,
                cancellationToken).configureAwait(false);
    if (!response.isSuccessStatusCode) {
      throw invalidOperationException(
                ''"
                {evaluatorName} failed to submit annotation request to the Azure AI Foundry Evaluation service.
                {response.statusCode} ({(int)response.statusCode}): {response.reasonPhrase}.
                To troubleshoot, see https://aka.ms/azsdk/python/evaluation/safetyevaluator/troubleshoot.
                """);
    }
    var responseContent = #if NET
            await response.content.readAsStringAsync(cancellationToken).configureAwait(false);
    #else
            await response.content.readAsStringAsync().configureAwait(false);
    var document = JsonDocument.parse(responseContent);
    var resultUrl = document.rootElement.getProperty("location").getString();
    if (string.isNullOrWhiteSpace(resultUrl)) {
      throw invalidOperationException(
                ''"
                {evaluatorName} failed to retrieve the result location from the following response for the annotation request submitted to The Azure AI Foundry Evaluation service.

                {responseContent}
                """);
    }
    return resultUrl!;
  }

  Future<String> fetchAnnotationResult(
    String resultUrl,
    String evaluatorName,
    CancellationToken cancellationToken,
  ) async  {
    var InitialDelayInMilliseconds = 500;
    var attempts = 0;
    HttpResponseMessage response;
    var stopwatch = Stopwatch.startNew();
    try {
      do {
        ++attempts;
        response =
                    await getResponseAsync(
                        resultUrl,
                        evaluatorName,
                        cancellationToken: cancellationToken).configureAwait(false);
        if (response.statusCode != HttpStatusCode.ok) {
          var elapsedDuration = stopwatch.elapsed;
          if (elapsedDuration.totalSeconds >= serviceConfiguration.timeoutInSecondsForRetries) {
            throw invalidOperationException(
                            ''"
                            {evaluatorName} failed to retrieve annotation result from the Azure AI Foundry Evaluation service.
                            The evaluation was timed out after {elapsedDuration} seconds (and {attempts} attempts).
                            {response.statusCode} ({(int)response.statusCode}): {response.reasonPhrase}.
                            """);
          } else {
            await Task.delay(
              InitialDelayInMilliseconds * attempts,
              cancellationToken,
            ) .configureAwait(false);
          }
        }
      } while (response.statusCode != HttpStatusCode.ok);
    } finally {
      stopwatch.stop();
    }
    var responseContent = #if NET
            await response.content.readAsStringAsync(cancellationToken).configureAwait(false);
    #else
            await response.content.readAsStringAsync().configureAwait(false);
    return responseContent;
  }

  Future<HttpResponseMessage> getResponse(
    String requestUrl,
    String evaluatorName,
    {HttpMethod? requestMethod, String? payload, CancellationToken? cancellationToken, },
  ) async  {
    requestMethod ??= HttpMethod.getValue;
    var request = httpRequestMessage(requestMethod, requestUrl);
    request.content = stringContent(payload ?? string.empty);
    await addHeadersAsync(request, evaluatorName, cancellationToken).configureAwait(false);
    var response = await _httpClient.sendAsync(request, cancellationToken).configureAwait(false);
    return response;
  }

  Future addHeaders(
    HttpRequestMessage httpRequestMessage,
    String evaluatorName,
    {CancellationToken? cancellationToken, },
  ) async  {
    var userAgent = 'microsoft-extensions-ai-evaluation/${Constants.version} (type=evaluator; subtype=${evaluatorName})';
    httpRequestMessage.headers.add("User-Agent", userAgent);
    var context = serviceConfiguration.isHubBasedProject
                ? tokenRequestContext(scopes: ["https://management.azure.com/.default"])
                : tokenRequestContext(scopes: ["https://ai.azure.com/.default"]);
    var token = await serviceConfiguration.credential.getTokenAsync(
      context,
      cancellationToken,
    ) .configureAwait(false);
    httpRequestMessage.headers.authorization = authenticationHeaderValue("Bearer", token.token);
    #pragma warning disable IDE0058 // Temporary workaround for Roslyn analyzer issue (see https://github.com/dotnet/roslyn/issues/80499).
        httpRequestMessage.content?.headers.contentType = mediaTypeHeaderValue("application/json");
  }
}
