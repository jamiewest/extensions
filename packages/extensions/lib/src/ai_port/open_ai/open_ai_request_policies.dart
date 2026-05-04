/// Provides an extension hook for adding [PipelinePolicy] instances to the
/// [RequestOptions] built by Microsoft.Extensions.AI for every outbound
/// OpenAI request made through the owning `IChatClient` or
/// `IEmbeddingGenerator`.
///
/// Remarks: Retrieve the instance via [Object)] (or the equivalent on other
/// Microsoft.Extensions.AI client interfaces) using [OpenAIRequestPolicies]
/// as the service type. The instance is per-client and reachable through any
/// `ChatClientBuilder` decorator chain. Customer-registered policies are
/// appended after Microsoft.Extensions.AI's own internal policies, so a
/// policy that calls `message.Request.Headers.Set("User-Agent", ...)`
/// replaces the existing value, while one that calls `Headers.Add(...)`
/// stacks an additional value. Registration is intended for one-time
/// configuration at startup, but is safe to call concurrently with in-flight
/// requests.
class OpenARequestPolicies {
  /// Initializes a new instance of the [OpenAIRequestPolicies] class.
  OpenARequestPolicies();

  static final List<Entry> _empty = Array.Empty<Entry>();

  List<Entry> _entries = _empty;

  /// Adds a [PipelinePolicy] to be applied to every [RequestOptions] produced
  /// for outbound OpenAI requests by the owning Microsoft.Extensions.AI client.
  ///
  /// [policy] The pipeline policy to register. Must not be `null`.
  ///
  /// [position] The position in the pipeline at which to place the policy.
  /// Defaults to [PerCall], which runs the policy once per logical request (for
  /// example, to stamp a User-Agent or correlation header).
  void addPolicy(PipelinePolicy policy, {PipelinePosition? position, }) {
    _ = Throw.ifNull(policy);
    var newEntry = entry(policy, position);
    while (true) {
      var current = Volatile.read(ref _entries);
      var updated = List.filled(current.length + 1, null);
      Array.copy(current, updated, current.length);
      updated[current.length] = newEntry;
      if (Interlocked.compareExchange(ref _entries, updated, current) == current) {
        return;
      }
    }
  }

  /// Applies all registered policies to the supplied [RequestOptions]. Called
  /// by the Microsoft.Extensions.AI OpenAI clients after their own internal
  /// policies have been registered.
  void applyTo(RequestOptions requestOptions) {
    var snapshot = Volatile.read(ref _entries);
    for (var i = 0; i < snapshot.length; i++) {
      var entry = snapshot[i];
      requestOptions.addPolicy(entry.policy, entry.position);
    }
  }
}
class Entry {
  const Entry(
    PipelinePolicy policy,
    PipelinePosition position,
  ) :
      policy = policy,
      position = position;

  final PipelinePolicy policy;

  final PipelinePosition position;

}
