import 'content_safety_evaluator.dart';

/// Specifies configuration parameters, such as the Azure AI Foundry project
/// and the credentials that should be used, when a [ContentSafetyEvaluator]
/// communicates with the Azure AI Foundry Evaluation service to perform
/// evaluations.
///
/// Remarks: Azure AI Foundry supports two kinds of projects - Hub-based
/// projects and non-Hub-based projects (also known simply as Foundry
/// projects). See Create a project for Azure AI Foundry . Hub-based projects
/// are configured by specifying the [SubscriptionId], [ResourceGroupName],
/// and [ProjectName] for the project. Non-Hub-based projects, on the other
/// hand, are configured by specifying only the [Endpoint] for the project.
/// Use the appropriate constructor overload to initialize
/// [ContentSafetyServiceConfiguration] based on the kind of project you are
/// working with.
class ContentSafetyServiceConfiguration {
  /// Initializes a new instance of the [ContentSafetyServiceConfiguration]
  /// class for a Hub-based Azure AI Foundry project with the specified
  /// `projectName`.
  ///
  /// Remarks: Azure AI Foundry supports two kinds of projects - Hub-based
  /// projects and non-Hub-based projects (also known simply as Foundry
  /// projects). See Create a project for Azure AI Foundry . Use this
  /// constructor overload if you are working with a Hub-based project.
  ///
  /// [credential] The Azure [TokenCredential] that should be used when
  /// authenticating requests.
  ///
  /// [subscriptionId] The ID of the Azure subscription that contains the
  /// Hub-based AI Foundry project identified by `projectName`.
  ///
  /// [resourceGroupName] The name of the Azure resource group that contains the
  /// Hub-based AI Foundry project identified by `projectName`.
  ///
  /// [projectName] The name of the Hub-based Azure AI Foundry project.
  ///
  /// [httpClient] The [HttpClient] that should be used when communicating with
  /// the Azure AI Foundry Evaluation service. While the parameter is optional,
  /// it is recommended to supply an [HttpClient] that is configured with robust
  /// resilience and retry policies.
  ///
  /// [timeoutInSecondsForRetries] The timeout (in seconds) after which a
  /// [ContentSafetyEvaluator] should stop retrying failed attempts to
  /// communicate with the Azure AI Foundry Evaluation service when performing
  /// evaluations.
  ContentSafetyServiceConfiguration(
    TokenCredential credential,
    HttpClient? httpClient,
    int timeoutInSecondsForRetries, {
    String? subscriptionId = null,
    String? resourceGroupName = null,
    String? projectName = null,
    Uri? endpoint = null,
    String? endpointUrl = null,
  }) : credential = Throw.ifNull(credential),
       subscriptionId = Throw.ifNullOrWhitespace(subscriptionId),
       resourceGroupName = Throw.ifNullOrWhitespace(resourceGroupName),
       projectName = Throw.ifNullOrWhitespace(projectName),
       httpClient = httpClient,
       timeoutInSecondsForRetries = timeoutInSecondsForRetries;

  /// Gets the Azure [TokenCredential] that should be used when authenticating
  /// requests.
  final TokenCredential credential;

  /// Gets the ID of the Azure subscription that contains the project identified
  /// by [ProjectName] if the project is a Hub-based project.
  final String? subscriptionId;

  /// Gets the name of the Azure resource group that contains the project
  /// identified by [ProjectName] if the project is a Hub-based project.
  final String? resourceGroupName;

  /// Gets the name of the Azure AI Foundry project if the project is a
  /// Hub-based project.
  final String? projectName;

  /// Gets the endpoint for the Azure AI Foundry project if the project is a
  /// non-Hub-based project.
  final Uri? endpoint;

  /// Gets the [HttpClient] that should be used when communicating with the
  /// Azure AI Foundry Evaluation service.
  ///
  /// Remarks: While supplying an [HttpClient] is optional, it is recommended to
  /// supply one that is configured with robust resilience and retry policies.
  final HttpClient? httpClient;

  /// Gets the timeout (in seconds) after which a [ContentSafetyEvaluator]
  /// should stop retrying failed attempts to communicate with the Azure AI
  /// Foundry Evaluation service when performing evaluations.
  final int timeoutInSecondsForRetries;

  bool get isHubBasedProject {
    return !string.isNullOrWhiteSpace(subscriptionId) &&
        !string.isNullOrWhiteSpace(resourceGroupName) &&
        !string.isNullOrWhiteSpace(projectName) &&
        endpoint == null;
  }
}
