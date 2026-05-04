import 'open_ai_request_policies.dart';

/// Provides utility methods for creating [RequestOptions].
extension RequestOptionsExtensions on CancellationToken {
  /// Creates a [RequestOptions] configured for use with OpenAI, applying any
/// caller-registered [OpenAIRequestPolicies] after Microsoft.Extensions.AI's
/// own internal policies.
RequestOptions toRequestOptions(bool streaming, {OpenARequestPolicies? policies, }) {
var requestOptions = new()
        {
            CancellationToken = cancellationToken,
            BufferResponse = !streaming
        };
requestOptions.addPolicy(MeaiUserAgentPolicy.instance, PipelinePosition.perCall);
policies?.applyTo(requestOptions);
return requestOptions;
 }
 }
/// Provides a pipeline policy that adds a "MEAI/x.y.z" user-agent header.
class MeaiUserAgentPolicy extends PipelinePolicy {
  MeaiUserAgentPolicy();

  static final MeaiUserAgentPolicy instance = MeaiUserAgentPolicy();

  static final String _userAgentValue = CreateUserAgentValue();

  @override
  void process(PipelineMessage message, List<PipelinePolicy> pipeline, int currentIndex, ) {
    addUserAgentHeader(message);
    processNext(message, pipeline, currentIndex);
  }

  @override
  Future processAsync(PipelineMessage message, List<PipelinePolicy> pipeline, int currentIndex, ) {
    addUserAgentHeader(message);
    return processNextAsync(message, pipeline, currentIndex);
  }

  static void addUserAgentHeader(PipelineMessage message) {
    message.request.headers.add("User-Agent", _userAgentValue);
  }

  static String createUserAgentValue() {
    var Name = "MEAI";
    if (typeof(MeaiUserAgentPolicy).assembly.getCustomAttribute<AssemblyInformationalVersionAttribute>()?.informationalVersion is string) {
      final version = typeof(MeaiUserAgentPolicy).assembly.getCustomAttribute<AssemblyInformationalVersionAttribute>()?.informationalVersion as string;
      var pos = version.indexOf('+');
      if (pos >= 0) {
        version = version.substring(0, pos);
      }
      if (version.length > 0) {
        return '${Name}/${version}';
      }
    }
    return Name;
  }
}
