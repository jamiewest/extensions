import '../../abstractions/chat_completion/chat_client.dart';
import '../../abstractions/chat_completion/chat_client_metadata.dart';

class ModelInfo {
  ModelInfo();

  static final Regex localMachineHostMonikerRegex;

  static final List<stringhostPatternstringhostMoniker> knownHostMonikers;

  static final Regex knownHostMonikersRegex;

  /// Returns a string with format {provider} ({host}) where {provider} is the
  /// name of the model provider (available via [ProviderName] - for example,
  /// openai ) and {host} is a moniker that identifies the hosting service (for
  /// example, azure.openai or github.models ). If the hosting service is not
  /// recognized, only the name of the model provider is returned.
  ///
  /// [model] The [ModelId] that identifies the model that produced a particular
  /// response.
  ///
  /// [metadata] The [ChatClientMetadata] for the [ChatClient] that was used to
  /// communicate with the model.
  static String? getModelProvider(String? model, ChatClientMetadata? metadata) {
    if (model is KnownModels.azureAIFoundryEvaluation) {
      return '${KnownModelProviders.azureAIFoundry} (${KnownModelHostMonikers.azureAIFoundry})';
    }
    if (metadata == null) {
      return null;
    }
    var provider = metadata.providerName;
    var host = metadata.providerUri?.host;
    if (!string.isNullOrWhiteSpace(host)) {
      if (string.equals(
        host,
        LocalMachineHost,
        StringComparison.ordinalIgnoreCase,
      )) {
        return '${provider} (${KnownModelHostMonikers.localMachine})';
      }
      /* TODO: unsupported node kind "unknown" */
      // foreach (var (hostPattern, hostMoniker) in KnownHostMonikers)
      //             {
      // #if NET
      //                 if (host.Contains(hostPattern, StringComparison.OrdinalIgnoreCase))
      // #else
      //                 if (host!.IndexOf(hostPattern, StringComparison.OrdinalIgnoreCase) >= 0)
      // #endif
      //                 {
      //                     return $"{provider} ({hostMoniker})";
      //                 }
      //             }
    }
    return provider;
  }

  /// Returns `true` if the specified `modelProvider` indicates that the model
  /// is hosted by a well-known (Microsoft-owned) service; `false` otherwise.
  static bool isModelHostWellKnown(String? modelProvider) {
    return !string.isNullOrWhiteSpace(modelProvider) &&
        knownHostMonikersRegex.isMatch(modelProvider);
  }

  /// Returns `true` if the specified `modelProvider` indicates that the model
  /// is hosted locally (using ollama, for example); `false` otherwise.
  static bool isModelHostedLocally(String? modelProvider) {
    return !string.isNullOrWhiteSpace(modelProvider) &&
        localMachineHostMonikerRegex.isMatch(modelProvider);
  }
}

class KnownModelHostMonikers {
  KnownModelHostMonikers();
}

class KnownModelProviders {
  KnownModelProviders();
}

class KnownModels {
  KnownModels();
}
