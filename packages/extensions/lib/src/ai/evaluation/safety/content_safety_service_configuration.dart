import 'package:extensions/annotations.dart';

/// Configuration for connecting to the Azure AI Foundry Evaluation service.
///
/// Supports both Hub-based projects (subscription + resource group + project
/// name) and non-Hub-based Foundry projects (endpoint URI only).
@Source(
  name: 'ContentSafetyServiceConfiguration.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Safety',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Safety/',
)
class ContentSafetyServiceConfiguration {
  /// Creates a configuration for a Hub-based Azure AI Foundry project.
  const ContentSafetyServiceConfiguration.hubBased({
    required this.subscriptionId,
    required this.resourceGroupName,
    required this.projectName,
    required this.apiKey,
    this.endpoint,
    this.timeoutInSeconds = 120,
  });

  /// Creates a configuration for a non-Hub-based Foundry project.
  const ContentSafetyServiceConfiguration.foundry({
    required Uri this.endpoint,
    required this.apiKey,
    this.timeoutInSeconds = 120,
  })  : subscriptionId = null,
        resourceGroupName = null,
        projectName = null;

  /// Azure subscription ID (Hub-based projects only).
  final String? subscriptionId;

  /// Azure resource group name (Hub-based projects only).
  final String? resourceGroupName;

  /// Azure AI Foundry project name (Hub-based projects only).
  final String? projectName;

  /// Endpoint URI for non-Hub-based Foundry projects.
  final Uri? endpoint;

  /// API key for authentication.
  final String apiKey;

  /// Request timeout in seconds.
  final int timeoutInSeconds;

  /// Whether this is a Hub-based project configuration.
  bool get isHubBasedProject =>
      subscriptionId != null &&
      resourceGroupName != null &&
      projectName != null &&
      endpoint == null;
}
